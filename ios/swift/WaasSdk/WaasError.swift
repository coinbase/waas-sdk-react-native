import Foundation

public enum WaasError: Error {
    // Thrown when an invalid password is entered
    case mpcKeyServiceFailedToInitialize
    
    // Thrown when key service experiences an error.
    case mpcKeyServiceUnspecifiedError(_ error: Error)
    
    case walletServiceFailedToInitialize(_ error: Error)
    
    case walletServiceUnspecifiedError(_ error: Error)
    
    case poolServiceFailedToInitialize
    
    case poolServiceUnspecifiedError(_ error: Error)
    
    case mpcSdkFailedToInitialize(_ error: Error)
    
    case mpcSdkUnspecifiedError(_ error: Error)
    
    public var description: String {
        switch self {
        case .mpcKeyServiceFailedToInitialize:
            return "The provided password is not valid."
        case .mpcKeyServiceUnspecifiedError(let error):
            return "The mpc service experienced an error: \(error.localizedDescription)"
        case .poolServiceFailedToInitialize:
            return "The pool service failed to initialize."
        case .poolServiceUnspecifiedError(let error):
            return "Pool service experienced an error: \(error.localizedDescription)"
        case .walletServiceFailedToInitialize:
            return "The wallet service failed to initialize"
        case .walletServiceUnspecifiedError(let error):
            return "Wallet service experienced an error: \(error.localizedDescription)"
        default:
            return "Unknown error"
        }
    }
    
    public var code: String {
        switch self {
        case .mpcKeyServiceFailedToInitialize:
            fallthrough
        case .mpcKeyServiceUnspecifiedError:
            return "E_MPC_SDK"
        case .poolServiceFailedToInitialize:
            fallthrough
        case .poolServiceUnspecifiedError:
            return "E_POOL_SERVICE"
        case .walletServiceFailedToInitialize:
            fallthrough
        case .walletServiceUnspecifiedError:
            return "E_WALLET_SERVICE"
        case .mpcSdkFailedToInitialize:
            fallthrough
        case .mpcSdkUnspecifiedError:
            return "E_MPC_SDK"
        }
    }
}
