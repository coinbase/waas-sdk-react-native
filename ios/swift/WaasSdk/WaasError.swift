import Foundation

enum WaasError: Error {
    // Thrown when an invalid password is entered
    case mpcKeyServiceFailedToInitialize
    
    // Thrown when key service experiences an error.
    case mpcKeyServiceUnspecifiedError(_ error: Error)
    
    case walletServiceFailedToInitialize(_ error: Error?)
    
    case walletServiceUnspecifiedError(_ error: Error?)
    
    case poolServiceFailedToInitialize
    
    case poolServiceUnspecifiedError(_ error: Error)
    
    case mpcSdkFailedToInitialize(_ error: Error?)
    
    case mpcSdkUnspecifiedError(_ error: Error)
    
    public var description: String {
        switch self {
        case .mpcKeyServiceFailedToInitialize:
            return "The provided password is not valid."
        case .mpcKeyServiceUnspecifiedError:
            return "The specified item could not be found."
        case .poolServiceFailedToInitialize:
            return "The pool service failed to initialize."
        case .poolServiceUnspecifiedError:
            return "Pool service experienced an error."
        default:
            return "Unknown error"
        }
    }
}
