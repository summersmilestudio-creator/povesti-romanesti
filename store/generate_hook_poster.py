# -*- coding: utf-8 -*-
"""
Afis MARKETING premium cu HOOK pentru "Povesti Romanesti" (ro.povestiromanesti.app)
Stil editorial/premium: tipografie serif, cadru auriu, compozitie aerisita.
Format: 1080x1350 (FB/IG feed) + 1080x1080 (grupuri FB).
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE = os.path.dirname(os.path.abspath(__file__))
ICON_CANDIDATES = [
    os.path.join(BASE, "..", "assets", "app_icon.png"),
    os.path.join(BASE, "icon-512.png"),
]


def font(names, size):
    for n in names:
        p = f"C:/Windows/Fonts/{n}"
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()


F_SERIF_B = ["georgiab.ttf", "timesbd.ttf"]          # titluri elegante
F_SERIF_I = ["georgiai.ttf", "timesi.ttf"]           # citate / autori
F_SERIF = ["georgia.ttf", "times.ttf"]
F_SANS_B = ["segoeuib.ttf", "arialbd.ttf"]           # accente
F_SANS_SB = ["seguisb.ttf", "segoeui.ttf"]           # subtitlu
F_SANS = ["segoeui.ttf", "arial.ttf"]

# Paleta premium (editorial storybook)
INK = (24, 15, 44)
PLUM = (96, 34, 86)
AMBER = (226, 142, 70)
CREAM = (250, 244, 234)
GOLD = (236, 198, 126)
GOLD_BRIGHT = (255, 216, 142)
LAV = (210, 196, 222)


def lerp(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(w, h):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / h
        if t < 0.5:
            c = lerp(INK, PLUM, t / 0.5)
        else:
            c = lerp(PLUM, AMBER, (t - 0.5) / 0.5)
        for x in range(w):
            px[x, y] = c
    return img


def vignette(img, strength=120):
    w, h = img.size
    ov = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(ov)
    d.ellipse([-w * 0.30, -h * 0.22, w * 1.30, h * 1.22], fill=255)
    ov = ov.filter(ImageFilter.GaussianBlur(220))
    dark = Image.new("RGB", (w, h), (0, 0, 0))
    inv = Image.eval(ov, lambda v: strength - int(v * strength / 255))
    img.paste(Image.composite(dark, img, inv))


def soft_glow(img, cx, cy, r, color, strength):
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    steps = 50
    for i in range(steps, 0, -1):
        rr = int(r * i / steps)
        a = int(strength * (1 - i / steps))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=color + (a,))
    ov = ov.filter(ImageFilter.GaussianBlur(50))
    img.alpha_composite(ov)


def star4(d, x, y, s, col, a):
    d.polygon([(x, y - s), (x + s * 0.22, y - s * 0.22),
               (x + s, y), (x + s * 0.22, y + s * 0.22),
               (x, y + s), (x - s * 0.22, y + s * 0.22),
               (x - s, y), (x - s * 0.22, y - s * 0.22)], fill=col + (a,))


def starfield(img):
    import random
    random.seed(11)
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    W, H = img.size
    for _ in range(90):
        x = random.randint(8, W - 8)
        y = random.randint(8, int(H * 0.55))
        rr = random.choice([1, 1, 2])
        a = random.randint(40, 130)
        d.ellipse([x, y, x + rr, y + rr], fill=(255, 255, 255, a))
    for _ in range(14):
        x = random.randint(40, W - 40)
        y = random.randint(30, int(H * 0.5))
        s = random.choice([5, 7, 9])
        star4(d, x, y, s, random.choice([GOLD_BRIGHT, (255, 255, 230)]),
              random.randint(110, 190))
    img.alpha_composite(ov)


def measure(d, txt, f):
    b = d.textbbox((0, 0), txt, font=f)
    return b[2] - b[0], b[3] - b[1], b[0], b[1]


def ctext(d, cx, y, txt, f, fill, shadow=None, so=2, ls=0):
    if ls:
        # letter-spacing manual
        widths = [d.textbbox((0, 0), ch, font=f)[2] - d.textbbox((0, 0), ch, font=f)[0] for ch in txt]
        total = sum(widths) + ls * (len(txt) - 1)
        x = cx - total / 2
        for ch, cw in zip(txt, widths):
            if shadow:
                d.text((x + so, y + so), ch, font=f, fill=shadow)
            d.text((x, y), ch, font=f, fill=fill)
            x += cw + ls
        return
    w, h, ox, oy = measure(d, txt, f)
    x = cx - w / 2 - ox
    if shadow:
        d.text((x + so, y + so), txt, font=f, fill=shadow)
    d.text((x, y), txt, font=f, fill=fill)


def gold_rule(d, cx, y, half=140):
    d.line([(cx - half, y), (cx + half, y)], fill=GOLD, width=2)
    for k, dx in ((0, 0), (1, -half), (1, half)):
        r = 4 if k == 0 else 3
        d.ellipse([cx + dx - r, y - r, cx + dx + r, y + r], fill=GOLD_BRIGHT)


def load_icon(size):
    for c in ICON_CANDIDATES:
        if os.path.exists(c):
            ic = Image.open(c).convert("RGBA").resize((size, size), Image.LANCZOS)
            mask = Image.new("L", (size, size), 0)
            ImageDraw.Draw(mask).rounded_rectangle([0, 0, size, size],
                                                   radius=int(size * 0.20), fill=255)
            ic.putalpha(mask)
            return ic
    return None


def build(W, H, fname, portrait=True):
    S = H / 1350.0
    img = gradient(W, H).convert("RGBA")
    vignette(img, 130)
    starfield(img)
    img2 = img.convert("RGBA")
    img = img2
    d = ImageDraw.Draw(img)
    CX = W // 2

    # --- cadru auriu premium ---
    m = int(34 * S)
    d.rounded_rectangle([m, m, W - m, H - m], radius=int(26 * S),
                        outline=(*GOLD, 150), width=2)
    d.rounded_rectangle([m + 8, m + 8, W - m - 8, H - m - 8],
                        radius=int(20 * S), outline=(*GOLD, 60), width=1)

    y = int(86 * S)

    # --- kicker ---
    f_k = font(F_SANS_B, int(24 * S))
    ctext(d, CX, y, "APLICAȚIA DE BASME ȘI LEGENDE ROMÂNEȘTI",
          f_k, GOLD, ls=int(6 * S))
    y += int(58 * S)

    # --- hook: citat serif ---
    f_q = font(F_SERIF_B, int(74 * S) if portrait else int(66 * S))
    ctext(d, CX, y, "„Hai, încă o poveste!”", f_q, CREAM,
          shadow=(0, 0, 0, 120), so=int(3 * S))
    y += int(96 * S)
    f_sub = font(F_SERIF_I, int(40 * S))
    ctext(d, CX, y, "...iar tu nu mai ai glas.", f_sub, LAV)
    y += int(70 * S)
    gold_rule(d, CX, y, int(120 * S))
    y += int(34 * S)
    f_turn = font(F_SANS_SB, int(36 * S))
    ctext(d, CX, y, "Lasă aplicația să citească pentru tine.", f_turn, GOLD_BRIGHT)

    # --- icon, prezentat premium ---
    isz = int(W * (0.265 if portrait else 0.24))
    iy = int(y + 76 * S)
    soft_glow(img, CX, iy + isz // 2, int(isz * 0.85), (255, 200, 120), 60)
    d = ImageDraw.Draw(img)
    ic = load_icon(isz)
    if ic:
        sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            [CX - isz // 2, iy + 14, CX + isz // 2, iy + isz + 14],
            radius=int(isz * 0.20), fill=(0, 0, 0, 130))
        img.alpha_composite(sh.filter(ImageFilter.GaussianBlur(22)))
        img.alpha_composite(ic, (CX - isz // 2, iy))
        d = ImageDraw.Draw(img)
        d.rounded_rectangle(
            [CX - isz // 2, iy, CX + isz // 2, iy + isz],
            radius=int(isz * 0.20), outline=(*GOLD, 180), width=2)

    # --- titlu ---
    y = iy + isz + int(40 * S)
    f_t = font(F_SERIF_B, int(82 * S) if portrait else int(74 * S))
    ctext(d, CX, y, "POVEȘTI ROMÂNEȘTI", f_t, CREAM,
          shadow=(0, 0, 0, 130), so=int(3 * S))
    y += int(98 * S)

    # --- subtitlu cu bullets aurii ---
    f_s = font(F_SANS_SB, int(31 * S))
    parts = ["60 de basme", "citite cu voce", "pentru toată familia"]
    seg_w = []
    for p in parts:
        w, _, ox, _ = measure(d, p, f_s)
        seg_w.append(w)
    dot = int(26 * S)
    total = sum(seg_w) + dot * (len(parts) - 1)
    x = CX - total / 2
    for i, p in enumerate(parts):
        d.text((x, y), p, font=f_s, fill=CREAM)
        x += seg_w[i]
        if i < len(parts) - 1:
            cxx = x + dot / 2
            d.ellipse([cxx - 3, y + int(16 * S), cxx + 3, y + int(22 * S)], fill=GOLD)
            x += dot
    y += int(62 * S)

    # --- linie feature elegant (un rand, separatoare aurii) ---
    f_f = font(F_SANS, int(26 * S))
    feats = ["Voce naturală RO", "Mod noapte", "Offline", "Gratuit"]
    fw = []
    for p in feats:
        w, _, ox, _ = measure(d, p, f_f)
        fw.append(w)
    sep = int(34 * S)
    total = sum(fw) + sep * (len(feats) - 1)
    x = CX - total / 2
    for i, p in enumerate(feats):
        d.text((x, y), p, font=f_f, fill=LAV)
        x += fw[i]
        if i < len(feats) - 1:
            cxx = x + sep / 2
            d.line([(cxx, y + int(4 * S)), (cxx, y + int(26 * S))], fill=(*GOLD, 150), width=2)
            x += sep
    y += int(60 * S)

    # --- autori (serif italic, muted) ---
    f_a = font(F_SERIF_I, int(28 * S))
    ctext(d, CX, y, "Creangă · Ispirescu · Eminescu · Slavici", f_a,
          (200, 184, 210))
    y += int(70 * S)

    # --- CTA premium tip Google Play ---
    bw = int(W * (0.78 if portrait else 0.66))
    bh = int(116 * S)
    bx = CX - bw // 2
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([bx, y + 10, bx + bw, y + bh + 10],
                                         radius=bh // 2, fill=(0, 0, 0, 140))
    img.alpha_composite(sh.filter(ImageFilter.GaussianBlur(18)))
    btn = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    bd = ImageDraw.Draw(btn)
    for i in range(bh):
        bd.line([(0, i), (bw, i)], fill=lerp((48, 200, 100), (20, 150, 74), i / bh))
    bmask = Image.new("L", (bw, bh), 0)
    ImageDraw.Draw(bmask).rounded_rectangle([0, 0, bw, bh], radius=bh // 2, fill=255)
    img.paste(btn, (bx, y), bmask)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([bx, y, bx + bw, y + bh], radius=bh // 2,
                        outline=(*GOLD_BRIGHT, 110), width=2)
    # badge play (patrat rotunjit alb + triunghi verde)
    ps = int(bh * 0.52)
    pxx = bx + int(34 * S)
    pyy = y + (bh - ps) // 2
    d.rounded_rectangle([pxx, pyy, pxx + ps, pyy + ps], radius=int(ps * 0.26),
                        fill=(255, 255, 255))
    tri = int(ps * 0.40)
    tcx = pxx + ps // 2 + int(ps * 0.04)
    tcy = pyy + ps // 2
    d.polygon([(tcx - tri * 0.5, tcy - tri * 0.62),
               (tcx - tri * 0.5, tcy + tri * 0.62),
               (tcx + tri * 0.66, tcy)], fill=(22, 156, 74))
    # text CTA
    f_c1 = font(F_SANS_B, int(36 * S))
    f_c2 = font(F_SANS_SB, int(23 * S))
    tx = pxx + ps + int(26 * S)
    region_cx = (tx + (bx + bw)) // 2
    ctext(d, region_cx, y + int(28 * S), "DESCARCĂ GRATUIT", f_c1, (255, 255, 255))
    ctext(d, region_cx, y + int(70 * S), "pe Google Play", f_c2, (228, 255, 238))
    y += bh + int(34 * S)

    # --- footer ---
    f_ft = font(F_SANS_SB, int(23 * S))
    ctext(d, CX, y, "Povești Românești   ·   Summer Smile", f_ft, (236, 214, 184))

    out = os.path.join(BASE, fname)
    img.convert("RGB").save(out, "PNG", quality=95)
    print("SAVED:", out, img.size)


if __name__ == "__main__":
    build(1080, 1350, "afis_hook_povesti.png", portrait=True)
    build(1080, 1080, "afis_hook_povesti_square.png", portrait=False)
