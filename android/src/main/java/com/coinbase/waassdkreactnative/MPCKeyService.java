package com.coinbase.waassdkreactnative;

import static com.coinbase.waassdkreactnative.Utils.convertMapToJson;

import androidx.annotation.NonNull;

import com.coinbase.waassdk.WaasException;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.waassdkinternal.v1.Device;
import com.waassdkinternal.v1.Signature;
import com.waassdkinternal.v1.SignedTransaction;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * React Native wrapper for {@link com.coinbase.waassdk.MPCKeyService}
 */
@ReactModule(name = MPCKeyService.NAME)
public class MPCKeyService extends ReactContextBaseJavaModule {

  // The error code for MPCKeyService-related errors.
  private String mpcKeyServiceErr = "E_MPC_KEY_SERVICE";

  // The error message for calls made without initializing SDK.
  private String uninitializedErr = "MPCKeyService must be initialized";
  public static final String NAME = "MPCKeyService";

  ExecutorService executor;

  // The handle to the Go MPCKeyService client.
  com.coinbase.waassdk.MPCKeyService keyClient;
  private static final int NUMBER_OF_CORES = Runtime.getRuntime().availableProcessors();

  MPCKeyService(ReactApplicationContext reactContext) {
    super(reactContext);
    this.executor = Executors.newFixedThreadPool(NUMBER_OF_CORES);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  private boolean failIfUninitialized(Promise promise) {
    if (keyClient == null) {
      promise.reject(new WaasException(mpcKeyServiceErr, uninitializedErr));
      return true;
    }
    return false;
  }

  /**
   * Initializes the MPCKeyService  with the given parameters.
   * Resolves on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void initialize(String apiKeyName, String privateKey, Promise promise) {
    if (keyClient != null) {
      promise.resolve(null);
      return;
    }

    try {
      keyClient = new com.coinbase.waassdk.MPCKeyService(apiKeyName, privateKey, this.executor);
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(new WaasException("initialize MPC key service failed : ", e.getMessage()));
    }
  }

  /**
   * Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void registerDevice(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(keyClient.registerDevice(), promise, (Device device) -> {
      WritableMap jsMap = Arguments.createMap();
      jsMap.putString("Name", device.getName());
      return jsMap;
    }, this.executor);
  }

  /**
   * Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void pollForPendingDeviceGroup(String deviceGroup, int pollInterval, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.pollForPendingDeviceGroup(deviceGroup, pollInterval), promise, Utils::convertJsonToArray, this.executor);
  }

  /**
   * Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
   * Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
   * resolves with the empty string otherwise.
   */
  @ReactMethod
  public void stopPollingPendingDeviceGroup(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.stopPollingPendingDeviceGroup(), promise, null, this.executor);
  }

  /**
   * Initiates an operation to create a Signature resource from the given transaction.
   * Resolves with the string "success" on successful initiation; rejects with an error otherwise.
   */
  @ReactMethod
  public void createSignatureFromTx(String parent, ReadableMap transaction, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    try {
      JSONObject serializedTx = convertMapToJson(transaction);
      WaasPromise.resolveMap(keyClient.createSignatureFromTx(parent, serializedTx), promise, null, this.executor);
    } catch (Exception e) {
      promise.reject("createSignatureFromTx failed : ", e);
    }
  }

  /**
   * Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForPendingSignatures or processPendingSignature before another call is made to this function.
   * Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void pollForPendingSignatures(String deviceGroup, int pollInterval, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.pollForPendingSignatures(deviceGroup, pollInterval), promise, Utils::convertJsonToArray, this.executor);
  }

  /**
   * Stops polling for pending Signatures This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
   * Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
   * resolves with the empty string otherwise.
   */
  @ReactMethod
  public void stopPollingForPendingSignatures(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.stopPollingForPendingSignatures(), promise, null, this.executor);
  }

  /**
   * Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
   * rejects with an error otherwise.
   */
  @ReactMethod
  public void waitPendingSignature(String operation, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(keyClient.waitPendingSignature(operation), promise, (Signature signature) -> {
      WritableMap map = Arguments.createMap();
      map.putString("Name", signature.getName());
      map.putString("Payload", signature.getPayload());
      map.putString("SignedPayload", signature.getSignedPayload());
      return map;
    }, this.executor);
  }

  /**
   * Gets the signed transaction using the given inputs.
   * Resolves with the SignedTransaction on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void getSignedTransaction(ReadableMap transaction, ReadableMap signature, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    try {
      Signature goSignature = new Signature();
      goSignature.setName(signature.getString("Name"));
      goSignature.setPayload(signature.getString("Payload"));
      goSignature.setSignedPayload(signature.getString("SignedPayload"));

      JSONObject serializedTx = convertMapToJson(transaction);

      WaasPromise.resolveMap(keyClient.getSignedTransaction(serializedTx, goSignature), promise, (SignedTransaction tx) -> {
        WritableMap map = Arguments.createMap();
        map.putMap("Transaction", transaction);
        map.putMap("Signature", signature);
        map.putString("RawTransaction", tx.getRawTransaction());
        map.putString("TransactionHash", tx.getTransactionHash());
        return map;
      }, this.executor);
    } catch (Exception e) {
      promise.reject("getSignedTransaction failed : ", e);
    }
  }

  /**
   * Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void getDeviceGroup(String name, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(keyClient.getDeviceGroup(name), promise, (deviceGroup) -> {
      byte[] devicesData = deviceGroup.getDevices();
      String devicesDataBytesToStrings = new String(devicesData, StandardCharsets.UTF_8);

      WritableMap map = Arguments.createMap();
      map.putString("Name", deviceGroup.getName());
      map.putString("MPCKeyExportMetadata", deviceGroup.getMPCKeyExportMetadata());
      map.putString("Devices", devicesDataBytesToStrings);
      return map;
    }, this.executor);
  }

  /**
   * Initiates an operation to prepare device archive for MPCKey export. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  @ReactMethod
  public void prepareDeviceArchive(String deviceGroup, String device, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.prepareDeviceArchive(deviceGroup, device), promise, null, this.executor);
  }

  /**
   * Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void pollForPendingDeviceArchives(String deviceGroup, int pollInterval, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.pollForPendingDeviceArchives(deviceGroup, pollInterval), promise, Utils::convertJsonToArray, this.executor);
  }

  /**
   * Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
   * Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  @ReactMethod
  public void stopPollingForPendingDeviceArchives(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.stopPollingForPendingDeviceArchives(), promise, null, this.executor);
  }


  /**
   * Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
   * Only one DeviceBackup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void pollForPendingDeviceBackups(String deviceGroup, int pollInterval, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.pollForPendingDeviceBackups(deviceGroup, pollInterval), promise, Utils::convertJsonToArray, this.executor);
  }

  /**
   * Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackup.
   * Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  @ReactMethod
  public void stopPollingForPendingDeviceBackups(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.stopPollingForPendingDeviceBackups(), promise, null, this.executor);
  }


  /**
   * Initiates an operation to prepare device backup to add new Devices to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  @ReactMethod
  public void prepareDeviceBackup(String deviceGroup, String device, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.prepareDeviceBackup(deviceGroup, device), promise, null, this.executor);
  }

  /**
   * Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  @ReactMethod
  public void addDevice(String deviceGroup, String device, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.addDevice(deviceGroup, device), promise, null, this.executor);
  }


  /**
   * Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
   * Only one Device can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDevices or computeAddDeviceMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending Devices on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void pollForPendingDevices(String deviceGroup, int pollInterval, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.pollForPendingDevices(deviceGroup, pollInterval), promise, Utils::convertJsonToArray, this.executor);
  }

  /**
   * Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Device.
   * Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  @ReactMethod
  public void stopPollingForPendingDevices(Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }
    WaasPromise.resolveMap(keyClient.stopPollingForPendingDevices(), promise, null, this.executor);
  }
}

