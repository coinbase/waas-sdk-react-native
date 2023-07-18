package com.coinbase.waassdkreactnative;


import static com.coinbase.waassdkreactnative.Utils.convertJsonToMap;

import androidx.annotation.NonNull;

import com.coinbase.waassdk.WaasException;
import com.coinbase.waassdk.WaasNetwork;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * React-native wrapper for {@link com.coinbase.waassdk.MPCWalletService}
 */
@ReactModule(name = MPCWalletService.NAME)
public class MPCWalletService extends ReactContextBaseJavaModule {
  public static final String NAME = "MPCWalletService";
  // The handle to the Go MPCWalletService client.
  com.coinbase.waassdk.MPCWalletService walletsClient;
  // The error code for MPCWalletService-related errors.
  private final String walletsErr = "E_MPC_WALLET_SERVICE";
  // The error message for calls made without initializing SDK.
  private final String uninitializedErr = "MPCWalletService must be initialized";

  ExecutorService executor;

  MPCWalletService(ReactApplicationContext reactContext) {
    super(reactContext);
    executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  private boolean failIfUninitialized(Promise promise) {
    if (walletsClient == null) {
      promise.reject(new WaasException(walletsErr, uninitializedErr));
      return true;
    }

    return false;
  }

  /**
   * Initializes the MPCWalletService with the given Cloud API Key parameters. Resolves
   * on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void initialize(String apiKeyName, String privateKey, Promise promise) {
    if (walletsClient != null) {
      promise.resolve(true);
      return;
    }

    try {
      walletsClient = new com.coinbase.waassdk.MPCWalletService(apiKeyName, privateKey, executor);
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject("initialize MPC wallet service failed : ", e);
    }
  }

  /**
   * Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
   * otherwise.
   */
  @ReactMethod
  public void createMPCWallet(String parent, String device, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(walletsClient.createMPCWallet(parent, device), promise, (response) -> {
      WritableMap map = Arguments.createMap();
      map.putString("DeviceGroup", response.getDeviceGroup());
      map.putString("Operation", response.getOperation());
      return map;
    }, executor);
  }

  /**
   * Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
   * rejects with an error otherwise.
   */

  @ReactMethod
  public void waitPendingMPCWallet(String operation, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(walletsClient.waitPendingMPCWallet(operation), promise, (wallet) -> {
      WritableMap map = Arguments.createMap();
      map.putString("Name", wallet.getName());
      map.putString("DeviceGroup", wallet.getDeviceGroup());
      return map;
    }, executor);
  }

  /**
   * Generates an Address within an MPCWallet. Resolves with the Address object on success;
   * rejects with an error otherwise.
   */

  @ReactMethod
  public void generateAddress(String mpcWallet, String network, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(walletsClient.generateAddress(mpcWallet, WaasNetwork.fromNetworkString(network)), promise, (address) ->
        convertJsonToMap(address.toJSON())
      , executor);
  }

  /**
   * Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
   */
  @ReactMethod
  public void getAddress(String name, Promise promise) {
    if (failIfUninitialized(promise)) {
      return;
    }

    WaasPromise.resolveMap(walletsClient.getAddress(name), promise, (address) ->
        convertJsonToMap(address.toJSON())
      , executor);
  }
}

