package com.example.flutter_base2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ⚡ Register native ad factories — `factoryId` phải match Dart:
        //    NativeAd(factoryId: 'nativeSmall' / 'nativeMedium' / 'nativeFull')
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeSmall",
            NativeAdFactorySmall(layoutInflater)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeMedium",
            NativeAdFactoryMedium(layoutInflater)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeFull",
            NativeAdFactoryFull(layoutInflater)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeSmall")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeMedium")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeFull")
    }
}
