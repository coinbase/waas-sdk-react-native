import Foundation
import WaasSdkGo
import Combine

@objc
class PoolService: NSObject {
    // The URL of the PoolService.
    let poolServiceUrl = "https://api.developer.coinbase.com/waas/pools"

    // The handle to the Go PoolService client.
    var poolsClient: V1PoolServiceProtocol

    /**
     Initializes the PoolService with the given Cloud API Key parameters. Resolves with the string "success" on success;
     rejects with an error otherwise.
     */
    init(_ apiKeyName: NSString, privateKey: NSString) throws {
        var error: NSError?
        var _poolsClient = V1NewPoolService(poolServiceUrl as String, apiKeyName as String, privateKey as String, &error)
        if (_poolsClient == nil) {
            throw WaasError.poolServiceFailedToInitialize
        }
        
        poolsClient = _poolsClient!
    }

    /**
     Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
     otherwise.
     */
    func createPool(_ displayName: NSString, poolID: NSString) -> Future<V1Pool, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    var pool = try self.poolsClient.createPool(displayName as String, poolID: poolID as String)
                    promise(Result.success(pool))
                } catch {
                    promise(Result.failure(WaasError.poolServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }
}
