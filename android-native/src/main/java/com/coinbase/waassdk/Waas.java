package com.coinbase.waassdk;

import android.content.Context;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * A utility class for talking to several Waas services
 * at the same time. You likely do not want to use this, as
 * you should not be embedding your credentials in your app.
 */
public class Waas {

  // raw references to the underlying waas services.
  public final MPCSdk mpc;
  public final MPCKeyService keys;
  public final MPCWalletService wallets;
  public final PoolService pools;

  ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());

  public Waas(String apiKey, String privateKey, Context context, boolean isSimulator, String passcode) throws WaasException {
    mpc = new MPCSdk(context, isSimulator, executor);
    keys = new MPCKeyService(apiKey, privateKey, executor);
    wallets = new MPCWalletService(apiKey, privateKey, executor);
    pools = new PoolService(apiKey, privateKey, executor);

    // mpc needs to be bootstrapped once.
    mpc.bootstrapDevice(passcode);
  }
}
