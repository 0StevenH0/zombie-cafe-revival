package com.capcom.zombiecafeandroid.offline;

import android.content.Intent;
import android.os.Bundle;

import com.capcom.zombiecafeandroid.ZombieCafeAndroid;

/**
 * Completes toxin purchases locally. SmurfsBilling (the Activity
 * ZombieCafeAndroid.BuyToxin launches) calls this from onCreate and then
 * finishes, so the native shop sees the same Activity round trip a real
 * purchase produced while the credit goes through the game's own success
 * callback: boughtToxin -> PurchaseAndroidToxin -> ZombieCafe::GiveBoughtToxin.
 * Nothing is sent to Google Play, Amazon or any server.
 */
public final class OfflineStore {
    /** Product ids by purchase slot, as ZombieCafeAndroid.BuyToxin puts them in ItemName0. */
    static final String[] PRODUCTS = {
        "zc_50_toxin_3", "zc_125_toxin_2", "zc_350_toxin_2", "zc_800_toxin_2", "zc_2000_toxin_2",
    };

    private OfflineStore() {}

    public static void completePurchase(Intent intent) {
        try {
            String product = productFromIntent(intent);
            if (product == null) {
                int slot = ZombieCafeAndroid.purchaseSlot;
                if (slot >= 0 && slot < PRODUCTS.length) {
                    product = PRODUCTS[slot];
                }
            }
            if (product == null) {
                OfflineLog.w("purchase without a product id or slot; nothing granted", null);
                return;
            }
            OfflineLog.d("granting " + product);
            ZombieCafeAndroid.boughtToxin(product);
        } catch (Throwable t) {
            OfflineLog.w("purchase failed", t);
        }
    }

    private static String productFromIntent(Intent intent) {
        if (intent == null) {
            return null;
        }
        Bundle extras = intent.getExtras();
        if (extras == null) {
            return null;
        }
        String product = extras.getString("ItemName0");
        for (String known : PRODUCTS) {
            if (known.equals(product)) {
                return product;
            }
        }
        return null;
    }
}
