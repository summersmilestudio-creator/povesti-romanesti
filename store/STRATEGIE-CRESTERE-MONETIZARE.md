# Povești Românești — Strategie de creștere & monetizare
**Data analizei:** 15 mai 2026 · Bazat pe date reale AdMob (`admob-report.csv`) + cercetare piață

---

## 1. Diagnostic real (din AdMob, 15.05.2026)

| Metric | Valoare reală | Interpretare |
|---|---|---|
| Venit estimat / zi | **0,02 USD** | Practic pre-venit |
| eCPM observat | **0,77 USD** | Foarte mic (trafic RO tier-3 + doar banner/interstitial) |
| Solicitări | 51 | Volum minuscul → puțini useri |
| Afișări | 32 | interstitial_story 22 + banner_home 11 |
| Utilizatori activi zilnic | **~39** | Aici e adevărata problemă |
| Clicuri / CTR | 0 / 0,00% | Normal la volum mic |
| Unități anunț | 2 (banner + interstitial) | **Lipsește rewarded video** |

**Concluzia dură:** aplicația e cea mai bună *dintre ale tale*, dar în absolut e încă minusculă (~39 useri/zi, cenți/zi). 
Venit = `Useri × Sesiuni × Afișări/sesiune × eCPM`. Acum **toți** cei 4 factori sunt mici. 
Optimizarea reclamelor singură = tot cenți. **Pârghia #1 e CREȘTEREA numărului de useri**, apoi structura de monetizare.

---

## 2. Plan prioritizat după ROI (fă în ordinea asta)

### 🥇 PRIORITATE 1 — Diaspora românească (impact 3–10x, efort mic)
Românii din **Germania, UK, Italia, Austria, SUA, Spania** = trafic **tier-1**: eCPM de **3–5x** mai mare ca în RO, ȘI sunt un public disperat după conținut în limba română pentru copiii lor (școala de duminică, „să nu uite limba").
- Localizează listarea Google Play (aceeași descriere RO) cu **targetare pe țările cu diaspora mare**.
- Postează afișul (cel nou) în grupuri FB de **români din străinătate** (ex: „Români în Germania", „Mamici românce în UK") — sunt zeci, foarte active.
- Același conținut, de 3–5x mai mulți bani per user + audiență uriașă neexploatată.

### 🥈 PRIORITATE 2 — Adaugă REWARDED VIDEO (impact 3–5x pe monetizare, efort mediu)
Acum: doar banner (~0$ eCPM) + interstitial ($2,5–5 eCPM global).
Rewarded video = **$8–18 eCPM global, $15–30 tier-1** — de departe cel mai profitabil format.
Plasări naturale într-o app de povești:
- „🔓 Deblochează **30 min fără reclame**" — userul alege să vadă un clip.
- „🔊 Ascultă povestea cu **voce** — vezi un clip scurt înainte."
- „⭐ Deblochează **pachetul de povești premium**" (10 povești marcate premium).
- Adaugă și **rewarded interstitial** + **App Open ad** (1 la pornire la rece, max 1/sesiune).

### 🥉 PRIORITATE 3 — eCPM: mediere + toate formatele (impact 2–4x, efort mic)
- Activează **AdMob Mediation / Bidding** (mai multe rețele licitează → eCPM crește; acum „procentaj câștiguri 100%" = nu există competiție).
- Activează toate formatele, nu doar 2 unități.
- Reglează frecvența interstitial (acum 1 la 3 povești / 3 min — OK, dar testează 1 la 2).
- Țintă realistă: din **0,77$** → **2–4$ eCPM** pe RO, mult mai mult pe diaspora.

### PRIORITATE 4 — Retenție = mai multe sesiuni/user (impact 2–3x liniar pe venit)
- **Mod somn / playlist audio**: redă poveștile una după alta cu TTS (copilul adoarme, app rulează 20–40 min = multe afișări + lipicios).
- **Notificare „Povestea serii"** zilnic la 20:00 → revin zilnic.
- **Streak / progres citit** + Favorite vizibile.
- **Descarcă pentru offline** explicit (mașină, avion, fără net).

### PRIORITATE 5 — ASO (impact 1.5–2x pe descărcări organice, efort mic)
- Titlu cu cuvinte căutate: `Povești Românești – Basme audio pentru copii și familie` („audio" = diferențiatorul tău unic + se caută).
- Screenshots noi care arată **funcția AUDIO/voce** (hook-ul real) — nu doar liste de text.
- **Cere review în app** după a 3-a poveste citită (rating mare = ranking + conversie mai bună).
- Poveste nouă **săptămânal** → Google Play boost „actualizat recent" + motiv de revenire.

---

## 3. Monetizare secundară (mai târziu, la scară)

- **NU abonament ca principal.** Concurentul mare **HeyKids** (ANIMAJ, €0,99/lună sau €10,99/an, 3D animat, fără reclame, 14 limbi) domină nișa de abonament pe video animat. Nu te bate cu un studio finanțat pe terenul lor.
- **DA un IAP one-time ieftin**: „Fără reclame + Narațiune profesională" la **~15–20 RON o singură dată**. Convertește bine la app gratuită utilitară, nu cere conținut recurent. Reclamele rămân venitul principal, IAP-ul = bonus.
- **Diferențiere vs HeyKids**: tu ai textul **literar autentic** (Creangă, Ispirescu, Eminescu, Slavici — patrimoniu), gratuit, offline, pentru **toată familia/diaspora** — nu 3D pentru bebeluși. Mizează pe asta.

## 4. Produs — îmbunătățiri concrete
1. **Narațiune umană** pentru top 10 povești (TTS-ul e funcțional, dar voce reală = retenție + bază pentru IAP premium).
2. **Mod somn autoplay** (vezi Prioritate 4) — probabil cel mai mare câștig de engagement.
3. **Ilustrație pe poveste** (1 imagine/poveste) — crește timpul în app + calitate percepută.
4. **Poveste nouă/săptămână** din domeniu public (Slavici, Ispirescu — toți expirați >70 ani, legal OK).
5. Buton **Share** („Trimite povestea unui părinte") — creștere virală gratis.

---

## TL;DR — fă astea 3 acum
1. **Distribuie în grupuri FB de diaspora** + localizare Play pe țări tier-1 (gratis, 3–5x venit/user).
2. **Adaugă rewarded video** (banner→rewarded = 3–5x pe monetizare).
3. **Activează AdMob mediation** (gratis, 2–4x eCPM).

Restul (retenție, ASO, narațiune umană, IAP) = ordinea 4→7. La ~39 useri/zi, **creșterea bate orice optimizare** — fără useri, eCPM perfect tot înseamnă cenți.
