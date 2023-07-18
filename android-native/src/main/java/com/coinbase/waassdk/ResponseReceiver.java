package com.coinbase.waassdk;

import com.waassdkinternal.v1.ApiResponseReceiver;

/**
 * A class to receive API responses across the gomobile bridge.
 *  This class exists because `gomobile` has trouble returning (string, error)
 *  across the go boundary on some platforms.
 */
public class ResponseReceiver implements ApiResponseReceiver {
  public String data;
  public Exception err;

  @Override
  public void returnValue(String data, Exception err) {
    this.data = data;
    this.err = err;
  }

  public String get() throws Exception {
    if (this.err != null) {
      throw this.err;
    }
    return data;
  }
}
