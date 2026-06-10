package com.example.flutter_base_template

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

// ── Small (icon + title + body + CTA inline) ─────────────────

class NativeAdSmallFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val view = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_small, null) as NativeAdView

        val headline = view.findViewById<TextView>(R.id.ad_headline)
        val body     = view.findViewById<TextView>(R.id.ad_body)
        val icon     = view.findViewById<ImageView>(R.id.ad_app_icon)
        val cta      = view.findViewById<Button>(R.id.ad_call_to_action)

        view.headlineView      = headline
        view.bodyView          = body
        view.iconView          = icon
        view.callToActionView  = cta

        headline.text = nativeAd.headline
        body.text     = nativeAd.body
        cta.text      = nativeAd.callToAction
        nativeAd.icon?.drawable?.let { icon.setImageDrawable(it) }

        if (nativeAd.callToAction == null) cta.visibility = android.view.View.INVISIBLE

        view.setNativeAd(nativeAd)
        return view
    }
}

// ── Medium (image chiếm giữa, CTA dưới cùng) ─────────────────

class NativeAdMediumFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val view = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_medium, null) as NativeAdView

        val headline   = view.findViewById<TextView>(R.id.ad_headline)
        val advertiser = view.findViewById<TextView>(R.id.ad_advertiser)
        val body       = view.findViewById<TextView>(R.id.ad_body)
        val icon       = view.findViewById<ImageView>(R.id.ad_app_icon)
        val media      = view.findViewById<MediaView>(R.id.ad_media)
        val cta        = view.findViewById<Button>(R.id.ad_call_to_action)

        view.headlineView      = headline
        view.advertiserView    = advertiser
        view.bodyView          = body
        view.iconView          = icon
        view.mediaView         = media
        view.callToActionView  = cta

        headline.text   = nativeAd.headline
        advertiser.text = nativeAd.advertiser
        body.text       = nativeAd.body
        cta.text        = nativeAd.callToAction
        nativeAd.icon?.drawable?.let { icon.setImageDrawable(it) }

        if (nativeAd.callToAction == null) cta.visibility = android.view.View.INVISIBLE

        view.setNativeAd(nativeAd)
        return view
    }
}
