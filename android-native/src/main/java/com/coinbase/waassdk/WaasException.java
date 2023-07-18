package com.coinbase.waassdk;

/**
 * A wrapped-exception propagated by Waas, containing the
 * portion of the system which broke.
 */
public class WaasException extends Exception {
  private final String errorType;
  public WaasException(String errorType, String errorMessage) {
    super(errorMessage);
    this.errorType = errorType;
  }

  public String getErrorType() {
    return errorType;
  }

  @Override
  public String toString() {
    return "CustomException of type " + errorType + " occurred: " + getMessage();
  }
}
