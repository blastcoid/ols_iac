from google.cloud import kms_v1
import base64

# set variable reqquired configuration
project_id = "ols-platform-dev"
location_id = "global"
key_ring_id = "ols-dev-security-kms-keyring"
crypto_key_id = "ols-dev-security-kms-cryptokey"

# client initialization
client = kms_v1.KeyManagementServiceClient()
key_name = client.crypto_key_path(project_id, location_id, key_ring_id, crypto_key_id)


def encrypt(plaintext):

    # Encrypt the plaintext
    response = client.encrypt(
        request={"name": key_name, "plaintext": plaintext.encode("utf-8")}
    )

    # Print the ciphertext
    ciphertext = base64.b64encode(response.ciphertext).decode("utf-8")
    return ciphertext

def decrypt(chipertext):
    # Decode the ciphertext
    ciphertext = base64.b64decode(chipertext.encode("utf-8"))
    # Decrypt the ciphertext
    response = client.decrypt(request={"name": key_name, "ciphertext": ciphertext})
    plaintext = response.plaintext.decode("utf-8")
    # return the plaintext
    return plaintext


if __name__ == "__main__":
    option = 0
    # loop until user input 1 or 2
    while option not in ["1", "2"]:
        # prompt user to choose encryption or decryption
        option = input("Input your choice:\n1. Encryption\n2. Decryption\nChoice: ")
        if option == "1":
            # with open('test.pem', 'r') as file:
            #   plaintext = file.read()

            # prompt user to enter plaintext
            plaintext = input("Enter the plaintext: ")
            # encrypt the plaintext
            encrypted_text = encrypt(plaintext)
            # print the encrypted text
            print(f"Chipertext: {encrypted_text}")
        elif option == "2":
            # prompt user to enter encrypted text
            encrypted_text = input("Enter the encrypted text: ")
            # decrypt the encrypted text
            ciphertext = decrypt(encrypted_text)
            # print the plaintext
            print(f"Plaintext: {ciphertext}")
        else:
            # prompt user to enter valid input
            print("Invalid input")
            input("Press enter to continue...")
            # clear the screen
            print("\033c")
