import Foundation
import CryptoKit

enum ConfigCrypto {

    // .icconfig file layout: [salt 16B] [nonce 12B] [encrypted payload + tag]

    static func encrypt(_ data: Data, password: String) throws -> Data {
        let salt = randomBytes(count: 16)
        let key = deriveKey(password: password, salt: salt)
        let nonce = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(data, using: key, nonce: nonce)
        guard let combined = sealed.combined else {
            throw CryptoError.encryptionFailed
        }
        return salt + combined
    }

    static func decrypt(_ data: Data, password: String) throws -> Data {
        guard data.count > 28 else { throw CryptoError.invalidData }
        let salt = data.prefix(16)
        let sealed = data.dropFirst(16)
        let key = deriveKey(password: password, salt: Data(salt))
        let box = try AES.GCM.SealedBox(combined: sealed)
        return try AES.GCM.open(box, using: key)
    }

    private static func deriveKey(password: String, salt: Data) -> SymmetricKey {
        let passData = Data(password.utf8)
        // PBKDF2-like derivation using HKDF (CryptoKit native)
        let inputKey = SymmetricKey(data: passData)
        let derived = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: Data("com.iconchanger.config".utf8),
            outputByteCount: 32
        )
        return derived
    }

    private static func randomBytes(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }

    enum CryptoError: LocalizedError {
        case encryptionFailed
        case invalidData
        case wrongPassword

        var errorDescription: String? {
            switch self {
            case .encryptionFailed: return "Encryption failed."
            case .invalidData: return "Invalid or corrupted file."
            case .wrongPassword: return "Incorrect password."
            }
        }
    }
}
