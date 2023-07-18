package com.coinbase.waassdkreactnative;

import androidx.annotation.NonNull;

import com.coinbase.waassdk.WaasException;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * React-native wrapper for {@link com.coinbase.waassdk.MPCSdk}
 */
@ReactModule(name = MPCSdk.NAME)
public class MPCSdk extends ReactContextBaseJavaModule {
  public static final String NAME = "MPCSdk";

  // The error code for MPC-SDK related errors.
  private final String mpcSdkErr = "E_MPC_SDK";
  // The error message for calls made without initializing SDK.
  private final String uninitializedErr = "MPCSdk must be initialized";
  ExecutorService executor;
  // The handle to the Go MPCSdk class.
  com.coinbase.waassdk.MPCSdk sdk;

  MPCSdk(ReactApplicationContext reactContext) {
    super(reactContext);
    this.executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


  private boolean failIfUnitialized(Promise promise) {
    if (sdk == null) {
      promise.reject(new WaasException(mpcSdkErr, uninitializedErr));
      return true;
    }

    return false;
  }

  /**
   * Initializes the MPCSdk  with the given parameters.
   * Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void initialize(Boolean isSimulator, Promise promise) {
    if (sdk != null) {
      promise.resolve(true);
      return;
    }

    try {
      sdk = new com.coinbase.waassdk.MPCSdk(WaasSdkReactNativeModule.context, isSimulator, this.executor);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject("initialize MPCSdk service failed : ", e);
    }
  }

  /**
   * BootstrapDevice initializes the Device with the given passcode. The passcode is used to generate a private/public
   * key pair that encodes the back-up material for WaaS keys created on this Device. This function should be called
   * exactly once per Device per application, and should be called before the Device is registered with
   * GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
   * has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
   * or a rejection otherwise.
   */
  @ReactMethod
  public void bootstrapDevice(String passcode, Promise promise) {
    if (failIfUnitialized(promise)) {

      return;
    }

    try {
      sdk.bootstrapDevice(passcode);
      promise.resolve(null);
    } catch (WaasException e) {
      promise.reject(e);
    }
  }

  /**
   * GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
   * Resolves with the RegistrationData on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void getRegistrationData(Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    try {
      promise.resolve(sdk.getRegistrationData());
    } catch (WaasException e) {
      promise.reject(e);
    }
  }

  /**
   * ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computeMPCOperation(String mpcData, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolve(sdk.computeMPCOperation(mpcData), promise, executor);
  }


  /**
   * Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
   * exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
   * rejects with an error otherwise.
   */
  @ReactMethod
  public void exportPrivateKeys(String mpcKeyExportMetadata, String passcode, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(sdk.exportPrivateKeys(mpcKeyExportMetadata, passcode), promise, Utils::convertJsonToArray, executor);
  }


  /**
   * Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computePrepareDeviceArchiveMPCOperation(String mpcData, String passcode, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolve(sdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode), promise, executor);
  }

  /**
   * Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computePrepareDeviceBackupMPCOperation(String mpcData, String passcode, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolve(sdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode), promise, executor);
  }

  /**
   * Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
   * Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void exportDeviceBackup(Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolve(sdk.exportDeviceBackup(), promise, executor);
  }


  /**
   * Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService, passcode of the Device and deviceBackup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computeAddDeviceMPCOperation(String mpcData, String passcode, String deviceBackup, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }

    WaasPromise.resolve(sdk.computeAddDeviceMPCOperation(mpcData, passcode, deviceBackup), promise, executor);
  }

  /**
   * Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
   * While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
   * PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
   * This function can be used when/if the end user forgets their old passcode.
   * It resolves with the string "passcode reset" on success; a rejection otherwise.
   */
  @ReactMethod
  public void resetPasscode(String newPasscode, Promise promise) {
    if (failIfUnitialized(promise)) {
      return;
    }
    WaasPromise.resolve(sdk.resetPasscode(newPasscode), promise, executor);
  }
}

