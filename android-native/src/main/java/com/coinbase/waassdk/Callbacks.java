package com.coinbase.waassdk;

import android.content.Context;

import androidx.annotation.NonNull;

import com.mpcmw.corekmsutils.ClientStatus;
import com.mpcmw.corekmsutils.SystemKeys;
import com.waassdkinternal.v1.AndroidCallbacks;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * A series of hooks into Android for supporting Waas-android.
 */
public class Callbacks {

  public static AndroidCallbacks get(Context context) {
    SystemKeys systemKeys = new SystemKeys(context);
    int gracePeriod = 0x7fffffff;
    return new AndroidCallbacks() {
      public long fGetAPIVersion() {
        return systemKeys.API_VERSION;
      }

      // Get the home dir of the device.
      public String fGetHomeDir() {
        return context.getFilesDir().getPath();
      }

      // Set the storage type.
      public void fSetStorageType(long storageType) {
        systemKeys.setStorageType((int) storageType);
      }

      // Get the client status.
      public String fGetClientStatus() throws Exception {
        return ClientStatus.GetClientStatus(context);
      }

      // Generate HMAC key.
      public long fGenHMAC(String tag, String jsonProtection) throws Exception {
        return systemKeys.generateHMAC(tag, jsonProtection, gracePeriod);
      }

      // Generate ECDSA key.
      public void fGenECDSA(String tag, String jsonProtection) throws Exception {
        systemKeys.generateECDSA(tag, jsonProtection, gracePeriod);
      }

      // Get public key ECDSA from alias.
      public byte[] fGetPublicECDSA(String tag) throws Exception {
        return systemKeys.getPublicECDSA(tag);
      }

      // Delete a key.
      public void fDelete(String tag) throws Exception {
        systemKeys.deleteKey(tag);
      }

      // Get derived HMAC.
      public byte[] fDeriveHMAC(String tag, byte[] seed) throws Exception {
        return systemKeys.deriveHMAC(tag, seed, " ", " ");
      }

      // Sign with ECDSA key.
      public byte[] fSignECDSA(String tag, byte[] data) throws Exception {
        return systemKeys.signECDSA(tag, data, " ", " ");
      }

      @Override
      public void fValidate(String tag) throws Exception {
        systemKeys.validateKey(tag);
      }

      // Open a session.
      public long fOpenSession(long op, String jsonProtection, String title, String subTitle, long timeout) throws Exception {
        return systemKeys.openSession(op, jsonProtection, title, subTitle, timeout);
      }

      // Close a session.
      public void fCloseSession(long handle) throws Exception {
        systemKeys.closeSession(handle);
      }

      // Derive HMAC from exists session.
      public byte[] fSessionDeriveHMAC(long handle, String tag, byte[] seed) throws Exception {
        return systemKeys.sessionDeriveHMAC(handle, tag, seed);
      }

      // Sign ECDSA from exists session.
      public byte[] fSessionSignECDSA(long handle, String tag, byte[] data) throws Exception {
        return systemKeys.sessionSignECDSA(handle, tag, data);
      }
    };
  }
}
