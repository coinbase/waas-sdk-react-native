import Foundation

public struct PrivateKey: Codable {
  // The 32 byte long elliptic curve private key of an MPCKey, as a non-prefixed hex string.
  public var PrivateKey: String
  // The ethereum address as "0x"-prefixed hex string that corresponds to the exported private key.
  // Note: This is NOT a WaaS Address resource of the form
  // `networks/{networkID}/addresses/{addressID}.
  public var Address: String
}
