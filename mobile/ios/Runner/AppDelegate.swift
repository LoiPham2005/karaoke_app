import Flutter
import UIKit
import GoogleMaps
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAWO_lTAsjzDAC6Lml3W0qy0Dg-K1CtsmU")
    GeneratedPluginRegistrant.register(with: self)

    let registry = self as! FlutterPluginRegistry
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      registry, factoryId: "nativeSmall", nativeAdFactory: NativeAdSmallFactory()
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      registry, factoryId: "nativeMedium", nativeAdFactory: NativeAdMediumFactory()
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
