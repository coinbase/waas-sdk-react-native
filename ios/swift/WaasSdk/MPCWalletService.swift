import Foundation
import WaasSdkGo
import Combine

@objc
public class MPCWalletService: NSObject {
    // The URL of the MPCWalletService.
    let mpcWalletServiceUrl = "https://api.developer.coinbase.com/waas/mpc_wallets"

    // The error code for MPCWalletService-related errors.
    let walletsErr = "E_MPC_WALLET_SERVICE"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCWalletService must be initialized"

    // The handle to the Go MPCWalletService client.
    var walletsClient: V1MPCWalletServiceProtocol

    /**
     Initializes the MPCWalletService with the given Cloud API Key parameters. Resolves with the string "success"
     on success; rejects with an error otherwise.
     */
    public init(_ apiKeyName: NSString, privateKey: NSString) throws {
        var error: NSError?

        let _walletsClient = V1NewMPCWalletService(
            mpcWalletServiceUrl as String,
            apiKeyName as String,
            privateKey as String,
            &error)

        if error != nil {
            throw WaasError.walletServiceFailedToInitialize(error!)
        }
        
        walletsClient = _walletsClient!
    }

    /**
     Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
     otherwise.
     */
    public func createMPCWallet(parent: NSString, device: NSString) -> Future<V1CreateMPCWalletResponse, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let response = try self.walletsClient.createMPCWallet(parent as String, device: device as String)
                    promise(Result.success(response))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
     rejects with an error otherwise.
     */
    public func waitPendingMPCWallet(operation: NSString) -> Future<V1MPCWallet, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let mpcWallet = try self.walletsClient.waitPendingMPCWallet(operation as String)
                    promise(Result.success(mpcWallet))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Generates an Address within an MPCWallet. Resolves with the Address object on success;
     rejects with an error otherwise.
     */
    public func generateAddress(_ mpcWallet: NSString, network: NSString) -> Future<NSDictionary, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let addressData = try self.walletsClient.generateAddress(mpcWallet as String, network: network as String)
                    let res = try JSONSerialization.jsonObject(with: addressData) as? NSDictionary
                    promise(Result.success(res!))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
     */
    public func getAddress(name: NSString) -> Future<NSDictionary, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let addressData = try self.walletsClient.getAddress(name as String)
                    let res = try JSONSerialization.jsonObject(with: addressData) as? NSDictionary
                    promise(Result.success(res!))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }
}
