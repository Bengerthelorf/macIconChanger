import Foundation
import CryptoKit
import CommonCrypto

enum ConfigCrypto {

    // .icconfig layout: [salt 16B] [nonce 12B] [encrypted payload + tag]

    static func encrypt(_ data: Data, password: String) throws -> Data {
        let salt = try randomBytes(count: 16)
        let key = try deriveKey(password: password, salt: salt)
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
        let key = try deriveKey(password: password, salt: Data(salt))
        do {
            let box = try AES.GCM.SealedBox(combined: sealed)
            return try AES.GCM.open(box, using: key)
        } catch {
            throw CryptoError.wrongPassword
        }
    }

    // PBKDF2 with 100k iterations for real brute-force resistance
    private static func deriveKey(password: String, salt: Data) throws -> SymmetricKey {
        let passData = Data(password.utf8)
        var derivedBytes = [UInt8](repeating: 0, count: 32)

        let status = passData.withUnsafeBytes { passPtr in
            salt.withUnsafeBytes { saltPtr in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passPtr.baseAddress?.assumingMemoryBound(to: Int8.self),
                    passData.count,
                    saltPtr.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    100_000,
                    &derivedBytes,
                    32
                )
            }
        }

        guard status == kCCSuccess else { throw CryptoError.encryptionFailed }
        return SymmetricKey(data: derivedBytes)
    }

    private static func randomBytes(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        guard SecRandomCopyBytes(kSecRandomDefault, count, &bytes) == errSecSuccess else {
            throw CryptoError.encryptionFailed
        }
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
