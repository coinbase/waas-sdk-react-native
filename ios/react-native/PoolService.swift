import Foundation
import WaasSdk
import WaasSdkGo

@objc(PoolService)
class PoolService: BaseModule {
    // The error code for PoolService-related errors.
    let poolsErr = "E_POOL_SERVICE"

    // The handle to the Go PoolService client.
    var poolsClient: WaasSdk.PoolService?

    /**
     Initializes the PoolService with the given Cloud API Key parameters. Resolves with the string "success" on success;
     rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        do {
            poolsClient = try WaasSdk.PoolService(apiKeyName as String, privateKey: privateKey as String)
            resolve(nil)
        } catch {
            reject(poolsErr, error.localizedDescription, nil)
        }
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }

    /**
     Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
     otherwise.
     */
    @objc(createPool:withPoolID:withResolver:withRejecter:)
    func createPool(_ displayName: NSString, poolID: NSString,
                    resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.poolsClient == nil {
            reject(self.poolsErr, "pool service must be initialized", nil)
            return
        }

        run(Operation(self.poolsClient!.createPool(displayName: displayName as String, poolID: poolID as String)).any(resolve: resolve, reject: reject) { pool in
            return [
                "name": pool.name as Any,
                "displayName": pool.displayName as Any
            ] as NSDictionary
        })
    }
}
