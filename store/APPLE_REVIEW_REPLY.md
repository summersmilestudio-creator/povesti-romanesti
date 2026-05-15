# Reply pentru Apple Review — Submission 893c2310-36a4-4087-b2bf-08b76b3c3ed2

## Plasare în App Store Connect:
App Store Connect → My Apps → Povesti Romanesti → App Review → Reply

## Text reply (engleză):

---

Hello App Review Team,

Thank you for reviewing our app. Please find responses to each item below.

**Re: Guideline 2.1 — Where can we see the ads that the In-App Purchase is supposed to remove?**

The app uses Google AdMob to display two ad placements:

1. **Banner ad** — displayed at the bottom of the **Home screen** (story list). The banner appears below the list of stories. It is implemented in `lib/screens/home_screen.dart` (lines 195-204) and loaded via `AdService.createBannerAdIfAllowed()` in `lib/services/ad_service.dart`.

2. **Interstitial ad** — displayed automatically **after the user finishes reading 3 stories**, with a minimum interval of 3 minutes between interstitials to avoid disrupting the reading experience. Implemented in `lib/screens/reading_screen.dart` (line 137) via `AdService.showInterstitialAd()`.

The In-App Purchase `noads_monthly` (Remove Ads — Monthly, 25 RON) disables both ad placements for 32 days. When the user purchases or restores `noads_monthly`, `SubscriptionService.instance.noAds` becomes `true`, and `AdService.createBannerAdIfAllowed()` returns `null` while `AdService.showInterstitialAd()` returns immediately without showing.

**Reason ads may not have appeared during your review:** AdMob does not always serve ads in test environments with limited network traffic or new accounts. The AdMob unit IDs are live and verified in production:
- iOS Banner: `ca-app-pub-5549243085914479/1966190531`
- iOS Interstitial: `ca-app-pub-5549243085914479/8469009388`
- `GADApplicationIdentifier` is correctly set in `ios/Runner/Info.plist`.

To verify the ad placements, you can:
- Open the app → Home screen → scroll to the bottom of the story list → the banner ad container loads there.
- Read 3 different stories → the interstitial ad will trigger when finishing the 3rd story.

We can also enable AdMob test devices for the review team if needed — please share the test device IDs.

**Re: Guideline 2.1(b) — In-App Purchases not submitted for review**

We have now added the App Review screenshot for `noads_monthly` and submitted the In-App Purchase for review along with this updated binary.

**Re: Guideline 2.3.3 — Screenshots do not show the current version**

We have uploaded new screenshots that reflect the actual UI of version 2.0.1, showing:
- Home screen with the story list and welcome banner
- Story reading screen with night mode toggle
- Categories / favorites screen
- Settings screen with the Remove Ads subscription option

Thank you for your patience. Please let us know if you need additional information.

Best regards,
Lucian Apetrei
Summer Smile SRL

---

## Text reply (română — backup, dacă vrei să trimit în română):

Bună ziua,

Mulțumim pentru review. Vă răspund la fiecare punct:

**Guideline 2.1** — Reclamele sunt afișate prin Google AdMob în două locuri:
1. **Banner** în partea de jos a ecranului principal (lista poveștilor)
2. **Interstitial** după citirea a 3 povești (cu interval minim de 3 minute între interstitiale)

IAP `noads_monthly` (25 RON/lună) elimină ambele tipuri pentru 32 zile.

E posibil ca AdMob să nu fi servit reclame în review environment — putem activa test device IDs dacă ne furnizați ID-urile.

**Guideline 2.1(b)** — Am atașat App Review screenshot la IAP `noads_monthly` și l-am submis la review împreună cu binarul actualizat.

**Guideline 2.3.3** — Am încărcat screenshots noi care reflectă v2.0.1.

Mulțumim,
Lucian Apetrei
