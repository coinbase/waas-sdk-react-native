// Copyright (c) 2018-2023 Coinbase, Inc. <https://www.coinbase.com/>
// Licensed under the Apache License, version 2.0

import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-waas-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

/**
 * The native hook into the WaaS MPC SDK.
 */
const MPCSdk = NativeModules.MPCSdk
  ? NativeModules.MPCSdk
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * An object representing response to the ExportPrivateKeys request.
 */
export type ExportPrivateKeysResponse = {
  // The 32 byte long elliptic curve private key of an MPCKey, as a non-prefixed hex string.
  PrivateKey: string;
  // The ethereum address as "0x"-prefixed hex string that corresponds to the exported private key.
  // Note: This is NOT a WaaS Address resource of the form
  // `networks/{networkID}/addresses/{addressID}.
  Address: string;
};

/**
 * Initializes the MPC SDK. This function must be invoked before
 * any MPC SDK methods are called.
 * @returns A void promise, that either succeeds or rejects.
 * otherwise.
 */
export function initMPCSdk(isSimulator?: boolean): Promise<void> {
  return MPCSdk.initialize(isSimulator);
}

/**
 Bootstraps the Device with the given passcode. The passcode is used to generate a private/public key pair
 that encrypts the backup and archive for the DeviceGroups containing this Device. This function should be called
 exactly once per Device per application, and should be called before the Device is registered with GetRegistrationData.
 It is the responsibility of the application to track whether bootstrapDevice has been called for the Device.
 * @param passcode Passcode to protect all key materials in the secure enclave.
 * @returns A void promise, that either succeeds or rejects..
 */
export function bootstrapDevice(passcode: string): Promise<void> {
  return MPCSdk.bootstrapDevice(passcode);
}

/**
 * Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
 * While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
 * PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
 * This function can be used when/if the end user forgets their old passcode.
 * @param newPasscode The new passcode to use to encrypt backups and archives associated with the Device.
 * @returns A void promise, that either succeeds or rejects.
 */
export function resetPasscode(newPasscode: string): Promise<void> {
  return MPCSdk.resetPasscode(newPasscode);
}

/**
 * Retrieves the data required to call RegisterDeviceAPI on MPCKeyService.
 * @returns A promise with the RegistrationData on success; a rejection otherwise.
 */
export function getRegistrationData(): Promise<string> {
  return MPCSdk.getRegistrationData();
}

/**
 * Computes an MPC operation, given mpcData from the response of ListMPCOperations API on MPCKeyService.
 * This function can be used to compute MPCOperations of types: CreateDeviceGroup and CreateSignature.
 * @param mpcData The mpcData from ListMPCOperationsResponse on MPCKeyService.
 * @returns A void promise, that either succeeds or rejects.
 */
export function computeMPCOperation(mpcData: string): Promise<void> {
  return MPCSdk.computeMPCOperation(mpcData);
}

/**
 * Computes a PrepareDeviceArchive MPCOperation,
 * given mpcData from the response of ListMPCOperations API on MPCKeyService and passcode for the Device.
 * @param mpcData The mpcData from ListMPCOperationsResponse on MPCKeyService.
 * @param passcode The passcode set for the Device on BootstrapDevice call.
 * @returns A void promise, that either succeeds or rejects.
 */
export function computePrepareDeviceArchiveMPCOperation(
  mpcData: string,
  passcode: string
): Promise<void> {
  return MPCSdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode);
}

/**
 * Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
 * exporting private keys that back EVM addresses. This function is recommended to be called while the Device is
 * on airplane mode.
 * @param mpcKeyExportMetadata The metadata to be used to export MPCKeys. This metadata is obtained from the response
 * of GetDeviceGroup RPC in MPCKeyService. This metadata is a dynamic value, ensure you pass the most recent value of
 * this metadata.
 * @param passcode Passcode protecting key materials in the device, set during the call to BootstrapDevice.
 * @returns A promise with the ExportPrivateKeysResponse on success; a rejection otherwise.
 */
export function exportPrivateKeys(
  mpcKeyExportMetadata: string,
  passcode: string
): Promise<Array<ExportPrivateKeysResponse>> {
  return MPCSdk.exportPrivateKeys(mpcKeyExportMetadata, passcode);
}

/**
 * Computes a PrepareDeviceBackup MPCOperation,
 * given mpcData from the response of ListMPCOperations API on MPCKeyService and passcode for the Device.
 * @param mpcData The mpcData from ListMPCOperationsResponse on MPCKeyService.
 * @param passcode The passcode set for the Device on BootstrapDevice call.
 * @returns A void promise, that either succeeds or rejects.
 */
export function computePrepareDeviceBackupMPCOperation(
  mpcData: string,
  passcode: string
): Promise<void> {
  return MPCSdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode);
}

/**
 * Exports the device backup that is created after successfully computing a PrepareDeviceBackup MPCOperation.
 * It is recommended to store this backup securely in a storage provider of your choice. If the existing Device is lost,
 * follow the below steps:
 * 1. Bootstrap the new Device with the same passcode as the old Device.
 * 2. Register the new Device.
 * 3. Initiate AddDevice MPCOperation using the AddDevice RPC in the MPCKeyService.
 * 4. Compute AddDevice MPCOperation with the computeAddDeviceMPCOperation method using this exported device backup.
 * @returns A promise with the backup as hex-encoded string; a rejection otherwise.
 */
export function exportDeviceBackup(): Promise<String> {
  return MPCSdk.exportDeviceBackup();
}

/**
 * Computes an AddDevice MPCOperation,
 * given mpcData from the response of ListMPCOperations API on MPCKeyService and passcode for the Device.
 * @param mpcData The mpcData from ListMPCOperationsResponse on MPCKeyService.
 * @param passcode The passcode set for the Device on BootstrapDevice call.
 * @param deviceBackup The backup retrieved from the exportDeviceBackup call after successful computation of a
 * PrepareDeviceBackup MPCOperation.
 * @returns A void promise, that either succeeds or rejects.
 */
export function computeAddDeviceMPCOperation(
  mpcData: string,
  passcode: string,
  deviceBackup: string
): Promise<void> {
  return MPCSdk.computeAddDeviceMPCOperation(mpcData, passcode, deviceBackup);
}

/**
 * The native hook into the WaaS PoolService.
 */
const PoolService = NativeModules.PoolService
  ? NativeModules.PoolService
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * The Pool resource.
 */
export type Pool = {
  // The resource name of the Pool.
  // Format: pools/{pool_id}
  name: string;
  // A user-readable name for the Pool set by the user.
  // Example: 'Acme Co. Retail Trading'
  displayName: string;
};

/**
 * Initializes the PoolService with Cloud API Key. This function must be invoked before
 * any PoolService functions are called.
 * @param apiKeyName The API key name.
 * @param privateKey The private key.
 * @param url The URL of the PoolService. Optional.
 * @returns A void promise, that either succeeds or rejects.
 * otherwise.
 */
export function initPoolService(
  apiKeyName: string,
  privateKey: string
): Promise<void> {
  return PoolService.initialize(apiKeyName, privateKey);
}

/**
 * Creates a Pool. Call this method before creating any resources scoped to a Pool.
 * @param displayName A user-readable name for the Pool.
 * @param poolID The ID to use for the Pool, which will become the final component of
 * the resource name. If not provided, the server will assign a Pool ID automatically.
 * @returns A promise with the Pool on success; a rejection otherwise.
 */
export function createPool(
  displayName: string,
  poolID?: string
): Promise<Pool> {
  let poolIDString = poolID;
  if (poolIDString === undefined) {
    poolIDString = '';
  }

  return PoolService.createPool(displayName, poolIDString);
}

/**
 * The native hook into the WaaS MPCKeyService.
 */
const MPCKeyService = NativeModules.MPCKeyService
  ? NativeModules.MPCKeyService
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * Initializes the MPCKeyService.
 * This function must be invoked before any MPCKeyService functions are called.
 * @returns A void promise, that either succeeds or rejects.
 * otherwise.
 */
export function initMPCKeyService(
  apiKeyName: string,
  privateKey: string
): Promise<void> {
  return MPCKeyService.initialize(apiKeyName, privateKey);
}

/**
 * An object representing a pending CreateDeviceGroup operation.
 * Also referred to as a "pending DeviceGroup"
 */
export type CreateDeviceGroupOperation = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the Operation creating this DeviceGroup.
  // The format: operations/{operation_id}
  Operation: string;
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  MPCOperation: string;
  // The MPCData associated with this operation. To process this operation, ComputeMPCOperation API has to be invoked with this data.
  // Format: base64 encoded string.
  MPCData: string;
};

/**
 * The Device resource.
 */
export type Device = {
  // The resource name of this Device.
  // Format: devices/{device_id}
  Name: string;
};

/**
 * The Signature resource.
 */
export type Signature = {
  // The resource name of the Signature.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcKeys/{mpc_key_id}/signatures/{signature_id}
  Name: string;

  // The hex-encoded payload to be signed.
  // In the case of transactions, this corresponds to the hash of the unsigned
  // transaction.
  Payload: string;

  // The hex-encoded signed payload.
  // In the case of transactions, this corresponds to the 65-byte V, R, S value.
  // Note that this signed payload must be combined with a transaction object and then
  // marshaled into RLP format before it can be broadcast on-chain.
  SignedPayload: string;
};

/**
 * An EIP-1559 transaction.
 */
export type Transaction = {
  // The chain ID of the transaction as a "0x"-prefixed hex string.
  ChainID: string;
  // The nonce of the transaction.
  Nonce: number;
  // The EIP-1559 maximum priority fee per gas as a "0x"-prefixed hex string.
  MaxPriorityFeePerGas: string;
  // The EIP-1559 maximum fee per gas as a "0x"-prefixed hex string.
  MaxFeePerGas: string;
  // The maximum amount of gas to use on the transaction.
  Gas: number;
  // The checksummed address to which the transaction is addressed, as a "0x"-prefixed hex string.
  // Note: This is NOT a WaaS Address resource of the form
  // `networks/{networkID}/addresses/{addressID}.
  To: string;
  // The native value of the transaction as a "0x"-prefixed hex string.
  Value: string;
  // The hex-encoded data for the transaction.
  Data: string;
};

/**
 * A signed EIP-1559 transaction.
 */
export type SignedTransaction = {
  // The unsigned Transaction.
  Transaction: Transaction;

  // The signature of the signed transaction.
  // The Payload is the hash of the unsigned transaction, and the
  // SignedPayload is the 65-byte V, R, S value.
  // Both are hex strings.
  Signature: Signature;

  // RawTransaction is the RLP-encoded signed transaction.
  // It is a hex string that can be broadcast on-chain.
  RawTransaction: string;

  // TransactionHash is the hash of the signed transaction.
  // It is a hex string.
  TransactionHash: string;
};

/**
 * An object representing a pending CreateSignature MPC operation.
 * Another name for this is a "pending Signature".
 */
export type CreateSignatureOperation = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the Operation creating this DeviceGroup.
  // The format: operations/{operation_id}
  Operation: string;
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  MPCOperation: string;
  // The MPCData associated with this operation. To process this operation, ComputeMPCOperation API has to be invoked with this data.
  // Format: base64 encoded string.
  MPCData: string;
  // The hex-encoded payload to be signed.
  Payload: string;
};

/**
 * An object representing a WaaS DeviceGroup.
 */
export type DeviceGroup = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The metadata to be used to export MPCKeys derived from the Seed associated with the DeviceGroup.
  // This metadata has to be passed to the ExportPrivateKeys function to export private keys corresponding to
  // MPCKeys that are derived from the HardenedChildren of the Seed associated with the DeviceGroup.
  // Format: base64 encoded string.
  MPCKeyExportMetadata: string;
  // The list of Device resource names in this DeviceGroup.
  // Format: devices/{device_id}
  Devices: Array<string>;
};

/**
 * An object representing a pending PrepareDeviceArchive MPC operation.
 * Another name for this is a "pending DeviceArchive".
 */
export type PrepareDeviceArchiveOperation = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the Operation creating this DeviceGroup.
  // The format: operations/{operation_id}
  Operation: string;
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  MPCOperation: string;
  // The MPCData associated with this operation. To process this operation, ComputePrepareDeviceArchiveMPCOperation
  // API has to be invoked with this data.
  // Format: base64 encoded string.
  MPCData: string;
};

/**
 * An object representing a pending PrepareDeviceBackup MPC operation.
 * Another name for this is a "pending DeviceBackup".
 */
export type PrepareDeviceBackupOperation = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the Operation preparing this DeviceBackup.
  // The format: operations/{operation_id}
  Operation: string;
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  MPCOperation: string;
  // The MPCData associated with this operation. To process this operation, ComputePrepareDeviceBackupMPCOperation
  // API has to be invoked with this data.
  // Format: base64 encoded string.
  MPCData: string;
};

/**
 * An object representing a pending AddDevice MPC operation.
 * Another name for this is a "pending Device".
 */
export type AddDeviceOperation = {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the Operation adding the Device to the DeviceGroup.
  // The format: operations/{operation_id}
  Operation: string;
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  MPCOperation: string;
  // The MPCData associated with this operation. To process this operation, ComputeAddDeviceMPCOperation
  // API has to be invoked with this data.
  // Format: base64 encoded string.
  MPCData: string;
};

/**
 * Registers the current Device.
 * @returns A promise with the registered Device on success; a rejection otherwise.
 */
export function registerDevice(): Promise<Device> {
  return MPCKeyService.registerDevice();
}

/**
 * Polls for pending DeviceGroup (i.e. CreateDeviceGroup), and returns the first set that materializes.
 * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
 * stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
 * @param deviceGroup The resource name of the DeviceGroup for which to poll the pending
 * CreateDeviceGroupOperation.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending CreateDeviceGroupOperations on success; a rejection otherwise.
 */
export function pollForPendingDeviceGroup(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<CreateDeviceGroupOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingDeviceGroup(
    deviceGroup,
    pollIntervalToUse
  );
}

/**
 * Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
 * @returns A promise with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
 * a promise with the empty string otherwise.
 */
export function stopPollingForPendingDeviceGroup(): Promise<string> {
  return MPCKeyService.stopPollingForPendingDeviceGroup();
}

/**
 * Initiates an operation to create a Signature resource from the given Transaction using
 * the given parent Key.
 * @param parent The resource name of the parent Key.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcKeys/{mpc_key_id}
 * @param tx The transaction to sign.
 * @returns A promise with the resource name of the WaaS operation creating the Signature on successful initiation;
 * a rejection otherwise.
 */
export function createSignatureFromTx(
  parent: string,
  tx: Transaction
): Promise<string> {
  return MPCKeyService.createSignatureFromTx(parent, tx);
}

/**
 * Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
 * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
 * stopPollingForPendingSignatures or processPendingSignature) before another call is made to this function.
 * @param deviceGroup The resource name of the DeviceGroup for which to poll the pending
 * CreateSignatureOperation.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending Signatures on success; a rejection otherwise.
 */
export function pollForPendingSignatures(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<CreateSignatureOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingSignatures(deviceGroup, pollIntervalToUse);
}

/**
 * Stops polling for pending Signatures. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signature.
 * @returns A promise with string "stopped polling for pending Signatures" if polling is stopped successfully;
 * a promise with the empty string otherwise.
 */
export function stopPollingForPendingSignatures(): Promise<string> {
  return MPCKeyService.stopPollingForPendingSignatures();
}

/**
 * Waits for a pending Signature.
 * @param wallet The name of operation that created the Signature.
 * @returns A promise with the Signature on success; a rejection otherwise.
 */
export function waitPendingSignature(operation: string): Promise<Signature> {
  return MPCKeyService.waitPendingSignature(operation);
}

/**
 * Obtains the signed transaction object based on the given inputs.
 * @param unsignedTx The unsigned Transaction object.
 * @param signature The Signature object obtained from the CreateSignature flow.
 */
export function getSignedTransaction(
  unsignedTx: Transaction,
  signature: Signature
): Promise<SignedTransaction> {
  return MPCKeyService.getSignedTransaction(unsignedTx, signature);
}

/**
 * Gets a DeviceGroup.
 * @param name The resource name of the DeviceGroup.
 * @returns A promise with the Address on success; a rejection otherwise.
 */
export function getDeviceGroup(name: string): Promise<DeviceGroup> {
  return MPCKeyService.getDeviceGroup(name);
}

/**
 * Initiates an operation to prepare device archive for MPCKey export. Ensure this operation is run prior to any attempts
 * generate Addresses for the DeviceGroup. The prepared archive will include cryptographic materials to export the
 * private keys corresponding to each of the MPCKey in the DeviceGroup. Once the device archive is prepared, utilize
 * ExportPrivateKeys function to export private keys for to your MPCKeys.
 * @param deviceGroup The resource name of the DeviceGroup.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param device The resource name of the Device that prepares the archive.
 * Format: devices/{device_id}
 * @returns A promise with the resource name of the WaaS operation creating the Device Archive on successful initiation;
 * a rejection otherwise.
 */
export function prepareDeviceArchive(
  deviceGroup: string,
  device: string
): Promise<string> {
  return MPCKeyService.prepareDeviceArchive(deviceGroup, device);
}

/**
 * Polls for pending DeviceArchives (i.e. PrepareDeviceArchiveOperation), and returns the first set that materializes.
 * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
 * stopPollingForPendingDeviceArchives or computePrepareDeviceArchiveMPCOperation)
 * before another call is made to this function.
 * @param deviceGroup The resource name of the DeviceGroup for which to poll the pending
 * PrepareDeviceArchiveOperation.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending operations on success; a rejection otherwise.
 */
export function pollForPendingDeviceArchives(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<PrepareDeviceArchiveOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingDeviceArchives(
    deviceGroup,
    pollIntervalToUse
  );
}

/**
 * Stops polling for pending device archive operations. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchive.
 * @returns A promise with string "stopped polling for pending Device Archives" if polling is
 * stopped successfully; a promise with the empty string otherwise.
 */
export function stopPollingForPendingDeviceArchives(): Promise<string> {
  return MPCKeyService.stopPollingForPendingDeviceArchives();
}

/**
 * Initiates an operation to prepare a device backup for the given Device. The backup contains certain cryptographic
 * materials that can be used to restore MPCKeys, which have the given DeviceGroup as their parent, on a new Device.
 * The Device must retrieve the resulting MPCOperation using pollForPendingDeviceBackups and compute with
 * computePrepareDeviceBackupMPCOperation method.
 * @param deviceGroup The resource name of the DeviceGroup.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param device The resource name of the Device that is preparing the device backup.
 * Format: devices/{device_id}
 * @returns A promise with the resource name of the WaaS operation creating the Device Backup; a rejection
 * otherwise.
 */
export function prepareDeviceBackup(
  deviceGroup: string,
  device: string
): Promise<string> {
  return MPCKeyService.prepareDeviceBackup(deviceGroup, device);
}

/**
 * Polls for pending DeviceBackups (i.e. PrepareDeviceBackupOperation), and returns the first set that materializes.
 * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
 * stopPollingForPendingDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made
 * to this function.
 * @param deviceGroup The resource name of the DeviceGroup for which to poll the pending
 * PrepareDeviceBackupOperation.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending operations on success; a rejection otherwise.
 */
export function pollForPendingDeviceBackups(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<PrepareDeviceBackupOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingDeviceBackups(
    deviceGroup,
    pollIntervalToUse
  );
}

/**
 * Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackup.
 * @returns A promise with string "stopped polling for pending Device Backups" if polling is stopped successfully;
 * a promise with the empty string otherwise.
 */
export function stopPollingForPendingDeviceBackups(): Promise<string> {
  return MPCKeyService.stopPollingForPendingDeviceBackups();
}

/**
 * Initiates an operation to add a Device to the DeviceGroup,
 * using a device backup prepared with PrepareDeviceBackupOperation.
 * The Device must retrieve the resulting MPCOperation using pollForPendingDevices and compute with
 * computeAddDeviceMPCOperation method.
 * @param deviceGroup The resource name of the DeviceGroup to which the Device is to be added.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param device The resource name of the Device that has to be added to the DeviceGroup.
 * Format: devices/{device_id}
 * @returns A void promise, that either succeeds or rejects.
 * otherwise.
 */
export function addDevice(deviceGroup: string, device: string): Promise<void> {
  return MPCKeyService.addDevice(deviceGroup, device);
}

/**
 * Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
 * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
 * stopPollingForPendingDevices or computeAddDeviceMPCOperation) before another call is made
 * to this function.
 * @param deviceGroup The resource name of the deviceGroup for which to poll the pending
 * AddDeviceOperation.
 * Format: pools/{pool_id}/deviceGroups/{device_group_id}
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending operations on success; a rejection otherwise.
 */
export function pollForPendingDevices(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<AddDeviceOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingDevices(deviceGroup, pollIntervalToUse);
}

/**
 * Stops polling for pending Device operations. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Device.
 * @returns A promise with string "stopped polling for pending Devices" if polling is stopped successfully;
 * a promise with the empty string otherwise.
 */
export function stopPollingForPendingDevices(): Promise<string> {
  return MPCKeyService.stopPollingForPendingDevices();
}

/**
 * The native hook into the WaaS MPCWalletService.
 */
const MPCWalletService = NativeModules.MPCWalletService
  ? NativeModules.MPCWalletService
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * The response for CreateMPCWallet.
 */
export type CreateMPCWalletResponse = {
  // The resource name of the DeviceGroup associated with this MPCWallet.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
  // The resource name of the WaaS operation that creates this MPCWallet.
  // Format: operations/{operation_id}
  Operation: string;
};

/**
 * The Address resource.
 */
export type Address = {
  // The resource name of the Address.
  Name: string;
  // The address value - for example, a 0x-prefixed checksummed hexadecimal string.
  Address: string;
  // The resource names of the MPCKeys that back this Address.
  // For EVM networks, there will be only one MPCKey.
  MPCKeys: Array<string>;
  // The resource name of the MPCWallet to which this Address belongs.
  MPCWallet: string;
};

/**
 * The MPCWallet resource.
 */
export type MPCWallet = {
  // The resource name of the MPCWallet.
  // Format: pools/{pool_id}/mpcWallets/{mpc_wallet_id}
  Name: string;
  // The resource name of the MPCKeyService DeviceGroup associated with this MPCWallet.
  // The DeviceGroup will perform the underlying MPC operations.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  DeviceGroup: string;
};

/**
 * Initializes the MPCWalletService with Cloud API Key. This function must be invoked before
 * any MPCWalletService functions are called.
 * @param apiKeyName The API key name.
 * @param privateKey The private key.
 * @param url The URL of the WalletService. Optional.
 * @returns A void promise, that either succeeds or rejects.
 * otherwise.
 */
export function initMPCWalletService(
  apiKeyName: string,
  privateKey: string
): Promise<void> {
  return MPCWalletService.initialize(apiKeyName, privateKey);
}

/**
 * Creates an MPCWallet.
 * @param parent The resource name of the parent Pool.
 * @param device The resource name of the Device.
 * @returns A promise with the response on success; a rejection otherwise.
 */
export function createMPCWallet(
  parent: string,
  device: string
): Promise<CreateMPCWalletResponse> {
  return MPCWalletService.createMPCWallet(parent, device);
}

/**
 * Computes an MPCWallet.
 * Computing an MPCWallet consists of two steps:
 * 1. Compute the MPC operation to create the DeviceGroup.
 * 2. Compute the MPC operation to prepare device archive for the DeviceGroup.
 * Users are provided with this convenience API to compute both MPC operations using one single API call.
 * Users have the choices to compute the two MPC operations separately.
 * @param deviceGroup The resource name of the DeviceGroup from the createMPCWallet response.
 * @param passcode Passcode protecting key materials in the device, set during the call to BootstrapDevice.
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A void promise, that either succeeds or rejects.
 */
export async function computeMPCWallet(
  deviceGroup: string,
  passcode: string,
  pollInterval?: number
): Promise<void> {
  const pendingDeviceGroup = await pollForPendingDeviceGroup(
    deviceGroup,
    pollInterval
  );

  for (let i = pendingDeviceGroup.length - 1; i >= 0; i--) {
    const deviceGroupOperation = pendingDeviceGroup[i];

    await computeMPCOperation(deviceGroupOperation?.MPCData as string);
  }

  const pendingDeviceArchiveOperations = await pollForPendingDeviceArchives(
    deviceGroup,
    pollInterval
  );

  for (let i = pendingDeviceArchiveOperations.length - 1; i >= 0; i--) {
    const pendingOperation = pendingDeviceArchiveOperations[i];
    await computePrepareDeviceArchiveMPCOperation(
      pendingOperation!.MPCData,
      passcode
    );
  }

  return;
}

/**
 * Waits for a pending MPCWallet.
 * @param wallet The name of operation that created the MPCWallet.
 * @returns A promise with the MPCWallet on success; a rejection otherwise.
 */
export function waitPendingMPCWallet(operation: string): Promise<MPCWallet> {
  return MPCWalletService.waitPendingMPCWallet(operation);
}

/**
 * Generates an Address.
 * @param wallet The resource name of the MPCWallet to create the Address in.
 * @param network The resource name of Network to create the Address for.
 * @returns A promise with the Address on success; a rejection otherwise.
 */
export function generateAddress(
  wallet: string,
  network: string
): Promise<Address> {
  return MPCWalletService.generateAddress(wallet, network);
}

/**
 * Gets an Address.
 * @param name The resource name of the Address.
 * @returns A promise with the Address on success; a rejection otherwise.
 */
export function getAddress(name: string): Promise<Address> {
  return MPCWalletService.getAddress(name);
}
