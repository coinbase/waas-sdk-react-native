import Foundation
import WaasSdk

@objc
class MPCWalletService: NSObject {
    // The URL of the MPCWalletService.
    let mpcWalletServiceUrl = "https://api.developer.coinbase.com/waas/mpc_wallets"

    // The error code for MPCWalletService-related errors.
    let walletsErr = "E_MPC_WALLET_SERVICE"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCWalletService must be initialized"

    // The handle to the Go MPCWalletService client.
    var walletsClient: V1MPCWalletServiceProtocol?

    /**
     Initializes the MPCWalletService with the given Cloud API Key parameters. Resolves with the string "success"
     on success; rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?
        try {
            walletsClient = V1NewMPCWalletService(
                mpcWalletServiceUrl as String,
                apiKeyName as String,
                privateKey as String,
                &error)
            resolve(nil)
        } catch {
            reject(walletsErr, error!.localizedDescription, nil)
        }
    }

    /**
     Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
     otherwise.
     */
    @objc(createMPCWallet:withDevice:withResolver:withRejecter:)
    func createMPCWallet(_ parent: NSString, device: NSString,
                         resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.walletsClient == nil {
            reject(self.walletsErr, self.uninitializedErr, nil)
            return
        }
        
        Operation(self.walletsClient?.createMPCWallet(parent as String, device: device as String)).bridge(resolve: resolve, reject: reject) { response in
            return [
               "DeviceGroup": response?.deviceGroup as Any,
               "Operation": response?.operation as Any
           ]
        }
    }

    /**
     Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
     rejects with an error otherwise.
     */
    @objc(waitPendingMPCWallet:withResolver:withRejecter:)
    func waitPendingMPCWallet(_ operation: NSString,
                              resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.walletsClient == nil {
            reject(self.walletsErr, self.uninitializedErr, nil)
            return
        }
        
        Operation(self.walletsClient?.waitPendingMPCWallet(operation as String)).bridge(resolve: resolve, reject: reject) { wallet in
            return  [
                "Name": mpcWallet?.name as Any,
                "DeviceGroup": mpcWallet?.deviceGroup as Any
            ]
        }
    }

    /**
     Generates an Address within an MPCWallet. Resolves with the Address object on success;
     rejects with an error otherwise.
     */
    @objc(generateAddress:withNetwork:withResolver:withRejecter:)
    func generateAddress(_ mpcWallet: NSString, network: NSString,
                         resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.walletsClient == nil {
            reject(self.walletsErr, self.uninitializedErr, nil)
            return
        }
        
        Operation(self.walletsClient?.generateAddress(mpcWallet as String, network: network as String)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
     */
    @objc(getAddress:withResolver:withRejecter:)
    func getAddress(_ name: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.walletsClient == nil {
            reject(self.walletsErr, self.uninitializedErr, nil)
            return
        }
        
        Operation(self.walletsClient?.getAddress(name as String)).bridge(resolve: resolve, reject: reject)
    }
}
