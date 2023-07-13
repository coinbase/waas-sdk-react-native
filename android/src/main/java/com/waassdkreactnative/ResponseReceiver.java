package com.waassdkreactnative;

import com.waassdkinternal.v1.ApiResponseReceiver;

/** A class to receive API responses across the gomobile bridge. */
public class ResponseReceiver implements ApiResponseReceiver {
  public String data;
  public Exception err;

  @Override
  public void returnValue(String data, Exception err) {
    this.data = data;
    this.err = err;
  }
}
