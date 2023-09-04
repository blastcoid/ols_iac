# Configure the backend for Terraform state storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/all/ols-dev-all-deployment"
  }
}

# Deploy the VPC using the VPC module
module "vpc_main" {
  source                  = "../../modules/gcp/network/vpc"
  region                  = var.region
  env                     = var.env
  vpc_name                = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[0]}"
  auto_create_subnetworks = false
  subnet_name             = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[1]}"
  ip_cidr_range = {
    dev = "10.0.0.0/16"
    stg = "10.1.0.0/16"
    prd = "10.2.0.0/16"
  }
  secondary_ip_range = {
    dev = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.16.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.17.0.0/16"
      }
    ]
    stg = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.18.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.19.0.0/16"
      }
    ]
    prd = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.20.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.21.0.0/16"
      }
    ]
  }
  router_name                        = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[2]}"
  address_name                       = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[3]}"
  nat_name                           = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[4]}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  firewall_name                      = "${var.unit}-${var.env}-${var.code[0]}-${var.vpc_feature[5]}"
  vpc_firewall_rules = {
    icmp = {
      name        = "allow-icmp"
      description = "Allow ICMP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
    internal = {
      name        = "allow-internal"
      description = "Allow internal traffic on the network."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      # source ranges based on the environment
      source_ranges = {
        dev = ["10.0.0.0/16"]
        stg = ["10.1.0.0/16"]
        prd = ["10.2.0.0/16"]
      }
      priority = 65534
    }
    ssh = {
      name        = "allow-ssh"
      description = "Allow SSH from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
    rdp = {
      name        = "allow-rdp"
      description = "Allow RDP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["3389"]
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
  }
}

data "google_service_account" "gcompute_engine_default_service_account" {
  account_id = "102052325554983869202"
}

data "terraform_remote_state" "vpc_main" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/all/ols-dev-all-deployment"
  }
}

# create cloud dns module

module "dns_blast" {
  source             = "../../modules/gcp/network/dns"
  region             = var.region
  zone_name          = "${var.unit}-${var.code[0]}-${var.dns_feature}"
  zone_dns_name      = "${var.unit}.blast.co.id."
  zone_description   = "Cloud DNS for for ${var.unit}.blast.co.id."
  zone_force_destroy = true
  zone_visibility    = "public"
}

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_ols_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-kms-main"
  }
}

# Decrypt list of secrets
data "google_kms_secret" "secrets" {
  for_each   = var.secrets_ciphertext
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.security_cryptokey_id
  ciphertext = each.value
}

module "secret-manager" {
  source             = "../../modules/gcp/security/secret-manager"
  region             = var.region
  env                = var.env
  secret_name_prefix = "${var.unit}-${var.env}-${var.code[2]}"
  secret_data        = data.google_kms_secret.secrets
}

# create gke from modules gke
module "gke_main" {
  # Naming standard
  source = "../../modules/gcp/compute/gke"
  region = var.region
  env    = var.env
  # cluster arguments
  cluster_name                  = "${var.unit}-${var.env}-${var.code[1]}-${var.gke_feature}"
  issue_client_certificate      = false
  vpc_self_link                 = module.vpc_main.vpc_self_link
  subnet_self_link              = module.vpc_main.subnet_self_link
  pods_secondary_range_name     = module.vpc_main.pods_secondary_range_name
  services_secondary_range_name = module.vpc_main.services_secondary_range_name
  enable_autopilot              = false
  cluster_autoscaling = {
    enabled = false
    resource_limits = {
      cpu = {
        minimum = 2
        maximum = 8
      }
      memory = {
        minimum = 4
        maximum = 32
      }
    }
  }
  binary_authorization = {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" # set to null to disable
  }
  network_policy = {
    enabled  = false
    provider = "CALICO"
  }
  datapath_provider = "ADVANCED_DATAPATH"

  master_authorized_networks_config = {
    cidr_blocks = {
      cidr_block   = "182.253.194.32/28"
      display_name = "my-home-public-ip"
    }
    gcp_public_cidrs_access_enabled = false
  }

  private_cluster_config = {
    dev = {
      enable_private_endpoint = false
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.0.0/28"
    }
    stg = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.1.0/28"
    }
    prd = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.2.0/28"
    }
  }

  dns_config = {
    dev = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "${var.gke_feature}.${trimsuffix(module.dns_blast.dns_name, ".")}"
    }
    stg = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "${var.gke_feature}.${trimsuffix(module.dns_blast.dns_name, ".")}"
    }
    prd = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "${var.gke_feature}.${trimsuffix(module.dns_blast.dns_name, ".")}"
    }
  }
  resource_labels = {
    name    = "${var.unit}-${var.env}-${var.code[1]}-${var.gke_feature}"
    env     = var.env
    unit    = var.unit
    code    = var.code[1]
    feature = var.gke_feature
  }
  # node pool only work when enable_autopilot = false
  node_config = {
    ondemand = {
      is_spot    = false
      node_count = 1
      machine_type = {
        dev = "e2-medium"
        stg = "e2-standard-2"
        prd = "e2-standard-4"
      }
      disk_size_gb    = 20
      disk_type       = ["pd-standard", "pd-ssd"]
      service_account = data.google_service_account.gcompute_engine_default_service_account.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["ondemand"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
      workload_metadata_config = {
        mode = "GKE_METADATA"
      }
    },
    spot = {
      is_spot    = true
      node_count = 2
      machine_type = {
        dev = "e2-medium"
        stg = "e2-standard-2"
        prd = "e2-standard-4"
      }
      disk_size_gb    = 20
      disk_type       = ["pd-standard", "pd-ssd"]
      service_account = data.google_service_account.gcompute_engine_default_service_account.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["spot"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
      workload_metadata_config = {
        mode = "GKE_METADATA"
      }
    }
  }

  autoscaling = {
    ondemand = {
      # min_node_count  = 2
      # max_node_count  = 20
      # location_policy = "BALANCED"
    }
    spot = {
      min_node_count  = 2
      max_node_count  = 20
      location_policy = "ANY"
    }
  }

  node_management = {
    auto_repair  = true
    auto_upgrade = true
  }
}

module "blast_private_zone" {
  source             = "../../modules/gcp/network/dns"
  region             = var.region
  zone_name          = "${var.unit}-${var.code[0]}-${var.dns_feature}-internal"
  zone_dns_name      = "internal.${module.dns_blast.dns_name}"
  zone_description   = "Cloud DNS for internal.${module.dns_blast.dns_name}"
  zone_force_destroy = true
  zone_visibility    = "private"
  private_visibility_config = {
    networks = {
      network_url = module.vpc_main.vpc_id
    }
    gke_clusters = {
      gke_cluster_name = module.gke_main.cluster_id
    }
  }
}


data "google_secret_manager_secret_version" "ssh_key" {
  secret = "ssh-key-main"
}

# Get current project id

# create gce from modules gce
module "gce-atlantis" {
  source               = "../../modules/gcp/compute/gce"
  region               = var.region
  env                  = var.env
  zone                 = "${var.region}-a"
  project_id           = "${var.unit}-platform-${var.env}"
  instance_name        = "${var.unit}-${var.env}-${var.code[1]}-${var.gce_feature[0]}"
  service_account_role = "roles/owner"
  linux_user           = var.gce_feature[0]
  ssh_key              = data.google_secret_manager_secret_version.ssh_key.secret_data
  machine_type         = "e2-medium"
  disk_size            = 20
  disk_type            = "pd-standard"
  network_self_link    = module.vpc_main.vpc_self_link
  subnet_self_link     = module.vpc_main.subnet_self_link
  is_public            = true
  access_config = {
    dev = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "STANDARD"
    }
    stg = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "PREMIUM"
    }
    prd = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "PREMIUM"
    }
  }
  tags              = [var.gce_feature[0]]
  image             = "debian-cloud/debian-11"
  create_dns_record = true
  dns_config = {
    dns_name      = module.dns_blast.dns_name
    dns_zone_name = module.dns_blast.dns_zone_name
    record_type   = "A"
    ttl           = 300
  }
  run_ansible       = true
  ansible_tags      = ["initialization"]
  ansible_skip_tags = []
  ansible_vars = {
    project_id        = "${var.unit}-platform-${var.env}"
    cluster_name      = module.gke_main.cluster_name
    region            = "${var.region}-a"
    github_orgs       = "blastcoid"
    github_token      = module.secret-manager.secret_version_data["github-token-atlantis"]
    github_token_iac  = module.secret-manager.secret_version_data["github-token-iac"]
    github_secret     = module.secret-manager.secret_version_data["github-secret"]
    atlantis_password = module.secret-manager.secret_version_data["atlantis-password"]
  }
  firewall_rules = {
    "ssh" = {
      protocol = "tcp"
      ports    = ["22"]
    }
    "http" = {
      protocol = "tcp"
      ports    = ["80"]
    }
    "atlantis" = {
      protocol = "tcp"
      ports    = ["4141"]
    }
    "https" = {
      protocol = "tcp"
      ports    = ["443"]
    }
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.gce_feature[0]]
}

module "external-dns" {
  source                      = "../../modules/cicd/helm"
  region                      = var.region
  env                         = var.env
  repository                  = "https://charts.bitnami.com/bitnami"
  chart                       = "external-dns"
  service_account_name        = "${var.unit}-${var.env}-${var.code[3]}-${var.helm_feature[0]}"
  create_service_account      = true
  use_workload_identity       = true
  project_id                  = "${var.unit}-platform-${var.env}"
  google_service_account_role = "roles/dns.admin"
  create_managed_certificate  = false
  values                      = ["${file("external_dns/values.yaml")}"]
  helm_sets = [
    {
      name  = "provider"
      value = "google"
    },
    {
      name  = "google.project"
      value = "${var.unit}-platform-${var.env}"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "zoneVisibility"
      value = module.dns_blast.dns_zone_visibility
    }
  ]
  namespace        = "ingress"
  create_namespace = true
  depends_on = [
    module.gke_main
  ]
}

module "helm_nginx" {
  source               = "../../modules/cicd/helm"
  region               = var.region
  env                  = var.env
  repository           = "https://kubernetes.github.io/ingress-nginx"
  chart                = "ingress-nginx"
  service_account_name = "${var.unit}-${var.env}-${var.code[3]}-${var.helm_feature[1]}"
  values               = ["${file("nginx/values.yaml")}"]
  namespace            = "ingress"
  project_id           = "${var.unit}-platform-${var.env}"
  dns_name             = trimsuffix(module.dns_blast.dns_name, ".")
  depends_on = [
    module.gke_main,
    module.external-dns
  ]
}

module "helm_certmanager" {
  source               = "../../modules/cicd/helm"
  region               = var.region
  env                  = var.env
  repository           = "https://charts.jetstack.io"
  chart                = "cert-manager"
  service_account_name = "${var.unit}-${var.env}-${var.code[3]}-${var.helm_feature[2]}"
  project_id           = "${var.unit}-platform-${var.env}"
  values               = ["${file("cert_manager/values.yaml")}"]
  namespace            = "ingress"
  after_crd_installed  = "cluster-issuer.yaml"
  depends_on = [
    module.gke_main,
    module.external-dns
  ]
}

module "helm_argocd" {
  source                      = "../../modules/cicd/helm"
  region                      = var.region
  env                         = var.env
  repository                  = "https://argoproj.github.io/argo-helm"
  chart                       = "argo-cd"
  service_account_name        = "${var.unit}-${var.env}-${var.code[3]}-${var.helm_feature[3]}"
  values                      = ["${file("argocd/values.yaml")}"]
  namespace                   = "cd"
  create_namespace            = true
  create_service_account      = true
  use_workload_identity       = true
  project_id                  = "${var.unit}-platform-${var.env}"
  google_service_account_role = "roles/container.admin"
  dns_name                    = trimsuffix(module.dns_blast.dns_name, ".")
  extra_vars = {
    github_orgs      = "blastcoid"
    github_client_id = "9781757e794562ceb7e1"
  }
  helm_sets_sensitive = [
    {
      name  = "configs.secret.githubSecret"
      value = module.secret-manager.secret_version_data["github-secret"]
    },
    {
      name  = "configs.secret.extra.dex\\.github\\.clientSecret"
      value = module.secret-manager.secret_version_data["github-oauth-client-secret-argocd"]
    }
  ]
  depends_on = [
    module.gke_main,
    module.external-dns,
    module.helm_nginx,
    module.helm_certmanager
  ]
}
