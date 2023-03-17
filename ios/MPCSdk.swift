import Foundation

@objc(MPCSdk)
class MPCSdk: NSObject {
    
    // The config to be used for MPCSdk initialization.
    let mpcSdkConfig = "default"
    
    // The error code for MPC-SDK related errors.
    let mpcSdkErr = "E_MPC_SDK"
    
    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCSdk must be initialized"
    
    // The handle to the Go MPCSdk class.
    var sdk: V1MPCSdkProtocol?
    
    /**
     Initializes the MPCSdk  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withResolver:withRejecter:)
    func initialize(_ isSimulator: NSNumber, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?
        sdk = V1NewMPCSdk(
            mpcSdkConfig as String,
            isSimulator.intValue != 0,
            nil,
            &error)
        
        if error != nil {
            reject(mpcSdkErr, error!.localizedDescription, nil)
        } else {
            resolve("success" as NSString)
        }
    }
    
    /**
     BootstrapDevice initializes the Device with the given passcode. The passcode is used to generate a private/public key pair
     that encodes the back-up material for WaaS keys created on this Device. This function should be called exactly once per
     Device per application, and should be called before the Device is registered with GetRegistrationData.
     It is the responsibility of the application to track whether BootstrapDevice has been called for the Device.
     It resolves with the string "bootstrap complete" on successful initialization; or a rejection otherwise.
     */
    @objc(bootstrapDevice:withResolver:withRejecter:)
    func bootstrapDevice(_ passcode: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }
        
        var error: NSError?
        
        let res = self.sdk?.bootstrapDevice(passcode as String, error: &error)
        if error != nil{
            reject(self.mpcSdkErr, error!.localizedDescription, nil)
        } else{
            resolve(res)
        }
    }
    
    /**
     GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
     Resolves with the RegistrationData on success; rejects with an error otherwise.
     */
    @objc(getRegistrationData:withRejecter:)
    func getRegistrationData(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }
        var error: NSError?
        
        let registrationData = self.sdk?.getRegistrationData(&error)
        if error != nil {
            reject(mpcSdkErr, error!.localizedDescription, nil)
        } else {
            resolve(registrationData)
        }
    }
    
    /**
     ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on MPCKeyService.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computeMPCOperation:withResolver:withRejecter:)
    func computeMPCOperation(_ mpcData: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }
        
        do {
            try self.sdk?.computeMPCOperation(mpcData as String)
            resolve("success" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }
}
