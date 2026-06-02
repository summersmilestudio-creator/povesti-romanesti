# Ghid — Deblocare povești (0,99 lei)

Modelul: **primele 7 povești gratuite**, restul (toate cele
60+ basme și legende) se deblochează printr-o **singură plată**
non-consumabilă, **0,99 lei, pentru totdeauna** (fără abonament).

Codul folosește produsul cu ID-ul exact:

```
unlock_all_stories
```

⚠️ **Prețul NU se setează din cod.** Aplicația afișează prețul real
configurat în magazin. În cod există doar un text de rezervă („0,99 lei")
folosit doar dacă magazinul nu răspunde. Trebuie să creezi produsul în
ambele console, cu același ID, la prețul 0,99 RON.

---

## 1. Google Play Console (prioritar — app-ul e LIVE pe Play)

1. Play Console → aplicația **Povești Românești** → meniul stânga
   **Monetizare → Produse → Produse în aplicație**.
2. **Creează produs**.
   - **ID produs:** `unlock_all_stories` (exact, nu se mai poate schimba).
   - **Nume:** `Deblochează toate poveștile`
   - **Descriere:** `Deblochează toate basmele și legendele, pentru
     totdeauna. O singură plată, fără abonament.`
3. **Preț:** setează **0,99 RON**.
   - România e pe lista piețelor „sub-dolar" Google, deci 0,99 RON ar
     trebui să fie acceptat. Dacă Play Console refuză (sub minimul
     curent), alege **cel mai mic preț permis** pe care îl arată Google
     (aplicația va afișa automat acel preț).
4. **Activează** produsul (status „Activ"). Fără asta nu apare în app.
5. Produsul devine disponibil în app după ce există o versiune (chiar și
   în testare internă) cu noua versiune urcată. Versiune nouă: **2.3.1+9**.

## 2. App Store Connect (când iOS iese din TestFlight)

1. App Store Connect → app **Povești Romanesti - Basme**
   (ASC App ID `6768338008`) → **Achiziții în aplicație**.
2. **Tip:** „Non-consumabil". **ID produs:** `unlock_all_stories`.
3. Nume afișat + descriere (la fel ca mai sus).
4. **Preț:** Apple lucrează cu „puncte de preț", nu sumă liberă.
   Dacă 0,99 RON nu există ca punct de preț, alege **cel mai mic punct
   de preț disponibil** (cel mai apropiat de 0,99 lei). Aplicația
   afișează automat exact prețul ales aici.
5. Adaugă o captură de ecran pentru review și trimite produsul la
   aprobare odată cu versiunea aplicației.

---

## Verificare în app

- Primele **7** povești se deschid normal (gratuit).
- A 8-a și restul afișează lacăt → la atingere apare dialogul de
  deblocare cu prețul din magazin (0,99 lei).
- După plată: toate poveștile deblocate, pentru totdeauna.
- „Restaurează" (în dialog și în Setări) readuce achiziția pe alt
  dispozitiv / după reinstalare.

> Numărul de povești gratuite se schimbă dintr-o singură constantă:
> `kFreeStoryCount` în `lib/data/stories.dart`.
