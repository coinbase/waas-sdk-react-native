import Foundation
import WaasSdkGo
import Combine

public class PoolService: NSObject {
    // The URL of the PoolService.
    let poolServiceUrl = "https://api.developer.coinbase.com/waas/pools"

    // The handle to the Go PoolService client.
    var poolsClient: V1PoolServiceProtocol

    /**
     Initializes the PoolService with the given Cloud API Key parameters. Resolves with the string "success" on success;
     rejects with an error otherwise.
     */
    public init(_ apiKeyName: String, privateKey: String) throws {
        var error: NSError?
        let _poolsClient = V1NewPoolService(poolServiceUrl, apiKeyName, privateKey, &error)
        if (_poolsClient == nil) {
            throw WaasError.poolServiceFailedToInitialize
        }
        
        poolsClient = _poolsClient!
    }
    
    /**
     Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
     otherwise.
     */
    public func createPool(displayName: String, poolID: String) -> Future<V1Pool, WaasError> {
        return Future() { promise in
            Job.background().async(execute: {
                do {
                    let pool = try self.poolsClient.createPool(displayName, poolID: poolID)
                    promise(Result.success(pool))
                } catch {
                    promise(Result.failure(WaasError.poolServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }
}
