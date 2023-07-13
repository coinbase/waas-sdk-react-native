package com.waassdkreactnative;

import static com.waassdkinternal.v1.V1.newMPCSdk;
import static com.waassdkreactnative.Utils.convertJsonToArray;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.common.StandardCharsets;
import com.facebook.react.module.annotations.ReactModule;

import org.json.JSONArray;

import okhttp3.Response;


@ReactModule(name = MPCSdk.NAME)
public class MPCSdk extends ReactContextBaseJavaModule {
  public static final String NAME = "MPCSdk";

  // The config to be used for MPCSdk initialization.
  private static final String mpcSdkConfig = "default";

  // The error code for MPC-SDK related errors.
  private String mpcSdkErr = "E_MPC_SDK";

  // The error message for calls made without initializing SDK.
  private String uninitializedErr = "MPCSdk must be initialized";

  // The handle to the Go MPCSdk class.
  com.waassdkinternal.v1.MPCSdk sdk;

  MPCSdk(ReactApplicationContext reactContext) {
    super(reactContext);

  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


/********MPCSdk SERVICE API'S********************* */

  /**
   * Initializes the MPCSdk  with the given parameters.
   * Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void initialize(Boolean isSimulator, Promise promise) {
    try {
      sdk = newMPCSdk(mpcSdkConfig, isSimulator, WaasSdkReactNativeModule.getCallbacks(WaasSdkReactNativeModule.context));
      promise.resolve("success");
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
    if (sdk == null) {
      promise.reject(mpcSdkErr, uninitializedErr);
    }

    ResponseReceiver receiver = new ResponseReceiver();
    sdk.bootstrapDevice(passcode, receiver);

    if (receiver.err != null) {
      promise.reject("bootstrapDevice failed", receiver.err);
    } else {
      promise.resolve(receiver.data);
    }
  }

  /**
   * GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
   * Resolves with the RegistrationData on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void getRegistrationData(Promise promise) {
    if (sdk == null) {
      promise.reject(mpcSdkErr, uninitializedErr);
    }

    ResponseReceiver receiver = new ResponseReceiver();
    sdk.getRegistrationData(receiver);

    if (receiver.err != null) {
      promise.reject("getRegistrationData failed", receiver.err);
    } else {
      promise.resolve(receiver.data);
    }
  }

  /**
   * ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computeMPCOperation(String mpcData, Promise promise) {
    try {
      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      sdk.computeMPCOperation(mpcData);

      promise.resolve("success");

    } catch (Exception e) {
      promise.reject("computeMPCOperation failed : ", e);
    }
  }


  /**
   * Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
   * exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
   * rejects with an error otherwise.
   */
  @ReactMethod
  public void exportPrivateKeys(String mpcKeyExportMetadata, String passcode, Promise promise) {
    try {

      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      byte[] exportPrivateKeysData = sdk.exportPrivateKeys(mpcKeyExportMetadata, passcode);

      // Converting the bytes to String.
      String exportPrivateKeysDataBytesToStrings = new String(exportPrivateKeysData, StandardCharsets.UTF_8);
      JSONArray jsonArray = new JSONArray(new String(exportPrivateKeysDataBytesToStrings));

      WritableArray array = convertJsonToArray(jsonArray);

      promise.resolve(array);

    } catch (Exception e) {
      promise.reject("exportPrivateKeys failed : ", e);
    }
  }


  /**
   * Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computePrepareDeviceArchiveMPCOperation(String mpcData, String passcode, Promise promise) {
    try {
      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      sdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode);

      promise.resolve("success");

    } catch (Exception e) {
      promise.reject("computePrepareDeviceArchiveMPCOperation failed : ", e);
    }
  }

  /**
   * Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computePrepareDeviceBackupMPCOperation(String mpcData, String passcode, Promise promise) {
    try {
      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      sdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode);

      promise.resolve("success");

    } catch (Exception e) {
      promise.reject("computePrepareDeviceBackupMPCOperation failed : ", e);
    }
  }

  /**
   * Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
   * Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void exportDeviceBackup(Promise promise) {
    if (sdk == null) {
      promise.reject(mpcSdkErr, uninitializedErr);
    }

    ResponseReceiver receiver = new ResponseReceiver();
    sdk.exportDeviceBackup(receiver);

    if (receiver.err != null) {
      promise.reject("exportDeviceBackup failed", receiver.err);
    } else {
      promise.resolve(receiver.data);
    }
  }


  /**
   * Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService, passcode of the Device and deviceBackup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void computeAddDeviceMPCOperation(String mpcData, String passcode, String deviceBackup, Promise promise) {
    try {
      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      sdk.computeAddDeviceMPCOperation(mpcData, passcode, deviceBackup);

      promise.resolve("success");

    } catch (Exception e) {
      promise.reject("computeAddDeviceMPCOperation failed : ", e);
    }
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
    try {
      if (sdk == null) {
        promise.reject(mpcSdkErr, uninitializedErr);
      }

      sdk.resetPasscode(newPasscode);

      promise.resolve("passcode reset");

    } catch (Exception e) {
      promise.reject("resetPasscode failed : ", e);
    }
  }


/********END MPCSdk  API'S********************* */

}

