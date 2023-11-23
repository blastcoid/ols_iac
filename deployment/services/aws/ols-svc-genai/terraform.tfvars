env          = "mstr"
region       = "us-west-1"
github_owner = "blastcoid"
configs = {
  app_host                          = "0.0.0.0"
  app_port                          = "8000"
  app_log_level                     = "debug"
  openai_chatcompletion_model       = "gpt-3.5-turbo"
  openai_chatcompletion_temperature = "0.5"
  openai_max_response_tokens        = "1000"
}

secrets_ciphertext = {
  openai_api_key = "AQICAHgUmSZTukL4Gkutt2/No3HqyGPN4o11Ym4LBI9+rKtMRQHmDGV3m0LM1UHhV/4YPmmsAAAAlDCBkQYJKoZIhvcNAQcGoIGDMIGAAgEAMHsGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMgagDW1P9fZ1zbsbXAgEQgE7FpJJm0Exi5tCM3Q4nwSEaTEXIzg30jU9wpbZev7gyphGw/kRxdgDLgHWAICFL3EO7uOMTFoI6/qNUTApd/IYdO0+0NihQJxzPYZ/EQxc="
}
