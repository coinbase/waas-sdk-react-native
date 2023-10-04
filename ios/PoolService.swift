import Foundation
import WaasSdkGo

@objc(PoolService)
class PoolService: NSObject {
    // The URL of the PoolService when running in "direct mode".
    let poolServiceWaaSUrl = "https://api.developer.coinbase.com/waas/pools"

    // The error code for PoolService-related errors.
    let poolsErr = "E_POOL_SERVICE"

    // The handle to the Go PoolService client.
    var poolsClient: V1PoolServiceProtocol?

    /**
     * Initializes the PoolService with the given Cloud API Key parameters or proxy URL.
     * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
     * Uses direct WaaS URL with the API keys if both are provided.
     * Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withProxyUrl:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString, proxyUrl: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?

        let insecure: Bool

        let poolServiceUrl: String

        if apiKeyName as String == "" || privateKey as String == "" {
            poolServiceUrl = proxyUrl as String
            insecure = true
        } else {
            poolServiceUrl = poolServiceWaaSUrl
            insecure = false
        }

        poolsClient = V1NewPoolService(
            poolServiceUrl as String,
            apiKeyName as String,
            privateKey as String,
            insecure as Bool,
            &error)

        if error != nil {
            reject(poolsErr, error!.localizedDescription, nil)
        } else {
            resolve("success" as NSString)
        }
    }

    /**
     Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
     otherwise.
     */
    @objc(createPool:withPoolID:withResolver:withRejecter:)
    func createPool(_ displayName: NSString, poolID: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.poolsClient == nil {
            reject(self.poolsErr, "pool service must be initialized", nil)
            return
        }

        var pool: V1Pool?

        do {
            try pool = self.poolsClient?.createPool(displayName as String, poolID: poolID as String)
            let res: NSDictionary = [
                "name": pool?.name as Any,
                "displayName": pool?.displayName as Any
            ]
            resolve(res)
        } catch {
            reject(self.poolsErr, error.localizedDescription, nil)
        }
    }
}
