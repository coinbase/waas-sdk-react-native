package com.coinbase.waassdk;


import static com.waassdkinternal.v1.V1.newMPCWalletService;

import com.waassdkinternal.v1.CreateMPCWalletResponse;
import com.waassdkinternal.v1.MPCWallet;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

/**
 * Methods for creating and managing MPC wallets with Coinbase.
 */
public class MPCWalletService {
  // The URL of the MPCWalletService when running in "direct mode".
  public static final String mpcWalletServiceWaaSUrl = "https://api.developer.coinbase.com/waas/mpc_wallets";

  com.waassdkinternal.v1.MPCWalletService walletsClient;

  ExecutorService executor;

  private <T> Future<T> call(Callable<T> callable) {
    return executor.submit(callable);
  }

  /**
   * Initializes the MPCWalletService with the given Cloud API Key parameters or proxy URL.
   * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
   * NOTE: You should almost never include these credentials in your app, and instead
   *       delegate to a proxy server to perform these calls.
   */
  public MPCWalletService(String apiKeyName, String privateKey, String proxyUrl, ExecutorService executor) throws WaasException {
    Bool insecure;

    String mpcWalletServiceUrl;
    
    if (apiKeyName == "" && privateKey == "") {
      mpcWalletServiceUrl = proxyUrl;
      insecure = true;
    } else {
      mpcWalletServiceUrl = mpcWalletServiceWaaSUrl;
      insecure = false;
    }

    try {
      walletsClient = newMPCWalletService(mpcWalletServiceUrl, apiKeyName, privateKey, insecure);
      this.executor = executor;
    } catch (Exception e) {
      throw new WaasException("initialize MPC wallet service failed : ", e.getMessage());
    }
  }

  /**
   * Creates an MPCWallet with the given parameters.  Resolves on success; rejects with an error
   * otherwise.
   */
  public Future<CreateMPCWalletResponse> createMPCWallet(String poolId, String device) {
    return call(() -> {
      try {
        return walletsClient.createMPCWallet(poolId, device);
      } catch (Exception e) {
        throw new WaasException("createMPCWallet failed : ", e.getMessage());
      }
    });
  }

  /**
   * Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
   * rejects with an error otherwise.
   */
  public Future<MPCWallet> waitPendingMPCWallet(String operation) {
    return call(() -> {
      try {
        return walletsClient.waitPendingMPCWallet(operation);
      } catch (Exception e) {
        throw new WaasException("waitPendingMPCWallet failed : ", e.getMessage());
      }
    });
  }



  /**
   * Generates an Address within an MPCWallet.
   * Resolves with the Address object on success; rejects with an error otherwise.
   */
  public Future<Address> generateAddress(String mpcWallet, WaasNetwork network) {
    return call(() -> {
      try {
        byte[] addressData = walletsClient.generateAddress(mpcWallet, network.toString());
        String addressDataBytesToStrings = new String(addressData, StandardCharsets.UTF_8);
        return Address.fromJSON(new JSONObject(addressDataBytesToStrings));
      } catch (Exception e) {
        throw new WaasException("generateAddress failed : ", e.getMessage());
      }
    });
  }

  /**
   * Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
   */
  public Future<Address> getAddress(String name) {
    return call(() -> {
      try {
        byte[] addressData = walletsClient.getAddress(name);
        String addressDataBytesToStrings = new String(addressData, StandardCharsets.UTF_8);
        return Address.fromJSON(new JSONObject(addressDataBytesToStrings));
      } catch (Exception e) {
        throw new WaasException("getAddress failed : ", e.getMessage());
      }
    });
  }
}

