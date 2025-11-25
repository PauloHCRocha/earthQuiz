//
//  BannerAdView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-25.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    // Use Google's test ad unit ID - replace with your own after setting up AdMob
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No need to update
    }
}

// Preview wrapper for SwiftUI previews
struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAdView()
            .frame(height: 50)
            .background(Color.gray.opacity(0.2))
    }
}
