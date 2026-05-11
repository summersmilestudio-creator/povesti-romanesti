# iOS — Submission App Store

**Status proiect**: cod Flutter complet, iOS folder configurat. Lipsesc: cont Apple Developer, AdMob iOS App ID, screenshot-uri iOS specifice.

## 1. Pre-rechizite (verifică tu)

- [ ] Cont **Apple Developer Program** activ sub `summer.smile.studio@gmail.com` (99 USD/an) — fără acesta, nu se poate publica
- [ ] Mac cu Xcode 15+ — Apple cere build și upload prin Xcode/Transporter
- [ ] Certificate iOS + Provisioning Profile pentru distribuire

> Dacă nu ai Mac fizic, alternative: **MacInCloud** (≈30 USD/lună), **MacStadium**, sau un Mac la prieten/internet café.

## 2. Bundle ID și AdMob iOS

În AdMob console (`admob.google.com`):

1. **Add app** → Platform: **iOS** → Bundle ID: `ro.povestiromanesti.app`
2. Notează **AdMob App ID iOS** (ex: `ca-app-pub-5549243085914479~XXXXXXXXXX`)
3. Creează 2 ad units iOS:
   - Banner — notează ID
   - Interstitial — notează ID

Apoi în cod, după ce ai ID-urile, actualizez `lib/services/ad_service.dart` să folosească ID-uri condiționate pe Platform:

```dart
import 'dart:io' show Platform;

static String get bannerAdUnitId =>
  Platform.isAndroid
    ? 'ca-app-pub-5549243085914479/3341750336'
    : 'ca-app-pub-5549243085914479/IOS_BANNER_ID';

static String get interstitialAdUnitId =>
  Platform.isAndroid
    ? 'ca-app-pub-5549243085914479/6783744852'
    : 'ca-app-pub-5549243085914479/IOS_INTERSTITIAL_ID';
```

În `ios/Runner/Info.plist` adaugă:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-5549243085914479~IOS_APP_ID</string>
<key>SKAdNetworkItems</key>
<array>
  <!-- AdMob SKAdNetworkItems — listă din docs Google -->
</array>
```

## 3. App Store Connect — listing

Path: `appstoreconnect.apple.com` → My Apps → +

- **Name**: Povești Românești
- **Primary Language**: Romanian
- **Bundle ID**: `ro.povestiromanesti.app` (creat în Developer Portal)
- **SKU**: `povesti-romanesti-001`
- **User Access**: Full Access

## 4. Texte ASC (copy-paste)

### Subtitle (max 30 chars)
```
Basme și legende românești
```

### Promotional Text (max 170 chars)
```
60 de povești din folclorul românesc — Creangă, Eminescu, Ispirescu, Slavici. Citire vocală, mod noapte, offline.
```

### Description (max 4000 chars) — același text ca pe Play Store (vezi PLAY_CONSOLE_RECLASIFICARE.md)

### Keywords (max 100 chars, separate prin virgulă)
```
povești,basme,legende,Creangă,Eminescu,Ispirescu,română,folclor,copii,familie,citire,carte
```

### Category
- Primary: **Books**
- Secondary: **Reference**

### Age Rating
- Răspunde la chestionar identic cu Play Console
- Rezultat țintit: **4+** sau **9+** (NU "Made for Kids")
- Important: NU bifa "Made for Kids" / Kids Category (echivalent iOS al "Designed for Families")

## 5. Screenshot-uri iOS necesare

App Store cere screenshot-uri pentru:

- **iPhone 6.7"** (1290×2796) — iPhone 15 Pro Max — 3-10 imagini
- **iPhone 6.5"** (1242×2688) — iPhone 11 Pro Max — 3-10 imagini  
- **iPad Pro 12.9"** (2048×2732) — opțional dar recomandat — 3-10 imagini

Pot genera screenshot-urile cu simulatorul iOS:
```bash
flutter run -d "iPhone 15 Pro Max"
# screenshots prin Cmd+S în simulator
```

Sau folosesc tool ca **screenshot.rocks** / **rotato** pentru mockup-uri.

## 6. Build și upload IPA

Pe Mac:
```bash
cd /path/to/PovestiRomanesti
flutter build ios --release
open ios/Runner.xcworkspace
```

În Xcode:
1. Selectează **Any iOS Device (arm64)**
2. **Product → Archive**
3. După archive: **Distribute App → App Store Connect → Upload**
4. Așteaptă procesarea în ASC (≈30 min)

## 7. App Review Information

În ASC → App Information:
- **Sign-in required**: No
- **Contact info**: nume, email, telefon (datele tale)
- **Notes**: 
  ```
  Aplicația conține 60 de povești tradiționale românești din domeniul public 
  (autori decedați înainte de 1925). Conține reclame AdMob non-personalizate. 
  Nu colectează date personale. Toate textele sunt în limba română.
  ```

## 8. Pricing

- **Price Tier**: 0 (Free)
- **Availability**: All territories sau doar Romania + Moldova + țări cu diaspora românească (IT, ES, UK, DE)

## 9. Submit for Review

Apple review durează **24-48 ore** în general, dar uneori 5-7 zile.

Probleme frecvente la respingere:
- Privacy policy URL nu funcționează → asigură-te că e public
- Screenshot-uri prea slabe sau cu watermarks → folosește mockup-uri profesionale
- App care nu pornește → testează în Xcode înainte de submit

## 10. După publicare

- App-ul va apărea pe App Store într-o zi
- Setează **App Store Search Ads** (Apple Search Ads) pentru keyword "basme românești" — buget mic, 3 EUR/zi
- Monitorizează ASC pentru rating și recenzii
