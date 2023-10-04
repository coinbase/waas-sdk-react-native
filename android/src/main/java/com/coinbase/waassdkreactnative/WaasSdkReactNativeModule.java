package com.coinbase.waassdkreactnative;

import android.content.Context;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.module.annotations.ReactModule;
import com.mpcmw.corekmsutils.ClientStatus;
import com.mpcmw.corekmsutils.SystemKeys;
import com.waassdkinternal.v1.AndroidCallbacks;

@ReactModule(name = WaasSdkReactNativeModule.NAME)
public class WaasSdkReactNativeModule extends ReactContextBaseJavaModule {
  public static final String NAME = "WaasSdkReactNative";
  public static Context context;

  public WaasSdkReactNativeModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.context = reactContext.getApplicationContext();
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

}
