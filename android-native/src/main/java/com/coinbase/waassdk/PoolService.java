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
  // The URL of the PoolService.
  public static String poolServiceUrl = "https://api.developer.coinbase.com/waas/pools";

  // The handle to the Go PoolService client.
  com.waassdkinternal.v1.PoolService poolClient;
  ExecutorService executor;

  /**
   * Initializes the PoolService with the given Cloud API Key parameters. Resolves with the string "success" on success;
   * rejects with an error otherwise.
   */
  public PoolService(String apiKeyName, String privateKey, ExecutorService executor) throws WaasException {
    this.executor = executor;
    try {
      poolClient = newPoolService(poolServiceUrl, apiKeyName, privateKey);
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
