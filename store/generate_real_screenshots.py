"""Generează screenshots iOS care reflectă UI-ul real v2.0.1
   Sizes obligatorii Apple:
   - iPhone 6.7" (1290 x 2796)
   - iPad 13" (2064 x 2752)
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_IPHONE = os.path.join(SRC_DIR, "ios_screenshots_v2")
OUT_IPAD = os.path.join(SRC_DIR, "ipad_screenshots_v2")
os.makedirs(OUT_IPHONE, exist_ok=True)
os.makedirs(OUT_IPAD, exist_ok=True)

# Culori (din lib/theme.dart)
CREAM = (255, 248, 240)
WARM_BROWN = (74, 55, 40)
LIGHT_BROWN = (107, 83, 68)
FOREST_GREEN = (45, 95, 45)
GOLDEN = (212, 165, 116)
LIGHT_GOLDEN = (232, 201, 155)
SOFT_PINK = (245, 225, 208)
CARD_BG = (255, 243, 230)

NIGHT_BG = (44, 36, 22)
NIGHT_CARD = (61, 50, 38)
NIGHT_TEXT = (232, 213, 192)
NIGHT_ACCENT = (212, 165, 116)


def load_font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for f in candidates:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def load_emoji_font(size):
    candidates = [
        "C:/Windows/Fonts/seguiemj.ttf",
        "C:/Windows/Fonts/seguisym.ttf",
    ]
    for f in candidates:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return load_font(size)


def rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle([x1, y1, x2, y2], radius=radius,
                           fill=fill, outline=outline, width=width)


def gradient_box(img, xy, color_top, color_bottom):
    x1, y1, x2, y2 = xy
    w, h = x2 - x1, y2 - y1
    grad = Image.new("RGB", (w, h), color_top)
    d = ImageDraw.Draw(grad)
    for y in range(h):
        r = color_top[0] + (color_bottom[0] - color_top[0]) * y // h
        g = color_top[1] + (color_bottom[1] - color_top[1]) * y // h
        b = color_top[2] + (color_bottom[2] - color_top[2]) * y // h
        d.line([(0, y), (w, y)], fill=(r, g, b))
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, w, h], radius=40, fill=255)
    img.paste(grad, (x1, y1), mask)


def draw_status_bar(draw, w, dark=False):
    color = NIGHT_TEXT if dark else WARM_BROWN
    f = load_font(28, bold=True)
    draw.text((50, 28), "9:41", font=f, fill=color)
    fi = load_emoji_font(28)
    draw.text((w - 220, 28), "📶 📡 🔋", font=fi, fill=color)


def screenshot_home(w, h, ipad=False):
    img = Image.new("RGB", (w, h), CREAM)
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw, w)

    # Header
    pad_x = 80 if ipad else 50
    f_emoji = load_emoji_font(110 if ipad else 80)
    f_title = load_font(78 if ipad else 56, bold=True)
    f_sub = load_font(44 if ipad else 34)

    draw.text((pad_x, 130), "📖", font=f_emoji, fill=WARM_BROWN)
    title_x = pad_x + (130 if ipad else 100)
    draw.text((title_x, 140), "Povești Românești",
              font=f_title, fill=WARM_BROWN)
    draw.text((title_x, 230 if ipad else 210),
              "Patrimoniu cultural românesc",
              font=f_sub, fill=LIGHT_BROWN)

    # Welcome banner gradient
    banner_y1 = 330 if ipad else 300
    banner_y2 = banner_y1 + (380 if ipad else 320)
    gradient_box(img, (pad_x, banner_y1, w - pad_x, banner_y2),
                 (240, 220, 190), SOFT_PINK)
    draw_inner = ImageDraw.Draw(img)
    rounded_rect(draw_inner, (pad_x, banner_y1, w - pad_x, banner_y2),
                 40, outline=GOLDEN, width=3)

    f_banner_title = load_font(56 if ipad else 42, bold=True)
    f_banner_body = load_font(40 if ipad else 30)
    draw_inner.text((pad_x + 40, banner_y1 + 40),
                    "A fost odată ca niciodată... ✨",
                    font=f_banner_title, fill=FOREST_GREEN)
    body_text = "17 basme și legende din folclorul\nromânesc te așteaptă."
    if ipad:
        body_text = "17 basme și legende din folclorul românesc te așteaptă.\nAlege o poveste și descoperă moștenirea noastră."
    draw_inner.multiline_text((pad_x + 40, banner_y1 + 130),
                              body_text,
                              font=f_banner_body, fill=WARM_BROWN, spacing=10)

    # Section header
    sec_y = banner_y2 + 70
    f_sec = load_font(56 if ipad else 42, bold=True)
    draw_inner.text((pad_x, sec_y), "Toate poveștile",
                    font=f_sec, fill=WARM_BROWN)

    # Story cards
    stories = [
        ("🐐", "Capra cu trei iezi", "Ion Creangă"),
        ("🤴", "Făt-Frumos din lacrimă", "Mihai Eminescu"),
        ("🍎", "Prâslea cel voinic", "Petre Ispirescu"),
        ("🦅", "Greuceanu", "Petre Ispirescu"),
        ("🐴", "Harap-Alb", "Ion Creangă"),
        ("🐷", "Povestea porcului", "Ion Creangă"),
    ]
    if ipad:
        stories = stories + [
            ("👰", "Ileana Cosânzeana", "Folclor"),
            ("💰", "Punguța cu doi bani", "Ion Creangă"),
        ]

    card_y = sec_y + (100 if ipad else 80)
    card_h = 220 if ipad else 170
    card_gap = 35 if ipad else 28
    f_card_title = load_font(50 if ipad else 38, bold=True)
    f_card_author = load_font(36 if ipad else 28)
    f_card_emoji = load_emoji_font(80 if ipad else 60)

    for emoji, title, author in stories:
        cx1, cx2 = pad_x, w - pad_x
        rounded_rect(draw_inner, (cx1, card_y, cx2, card_y + card_h),
                     30, fill=CARD_BG)
        draw_inner.line([(cx1 + 8, card_y + 20),
                         (cx1 + 8, card_y + card_h - 20)],
                        fill=GOLDEN, width=8)
        draw_inner.text((cx1 + 50, card_y + (60 if ipad else 50)),
                        emoji, font=f_card_emoji, fill=WARM_BROWN)
        draw_inner.text((cx1 + 170, card_y + 35),
                        title, font=f_card_title, fill=WARM_BROWN)
        draw_inner.text((cx1 + 170, card_y + (115 if ipad else 95)),
                        author, font=f_card_author, fill=LIGHT_BROWN)
        # Heart icon
        f_heart = load_emoji_font(50 if ipad else 38)
        draw_inner.text((cx2 - 90, card_y + (75 if ipad else 60)),
                        "🤍", font=f_heart, fill=GOLDEN)
        card_y += card_h + card_gap

    # Banner ad (AdMob placeholder)
    ad_y = h - (220 if ipad else 200)
    rounded_rect(draw_inner, (pad_x, ad_y, w - pad_x, ad_y + 130),
                 20, fill=(245, 235, 220), outline=GOLDEN, width=2)
    f_ad = load_font(36 if ipad else 28, bold=True)
    f_ad_sub = load_font(28 if ipad else 22)
    draw_inner.text((pad_x + 30, ad_y + 25),
                    "Ad · Sponsored", font=f_ad_sub, fill=LIGHT_BROWN)
    draw_inner.text((pad_x + 30, ad_y + 60),
                    "Reclamă · AdMob Banner", font=f_ad, fill=WARM_BROWN)

    # Bottom nav
    nav_y = h - 130
    draw_inner.rectangle([0, nav_y, w, h], fill=CREAM)
    draw_inner.line([0, nav_y, w, nav_y], fill=GOLDEN, width=2)
    nav_items = [("📖", "Povești", True),
                 ("⭐", "Favorite", False),
                 ("⚙️", "Setări", False)]
    nav_w = w // len(nav_items)
    f_nav = load_font(28 if ipad else 22)
    f_nav_emoji = load_emoji_font(50 if ipad else 38)
    for i, (e, lbl, active) in enumerate(nav_items):
        cx = nav_w * i + nav_w // 2
        c = FOREST_GREEN if active else LIGHT_BROWN
        draw_inner.text((cx - 25, nav_y + 20), e,
                        font=f_nav_emoji, fill=c)
        bbox = draw_inner.textbbox((0, 0), lbl, font=f_nav)
        tw = bbox[2] - bbox[0]
        draw_inner.text((cx - tw // 2, nav_y + 75), lbl,
                        font=f_nav, fill=c)

    return img


def screenshot_reading(w, h, ipad=False, dark=False):
    bg = NIGHT_BG if dark else CREAM
    text_color = NIGHT_TEXT if dark else WARM_BROWN
    sub_color = NIGHT_TEXT if dark else LIGHT_BROWN
    card_bg = NIGHT_CARD if dark else CARD_BG
    accent = NIGHT_ACCENT if dark else FOREST_GREEN

    img = Image.new("RGB", (w, h), bg)
    draw = ImageDraw.Draw(img)
    draw_status_bar(draw, w, dark=dark)

    pad_x = 80 if ipad else 50
    # Back button + title
    f_back = load_emoji_font(48 if ipad else 36)
    draw.text((pad_x, 130), "←", font=load_font(60 if ipad else 44, bold=True),
              fill=text_color)
    f_title = load_font(60 if ipad else 44, bold=True)
    draw.text((pad_x + 90, 135), "Capra cu trei iezi",
              font=f_title, fill=text_color)
    f_meta = load_font(36 if ipad else 28)
    draw.text((pad_x + 90, 210 if ipad else 195),
              "Ion Creangă · Pagina 1 / 5",
              font=f_meta, fill=sub_color)

    # Reading card
    card_y = 320 if ipad else 290
    card_h = h - card_y - (300 if ipad else 280)
    rounded_rect(draw, (pad_x, card_y, w - pad_x, card_y + card_h),
                 35, fill=card_bg)

    # Emoji header
    f_em = load_emoji_font(180 if ipad else 130)
    draw.text((w // 2 - 80, card_y + 50), "🐐", font=f_em, fill=text_color)

    # Body text
    f_body = load_font(48 if ipad else 36)
    text = (
        "A fost odată ca niciodată o capră\n"
        "cu trei iezi. Capra îi iubea foarte\n"
        "mult pe iezișorii ei.\n\n"
        "Într-o zi, capra trebuia să plece\n"
        "la piață să cumpere mâncare.\n\n"
        "— Dragii mei, le spuse capra, eu\n"
        "plec, dar voi să nu deschideți\n"
        "ușa la nimeni! Lupul cel rău umblă\n"
        "prin pădure și vrea să vă mănânce."
    )
    if ipad:
        text = (
            "A fost odată ca niciodată o capră cu trei iezi.\n"
            "Capra îi iubea foarte mult pe iezișorii ei.\n\n"
            "Într-o zi, capra trebuia să plece la piață să\n"
            "cumpere mâncare.\n\n"
            "— Dragii mei, le spuse capra, eu plec, dar voi\n"
            "să nu deschideți ușa la nimeni! Lupul cel rău\n"
            "umblă prin pădure și vrea să vă mănânce.\n\n"
            "Iezii au promis că vor fi cuminți. Capra a plecat."
        )
    draw.multiline_text((pad_x + 60, card_y + (280 if ipad else 220)),
                        text, font=f_body, fill=text_color, spacing=12)

    # Controls at bottom
    ctrl_y = card_y + card_h + 40
    f_ctrl = load_font(40 if ipad else 30, bold=True)
    btns = [("◀ Înapoi", LIGHT_BROWN if not dark else NIGHT_TEXT),
            ("Pagina următoare ▶", accent)]
    btn_w = (w - 2 * pad_x - 40) // 2
    for i, (lbl, c) in enumerate(btns):
        bx1 = pad_x + i * (btn_w + 40)
        rounded_rect(draw, (bx1, ctrl_y, bx1 + btn_w, ctrl_y + 110),
                     30, fill=c if i == 1 else card_bg,
                     outline=c if i == 0 else None, width=3)
        bbox = draw.textbbox((0, 0), lbl, font=f_ctrl)
        tw = bbox[2] - bbox[0]
        draw.text((bx1 + btn_w // 2 - tw // 2, ctrl_y + 35),
                  lbl, font=f_ctrl,
                  fill=(255, 255, 255) if i == 1 else c)

    # Bottom controls (night mode, font size, favorite)
    bc_y = ctrl_y + 160
    icons = [("🌙" if not dark else "☀️", "Mod noapte" if not dark else "Mod zi"),
             ("🔤", "Mărime text"),
             ("🤍", "Favorit")]
    f_ic = load_emoji_font(60 if ipad else 44)
    f_ic_lbl = load_font(32 if ipad else 24)
    ic_w = (w - 2 * pad_x) // 3
    for i, (e, lbl) in enumerate(icons):
        cx = pad_x + ic_w * i + ic_w // 2
        draw.text((cx - 30, bc_y), e, font=f_ic, fill=text_color)
        bbox = draw.textbbox((0, 0), lbl, font=f_ic_lbl)
        tw = bbox[2] - bbox[0]
        draw.text((cx - tw // 2, bc_y + 70), lbl,
                  font=f_ic_lbl, fill=sub_color)

    return img


def screenshot_settings(w, h, ipad=False):
    img = Image.new("RGB", (w, h), CREAM)
    draw = ImageDraw.Draw(img)
    draw_status_bar(draw, w)

    pad_x = 80 if ipad else 50
    f_title = load_font(72 if ipad else 52, bold=True)
    draw.text((pad_x, 130), "Setări", font=f_title, fill=WARM_BROWN)

    # Subscription card (Remove Ads)
    card_y = 260 if ipad else 230
    card_h = 480 if ipad else 380
    gradient_box(img, (pad_x, card_y, w - pad_x, card_y + card_h),
                 LIGHT_GOLDEN, SOFT_PINK)
    rounded_rect(draw, (pad_x, card_y, w - pad_x, card_y + card_h),
                 40, outline=GOLDEN, width=4)

    f_em = load_emoji_font(110 if ipad else 80)
    draw.text((pad_x + 40, card_y + 30), "✨", font=f_em, fill=GOLDEN)

    f_sub_title = load_font(60 if ipad else 44, bold=True)
    f_sub_body = load_font(40 if ipad else 30)
    draw.text((pad_x + 180, card_y + 50),
              "Elimină reclamele",
              font=f_sub_title, fill=WARM_BROWN)
    draw.text((pad_x + 180, card_y + (140 if ipad else 115)),
              "Abonament lunar · 25 RON",
              font=f_sub_body, fill=LIGHT_BROWN)

    body = (
        "Citește toate poveștile fără banner-uri\n"
        "sau reclame între ele. Sprijină dezvoltarea."
    )
    if ipad:
        body = (
            "Citește toate poveștile fără banner-uri sau reclame\n"
            "între capitole. Sprijină dezvoltarea aplicației.\n"
            "Se reînnoiește automat lunar; anulează oricând."
        )
    draw.multiline_text((pad_x + 40, card_y + (230 if ipad else 200)),
                        body, font=f_sub_body, fill=WARM_BROWN, spacing=10)

    btn_y = card_y + card_h - (140 if ipad else 115)
    btn_h = 100 if ipad else 80
    rounded_rect(draw, (pad_x + 40, btn_y, w - pad_x - 40, btn_y + btn_h),
                 30, fill=FOREST_GREEN)
    f_btn = load_font(46 if ipad else 34, bold=True)
    label = "Abonează-te · 25 RON / lună"
    bbox = draw.textbbox((0, 0), label, font=f_btn)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, btn_y + (28 if ipad else 22)),
              label, font=f_btn, fill=(255, 255, 255))

    # Restore purchases link
    rest_y = card_y + card_h + 40
    f_rest = load_font(36 if ipad else 28)
    rest_label = "Restaurează cumpărăturile"
    bbox = draw.textbbox((0, 0), rest_label, font=f_rest)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, rest_y),
              rest_label, font=f_rest, fill=FOREST_GREEN)

    # Other settings items
    items = [
        ("🌙", "Mod noapte"),
        ("🔤", "Mărime text"),
        ("📖", "Salvează ultima poveste citită"),
        ("ℹ️", "Despre aplicație"),
        ("🛡️", "Politica de confidențialitate"),
    ]
    item_y = rest_y + 120
    f_item = load_font(44 if ipad else 32)
    f_item_em = load_emoji_font(58 if ipad else 42)
    for e, lbl in items:
        rounded_rect(draw, (pad_x, item_y, w - pad_x, item_y + (130 if ipad else 100)),
                     25, fill=CARD_BG)
        draw.text((pad_x + 40, item_y + (35 if ipad else 28)),
                  e, font=f_item_em, fill=WARM_BROWN)
        draw.text((pad_x + 140, item_y + (40 if ipad else 32)),
                  lbl, font=f_item, fill=WARM_BROWN)
        draw.text((w - pad_x - 60, item_y + (40 if ipad else 32)),
                  "›", font=load_font(60 if ipad else 44, bold=True),
                  fill=LIGHT_BROWN)
        item_y += (150 if ipad else 120)

    return img


def screenshot_favorites(w, h, ipad=False):
    img = Image.new("RGB", (w, h), CREAM)
    draw = ImageDraw.Draw(img)
    draw_status_bar(draw, w)

    pad_x = 80 if ipad else 50
    f_title = load_font(72 if ipad else 52, bold=True)
    f_em = load_emoji_font(80 if ipad else 56)
    draw.text((pad_x, 130), "⭐", font=f_em, fill=GOLDEN)
    draw.text((pad_x + 110, 140), "Poveștile mele",
              font=f_title, fill=WARM_BROWN)
    f_sub = load_font(40 if ipad else 30)
    draw.text((pad_x, 250 if ipad else 220),
              "Favoritele tale și progresul citirii",
              font=f_sub, fill=LIGHT_BROWN)

    favs = [
        ("🐐", "Capra cu trei iezi", "Citită · 5/5 pagini", "❤️"),
        ("🤴", "Făt-Frumos din lacrimă", "În progres · 3/5", "❤️"),
        ("🍎", "Prâslea cel voinic", "Începută · 1/5", "❤️"),
        ("🦅", "Greuceanu", "Citită · 5/5 pagini", "❤️"),
        ("🐴", "Harap-Alb", "Necitită", "🤍"),
    ]
    if ipad:
        favs.append(("🐷", "Povestea porcului", "Citită · 5/5 pagini", "❤️"))

    card_y = 360 if ipad else 320
    card_h = 220 if ipad else 170
    card_gap = 35 if ipad else 28
    f_card_title = load_font(50 if ipad else 38, bold=True)
    f_card_meta = load_font(36 if ipad else 28)
    f_card_em = load_emoji_font(80 if ipad else 60)
    f_heart = load_emoji_font(60 if ipad else 44)

    for emoji, title, meta, heart in favs:
        rounded_rect(draw, (pad_x, card_y, w - pad_x, card_y + card_h),
                     30, fill=CARD_BG)
        draw.line([(pad_x + 8, card_y + 20),
                   (pad_x + 8, card_y + card_h - 20)],
                  fill=GOLDEN, width=8)
        draw.text((pad_x + 50, card_y + (60 if ipad else 50)),
                  emoji, font=f_card_em, fill=WARM_BROWN)
        draw.text((pad_x + 170, card_y + 35),
                  title, font=f_card_title, fill=WARM_BROWN)
        draw.text((pad_x + 170, card_y + (115 if ipad else 95)),
                  meta, font=f_card_meta, fill=FOREST_GREEN)
        draw.text((w - pad_x - 100, card_y + (70 if ipad else 55)),
                  heart, font=f_heart, fill=GOLDEN)
        # Progress bar
        if "progres" in meta or "Începută" in meta:
            pb_y = card_y + card_h - 30
            pct = 0.6 if "3/5" in meta else 0.2
            rounded_rect(draw, (pad_x + 170, pb_y, w - pad_x - 130, pb_y + 8),
                         4, fill=LIGHT_GOLDEN)
            fill_w = int((w - pad_x - 130 - pad_x - 170) * pct)
            rounded_rect(draw, (pad_x + 170, pb_y, pad_x + 170 + fill_w, pb_y + 8),
                         4, fill=FOREST_GREEN)
        card_y += card_h + card_gap

    # Bottom nav
    nav_y = h - 130
    draw.rectangle([0, nav_y, w, h], fill=CREAM)
    draw.line([0, nav_y, w, nav_y], fill=GOLDEN, width=2)
    nav_items = [("📖", "Povești", False),
                 ("⭐", "Favorite", True),
                 ("⚙️", "Setări", False)]
    nav_w = w // len(nav_items)
    f_nav = load_font(28 if ipad else 22)
    f_nav_emoji = load_emoji_font(50 if ipad else 38)
    for i, (e, lbl, active) in enumerate(nav_items):
        cx = nav_w * i + nav_w // 2
        c = FOREST_GREEN if active else LIGHT_BROWN
        draw.text((cx - 25, nav_y + 20), e, font=f_nav_emoji, fill=c)
        bbox = draw.textbbox((0, 0), lbl, font=f_nav)
        tw = bbox[2] - bbox[0]
        draw.text((cx - tw // 2, nav_y + 75), lbl,
                  font=f_nav, fill=c)

    return img


def make_all(w, h, ipad, out_dir):
    pics = [
        ("01_home.png", screenshot_home(w, h, ipad)),
        ("02_reading.png", screenshot_reading(w, h, ipad, dark=False)),
        ("03_night_mode.png", screenshot_reading(w, h, ipad, dark=True)),
        ("04_favorites.png", screenshot_favorites(w, h, ipad)),
        ("05_settings_iap.png", screenshot_settings(w, h, ipad)),
    ]
    for name, img in pics:
        p = os.path.join(out_dir, name)
        img.save(p, "PNG", optimize=True)
        print(f"OK: {p}")


if __name__ == "__main__":
    # iPhone 6.5" Display (1284 x 2778) — acceptat de Apple pentru "iPhone 6.5"" slot
    make_all(1284, 2778, ipad=False, out_dir=OUT_IPHONE)
    # iPad 13" (2064 x 2752)
    make_all(2064, 2752, ipad=True, out_dir=OUT_IPAD)
    print("\nGata. Screenshots iPhone:", OUT_IPHONE)
    print("Screenshots iPad:", OUT_IPAD)
