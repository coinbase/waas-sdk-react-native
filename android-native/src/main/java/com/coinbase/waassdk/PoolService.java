package com.coinbase.waassdk;

import static com.waassdkinternal.v1.V1.newPoolService;

import com.waassdkinternal.v1.Pool;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

/**
 * Methods for creating/modifying pools.
 * A pool represents a group of related wallets.
 */
public class PoolService {
  // The URL of the PoolService when running in "direct mode".
  public static final String poolServiceWaaSUrl = "https://api.developer.coinbase.com/waas/pools";
  // The handle to the Go PoolService client.
  com.waassdkinternal.v1.PoolService poolClient;
  ExecutorService executor;

  /**
   * Initializes the PoolService with the given Cloud API Key parameters or proxy URL.
   * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
   * Uses direct WaaS URL with the API keys if both are provided.
   * Resolves with the string "success" on success; rejects with an error otherwise.
   */
  public PoolService(String apiKeyName, String privateKey, String proxyUrl, ExecutorService executor) throws WaasException {
    this.executor = executor;

    Bool insecure;

    String poolServiceUrl;
    
    if (apiKeyName == "" && privateKey == "") {
      poolServiceUrl = proxyUrl;
      insecure = true;
    } else {
      poolServiceUrl = poolServiceWaaSUrl;
      insecure = false;
    }

    try {
      poolClient = newPoolService(poolServiceUrl, apiKeyName, privateKey, insecure);
    } catch (Exception e) {
      throw new WaasException("initialize pool failed : ", e.getMessage());
    }
  }

  /**
   * Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
   * otherwise.
   */
  public Future<Pool> createPool(String displayName, String poolID) {
    return executor.submit(() -> {
      try {
        return poolClient.createPool(displayName, poolID);
      } catch (Exception e) {
        throw new WaasException("create pool failed : ", e.getMessage());
      }
    });
  }
}
