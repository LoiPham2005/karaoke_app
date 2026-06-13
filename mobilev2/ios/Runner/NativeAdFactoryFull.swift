import Flutter
import GoogleMobileAds
import UIKit
import google_mobile_ads

/// Native ad factory FULL-SCREEN — MediaView fill toàn bộ space còn lại,
/// text + CTA dồn xuống đáy. Render khi
/// `NativeAd(factoryId: 'nativeFull', ...)` được gọi từ Dart.
///
/// XIB: `NativeAdFullView.xib`
class NativeAdFactoryFull: FLTNativeAdFactory {

    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {
        guard let nibObjects = Bundle.main.loadNibNamed(
            "NativeAdFullView", owner: nil, options: nil),
              let adView = nibObjects.first as? GADNativeAdView
        else {
            return nil
        }

        (adView.headlineView as? UILabel)?.text = nativeAd.headline

        if let body = nativeAd.body {
            (adView.bodyView as? UILabel)?.text = body
            adView.bodyView?.isHidden = false
        } else {
            adView.bodyView?.isHidden = true
        }

        if let cta = nativeAd.callToAction {
            (adView.callToActionView as? UIButton)?.setTitle(cta, for: .normal)
            adView.callToActionView?.isHidden = false
        } else {
            adView.callToActionView?.isHidden = true
        }

        if let icon = nativeAd.icon?.image {
            (adView.iconView as? UIImageView)?.image = icon
            adView.iconView?.isHidden = false
        } else {
            adView.iconView?.isHidden = true
        }

        if let advertiser = nativeAd.advertiser {
            (adView.advertiserView as? UILabel)?.text = advertiser
            adView.advertiserView?.isHidden = false
        } else {
            adView.advertiserView?.isHidden = true
        }

        adView.callToActionView?.isUserInteractionEnabled = false
        adView.nativeAd = nativeAd

        return adView
    }
}
