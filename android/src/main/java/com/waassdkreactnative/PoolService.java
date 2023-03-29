package com.waassdkreactnative;

import static com.waassdkinternal.v1.V1.newPoolService;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.waassdkinternal.v1.Pool;


@ReactModule(name = PoolService.NAME)
public class PoolService extends ReactContextBaseJavaModule {
  public static final String NAME = "PoolService";

  // The URL of the PoolService.
  public static String poolServiceUrl = "https://api.developer.coinbase.com/waas/pools";

  // The error code for PoolService-related errors.
  private String poolsErr = "E_POOL_SERVICE";

  
  private String uninitializedErr = "pool service must be initialized";

  // The handle to the Go PoolService client.
  com.waassdkinternal.v1.PoolService poolClient;

   PoolService(ReactApplicationContext reactContext) {
    super(reactContext);

  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


/********POOL SERVICE API'S********************* */

/**
  Initializes the PoolService with the given Cloud API Key parameters. Resolves with the string "success" on success;
  rejects with an error otherwise.
  */
@ReactMethod
public void initialize(String apiKeyName,String privateKey,Promise promise) {
  try{
    poolClient = newPoolService(poolServiceUrl,apiKeyName,privateKey);
    promise.resolve("success initialize new pool");
  } catch(Exception e) {
    promise.reject("initialize pool failed : ", e);
  }
}

/**
  Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
  otherwise.
  */
@ReactMethod
public void createPool(String displayName,String poolID,Promise promise) {
  try{

    if(poolClient==null)
    {
      promise.reject(poolsErr,uninitializedErr);
    }

    Pool pool = poolClient.createPool(displayName,poolID);
    WritableMap map = Arguments.createMap();
    map.putString("name", pool.getName());
    map.putString("displayName", pool.getDisplayName());

    promise.resolve(map);


  } catch(Exception e) {
    promise.reject("create pool failed : ", e);
  }
}

/********END POOL SERVICE API'S********************* */

}
