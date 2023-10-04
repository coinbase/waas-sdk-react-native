import Foundation
import WaasSdkGo

@objc(MPCKeyService)
// swiftlint:disable type_body_length
class MPCKeyService: NSObject {
    // The URL of the MPCKeyService when running in "direct mode".
    let mpcKeyServiceWaaSUrl = "https://api.developer.coinbase.com/waas/mpc_keys"

    // The URL of the MPCKeyService when running in "proxy mode".
    let mpcKeyServiceProxyUrl = "http://localhost:8091"

    // The error code for MPCKeyService-related errors.
    let mpcKeyServiceErr = "E_MPC_KEY_SERVICE"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCKeyService must be initialized"

    // The handle to the Go MPCKeyService client.
    var keyClient: V1MPCKeyServiceProtocol?

    /**
     * Initializes the MPCKeyService with the given Cloud API Key parameters or proxy URL.
     * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
     * Uses direct WaaS URL with the API keys if both are provided.
     * Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withProxyUrl:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString, proxyUrl: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?

        let insecure: Bool

        let mpcKeyServiceUrl: String

        if apiKeyName as String == "" || privateKey as String == "" {
            mpcKeyServiceUrl = proxyUrl as String
            insecure = true
        } else {
            mpcKeyServiceUrl = mpcKeyServiceWaaSUrl
            insecure = false
        }

        keyClient = V1NewMPCKeyService(
            mpcKeyServiceUrl as String,
            apiKeyName as String,
            privateKey as String,
            insecure as Bool,
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
    @objc(stopPollingForPendingDeviceGroup:withRejecter:)
    func stopPollingForPendingDeviceGroup(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.stopPollingPendingDeviceBackups(wrapGo(callback))
    }

    /**
     Initiates an operation to create a Signature resource from the given transaction.
     Resolves with the resource name of the WaaS operation creating the Signature on successful initiation; rejects with an error otherwise.
     */
    @objc(createSignatureFromTx:withTransaction:withResolver:withRejecter:)
    func createSignatureFromTx(_ parent: NSString, transaction: NSDictionary,
                               resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        do {
            let serializedTx = try JSONSerialization.data(withJSONObject: transaction)
            self.keyClient?.createTxSignature(parent as String, tx: serializedTx, receiver: wrapGo(callback))
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }

    /**
     Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingSignatures or computeMPCOperaton before another call is made to this
     function. Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
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
    func stopPollingForPendingSignatures(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.stopPollingPendingSignatures(wrapGo(callback))
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

    /**
     Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
     */
    @objc(getDeviceGroup:withResolver:withRejecter:)
    func getDeviceGroup(_ name: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        do {
            let deviceGroupRes = try self.keyClient?.getDeviceGroup(name as String)

            let devices = try JSONSerialization.jsonObject(with: deviceGroupRes!.devices! as Data)

            let res: NSDictionary = [
                "Name": deviceGroupRes?.name as Any,
                "MPCKeyExportMetadata": deviceGroupRes?.mpcKeyExportMetadata as Any,
                "Devices": devices as Any
            ]
            resolve(res)
        } catch {
            reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }

    /**
     Initiates an operation to prepare device archive for MPCKey export. Resolves with the resource name of the WaaS operation creating the Device Archive on successful initiation; rejects with
     an error otherwise.
     */
    @objc(prepareDeviceArchive:withDevice:withResolver:withRejecter:)
    func prepareDeviceArchive(_ deviceGroup: NSString, device: NSString,
                              resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.prepareDeviceArchive(
            deviceGroup as String, device: device as String, receiver: wrapGo(callback))
    }

    /**
     Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceArchives:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceArchives(_ deviceGroup: NSString, pollInterval: NSNumber,
                                      resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Polling occurs asynchronously, so dispatch it.
        let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
            if self.keyClient == nil {
                reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
                return
            }

            do {
                let pendingDeviceArchiveData = try self.keyClient?.pollPendingDeviceArchives(
                    deviceGroup as String,
                    pollInterval: pollInterval.int64Value)
                // swiftlint:disable force_cast
                let res = try JSONSerialization.jsonObject(with: pendingDeviceArchiveData!) as! NSArray
                // swiftlint:enable force_cast
                resolve(res)
            } catch {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            }
        })

        DispatchQueue.global().async(execute: dispatchWorkItem)
    }

    /**
     Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
     Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDeviceArchives:withRejecter:)
    func stopPollingForPendingDeviceArchives(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.stopPollingPendingDeviceArchives(wrapGo(callback))
    }

    /**
     Initiates an operation to prepare device backup to add a new Device to the DeviceGroup. Resolves with the resource name of the WaaS operation creating the Device Backup on
     successful initiation; rejects with an error otherwise.
     */
    @objc(prepareDeviceBackup:withDevice:withResolver:withRejecter:)
    func prepareDeviceBackup(_ deviceGroup: NSString, device: NSString,
                             resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.prepareDeviceBackup(
            deviceGroup as String, device: device as String, receiver: wrapGo(callback))
    }

    /**
     Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceBackups:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceBackups(_ deviceGroup: NSString, pollInterval: NSNumber,
                                     resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Polling occurs asynchronously, so dispatch it.
        let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
            if self.keyClient == nil {
                reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
                return
            }

            do {
                let pendingDeviceBackupData = try self.keyClient?.pollPendingDeviceBackups(
                    deviceGroup as String,
                    pollInterval: pollInterval.int64Value)
                // swiftlint:disable force_cast
                let res = try JSONSerialization.jsonObject(with: pendingDeviceBackupData!) as! NSArray
                // swiftlint:enable force_cast
                resolve(res)
            } catch {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            }
        })

        DispatchQueue.global().async(execute: dispatchWorkItem)
    }

    /**
     Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackupOperation.
     Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDeviceBackups:withRejecter:)
    func stopPollingForPendingDeviceBackups(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.stopPollingPendingDeviceBackups(wrapGo(callback))
    }

    /**
     Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
     an error otherwise.
     */
    @objc(addDevice:withDevice:withResolver:withRejecter:)
    func addDevice(_ deviceGroup: NSString, device: NSString,
                   resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.addDevice(
            deviceGroup as String, device: device as String, receiver: wrapGo(callback))
    }

    /**
     Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDevices or computeAddDeviceMPCOperation) before another call is made to this function.
     Resolves with a list of the pending Devices on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDevices:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDevices(_ deviceGroup: NSString, pollInterval: NSNumber,
                               resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Polling occurs asynchronously, so dispatch it.
        let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
            if self.keyClient == nil {
                reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
                return
            }

            do {
                let pendingDeviceData = try self.keyClient?.pollPendingDevices(
                    deviceGroup as String,
                    pollInterval: pollInterval.int64Value)
                // swiftlint:disable force_cast
                let res = try JSONSerialization.jsonObject(with: pendingDeviceData!) as! NSArray
                // swiftlint:enable force_cast
                resolve(res)
            } catch {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            }
        })

        DispatchQueue.global().async(execute: dispatchWorkItem)
    }

    /**
     Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending AddDeviceOperation.
     Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDevices:withRejecter:)
    func stopPollingForPendingDevices(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.keyClient == nil {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return
        }

        let callback: (String?, Error?) -> Void = { data, error in
            if let error = error {
                reject(self.mpcKeyServiceErr, error.localizedDescription, nil)
            } else {
                resolve(data ?? "")
            }
        }

        self.keyClient?.stopPollingPendingDevices(wrapGo(callback))
    }
}
