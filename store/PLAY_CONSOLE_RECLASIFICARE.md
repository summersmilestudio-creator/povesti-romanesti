# Play Console — Reclasificare Povești Românești (v2.0.0)

**Scop**: a debloca Google Ads (campanii și reclame în app prin AdMob normal) prin scoaterea aplicației din categoria "Kids/Family".

## 1. Target Audience and Content

Path în Play Console: **App content → Target audience and content → Manage**

- **Target age groups** — bifează doar: ✅ **13–17** și ✅ **18 and over**
  - DESELECTEAZĂ toate vârstele de sub 13: ❌ 5 and under, ❌ 6–8, ❌ 9–12
- **Appeals to children** — răspuns: **No**
- **Store listing presence in Designed for Families program** — răspuns: **No** (foarte important — scoate app-ul din programul Families)

> După ce salvezi: Google declanșează un review manual (3–7 zile lucrătoare). App-ul rămâne live cu varianta veche până la aprobare.

## 2. Content rating (PEGI / IARC) — re-aplicare chestionar

Path: **App content → Content rating → Start questionnaire**

- Category: **All other apps and games**
- Răspunde **No** la toate întrebările despre violență, drogări, conținut sexual, fricos, etc. (basme tradiționale — nu pică pe niciunul).
- Rezultat așteptat: **PEGI 3** sau **Everyone** — dar fără tag "Designed for Families".

## 3. Categorie principală pe Play Store

Path: **Store listing → Store settings → App category**

- **App category**: **Books & Reference**
  - (Era probabil "Education" sau "Kids" — schimbă acum)
- **Tags**: alege "Storytelling", "Cultural", "Romanian", "Folklore", "Reading"

## 4. Store Listing — texte noi (copy-paste)

Path: **Store listing → Main store listing**

### Titlu (max 30 caractere)
```
Povești Românești - Basme
```

### Descriere scurtă (max 80 caractere)
```
Basme și legende din folclorul românesc, citite frumos pentru toată familia.
```

### Descriere completă (max 4000 caractere)
```
📖 Povești Românești — colecția completă de basme, legende și fabule din folclorul românesc, accesibile gratuit pentru toată familia.

✨ ACUM CU 60 DE POVEȘTI

Patrimoniu cultural autentic românesc, repovestit cu grijă pentru cititorii moderni — copii, părinți, bunici. O bibliotecă digitală a poveștilor pe care le-am crescut cu toții.

📚 CE GĂSEȘTI ÎN APLICAȚIE

• Basme populare clasice de la Petre Ispirescu, Ion Creangă, Mihai Eminescu, Ioan Slavici — toți marii povestitori ai limbii române
• Legende istorice și mitologice (Meșterul Manole, Baba Dochia, Dragoș Vodă, Vlad Țepeș, Mioriță, Negru-Vodă și multe altele)
• Fabule cu morală (Grigore Alexandrescu, Alecu Donici)
• Povești cu animale, povești de noapte bună
• 5 categorii organizate clar pentru navigare ușoară

🎙️ CARACTERISTICI

✓ Citire vocală automată în limba română — apasă "Ascultă" și aplicația citește singură
✓ Mod noapte cu culori calde — pentru citit înainte de somn
✓ Mărime text reglabilă — confort vizual pentru orice vârstă
✓ Marcare favorite — păstrează poveștile preferate
✓ Funcționează offline — nu ai nevoie de internet după descărcare
✓ Fără colectare de date personale
✓ Citire pe pagini, cu progres vizibil

🇷🇴 PENTRU TOATĂ FAMILIA

Aplicația este pentru toți cei care iubesc literatura populară românească: părinți care citesc copiilor înainte de culcare, bunici care vor să-și amintească poveștile copilăriei, profesori, români din diaspora care vor să păstreze limba și tradiția, adulți pasionați de folclor.

Toate poveștile sunt din domeniul public — moștenire culturală liberă, repovestită cu respect pentru sursele originale.

📖 Descarcă acum și redescoperă moștenirea noastră culturală — povești care au format generații întregi de români.
```

## 5. Tagline și screenshot-uri

- **Feature graphic existent** (`store/feature_graphic.png`): verifică să nu mai conțină text "pentru copii". Dacă da, înlocuiește.
- Screenshot-uri în `store/`:
  - `screenshot_1_stories.png` — actualizează capture pentru a arăta noul subtitlu "Patrimoniu cultural românesc"
  - `screenshot_4_safe.png` — redenumește/regenerează ca să nu sugereze "safe for kids"

## 6. App content — Ads, In-app purchases

- **Ads**: răspuns **Yes** (conține reclame AdMob)
- **In-app purchases**: răspuns **No**
- **Subscriptions**: niciuna

## 7. Privacy policy

Path: **Store listing → Privacy policy URL**

Trebuie să existe un URL public. Sugestie text scurt (poți publica la `https://summer-smile.ro/povesti/privacy.html`):

```
POLITICA DE CONFIDENȚIALITATE — POVEȘTI ROMÂNEȘTI

Aplicația Povești Românești nu colectează date personale identificabile.

Date prelucrate:
- Preferințe utilizator (mod noapte, mărime text, favorite) — salvate doar local pe dispozitiv, niciodată trimise pe internet.
- Reclame Google AdMob — Google poate utiliza identificatori publicitari conform politicii proprii (https://policies.google.com/technologies/ads).

Nu solicităm permisiuni pentru: contacte, locație, cameră, microfon, fișiere personale.

Pentru întrebări: summer.smile.studio@gmail.com
Operator: Summer Smile, Constanța, România
Data actualizării: 11 mai 2026.
```

## 8. Upload AAB nou

- AAB va fi: `build/app/outputs/bundle/release/app-release.aab` (după `flutter build appbundle --release`)
- versionCode: 4 (sau mai mare decât 3, ultimul live)
- versionName: 2.0.0

Release notes (în "What's new in this version"):
```
Versiunea 2.0.0 — actualizare majoră:
• 60 de povești (de la 17) — basme populare, legende istorice, fabule
• 5 categorii noi: Basme populare, Povești cu animale, Povești de noapte bună, Legende românești, Fabule cu morală
• Autori clasici: Creangă, Eminescu, Ispirescu, Slavici, Alexandrescu, Donici
• Repoziționare către patrimoniu cultural pentru toată familia
• Optimizări la integrarea AdMob
• Îmbunătățiri vizuale și performanță
```

## 9. După publicare

1. Așteaptă review-ul Google (3–7 zile)
2. După aprobare, creează o **nouă campanie Google Ads** pentru app — acum va fi acceptată
3. Setează bugetul inițial mic (5–10 EUR/zi) ca să testezi conversia descărcărilor
4. Targetare: România, Republica Moldova, diaspora românească (Italia, Spania, UK, Germania)
