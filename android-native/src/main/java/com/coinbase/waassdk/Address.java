package com.coinbase.waassdk;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a derived address on a blockchain.
 */
public class Address {

  /**
   * The address resource-id
   */
  public final String name;

  /**
   * The blockchain address.
   */
  public final String address;
  /**
   * The key identifiers associated with this address.
   */
  public final List<String> mpcKeys;
  /**
   * The id of the associated wallet.
   */
  public final String wallet;

  public Address(String name, String address, List<String> keys, String wallet) {
    this.name = name;
    this.address = address;
    this.mpcKeys = keys;
    this.wallet = wallet;
  }

  private static List<String> toStringArray(JSONArray jsonArray) throws JSONException {
    List<String> stringList = new ArrayList<>();
    for (int i = 0; i < jsonArray.length(); i++) {
      stringList.add(jsonArray.getString(i));
    }
    return stringList;
  }

  public JSONArray stringListToJsonArray(List<String> stringList) {
    JSONArray jsonArray = new JSONArray();
    for (String s : stringList) {
      jsonArray.put(s);
    }
    return jsonArray;
  }

  public static Address fromJSON(JSONObject json) throws JSONException {
    return new Address(
      json.getString("Name"),
      json.getString("Address"),
      toStringArray(json.getJSONArray("MPCKeys")),
      json.getString("MPCWallet")
    );
  }

  public JSONObject toJSON() throws JSONException {
    JSONObject obj = new JSONObject();
    obj.put("Name", name);
    obj.put("Address", address);
    obj.put("MPCKeys", stringListToJsonArray(mpcKeys));
    obj.put("MPCWallet", wallet);
    return obj;
  }
}
