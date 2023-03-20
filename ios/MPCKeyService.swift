import Foundation

@objc(MPCKeyService)
class MPCKeyService: NSObject {
    // The URL of the MPCKeyService.
    let mpcKeyServiceUrl = "https://api.developer.coinbase.com/waas/mpc_keys"

    // The error code for MPCKeyService-related errors.
    let mpcKeyServiceErr = "E_MPC_KEY_SERVICE"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCKeyService must be initialized"

    // The handle to the Go MPCKeyService client.
    var keyClient: V1MPCKeyServiceProtocol?

    /**
     Initializes the MPCKeyService  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?
        keyClient = V1NewMPCKeyService(
            mpcKeyServiceUrl as String,
            apiKeyName as String,
            privateKey as String,
            &error)

        if error != nil {
            reject(mpcKeyServiceErr, error!.localizedDescription, nil)
        } else {
            resolve("success" as NSString)
        }
    }

    /**
     Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
     */
    @objc(registerDevice:withRejecter:)
    func registerDevice(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        do {
            let device = try self.keyClient?.registerDevice()
            let res: NSDictionary = [
                "Name": device?.name as Any
            ]
            resolve(res)
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }

    /**
     Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
     Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceGroup:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceGroup(_ deviceGroup: NSString, pollInterval: NSNumber,
                                   resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Polling occurs asynchronously, so dispatch it.
        let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
            if self.keyClient == nil {
                reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
                return
            }

            do {
                let pendingDeviceGroupData = try self.keyClient?.pollPendingDeviceGroup(
                    deviceGroup as String,
                    pollInterval: pollInterval.int64Value)
                let res = try JSONSerialization.jsonObject(with: pendingDeviceGroupData!) as? NSArray
                print(res)
                resolve(res)
            } catch {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            }
        })

        DispatchQueue.global().async(execute: dispatchWorkItem)
    }

    /**
     Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
     Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingSeeds:withRejecter:)
    func stopPollingForPendingSeed(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        var result: String?
        var error: NSError?

        result = self.keyClient?.stopPollingPendingDeviceGroup(&error)

        if error != nil {
            reject(self.mpcKeyServiceErr, error!.localizedDescription, nil)
        } else {
            resolve(result! as NSString)
        }
    }

    /**
     Initiates an operation to create a Signature resource from the given transaction.
     Resolves with the string "success" on successful initiation; rejects with an error otherwise.
     */
    @objc(createSignatureFromTx:withTransaction:withResolver:withRejecter:)
    func createSignatureFromTx(_ parent: NSString, transaction: NSDictionary,
                               resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        do {
            let serializedTx = try JSONSerialization.data(withJSONObject: transaction)
            try self.keyClient?.createTxSignature(parent as String, tx: serializedTx)
            resolve("success")
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }

    /**
     Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingSignatures or processPendingSignature before another call is made to this function.
     Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
     */
    @objc(pollForPendingSignatures:withPollInterval:withResolver:withRejecter:)
    func pollForPendingSignatures(_ deviceGroup: NSString, pollInterval: NSNumber,
                                  resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Polling occurs asynchronously, so dispatch it.
        let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
            if self.keyClient == nil {
                reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
                return
            }

            do {
                let pendingSignaturesData = try self.keyClient?.pollPendingSignatures(
                    deviceGroup as String,
                    pollInterval: pollInterval.int64Value)
                let res = try JSONSerialization.jsonObject(with: pendingSignaturesData!) as? NSArray
                resolve(res)
            } catch {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            }
        })

        DispatchQueue.global().async(execute: dispatchWorkItem)
    }

    /**
     Stops polling for pending Signatures This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
     Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingSignatures:withRejecter:)
    func stopPollingForPendingSignatures(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        var result: String?
        var error: NSError?

        result = self.keyClient?.stopPollingPendingSignatures(&error)

        if error != nil {
            reject(mpcKeyServiceErr, error!.localizedDescription, nil)
        } else {
            resolve(result! as NSString)
        }
    }

    /**
     Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
     rejects with an error otherwise.
     */
    @objc(waitPendingSignature:withResolver:withRejecter:)
    func waitPendingSignature(_ operation: NSString,
                              resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        var signature: V1Signature?

        do {
            signature = try self.keyClient?.waitPendingSignature(operation as String)
            let res: NSDictionary = [
                "Name": signature?.name as Any,
                "Payload": signature?.payload as Any,
                "SignedPayload": signature?.signedPayload as Any
            ]
            resolve(res)
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }
    /**
     Gets the signed transaction using the given inputs.
     Resolves with the SignedTransaction on success; rejects with an error otherwise.
     */
    @objc(getSignedTransaction:withSignature:withResolver:withRejecter:)
    func getSignedTransaction(_ transaction: NSDictionary, signature: NSDictionary,
                              resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        do {
            let serializedTx = try JSONSerialization.data(withJSONObject: transaction)

            let goSignature = V1Signature()
            // swiftlint:disable force_cast
            goSignature.name = signature["Name"] as! String
            goSignature.payload = signature["Payload"] as! String
            goSignature.signedPayload = signature["SignedPayload"] as! String
            // swiftlint:enable force_cast

            let signedTransaction = try self.keyClient?.getSignedTransaction(serializedTx, signature: goSignature)

            let res: NSDictionary = [
                "Transaction": transaction,
                "Signature": signature,
                "RawTransaction": signedTransaction?.rawTransaction as Any,
                "TransactionHash": signedTransaction?.transactionHash as Any
            ]
            resolve(res)
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }
}
