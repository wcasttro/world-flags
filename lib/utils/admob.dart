import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMod {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;

  final String bannerIdAdMob;
  final String interstitialAdMob;

  AdMod({required this.bannerIdAdMob, required this.interstitialAdMob});

  void createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerIdAdMob,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isBannerAdLoaded = false;
          ad.dispose();
        },
        onAdOpened: (Ad ad) => log('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => log('$BannerAd onAdClosed.'),
      ),
      request: const AdRequest(),
    )..load();
  }

  Widget banner() {
    if (_bannerAd == null || !_isBannerAdLoaded) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdMob,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
