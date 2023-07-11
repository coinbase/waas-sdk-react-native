package com.waassdkreactnative;


import static com.waassdkinternal.v1.V1.newMPCWalletService;
import static com.waassdkreactnative.Utils.convertJsonToMap;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.waassdkinternal.v1.CreateMPCWalletResponse;
import com.waassdkinternal.v1.MPCWallet;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;


@ReactModule(name = MPCWalletService.NAME)
public class MPCWalletService extends ReactContextBaseJavaModule {
  public static final String NAME = "MPCWalletService";
  
  // The URL of the MPCWalletService.
  public static final String  mpcWalletServiceUrl = "https://api.developer.coinbase.com/waas/mpc_wallets";

  // The error code for MPCWalletService-related errors.
  private String walletsErr = "E_MPC_WALLET_SERVICE";

  // The error message for calls made without initializing SDK.
  private String uninitializedErr = "MPCWalletService must be initialized";

  // The handle to the Go MPCWalletService client.
  com.waassdkinternal.v1.MPCWalletService walletsClient;


  MPCWalletService(ReactApplicationContext reactContext) {
    super(reactContext);

  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


/******** WALLET SERVICE API'S********************* */

/**
  Initializes the MPCWalletService with the given Cloud API Key parameters. Resolves with the string "success"
  on success; rejects with an error otherwise.
  */
@ReactMethod
public void initialize(String apiKeyName,String privateKey,Promise promise) {
  try{
    walletsClient = newMPCWalletService(mpcWalletServiceUrl,apiKeyName,privateKey);
    promise.resolve("success initialize MPC wallet service");
  } catch(Exception e) {
    promise.reject("initialize MPC wallet service failed : ", e);
  }
}

/**
  Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
  otherwise.
  */
@ReactMethod
public void createMPCWallet(String parent,String device, Promise promise) {
  try{

    if(walletsClient==null)
    {
      promise.reject(walletsErr,uninitializedErr);
    }
    CreateMPCWalletResponse createWalletResponse = walletsClient.createMPCWallet(parent,device);

    WritableMap map = Arguments.createMap();
    map.putString("DeviceGroup", createWalletResponse.getDeviceGroup());
    map.putString("Operation", createWalletResponse.getOperation());
    promise.resolve(map);

  } catch(Exception e) {
    promise.reject("createMPCWallet failed : ", e);
  }
}

/**
  Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
  rejects with an error otherwise.
  */

@ReactMethod
public void waitPendingMPCWallet(String operation,Promise promise) {
  try{

    if(walletsClient==null)
    {
      promise.reject(walletsErr,uninitializedErr);
    }

    MPCWallet mpcWallet = walletsClient.waitPendingMPCWallet(operation);

    WritableMap map = Arguments.createMap();
    map.putString("Name", mpcWallet.getName());
    map.putString("DeviceGroup", mpcWallet.getDeviceGroup());
    promise.resolve(map);


  } catch(Exception e) {
    promise.reject("waitPendingMPCWallet failed : ", e);
  }
}

/**
  Generates an Address within an MPCWallet. Resolves with the Address object on success;
  rejects with an error otherwise.
  */

@ReactMethod
public void generateAddress(String mpcWallet,String network, Promise promise) {
  try{

    if(walletsClient==null)
    {
      promise.reject(walletsErr,uninitializedErr);
    }

    byte[] addressData = walletsClient.generateAddress(mpcWallet,network);

    // Converting the bytes to String.
    String addressDataBytesToStrings = new String(addressData,StandardCharsets.UTF_8);
    JSONObject jsonobject = new JSONObject(new String(addressDataBytesToStrings));

    WritableMap  map = convertJsonToMap(jsonobject);
    promise.resolve(map);


  } catch(Exception e) {
    promise.reject("generateAddress failed : ", e);
  }
}

/**
  Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
  */
@ReactMethod
public void getAddress(String name,Promise promise) {
  try{

    if(walletsClient==null)
    {
      promise.reject(walletsErr,uninitializedErr);
    }

    byte[] addressData = walletsClient.getAddress(name);

    // Converting the bytes to String.
    String addressDataBytesToStrings = new String(addressData,StandardCharsets.UTF_8);
    JSONObject jsonobject = new JSONObject(new String(addressDataBytesToStrings));

    WritableMap  map = convertJsonToMap(jsonobject);
    promise.resolve(map);


  } catch(Exception e) {
    promise.reject("getAddress failed : ", e);
  }
}


/********END WALLETS SERVICE API'S********************* */

}

