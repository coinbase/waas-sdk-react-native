package com.waassdkreactnative;

import static com.waassdkinternal.v1.V1.newMPCSdk;
import androidx.annotation.NonNull;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;


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
  Initializes the MPCSdk  with the given parameters.
  Resolves with the string "success" on success; rejects with an error otherwise.
  */
@ReactMethod
public void initialize(Boolean isSimulator,Promise promise) {
  try{
    sdk = newMPCSdk(mpcSdkConfig,isSimulator,WaasSdkReactNativeModule.getCallbacks(WaasSdkReactNativeModule.context));
    promise.resolve("success");
  } catch(Exception e) {
    promise.reject("initialize MPCSdk service failed : ", e);
  }
}

/**
  BootstrapDevice initializes the Device with the given passcode. The passcode is used to generate a private/public
  key pair that encodes the back-up material for WaaS keys created on this Device. This function should be called
  exactly once per Device per application, and should be called before the Device is registered with
  GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
  has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
  or a rejection otherwise.
  */
  @ReactMethod
  public void bootstrapDevice(String passcode,Promise promise) {
    try {

      if(sdk==null)
      {
        promise.reject(mpcSdkErr,uninitializedErr);
      }

      String res = sdk.bootstrapDevice(passcode);

      promise.resolve(res);

    } catch(Exception e) {
      promise.reject("bootstrapDevice failed : ", e);
    }
  }

/**
  GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
  Resolves with the RegistrationData on success; rejects with an error otherwise.
  */
@ReactMethod
public void getRegistrationData(Promise promise) {
  try {

    if(sdk==null)
    {
      promise.reject(mpcSdkErr,uninitializedErr);
    }

    String registrationData = sdk.getRegistrationData();

    promise.resolve(registrationData);

  } catch(Exception e) {
    promise.reject("getRegistrationData failed : ", e);
  }
}

/**
  ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on
  MPCKeyService. Resolves with the string "success" on success; rejects with an error otherwise.
  */
  @ReactMethod
  public void computeMPCOperation(String mpcData,Promise promise) {
    try {
      if(sdk==null)
      {
        promise.reject(mpcSdkErr,uninitializedErr);
      }

      sdk.computeMPCOperation(mpcData);

      promise.resolve("success");

    } catch(Exception e) {
      promise.reject("computeMPCOperation failed : ", e);
    }
  }


/********END MPCSdk  API'S********************* */

}

