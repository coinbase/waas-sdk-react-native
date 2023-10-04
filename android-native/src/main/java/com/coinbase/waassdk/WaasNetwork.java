package com.coinbase.waassdk;

import androidx.annotation.NonNull;

/**
 * An opaque type for dealing with network names in Waas.
 */
public class WaasNetwork {
  private final String name;

  /**
   * An opaque representation of a network identifier,
   * to be instantiated from a call to the backend `ListNetworks` (or manually
   * if you know exactly what network you're looking for).
   *
   * @param networkString "networks/ethereum-goerli"
   * @return A WaasNetwork for use with the {@link MPCWalletService} api.
   */
  public static WaasNetwork fromNetworkString(String networkString) {
    return new WaasNetwork(networkString);
  }

  private WaasNetwork(final String text) {
    this.name = text;
  }

  @Override
  @NonNull
  public String toString() {
    return name;
  }
}
