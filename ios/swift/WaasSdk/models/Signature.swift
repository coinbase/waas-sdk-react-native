
import Foundation

/**
 A WaaS resource that represents a signature, computed by some key.

 It contains the original `Payload`, as well as the signed form (`SignedPayload`)
*/
public struct Signature: Codable {
    // the unique resource-name of this address
    public var Name: String
    
    // the raw payload that was to be signed
    public var Payload: String

    public var SignedPayload: String
}
