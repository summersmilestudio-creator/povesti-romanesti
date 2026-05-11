"""
Generate Google Play Store graphics for "Povesti Romanesti - Basme"
Requires: Pillow (pip install Pillow)
"""

from PIL import Image, ImageDraw, ImageFont
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# Font paths
FONT_BOLD = "C:/Windows/Fonts/segoeuib.ttf"
FONT_REGULAR = "C:/Windows/Fonts/segoeui.ttf"
FONT_LIGHT = "C:/Windows/Fonts/segoeuil.ttf"
FONT_EMOJI = "C:/Windows/Fonts/seguiemj.ttf"
FONT_COMIC_BOLD = "C:/Windows/Fonts/comicbd.ttf"
FONT_COMIC = "C:/Windows/Fonts/comic.ttf"


def draw_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = xy
    # Main body
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    # Corners
    draw.ellipse([x0, y0, x0 + 2 * radius, y0 + 2 * radius], fill=fill)
    draw.ellipse([x1 - 2 * radius, y0, x1, y0 + 2 * radius], fill=fill)
    draw.ellipse([x0, y1 - 2 * radius, x0 + 2 * radius, y1], fill=fill)
    draw.ellipse([x1 - 2 * radius, y1 - 2 * radius, x1, y1], fill=fill)


def draw_gradient(img, color_top, color_bottom):
    """Draw a vertical gradient on an image."""
    w, h = img.size
    draw = ImageDraw.Draw(img)
    for y in range(h):
        ratio = y / h
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return draw


def draw_gradient_radial_accent(img, cx, cy, radius, color):
    """Draw soft radial glow accent."""
    draw = ImageDraw.Draw(img)
    from PIL import Image as PILImage
    overlay = PILImage.new('RGBA', img.size, (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    for i in range(radius, 0, -2):
        alpha = int(40 * (i / radius))
        r, g, b = color
        odraw.ellipse([cx - i, cy - i, cx + i, cy + i], fill=(r, g, b, alpha))
    img.paste(PILImage.alpha_composite(img.convert('RGBA'), overlay).convert('RGB'))


def text_with_shadow(draw, pos, text, font, fill, shadow_color=(0, 0, 0, 60), offset=3):
    """Draw text with a subtle shadow."""
    x, y = pos
    # Shadow
    shadow_img = Image.new('RGBA', (draw.im.size[0], draw.im.size[1]), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.text((x + offset, y + offset), text, font=font, fill=shadow_color)
    # We'll just draw darker text as shadow approximation
    draw.text((x + offset, y + offset), text, font=font, fill=(0, 0, 0, 40))
    draw.text(pos, text, font=font, fill=fill)


def center_text(draw, y, text, font, fill, img_width):
    """Draw centered text at y position."""
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = (img_width - tw) // 2
    draw.text((x, y), text, font=font, fill=fill)
    return bbox[3] - bbox[1]


def center_text_shadow(draw, y, text, font, fill, img_width, shadow_offset=3):
    """Draw centered text with shadow at y position."""
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = (img_width - tw) // 2
    # Shadow
    draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=(0, 0, 0, 35))
    draw.text((x, y), text, font=font, fill=fill)
    return bbox[3] - bbox[1]


def draw_decorative_circles(draw, width, height, colors, count=12):
    """Draw soft decorative circles for visual interest."""
    import random
    random.seed(42)  # Consistent output
    for _ in range(count):
        x = random.randint(0, width)
        y = random.randint(0, height)
        r = random.randint(20, 80)
        color = random.choice(colors)
        draw.ellipse([x - r, y - r, x + r, y + r], fill=color)


def draw_stars(draw, width, height, count=15):
    """Draw small star/sparkle decorations."""
    import random
    random.seed(99)
    colors = [(255, 223, 100), (255, 200, 80), (255, 255, 180), (255, 180, 60)]
    for _ in range(count):
        x = random.randint(30, width - 30)
        y = random.randint(30, height - 30)
        size = random.randint(3, 8)
        color = random.choice(colors)
        # Simple 4-point star
        draw.polygon([(x, y - size * 2), (x + size, y), (x, y + size * 2), (x - size, y)], fill=color)


# ============================================================
# FEATURE GRAPHIC (1024 x 500)
# ============================================================
def generate_feature_graphic():
    print("Generating Feature Graphic (1024x500)...")
    W, H = 1024, 500
    img = Image.new('RGB', (W, H))

    # Warm gradient: cream/peach to soft orange
    color_top = (255, 235, 200)       # Warm cream
    color_bottom = (255, 165, 90)     # Soft orange
    draw = draw_gradient(img, color_top, color_bottom)

    # Soft decorative bubbles
    bubble_colors = [(255, 210, 160, 50), (255, 190, 130, 40), (255, 230, 190, 45)]
    import random
    random.seed(42)
    for _ in range(20):
        x = random.randint(0, W)
        y = random.randint(0, H)
        r = random.randint(30, 100)
        c = random.choice(bubble_colors)
        draw.ellipse([x - r, y - r, x + r, y + r], fill=c[:3])

    # Draw sparkles
    draw_stars(draw, W, H, count=20)

    # Main title
    font_title = ImageFont.truetype(FONT_COMIC_BOLD, 72)
    font_subtitle = ImageFont.truetype(FONT_COMIC, 36)
    font_emoji = ImageFont.truetype(FONT_EMOJI, 48)

    # Title with shadow
    title = "Povesti Romanesti"
    center_text_shadow(draw, 120, title, font_title, (139, 69, 19), W, shadow_offset=4)

    # Decorative line
    line_y = 210
    draw.rectangle([W // 2 - 150, line_y, W // 2 + 150, line_y + 4], fill=(180, 100, 40, 180))

    # Subtitle
    subtitle = "Basme pentru copii"
    center_text_shadow(draw, 230, subtitle, font_subtitle, (120, 60, 10), W, shadow_offset=2)

    # Emoji row at bottom
    emojis_text = "📖  🏰  🐐  🤴  👸  🦊"
    font_emoji_large = ImageFont.truetype(FONT_EMOJI, 52)
    center_text(draw, 320, emojis_text, font_emoji_large, (0, 0, 0), W)

    # Bottom accent bar
    draw.rectangle([0, H - 30, W, H], fill=(200, 100, 30))
    draw.rectangle([0, H - 32, W, H - 30], fill=(255, 200, 100))

    # Top accent bar
    draw.rectangle([0, 0, W, 12], fill=(200, 100, 30))
    draw.rectangle([0, 12, W, 14], fill=(255, 200, 100))

    # Side decorative elements - small book icons
    font_side_emoji = ImageFont.truetype(FONT_EMOJI, 36)
    draw.text((30, 60), "📚", font=font_side_emoji, fill=(0, 0, 0))
    draw.text((W - 70, 60), "📚", font=font_side_emoji, fill=(0, 0, 0))
    draw.text((30, H - 100), "⭐", font=font_side_emoji, fill=(0, 0, 0))
    draw.text((W - 70, H - 100), "⭐", font=font_side_emoji, fill=(0, 0, 0))

    # "Gratuit" badge top-right
    font_badge = ImageFont.truetype(FONT_COMIC_BOLD, 24)
    badge_text = "GRATUIT"
    badge_x, badge_y = W - 180, 30
    draw_rounded_rect(draw, (badge_x, badge_y, badge_x + 150, badge_y + 45), 22, (220, 50, 50))
    draw.text((badge_x + 22, badge_y + 8), badge_text, font=font_badge, fill=(255, 255, 255))

    path = os.path.join(OUTPUT_DIR, "feature_graphic.png")
    img.save(path, "PNG")
    print(f"  Saved: {path}")


# ============================================================
# SCREENSHOT 1 - "17 Basme Clasice"
# ============================================================
def generate_screenshot_1():
    print("Generating Screenshot 1 - 17 Basme Clasice (1080x1920)...")
    W, H = 1080, 1920
    img = Image.new('RGB', (W, H))

    # Warm gradient background
    color_top = (255, 248, 235)
    color_bottom = (255, 210, 160)
    draw = draw_gradient(img, color_top, color_bottom)

    # Decorative top bar
    draw.rectangle([0, 0, W, 100], fill=(210, 120, 50))
    draw.rectangle([0, 95, W, 100], fill=(255, 200, 100))

    # Title area
    font_number = ImageFont.truetype(FONT_COMIC_BOLD, 120)
    font_title = ImageFont.truetype(FONT_COMIC_BOLD, 60)
    font_subtitle = ImageFont.truetype(FONT_COMIC, 32)
    font_story = ImageFont.truetype(FONT_COMIC, 38)
    font_emoji = ImageFont.truetype(FONT_EMOJI, 48)
    font_story_emoji = ImageFont.truetype(FONT_EMOJI, 38)

    # Big number
    center_text_shadow(draw, 140, "17", font_number, (180, 80, 20), W, shadow_offset=4)

    # Title
    center_text_shadow(draw, 280, "Basme Romanesti", font_title, (139, 69, 19), W, shadow_offset=3)

    # Decorative separator
    sep_y = 365
    draw.rectangle([W // 2 - 200, sep_y, W // 2 + 200, sep_y + 3], fill=(180, 100, 40))

    # Author subtitle
    author_text = "Ion Creanga  ·  Petre Ispirescu  ·  Clasice"
    center_text(draw, 390, author_text, font_subtitle, (140, 80, 30), W)

    # Story list with emoji indicators
    stories = [
        ("🐐", "Capra cu trei iezi"),
        ("🤴", "Fat-Frumos din lacrima"),
        ("🍎", "Praslea cel voinic"),
        ("👸", "Ileana Cosanzeana"),
        ("🦊", "Ursul pacalit de vulpe"),
        ("👴", "Punguța cu doi bani"),
        ("🐔", "Povestea unui om lenes"),
        ("🏰", "Tinereţe fara batraneţe"),
        ("🌙", "Harap-Alb"),
    ]

    card_margin = 60
    card_width = W - 2 * card_margin
    start_y = 470
    card_height = 110
    card_gap = 12

    for i, (emoji, story_name) in enumerate(stories):
        y = start_y + i * (card_height + card_gap)
        if y + card_height > H - 120:
            break

        # Card background
        alpha_val = 220 if i % 2 == 0 else 200
        card_color = (255, 250, 240) if i % 2 == 0 else (255, 245, 230)
        draw_rounded_rect(draw, (card_margin, y, card_margin + card_width, y + card_height), 20, card_color)

        # Left colored strip
        strip_colors = [(230, 130, 50), (200, 100, 60), (180, 120, 40), (210, 90, 50),
                        (190, 110, 60), (220, 100, 40), (200, 120, 50), (180, 90, 60), (210, 110, 40)]
        strip_color = strip_colors[i % len(strip_colors)]
        draw_rounded_rect(draw, (card_margin, y, card_margin + 12, y + card_height), 6, strip_color)

        # Emoji
        draw.text((card_margin + 30, y + 25), emoji, font=font_story_emoji, fill=(0, 0, 0))

        # Story name
        draw.text((card_margin + 90, y + 30), story_name, font=font_story, fill=(80, 40, 10))

    # Bottom area
    font_bottom = ImageFont.truetype(FONT_COMIC_BOLD, 32)
    bottom_y = H - 140
    draw.rectangle([0, bottom_y, W, H], fill=(210, 120, 50))
    draw.rectangle([0, bottom_y, W, bottom_y + 5], fill=(255, 200, 100))
    center_text(draw, bottom_y + 40, "...si multe altele!", font_bottom, (255, 255, 255), W)

    path = os.path.join(OUTPUT_DIR, "screenshot_1_stories.png")
    img.save(path, "PNG")
    print(f"  Saved: {path}")


# ============================================================
# SCREENSHOT 2 - "Categorii"
# ============================================================
def generate_screenshot_2():
    print("Generating Screenshot 2 - Categorii (1080x1920)...")
    W, H = 1080, 1920
    img = Image.new('RGB', (W, H))

    # Soft lavender to warm peach gradient
    color_top = (245, 235, 255)
    color_bottom = (255, 220, 190)
    draw = draw_gradient(img, color_top, color_bottom)

    # Top decorative bar
    draw.rectangle([0, 0, W, 100], fill=(160, 100, 180))
    draw.rectangle([0, 95, W, 100], fill=(220, 180, 240))

    font_big = ImageFont.truetype(FONT_COMIC_BOLD, 100)
    font_title = ImageFont.truetype(FONT_COMIC_BOLD, 56)
    font_card_title = ImageFont.truetype(FONT_COMIC_BOLD, 44)
    font_card_desc = ImageFont.truetype(FONT_COMIC, 30)
    font_emoji_big = ImageFont.truetype(FONT_EMOJI, 80)
    font_emoji_card = ImageFont.truetype(FONT_EMOJI, 64)

    # "3" big number
    center_text_shadow(draw, 150, "3", font_big, (120, 60, 140), W, shadow_offset=4)

    # Title
    center_text_shadow(draw, 280, "Categorii", font_title, (100, 50, 120), W, shadow_offset=3)

    # Separator
    sep_y = 360
    draw.rectangle([W // 2 - 150, sep_y, W // 2 + 150, sep_y + 3], fill=(160, 100, 180))

    # Category cards
    categories = [
        ("📚", "Basme Populare", "Povesti clasice romanesti\ntransmise din generatie\nin generatie", (255, 245, 235), (200, 130, 60)),
        ("🐾", "Povesti cu Animale", "Aventuri cu animale\nindragite de copii\ndin lumea intreaga", (240, 248, 255), (70, 130, 180)),
        ("🌙", "Noapte Buna", "Povesti de seara\nperfecte pentru adormit\nlinistit si frumos", (240, 240, 255), (100, 80, 160)),
    ]

    card_margin = 70
    card_width = W - 2 * card_margin
    card_height = 380
    start_y = 420
    card_gap = 40

    for i, (emoji, title, desc, bg_color, accent_color) in enumerate(categories):
        y = start_y + i * (card_height + card_gap)

        # Card shadow
        draw_rounded_rect(draw, (card_margin + 5, y + 5, card_margin + card_width + 5, y + card_height + 5), 30, (0, 0, 0, 20))

        # Card background
        draw_rounded_rect(draw, (card_margin, y, card_margin + card_width, y + card_height), 30, bg_color)

        # Top accent bar on card
        draw_rounded_rect(draw, (card_margin, y, card_margin + card_width, y + 8), 4, accent_color)

        # Emoji centered
        emoji_bbox = draw.textbbox((0, 0), emoji, font=font_emoji_card)
        emoji_w = emoji_bbox[2] - emoji_bbox[0]
        draw.text(((W - emoji_w) // 2, y + 30), emoji, font=font_emoji_card, fill=(0, 0, 0))

        # Card title
        center_text(draw, y + 120, title, font_card_title, accent_color, W)

        # Description (multi-line centered)
        desc_lines = desc.split('\n')
        desc_y = y + 190
        font_desc = font_card_desc
        for line in desc_lines:
            center_text(draw, desc_y, line.strip(), font_desc, (100, 80, 70), W)
            desc_y += 42

    # Bottom bar
    draw.rectangle([0, H - 80, W, H], fill=(160, 100, 180))
    draw.rectangle([0, H - 80, W, H - 75], fill=(220, 180, 240))

    path = os.path.join(OUTPUT_DIR, "screenshot_2_categories.png")
    img.save(path, "PNG")
    print(f"  Saved: {path}")


# ============================================================
# SCREENSHOT 3 - "Mod Noapte"
# ============================================================
def generate_screenshot_3():
    print("Generating Screenshot 3 - Mod Noapte (1080x1920)...")
    W, H = 1080, 1920
    img = Image.new('RGB', (W, H))

    # Dark gradient - deep blue to dark purple
    color_top = (15, 15, 50)
    color_bottom = (40, 20, 60)
    draw = draw_gradient(img, color_top, color_bottom)

    # Stars in background
    import random
    random.seed(77)
    for _ in range(80):
        x = random.randint(10, W - 10)
        y = random.randint(10, H - 10)
        size = random.randint(1, 4)
        brightness = random.randint(150, 255)
        color = (brightness, brightness, brightness + random.randint(-20, 0))
        draw.ellipse([x - size, y - size, x + size, y + size], fill=color)

    # Larger twinkling stars
    for _ in range(15):
        x = random.randint(40, W - 40)
        y = random.randint(40, H - 40)
        size = random.randint(2, 5)
        draw.polygon([(x, y - size * 3), (x + size, y), (x, y + size * 3), (x - size, y)],
                      fill=(255, 255, 200, 200))

    # Moon glow effect (large soft circle)
    moon_x, moon_y = W // 2, 350
    for r in range(200, 0, -2):
        alpha = int(15 * (r / 200))
        glow_color = (60 + alpha, 50 + alpha, 80 + alpha * 2)
        draw.ellipse([moon_x - r, moon_y - r, moon_x + r, moon_y + r], fill=glow_color)

    # Moon emoji
    font_moon = ImageFont.truetype(FONT_EMOJI, 140)
    moon_bbox = draw.textbbox((0, 0), "🌙", font=font_moon)
    moon_w = moon_bbox[2] - moon_bbox[0]
    draw.text(((W - moon_w) // 2, 260), "🌙", font=font_moon, fill=(255, 255, 200))

    # Title
    font_title = ImageFont.truetype(FONT_COMIC_BOLD, 68)
    font_subtitle = ImageFont.truetype(FONT_COMIC, 36)
    font_desc = ImageFont.truetype(FONT_COMIC, 30)

    center_text_shadow(draw, 520, "Mod Noapte", font_title, (220, 200, 255), W, shadow_offset=3)

    # Separator - soft glowing line
    sep_y = 610
    for thickness in range(8, 0, -1):
        alpha_line = 80 + (8 - thickness) * 20
        draw.rectangle([W // 2 - 180, sep_y - thickness, W // 2 + 180, sep_y + thickness],
                        fill=(150, 130, 200))
    draw.rectangle([W // 2 - 180, sep_y - 1, W // 2 + 180, sep_y + 1], fill=(200, 180, 255))

    # Subtitle
    center_text(draw, 650, "Perfect pentru citit", font_subtitle, (180, 170, 220), W)
    center_text(draw, 700, "inainte de culcare", font_subtitle, (180, 170, 220), W)

    # Dark mode preview card
    card_margin = 90
    card_y = 820
    card_height = 700
    card_width = W - 2 * card_margin

    # Card shadow/glow
    for g in range(20, 0, -1):
        glow_alpha = 30 + g
        draw_rounded_rect(draw, (card_margin - g, card_y - g, card_margin + card_width + g, card_y + card_height + g),
                          35, (40 + g, 30 + g, 60 + g))

    # Card background (dark)
    draw_rounded_rect(draw, (card_margin, card_y, card_margin + card_width, card_y + card_height), 30, (30, 28, 45))

    # Card content - simulated story text
    font_story_title = ImageFont.truetype(FONT_COMIC_BOLD, 36)
    font_story_text = ImageFont.truetype(FONT_COMIC, 26)

    center_text(draw, card_y + 40, "🐐 Capra cu trei iezi", font_story_title, (200, 190, 230), W)

    story_lines = [
        "A fost odata ca niciodata,",
        "o capra cu trei iezi. Capra",
        "trebuia sa plece la padure",
        "dupa mancare si ii spuse",
        "iezilor ei sa nu deschida",
        "usa la nimeni, decat daca",
        "vor auzi glasul ei...",
        "",
        "— Nu deschideti usa la",
        "nimeni, dragi iezisori,",
        "ca vine lupul cel rau!",
    ]

    text_y = card_y + 110
    for line in story_lines:
        if line == "":
            text_y += 20
            continue
        center_text(draw, text_y, line, font_story_text, (170, 165, 200), W)
        text_y += 42

    # Sleeping emoji at bottom
    font_sleep = ImageFont.truetype(FONT_EMOJI, 48)
    center_text(draw, card_y + card_height - 80, "💤  😴  💤", font_sleep, (0, 0, 0), W)

    # Bottom info
    font_bottom = ImageFont.truetype(FONT_COMIC, 28)
    center_text(draw, H - 250, "Culori blande pentru ochi", font_bottom, (140, 130, 180), W)
    center_text(draw, H - 200, "Reducere lumina albastra", font_bottom, (140, 130, 180), W)

    # Bottom stars decoration
    font_star_emoji = ImageFont.truetype(FONT_EMOJI, 32)
    center_text(draw, H - 120, "⭐  🌟  ⭐  🌟  ⭐", font_star_emoji, (0, 0, 0), W)

    path = os.path.join(OUTPUT_DIR, "screenshot_3_night_mode.png")
    img.save(path, "PNG")
    print(f"  Saved: {path}")


# ============================================================
# SCREENSHOT 4 - "Sigur pentru Copii"
# ============================================================
def generate_screenshot_4():
    print("Generating Screenshot 4 - Sigur pentru Copii (1080x1920)...")
    W, H = 1080, 1920
    img = Image.new('RGB', (W, H))

    # Fresh green gradient
    color_top = (235, 255, 240)
    color_bottom = (180, 235, 195)
    draw = draw_gradient(img, color_top, color_bottom)

    # Top accent bar (green)
    draw.rectangle([0, 0, W, 100], fill=(60, 160, 80))
    draw.rectangle([0, 95, W, 100], fill=(140, 220, 150))

    # Shield emoji
    font_shield = ImageFont.truetype(FONT_EMOJI, 140)
    shield_bbox = draw.textbbox((0, 0), "🛡️", font=font_shield)
    shield_w = shield_bbox[2] - shield_bbox[0]
    draw.text(((W - shield_w) // 2, 150), "🛡️", font=font_shield, fill=(0, 0, 0))

    # Title
    font_title = ImageFont.truetype(FONT_COMIC_BOLD, 64)
    font_subtitle = ImageFont.truetype(FONT_COMIC, 34)

    center_text_shadow(draw, 340, "Sigur pentru", font_title, (40, 120, 50), W, shadow_offset=3)
    center_text_shadow(draw, 420, "Copii", font_title, (40, 120, 50), W, shadow_offset=3)

    # Separator
    sep_y = 510
    draw.rectangle([W // 2 - 150, sep_y, W // 2 + 150, sep_y + 3], fill=(60, 160, 80))

    # Safety features as cards
    features = [
        ("✅", "Fara reclame", "Experienta curata, fara\ndistractii sau pop-up-uri"),
        ("✅", "Fara date colectate", "Respectam intimitatea\ncopilului dumneavoastra"),
        ("✅", "Control parental", "Parintii au controlul\ncomplet al aplicatiei"),
        ("✅", "Functioneaza offline", "Nu e nevoie de internet\ndupa descarcare"),
    ]

    card_margin = 70
    card_width = W - 2 * card_margin
    card_height = 240
    start_y = 570
    card_gap = 30

    font_check = ImageFont.truetype(FONT_EMOJI, 52)
    font_feature_title = ImageFont.truetype(FONT_COMIC_BOLD, 40)
    font_feature_desc = ImageFont.truetype(FONT_COMIC, 28)

    for i, (icon, title, desc) in enumerate(features):
        y = start_y + i * (card_height + card_gap)

        # Card shadow
        draw_rounded_rect(draw, (card_margin + 4, y + 4, card_margin + card_width + 4, y + card_height + 4),
                          25, (100, 180, 110))

        # Card background
        card_bg = (255, 255, 255) if i % 2 == 0 else (248, 255, 250)
        draw_rounded_rect(draw, (card_margin, y, card_margin + card_width, y + card_height), 25, card_bg)

        # Left green accent strip
        draw_rounded_rect(draw, (card_margin, y, card_margin + 10, y + card_height), 5, (60, 180, 80))

        # Checkmark
        draw.text((card_margin + 35, y + 25), icon, font=font_check, fill=(40, 160, 60))

        # Feature title
        draw.text((card_margin + 110, y + 30), title, font=font_feature_title, fill=(40, 100, 50))

        # Description
        desc_lines = desc.split('\n')
        desc_y = y + 100
        for line in desc_lines:
            draw.text((card_margin + 110, desc_y), line.strip(), font=font_feature_desc, fill=(80, 120, 80))
            desc_y += 38

    # Bottom area
    bottom_y = H - 250

    # Trust badge
    font_trust = ImageFont.truetype(FONT_COMIC_BOLD, 36)
    font_trust_sub = ImageFont.truetype(FONT_COMIC, 28)
    font_heart = ImageFont.truetype(FONT_EMOJI, 40)

    center_text(draw, bottom_y, "💚  Creat cu grija  💚", font_heart, (0, 0, 0), W)
    center_text(draw, bottom_y + 60, "pentru familii din Romania", font_trust_sub, (60, 120, 70), W)

    # Bottom bar
    draw.rectangle([0, H - 80, W, H], fill=(60, 160, 80))
    draw.rectangle([0, H - 80, W, H - 75], fill=(140, 220, 150))

    # Bottom text
    font_bottom = ImageFont.truetype(FONT_COMIC_BOLD, 28)
    center_text(draw, H - 58, "Recomandat pentru varsta 3-10 ani", font_bottom, (255, 255, 255), W)

    path = os.path.join(OUTPUT_DIR, "screenshot_4_safe.png")
    img.save(path, "PNG")
    print(f"  Saved: {path}")


# ============================================================
# MAIN
# ============================================================
if __name__ == "__main__":
    print("=" * 50)
    print("Google Play Store Graphics Generator")
    print("Povesti Romanesti - Basme")
    print("=" * 50)
    print()

    generate_feature_graphic()
    generate_screenshot_1()
    generate_screenshot_2()
    generate_screenshot_3()
    generate_screenshot_4()

    print()
    print("=" * 50)
    print("All graphics generated successfully!")
    print(f"Output directory: {OUTPUT_DIR}")
    print("=" * 50)
    print()
    print("Files created:")
    for f in sorted(os.listdir(OUTPUT_DIR)):
        if f.endswith('.png') and f != 'icon-512.png':
            fpath = os.path.join(OUTPUT_DIR, f)
            size_kb = os.path.getsize(fpath) / 1024
            print(f"  {f} ({size_kb:.0f} KB)")
