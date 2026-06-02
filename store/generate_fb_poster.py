# -*- coding: utf-8 -*-
"""
Afis FACEBOOK pentru "Povesti Romanesti" -- STIL "afis publicitate de site"
(identic cu D:\\Claude\\fb-ads-optimizer\\creative\\ad_site_shown.py):
fundal foto blurat+intunecat, telefon realist cu SCREENSHOT REAL al app,
headline heavy, subtitlu auriu, buton portocaliu CTA, brand jos.
Output: afis_fb_povesti_square.png (1080x1080, grupuri)
        afis_fb_povesti.png        (1080x1350, feed)
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE = os.path.dirname(os.path.abspath(__file__))
SHOT = os.path.join(BASE, "screenshot_1_stories.png")
ICON = os.path.join(BASE, "..", "assets", "app_icon.png")

F_HEAVY = "C:/Windows/Fonts/bahnschrift.ttf"
F_BOLD = "C:/Windows/Fonts/arialbd.ttf"
F_REG = "C:/Windows/Fonts/arial.ttf"

CREAM = (255, 248, 230)
GOLD = (255, 220, 130)
ORANGE = (230, 105, 70)


def load(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.truetype(F_BOLD, size)


def tw(draw, text, font):
    b = draw.textbbox((0, 0), text, font=font)
    return b[2] - b[0]


def cover_crop(img, w, h, top_pct=0.0):
    sw, sh = img.size
    sr, tr = sw / sh, w / h
    if sr > tr:
        nw = int(sw * h / sh)
        img = img.resize((nw, h), Image.LANCZOS)
        left = (nw - w) // 2
        return img.crop((left, 0, left + w, h))
    nh = int(sh * w / sw)
    img = img.resize((w, nh), Image.LANCZOS)
    top = int(nh * top_pct)
    if top + h > nh:
        top = nh - h
    return img.crop((0, top, w, top + h))


def make_brand_bg(w, h, blur=42, dark=0.52):
    """Fundal cald, on-brand: iconul app scalat+blurat (ca tehnica
    'foto blurata' din site-ad, dar cu asset propriu) + bokeh + darken."""
    base = Image.open(ICON).convert("RGB")
    img = cover_crop(base, w, h).resize(
        (w // 2, h // 2), Image.LANCZOS).resize((w, h), Image.LANCZOS)
    img = img.filter(ImageFilter.GaussianBlur(radius=blur))
    img = img.convert("RGBA")
    # bokeh cald
    bok = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bok)
    import random
    random.seed(9)
    for _ in range(13):
        r = random.randint(60, 190)
        x = random.randint(-40, w)
        y = random.randint(-40, h)
        a = random.randint(16, 40)
        bd.ellipse([x, y, x + r, y + r], fill=(255, 210, 150, a))
    img = Image.alpha_composite(img, bok.filter(
        ImageFilter.GaussianBlur(28)))
    img = Image.alpha_composite(
        img, Image.new("RGBA", (w, h), (16, 8, 28, int(255 * dark))))
    return img


def make_phone_mockup(screenshot_path, target_screen_w=380):
    ss = Image.open(screenshot_path).convert("RGB")
    sw, sh = ss.size
    ratio = target_screen_w / sw
    th = int(sh * ratio)
    ss = ss.resize((target_screen_w, th), Image.LANCZOS)
    bezel = 14
    fw = target_screen_w + bezel * 2
    fh = th + bezel * 2
    phone = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    d.rounded_rectangle([0, 0, fw, fh], radius=40, fill=(20, 22, 26, 255))
    mask = Image.new("L", (target_screen_w, th), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, target_screen_w, th], radius=24, fill=255)
    phone.paste(ss, (bezel, bezel), mask)
    nw, nh = 110, 26
    nx = (fw - nw) // 2
    d.rounded_rectangle([nx, 18, nx + nw, 18 + nh], radius=14,
                        fill=(8, 8, 12, 255))
    return phone


def add_drop_shadow(img, offset=(0, 16), blur=30, alpha=170):
    w, h = img.size
    pad = blur * 2
    canvas = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    sh = Image.new("RGBA", (w, h), (0, 0, 0, alpha))
    if img.mode == "RGBA":
        sh.putalpha(img.split()[3].point(lambda p: alpha if p > 0 else 0))
    canvas.paste(sh, (pad + offset[0], pad + offset[1]))
    canvas = canvas.filter(ImageFilter.GaussianBlur(blur))
    canvas.paste(img, (pad, pad), img)
    return canvas


def heavy_text(draw, xy, text, font, fill=CREAM):
    x, y = xy
    for dx, dy in [(2, 2), (3, 3)]:
        draw.text((x + dx, y + dy), text, font=font, fill=(0, 0, 0, 200))
    draw.text((x, y), text, font=font, fill=fill)


def cta_badge(draw, x, y, text, fsize=26, pad=20, hgt=54):
    f = load(F_BOLD, fsize)
    w = tw(draw, text, f) + pad * 2
    draw.rounded_rectangle([x, y, x + w, y + hgt], radius=hgt // 2,
                           fill=ORANGE)
    draw.text((x + pad, y + (hgt - fsize) // 2 - 2), text, font=f,
              fill=(255, 255, 255))
    return w


def link_note(draw, x, y, fsize=22, anchor_w=None):
    """'Link-ul e în primul comentariu' sub buton + chevron jos."""
    txt = "Link-ul e în primul comentariu"
    f = load(F_BOLD, fsize)
    t_w = tw(draw, txt, f)
    ch = int(fsize * 0.5)
    block_w = t_w
    x0 = x + (anchor_w - block_w) // 2 if anchor_w is not None else x
    draw.text((x0 + 2, y + 2), txt, font=f, fill=(0, 0, 0, 200))
    draw.text((x0, y), txt, font=f, fill=(248, 244, 252))
    # chevron jos centrat sub text
    cx = x0 + t_w // 2
    cy = y + fsize + int(fsize * 0.55)
    draw.polygon([(cx - ch, cy - ch * 0.7), (cx + ch, cy - ch * 0.7),
                  (cx, cy + ch * 0.5)], fill=(248, 244, 252))


# ----------- compozitia 1: 1080x1080 (telefon stanga, text dreapta) -----
def build_square():
    W = H = 1080
    bg = make_brand_bg(W, H, blur=44, dark=0.50)
    phone = make_phone_mockup(SHOT, target_screen_w=372)
    phone = add_drop_shadow(phone, offset=(0, 16), blur=30, alpha=175)
    pw, ph = phone.size
    px, py = 64, (H - ph) // 2
    bg.paste(phone, (px, py), phone)

    d = ImageDraw.Draw(bg)
    tx = px + pw + 46
    avail = W - tx - 46

    hf = load(F_HEAVY, 86)
    l1, l2 = "EL MAI VREA", "O POVESTE."
    while max(tw(d, l1, hf), tw(d, l2, hf)) > avail and hf.size > 46:
        hf = load(F_HEAVY, hf.size - 4)
    hy1 = 250
    hy2 = hy1 + hf.size + 6
    heavy_text(d, (tx, hy1), l1, hf)
    heavy_text(d, (tx, hy2), l2, hf)

    sf = load(F_BOLD, 30)
    sy = hy2 + hf.size + 26
    for i, s in enumerate(["Aplicația i-o citește",
                           "cu voce. Tu respiri."]):
        d.text((tx + 1, sy + i * 40 + 1), s, font=sf, fill=(0, 0, 0, 200))
        d.text((tx, sy + i * 40), s, font=sf, fill=GOLD)

    cy = sy + 110
    cw = cta_badge(d, tx, cy, "DESCARCĂ GRATUIT", fsize=26, hgt=56)
    link_note(d, tx, cy + 56 + 22, fsize=23, anchor_w=cw)

    bf = load(F_BOLD, 30)
    sm = load(F_REG, 22)
    d.text((tx, H - 132), "Povești Românești", font=bf,
           fill=(255, 255, 255))
    d.text((tx, H - 96), "60 de basme · Creangă, Ispirescu, Eminescu",
           font=sm, fill=(225, 235, 255))
    d.text((tx, H - 64), "gratuit pe Google Play", font=sm, fill=GOLD)

    out = os.path.join(BASE, "afis_fb_povesti_square.png")
    bg.convert("RGB").save(out, "PNG", quality=95)
    print("SAVED:", out, bg.size)


# ----------- compozitia 2: 1080x1350 (telefon sus, text jos) ------------
def build_portrait():
    W, H = 1080, 1350
    bg = make_brand_bg(W, H, blur=46, dark=0.52)
    sw = 352
    blur = 32
    phone = make_phone_mockup(SHOT, target_screen_w=sw)
    phone = add_drop_shadow(phone, offset=(0, 16), blur=blur, alpha=175)
    pw, ph = phone.size
    px = (W - pw) // 2
    py = 52
    bg.paste(phone, (px, py), phone)

    d = ImageDraw.Draw(bg)
    # baza vizibila reala a telefonului (pad-ul de umbra e transparent)
    ss_h = int(1920 * sw / 1080) + 28
    phone_bottom = py + blur + ss_h
    base_y = phone_bottom + 34

    hf = load(F_HEAVY, 92)
    l1, l2 = "EL MAI VREA", "O POVESTE."
    while max(tw(d, l1, hf), tw(d, l2, hf)) > W - 120 and hf.size > 56:
        hf = load(F_HEAVY, hf.size - 4)
    hy1 = base_y
    hy2 = hy1 + hf.size + 4
    heavy_text(d, (60, hy1), l1, hf)
    heavy_text(d, (60, hy2), l2, hf)

    sf = load(F_BOLD, 33)
    sy = hy2 + hf.size + 22
    s = "Aplicația i-o citește cu voce. Tu respiri."
    d.text((61, sy + 1), s, font=sf, fill=(0, 0, 0, 200))
    d.text((60, sy), s, font=sf, fill=GOLD)

    cy = sy + 56
    cw = cta_badge(d, 60, cy, "DESCARCĂ GRATUIT", fsize=30, hgt=64)
    link_note(d, 60, cy + 64 + 22, fsize=25, anchor_w=cw)

    bf = load(F_BOLD, 30)
    sm = load(F_REG, 22)
    fy = H - 96
    d.text((60, fy), "Povești Românești", font=bf, fill=(255, 255, 255))
    d.text((60, fy + 38),
           "60 de basme citite cu voce · gratuit pe Google Play",
           font=sm, fill=GOLD)

    out = os.path.join(BASE, "afis_fb_povesti.png")
    bg.convert("RGB").save(out, "PNG", quality=95)
    print("SAVED:", out, bg.size)


if __name__ == "__main__":
    build_square()
    build_portrait()
