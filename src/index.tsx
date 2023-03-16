// Copyright (c) 2018-2023 Coinbase, Inc. <https://www.coinbase.com/>
// Licensed under the Apache License, version 2.0

import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-waas-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';


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
 * @returns A promise with the string "success" on successful initialization; a rejection
 * otherwise.
 */
export function initPoolService(
  apiKeyName: string,
  privateKey: string,
  url?: string
): Promise<string> {
  if (url === undefined || url === '') {
    url = 'https://api.developer.coinbase.com/waas/pools';
  }

  return PoolService.initialize(url, apiKeyName, privateKey);
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
 * @param isSimulator(optional) Whether or not this API is being called from an iOS simulator, as opposed to a physical device.
 * @returns A promise with the string "success" on successful initialization; a rejection
 * otherwise.
 */
export function initMPCKeyService(
  apiKeyName: string,
  privateKey: string,
  isSimulator?: boolean,
  url?: string,
): Promise<string> {
  if (url === undefined || url === '') {
    url = 'https://api.developer.coinbase.com/waas/mpc_keys';
  }

  return MPCKeyService.initialize(url, apiKeyName, privateKey, isSimulator);
}

/**
  Bootstraps the Device with the given passcode. The passcode is used to generate a private/public key pair
  that encodes the back-up material for WaaS keys created on this Device. This function should be called exactly once per
  Device per application, and should be called before the Device is registered with GetRegistrationData.
  It is the responsibility of the application to track whether BootstrapDevice has been called for the Device.
 * @param passcode: Passcode to protect all key materials in the secure enclave.
 * @returns A promise with the string "bootstrap complete" on successful initialization; a rejection
 * otherwise.
 */
  export function bootstrapDevice(
    passcode: string
  ): Promise<string> {
    return MPCKeyService.bootstrapDevice(passcode);
  }
  
/**
 * Retrieves the data required to call RegisterDeviceAPI on MPCKeyService.
 * @returns A promise with the RegistrationData on success; a rejection otherwise.
 */
export function getRegistrationData(): Promise<String> {
  return MPCKeyService.getRegistrationData();
}

/**
 * ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on MPCKeyService.
 * @param mpcData The mpcData from ListMPCOperationsResponse on MPCKeyService.
 * @returns A promise with the string "success" on successful MPC computation; a rejection otherwise.
 */
export function computeMPCOperation(
  mpcData: string,
): Promise<String> {
  return MPCKeyService.computeMPCOperation(mpcData);
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
 * @param pollInterval The interval at which to poll for the pending operation in milliseconds.
 * If not provided, a reasonable default will be used.
 * @returns A promise with a list of the pending CreateDeviceGroupOperations on success; a rejection otherwise.
 */
export function pollForPendingDeviceGroup(
  deviceGroup: string,
  pollInterval?: number
): Promise<Array<CreateDeviceGroupOperation>> {
  const pollIntervalToUse = pollInterval === undefined ? 200 : pollInterval;
  return MPCKeyService.pollForPendingDeviceGroup(deviceGroup, pollIntervalToUse);
}

/**
 * Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
 * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
 * @returns A promise with string "stoped polling for pending DeviceGroup" if polling is stopped successfully;
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
 * @returns A promise with the string "success" on successful initiation; a rejection
 * otherwise.
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
 * @param deviceGroup The resource name of the deviceGroup for which to poll the pending
 * CreateSignatureOperation.
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
  return MPCKeyService.getSignedTransaction(
    unsignedTx,
    signature
  );
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
  DeviceGroup: string
  // The resource name of the WaaS operation that creates this MPCWallet.
  // Format: operations/{operation_id}
  Operation: string
}

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
 * @returns A promise with the string "success" on successful initialization; a rejection
 * otherwise.
 */
export function initMPCWalletService(
  apiKeyName: string,
  privateKey: string,
  url?: string
): Promise<string> {
  if (url === undefined || url === '') {
    url = 'https://api.developer.coinbase.com/waas/mpc_wallets';
  }

  return MPCWalletService.initialize(url, apiKeyName, privateKey);
}

/**
 * Creates an MPCWallet.
 * @param parent The resource name of the parent Pool.
 * @param device The resource name of the Device.
 * @returns A promise with the response on success; a rejection otherwise.
 */
export function createMPCWallet(
  parent: string,
  device: string,
): Promise<CreateMPCWalletResponse> {
  return MPCWalletService.createMPCWallet(parent,device);
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
  network: string,
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
