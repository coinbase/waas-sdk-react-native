package com.coinbase.waassdkreactnative;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.waassdkinternal.v1.Pool;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * React-native wrapper for {@link com.coinbase.waassdk.PoolService}
 */
@ReactModule(name = PoolService.NAME)
public class PoolService extends ReactContextBaseJavaModule {
  public static final String NAME = "PoolService";
  private String poolsErr = "E_POOL_SERVICE";

  private String uninitializedErr = "pool service must be initialized";

  ExecutorService executor;

  // The handle to the Go PoolService client.
  com.coinbase.waassdk.PoolService poolClient;

  PoolService(ReactApplicationContext reactContext) {
    super(reactContext);
    this.executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  /**
   * Initializes the PoolService with the given Cloud API Key parameters. Resolves on success;
   * rejects with an error otherwise.
   */
  @ReactMethod
  public void initialize(String apiKeyName, String privateKey, Promise promise) {
    if (poolClient != null) {
      promise.resolve(true);
      return;
    }

    try {
      poolClient = new com.coinbase.waassdk.PoolService(apiKeyName, privateKey, executor);
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject("initialize pool failed : ", e);
    }
  }

  /**
   * Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
   * otherwise.
   */
  @ReactMethod
  public void createPool(String displayName, String poolID, Promise promise) {
    if (poolClient == null) {
      promise.reject(poolsErr, uninitializedErr);
      return;
    }

    WaasPromise.resolveMap(poolClient.createPool(displayName, poolID), promise, (Pool pool) -> {
      WritableMap outMap = new WritableNativeMap();
      outMap.putString("name", pool.getName());
      outMap.putString("displayName", pool.getDisplayName());
      return outMap;
    }, executor);
  }
}
