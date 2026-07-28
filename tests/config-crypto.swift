import Foundation

@main
struct ConfigCryptoTests {
    static func main() throws {
        let plaintext = Data("configuration-secret-probe".utf8)
        let encrypted = try ConfigCrypto.encrypt(plaintext, password: "correct horse battery staple")

        precondition(encrypted != plaintext)
        precondition(encrypted.range(of: plaintext) == nil)
        let decrypted = try ConfigCrypto.decrypt(
            encrypted,
            password: "correct horse battery staple"
        )
        precondition(decrypted == plaintext)

        do {
            _ = try ConfigCrypto.decrypt(encrypted, password: "wrong password")
            preconditionFailure("wrong password unexpectedly decrypted configuration")
        } catch ConfigCrypto.CryptoError.wrongPassword {
            // Expected authenticated-decryption failure.
        }

        print("Configuration encryption tests passed")
    }
}
