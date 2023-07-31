import Foundation
import WaasSdkGo
import Combine

public class MPCSdk: NSObject {

    // The config to be used for MPCSdk initialization.
    let mpcSdkConfig = "default"

    // The handle to the Go MPCSdk class.
    var sdk: V1MPCSdkProtocol

    /**
     Initializes the MPCSdk  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public init(_ isSimulator: Bool) throws {
        var error: NSError?
        let _sdk = V1NewMPCSdk(
            mpcSdkConfig,
            isSimulator,
            nil,
            &error)

        if error != nil {
            throw WaasError.mpcSdkFailedToInitialize(error!)
        }

        sdk = _sdk!
    }

    func wrapError(err: Error) -> WaasError {
        return WaasError.mpcSdkUnspecifiedError(err as NSError)
    }

    /**
     Initializes the Device with the given passcode. The passcode is used to generate a private/public
     key pair that encrypts the backups and archives of the DeviceGroups containing this Device. This function should be called
     exactly once per Device per application, and should be called before the Device is registered with
     GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
     has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
     or a rejection otherwise.
     */
    public func bootstrapDevice(_ passcode: String) -> Future<String, WaasError> {
        return Future { promise in
            Job.main().async(execute: {
                self.sdk.bootstrapDevice(passcode, receiver: goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
     While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
     PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
     This function can be used when/if the end user forgets their old passcode.
     It resolves on success; a rejection otherwise.
     */
    public func resetPasscode(_ newPasscode: String) -> Future<Void, WaasError> {
        return Future { promise in
            Job.main().async(execute: {
                do {
                    try self.sdk.resetPasscode(newPasscode)
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }
    }

    /**
     Returns the data required to call RegisterDeviceAPI on MPCKeyService.
     Resolves with the RegistrationData on success; rejects with an error otherwise.
     */
    public func getRegistrationData() -> Future<String, WaasError> {
        return Future { promise in
            Job.main().async(execute: {
                self.sdk.getRegistrationData(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Computes an MPC operation, given mpcData from the response of ListMPCOperations API on
     MPCKeyService. This function can be used to compute MPCOperations of types: CreateDeviceGroup and CreateSignature.
     Resolves on success; rejects with an error otherwise.
     */
    public func computeMPCOperation(_ mpcData: String) -> Future<Void, WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    try self.sdk.computeMPCOperation(mpcData)
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }
    }

    /**
     Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves on success; rejects with an error otherwise.
     */
    public func computePrepareDeviceArchiveMPCOperation(_ mpcData: String, passcode: String) -> Future<Void, WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    try self.sdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode: passcode)
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }
    }

    /**
     Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves on success; rejects with an error otherwise.
     */
    public func computePrepareDeviceBackupMPCOperation(_ mpcData: String, passcode: String) -> Future<Void, WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    try self.sdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode: passcode)
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }
    }

    /**
     Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
     MPCKeyService, passcode of the Device and device backup created with PrepareDeviceBackup operation. Resolves on success; rejects with an error otherwise.
     */
    public func computeAddDeviceMPCOperation(_ mpcData: String, passcode: String, deviceBackup: String) -> Future<Void, WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    try self.sdk.computeAddDeviceMPCOperation(
                        mpcData,
                        passcode: passcode,
                        deviceBackup: deviceBackup)
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }

    }

    /**
     Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
     exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
     rejects with an error otherwise.
     */
    public func exportPrivateKeys(_ mpcKeyExportMetadata: String, passcode: String) -> Future<[PrivateKey], WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                do {
                    let response = try self.sdk.exportPrivateKeys(
                        mpcKeyExportMetadata,
                        passcode: passcode)
                    let keys = try JSONDecoder().decode([PrivateKey].self, from: response)
                    promise(Result.success(keys))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            })
        }
    }

    /**
     Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
     Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
     */
    public func exportDeviceBackup() -> Future<String, WaasError> {
        return Future { promise in
            Job.backgroundHighPri().async(execute: {
                self.sdk.exportDeviceBackup(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }
}
