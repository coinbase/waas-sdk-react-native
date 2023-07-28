
import Foundation

/**
 A WaaS resource that represents a unique `Address` on a blockchain.
 
- `[.MPCKeys]` and `.MPCWallet` are foreign keys to other Waas resources.
- `.Address` represents an onchain address
*/
public struct Address: Codable {
    // the unique resource-name of this address
    public var Name: String
    
    // the protocol-relevant address that this represents ("0xdeafbeef")
    public var Address: String
    
    // an array of resource names of keys associated with this address.
    public var MPCKeys: [String]
    
    // the resource name of the wallet associated with this address
    public var MPCWallet: String
}
