import Foundation
import WaasSdkGo
import Combine

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
    public init(_ apiKeyName: String, privateKey: String) throws {
        var error: NSError?

        let _walletsClient = V1NewMPCWalletService(
            mpcWalletServiceUrl,
            apiKeyName,
            privateKey,
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
    public func createMPCWallet(parent: String, device: String) -> Future<V1CreateMPCWalletResponse, WaasError> {
        return Future() { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    let response = try self.walletsClient.createMPCWallet(parent, device: device)
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
    public func waitPendingMPCWallet(operation: String) -> Future<V1MPCWallet, WaasError> {
        return Future() { promise in
            Job.background().async(execute: {
                do {
                    let mpcWallet = try self.walletsClient.waitPendingMPCWallet(operation)
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
    public func generateAddress(_ mpcWallet: String, network: String) -> Future<Address, WaasError> {
        return Future() { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    // TODO: golang should return `V1Address` directly.
                    let addressData = try self.walletsClient.generateAddress(mpcWallet, network: network as String)
                    let address = try JSONDecoder().decode(Address.self, from: addressData)
                    promise(Result.success(address))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
     */
    public func getAddress(name: String) -> Future<Address, WaasError> {
        return Future() { promise in
            Job.background().async(execute: {
                do {
                    // TODO: golang should return `V1Address` directly.
                    let addressData = try self.walletsClient.getAddress(name)
                    let address = try JSONDecoder().decode(Address.self, from: addressData)
                    promise(Result.success(address))
                } catch {
                    promise(Result.failure(WaasError.walletServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }
}
