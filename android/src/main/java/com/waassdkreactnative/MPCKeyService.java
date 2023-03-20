package com.waassdkreactnative;

import static com.waassdkinternal.v1.V1.newMPCKeyService;
import static com.waassdkreactnative.Utils.convertJsonToArray;
import static com.waassdkreactnative.Utils.convertMapToJson;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.StandardCharsets;
import com.facebook.react.module.annotations.ReactModule;
import com.waassdkinternal.v1.Device;
import com.waassdkinternal.v1.Signature;
import com.waassdkinternal.v1.SignedTransaction;

import org.json.JSONArray;
import org.json.JSONObject;

@ReactModule(name = MPCKeyService.NAME)
public class MPCKeyService extends ReactContextBaseJavaModule {
  public static final String NAME = "MPCKeyService";
  
  // The URL of the MPCKeyService.
  public static final String  mpcKeyServiceUrl = "https://api.developer.coinbase.com/waas/mpc_keys";

  // The error code for MPCKeyService-related errors.
  private String mpcKeyServiceErr = "E_MPC_KEY_SERVICE";

  // The error message for calls made without initializing SDK.
  private String uninitializedErr = "MPCKeyService must be initialized";

  // The handle to the Go MPCKeyService client.
  com.waassdkinternal.v1.MPCKeyService keyClient;

   MPCKeyService(ReactApplicationContext reactContext) {
    super(reactContext);

  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


/********MPCKeyService SERVICE API'S********************* */

/**
  Initializes the MPCKeyService  with the given parameters.
  Resolves with the string "success" on success; rejects with an error otherwise.
  */
@ReactMethod
public void initialize(String apiKeyName,String privateKey,Promise promise) {
  try{
    keyClient = newMPCKeyService(mpcKeyServiceUrl,apiKeyName,privateKey);
    promise.resolve("success initialize MPC key service");
  } catch(Exception e) {
    promise.reject("initialize MPC key service failed : ", e);
  }
}

/**
  Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
  */
@ReactMethod
public void registerDevice(Promise promise) {
  try {

    if(keyClient==null)
    {
      promise.reject(mpcKeyServiceErr,uninitializedErr);
    }

    Device device = keyClient.registerDevice();

    WritableMap map = Arguments.createMap();
    map.putString("Name", device.getName());

    promise.resolve(map);

  } catch(Exception e) {
    promise.reject("registerDevice failed : ", e);
  }
}

/**
  Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
  Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
  stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
  Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
  */
  @ReactMethod
  public void pollForPendingDeviceGroup(String deviceGroup,int pollInterval,Promise promise) {
    try{
      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      byte[] pendingDeviceGroupData = keyClient.pollPendingDeviceGroup(deviceGroup,pollInterval);

      // Converting the bytes to String.
      String pendingDeviceGroupDataBytesToStrings = new String(pendingDeviceGroupData, StandardCharsets.UTF_8);
      JSONArray jsonArray=new JSONArray(new String(pendingDeviceGroupDataBytesToStrings));

      WritableArray array = convertJsonToArray(jsonArray);
      promise.resolve(array);

    } catch(Exception e) {
      promise.reject("pollForPendingDeviceGroup failed : ", e);
    }
  }

  /**
  Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
  screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
  Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
  resolves with the empty string otherwise.
  */
  @ReactMethod
  public void stopPollingPendingDeviceGroup(Promise promise) {
    try{
      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      String result = keyClient.stopPollingPendingDeviceGroup();

      promise.resolve(result);

    } catch(Exception e) {
      promise.reject("stopPollingPendingDeviceGroup failed : ", e);
    }
  }

  /**
  Initiates an operation to create a Signature resource from the given transaction.
  Resolves with the string "success" on successful initiation; rejects with an error otherwise.
  */
  @ReactMethod
  public void createSignatureFromTx(String parent, ReadableMap transaction, Promise promise) {
    try{

      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      JSONObject serializedTx = convertMapToJson(transaction);
      keyClient.createTxSignature(parent,serializedTx.toString().getBytes(StandardCharsets.UTF_8));

      promise.resolve("success");

    } catch(Exception e) {
      promise.reject("createSignatureFromTx failed : ", e);
    }
  }

  /**
  Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
  Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
  stopPollingForPendingSignatures or processPendingSignature before another call is made to this function.
  Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
  */
  @ReactMethod
  public void pollForPendingSignatures(String deviceGroup,int pollInterval,Promise promise) {
    try{
      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      byte[] pendingSeedsData = keyClient.pollPendingSignatures(deviceGroup,pollInterval);

      // Converting the bytes to String.
      String pendingSeedsDataBytesToStrings = new String(pendingSeedsData,StandardCharsets.UTF_8);
      JSONArray jsonArray=new JSONArray(new String(pendingSeedsDataBytesToStrings));

      WritableArray array = convertJsonToArray(jsonArray);

      promise.resolve(array);

    } catch(Exception e) {
      promise.reject("pollForPendingSignatures failed : ", e);
    }
  }

  /**
  Stops polling for pending Signatures This function should be called, e.g., before your app exits,
  screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
  Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
  resolves with the empty string otherwise.
  */
  @ReactMethod
  public void stopPollingForPendingSignatures(Promise promise) {
    try{
      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      String result = keyClient.stopPollingPendingSignatures();

      promise.resolve(result);

    } catch(Exception e) {
      promise.reject("stopPollingPendingSignatures failed : ", e);
    }
  }

/**
  Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
  rejects with an error otherwise.
  */
  @ReactMethod
  public void waitPendingSignature(String operation, Promise promise) {
    try{

      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }
      Signature signature = keyClient.waitPendingSignature(operation);

      WritableMap map = Arguments.createMap();
      map.putString("Name", signature.getName());
      map.putString("Payload", signature.getPayload());
      map.putString("SignedPayload", signature.getSignedPayload());

      promise.resolve(map);

    } catch(Exception e) {
      promise.reject("waitPendingSignature failed : ", e);
    }
  }

  /**
  Gets the signed transaction using the given inputs.
  Resolves with the SignedTransaction on success; rejects with an error otherwise.
  */
  @ReactMethod
  public void getSignedTransaction(ReadableMap transaction,ReadableMap signature,Promise promise) {
    try{

      if(keyClient==null)
      {
        promise.reject(mpcKeyServiceErr,uninitializedErr);
      }

      JSONObject serializedTx = convertMapToJson(transaction);
      Signature goSignature = new Signature();
      goSignature.setName(signature.getString("Name"));
      goSignature.setPayload(signature.getString("Payload"));
      goSignature.setSignedPayload(signature.getString("SignedPayload"));

      SignedTransaction signedTransaction = keyClient.getSignedTransaction(serializedTx.toString().getBytes(StandardCharsets.UTF_8),goSignature);

      WritableMap map = Arguments.createMap();
      map.putMap("Transaction", transaction);
      map.putMap("Signature", signature);
      map.putString("RawTransaction", signedTransaction.getRawTransaction());
      map.putString("TransactionHash", signedTransaction.getTransactionHash());

      promise.resolve(map);

    } catch(Exception e) {
      promise.reject("getSignedTransaction failed : ", e);
    }
  }

/********END MPCKeyService  API'S********************* */

}

