import google_mobile_ads
import GoogleMobileAds
import UIKit

// ── Small (icon + title + body + CTA inline) ──────────────────

class NativeAdSmallFactory: FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {
        let view = NativeAdSmallView()
        view.populate(nativeAd: nativeAd)
        return view
    }
}

class NativeAdSmallView: GADNativeAdView {
    private let iconView_   = UIImageView()
    private let headlineView_ = UILabel()
    private let bodyView_   = UILabel()
    private let ctaButton   = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setup() {
        backgroundColor = .white

        iconView_.contentMode = .scaleAspectFill
        iconView_.layer.cornerRadius = 6
        iconView_.clipsToBounds = true
        iconView_.translatesAutoresizingMaskIntoConstraints = false

        headlineView_.font = .boldSystemFont(ofSize: 13)
        headlineView_.textColor = .label
        headlineView_.numberOfLines = 1
        headlineView_.translatesAutoresizingMaskIntoConstraints = false

        bodyView_.font = .systemFont(ofSize: 11)
        bodyView_.textColor = .secondaryLabel
        bodyView_.numberOfLines = 2
        bodyView_.translatesAutoresizingMaskIntoConstraints = false

        ctaButton.backgroundColor = UIColor(red: 0.1, green: 0.45, blue: 0.91, alpha: 1)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        ctaButton.layer.cornerRadius = 6
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.isUserInteractionEnabled = false

        let textStack = UIStackView(arrangedSubviews: [headlineView_, bodyView_])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [iconView_, textStack, ctaButton])
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            iconView_.widthAnchor.constraint(equalToConstant: 40),
            iconView_.heightAnchor.constraint(equalToConstant: 40),
            ctaButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            ctaButton.heightAnchor.constraint(equalToConstant: 36),
        ])

        iconView = iconView_
        headlineView = headlineView_
        bodyView = bodyView_
        callToActionView = ctaButton
    }

    func populate(nativeAd: GADNativeAd) {
        headlineView_.text = nativeAd.headline
        bodyView_.text     = nativeAd.body
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        iconView_.image    = nativeAd.icon?.image
        self.nativeAd      = nativeAd
    }
}

// ── Medium (image chiếm giữa, CTA dưới cùng) ──────────────────

class NativeAdMediumFactory: FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {
        let view = NativeAdMediumView()
        view.populate(nativeAd: nativeAd)
        return view
    }
}

class NativeAdMediumView: GADNativeAdView {
    private let iconView_       = UIImageView()
    private let headlineView_   = UILabel()
    private let advertiserView_ = UILabel()
    private let mediaView_      = GADMediaView()
    private let bodyView_       = UILabel()
    private let ctaButton       = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setup() {
        backgroundColor = .white

        iconView_.contentMode = .scaleAspectFill
        iconView_.layer.cornerRadius = 6
        iconView_.clipsToBounds = true
        iconView_.translatesAutoresizingMaskIntoConstraints = false

        headlineView_.font = .boldSystemFont(ofSize: 14)
        headlineView_.textColor = .label
        headlineView_.numberOfLines = 1
        headlineView_.translatesAutoresizingMaskIntoConstraints = false

        advertiserView_.font = .systemFont(ofSize: 11)
        advertiserView_.textColor = .secondaryLabel
        advertiserView_.translatesAutoresizingMaskIntoConstraints = false

        mediaView_.translatesAutoresizingMaskIntoConstraints = false
        mediaView_.contentMode = .scaleAspectFill

        bodyView_.font = .systemFont(ofSize: 12)
        bodyView_.textColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1)
        bodyView_.numberOfLines = 2
        bodyView_.translatesAutoresizingMaskIntoConstraints = false

        ctaButton.backgroundColor = UIColor(red: 0.1, green: 0.45, blue: 0.91, alpha: 1)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        ctaButton.layer.cornerRadius = 8
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.isUserInteractionEnabled = false

        let titleStack = UIStackView(arrangedSubviews: [headlineView_, advertiserView_])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [iconView_, titleStack])
        headerStack.axis = .horizontal
        headerStack.spacing = 10
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [headerStack, mediaView_, bodyView_, ctaButton])
        mainStack.axis = .vertical
        mainStack.spacing = 0
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            iconView_.widthAnchor.constraint(equalToConstant: 36),
            iconView_.heightAnchor.constraint(equalToConstant: 36),
            // mediaView chiếm phần còn lại
            mediaView_.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            ctaButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        mainStack.setCustomSpacing(10, after: headerStack)
        mainStack.setCustomSpacing(8, after: mediaView_)
        mainStack.setCustomSpacing(8, after: bodyView_)

        iconView = iconView_
        headlineView = headlineView_
        advertiserView = advertiserView_
        mediaView = mediaView_
        bodyView = bodyView_
        callToActionView = ctaButton
    }

    func populate(nativeAd: GADNativeAd) {
        headlineView_.text   = nativeAd.headline
        advertiserView_.text = nativeAd.advertiser
        bodyView_.text       = nativeAd.body
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        iconView_.image      = nativeAd.icon?.image
        mediaView_.mediaContent = nativeAd.mediaContent
        self.nativeAd        = nativeAd
    }
}
