package com.example.flutter_base_template

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "nativeSmall", NativeAdSmallFactory(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "nativeMedium", NativeAdMediumFactory(context)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeSmall")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeMedium")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
