"""
Generează iconiță hook pentru Povești Românești.
Design: carte magică deschisă cu coroană aurie + stele scânteietoare pe gradient violet → magenta.
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math
import random

SIZE = 1024
random.seed(42)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def make_gradient_bg(size):
    img = Image.new("RGB", (size, size), (0, 0, 0))
    px = img.load()
    # Diagonal gradient: deep violet -> magenta -> warm gold
    c1 = (60, 20, 110)      # deep violet
    c2 = (180, 30, 130)     # magenta
    c3 = (255, 180, 60)     # warm gold
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            if t < 0.55:
                col = lerp_color(c1, c2, t / 0.55)
            else:
                col = lerp_color(c2, c3, (t - 0.55) / 0.45)
            px[x, y] = col
    return img


def draw_radial_glow(img, center, radius, color, intensity=0.5):
    """Glow radial cu transparență."""
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx, cy = center
    steps = 60
    for i in range(steps, 0, -1):
        r = int(radius * i / steps)
        alpha = int(255 * intensity * (1 - i / steps) ** 2)
        draw.ellipse(
            (cx - r, cy - r, cx + r, cy + r),
            fill=(*color, alpha),
        )
    img.alpha_composite(overlay)


def draw_star(draw, cx, cy, r_outer, r_inner, color, points=5, rotation=-math.pi / 2):
    coords = []
    for i in range(points * 2):
        angle = rotation + i * math.pi / points
        r = r_outer if i % 2 == 0 else r_inner
        coords.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(coords, fill=color)


def draw_open_book(draw, cx, cy, w, h):
    """Carte deschisă cu pagini albe și cotor roșu."""
    # Shadow under book
    shadow = Image.new("RGBA", (w + 80, 80), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.ellipse((0, 10, w + 80, 70), fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(20))
    # Will paste shadow after — handled outside

    # Book pages (left + right) — perspective rhomboid effect
    half_w = w // 2
    # Left page
    left_page = [
        (cx - half_w, cy - h // 2 + 20),
        (cx - 8, cy - h // 2),
        (cx - 8, cy + h // 2),
        (cx - half_w + 30, cy + h // 2 - 10),
    ]
    # Right page
    right_page = [
        (cx + 8, cy - h // 2),
        (cx + half_w, cy - h // 2 + 20),
        (cx + half_w - 30, cy + h // 2 - 10),
        (cx + 8, cy + h // 2),
    ]
    # Page shadow
    draw.polygon(
        [(p[0] + 8, p[1] + 12) for p in left_page],
        fill=(40, 0, 60),
    )
    draw.polygon(
        [(p[0] + 8, p[1] + 12) for p in right_page],
        fill=(40, 0, 60),
    )
    # Pages
    draw.polygon(left_page, fill=(255, 248, 230))
    draw.polygon(right_page, fill=(255, 248, 230))
    # Center spine (red)
    draw.polygon(
        [
            (cx - 14, cy - h // 2),
            (cx + 14, cy - h // 2),
            (cx + 14, cy + h // 2),
            (cx - 14, cy + h // 2),
        ],
        fill=(180, 30, 50),
    )
    draw.line((cx, cy - h // 2 + 4, cx, cy + h // 2 - 4), fill=(120, 10, 30), width=2)

    # Page lines (text suggestion)
    line_color = (180, 120, 80)
    line_y = cy - h // 2 + 60
    for i in range(6):
        y = line_y + i * 28
        # left
        draw.line(
            (cx - half_w + 50, y, cx - 30, y - 2),
            fill=line_color,
            width=4,
        )
        # right
        draw.line(
            (cx + 30, y - 2, cx + half_w - 50, y),
            fill=line_color,
            width=4,
        )


def draw_crown(draw, cx, cy, w, h):
    """Coroană aurie deasupra cărții."""
    base_y = cy + h // 2
    top_y = cy - h // 2
    half_w = w // 2
    # Base band
    draw.rounded_rectangle(
        (cx - half_w, base_y - 24, cx + half_w, base_y),
        radius=8,
        fill=(255, 200, 60),
    )
    # Body fill
    points = [
        (cx - half_w, base_y),
        (cx - half_w, top_y + 30),
        (cx - half_w + w * 0.18, top_y + 80),
        (cx - half_w + w * 0.30, top_y + 20),
        (cx, top_y + 70),
        (cx + half_w - w * 0.30, top_y + 20),
        (cx + half_w - w * 0.18, top_y + 80),
        (cx + half_w, top_y + 30),
        (cx + half_w, base_y),
    ]
    draw.polygon(points, fill=(255, 200, 60))
    # Highlight
    highlight = [
        (cx - half_w + 8, base_y - 4),
        (cx - half_w + 8, top_y + 40),
        (cx - half_w + 18, top_y + 80),
    ]
    draw.line(highlight, fill=(255, 240, 180), width=6)
    # Jewels (3 dots on band)
    for dx in (-half_w // 2, 0, half_w // 2):
        draw.ellipse(
            (cx + dx - 10, base_y - 18, cx + dx + 10, base_y - 2),
            fill=(220, 30, 60),
        )
        draw.ellipse(
            (cx + dx - 5, base_y - 16, cx + dx + 1, base_y - 10),
            fill=(255, 200, 200),
        )
    # Star tips (small stars on each peak)
    for px, py in [(cx - half_w + w * 0.18, top_y + 80),
                   (cx, top_y + 70),
                   (cx + half_w - w * 0.18, top_y + 80)]:
        draw_star(draw, px, py - 10, 22, 10, (255, 240, 180))


def add_sparkles(img):
    """Stele scânteietoare aleatorii pe fundal."""
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    positions = [
        (160, 180, 26),
        (860, 200, 32),
        (140, 760, 22),
        (880, 800, 28),
        (260, 480, 18),
        (760, 540, 20),
        (520, 140, 24),
        (500, 880, 26),
        (380, 240, 14),
        (660, 800, 14),
    ]
    for x, y, r in positions:
        # 4-point sparkle
        draw.polygon(
            [(x, y - r), (x + r // 4, y - r // 4),
             (x + r, y), (x + r // 4, y + r // 4),
             (x, y + r), (x - r // 4, y + r // 4),
             (x - r, y), (x - r // 4, y - r // 4)],
            fill=(255, 255, 220, 230),
        )
        # Center bright dot
        draw.ellipse((x - 4, y - 4, x + 4, y + 4), fill=(255, 255, 255, 255))
    img = img.convert("RGBA")
    img.alpha_composite(overlay)
    return img


def main():
    img = make_gradient_bg(SIZE).convert("RGBA")

    # Soft golden radial glow behind book
    draw_radial_glow(img, (SIZE // 2, SIZE // 2 + 40), 480, (255, 220, 120), 0.6)

    # Sparkles on background
    img = add_sparkles(img)

    draw = ImageDraw.Draw(img)

    # Book centered, slightly lower
    book_w = 520
    book_h = 420
    cx = SIZE // 2
    cy = SIZE // 2 + 60

    # Book shadow blob
    shadow = Image.new("RGBA", (book_w + 200, 100), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.ellipse((0, 20, book_w + 200, 90), fill=(0, 0, 0, 140))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    img.alpha_composite(shadow, (cx - (book_w + 200) // 2, cy + book_h // 2 - 30))

    draw_open_book(draw, cx, cy, book_w, book_h)

    # Crown above book
    crown_w = 360
    crown_h = 180
    draw_crown(draw, cx, cy - book_h // 2 - 50, crown_w, crown_h)

    # Big star top-left as accent
    draw_star(draw, 200, 220, 70, 30, (255, 240, 130))
    draw_star(draw, 200, 220, 35, 14, (255, 255, 220))

    # Save
    out_path = r"D:\PovestiRomanesti\assets\app_icon.png"
    img.convert("RGB").save(out_path, format="PNG")
    print(f"saved {out_path}")

    # Foreground (transparent bg) for adaptive icon — keep only book + crown + sparkles, no gradient
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    # Scale down 80% for safe zone of adaptive icon
    scale = 0.75
    new_size = int(SIZE * scale)
    inner = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
    inner_draw = ImageDraw.Draw(inner)
    s_book_w = int(book_w * scale)
    s_book_h = int(book_h * scale)
    s_cx = new_size // 2
    s_cy = new_size // 2 + int(60 * scale)
    draw_open_book(inner_draw, s_cx, s_cy, s_book_w, s_book_h)
    draw_crown(inner_draw, s_cx, s_cy - s_book_h // 2 - int(50 * scale),
               int(360 * scale), int(180 * scale))
    fg.paste(inner, ((SIZE - new_size) // 2, (SIZE - new_size) // 2), inner)
    fg.save(r"D:\PovestiRomanesti\assets\app_icon_foreground.png", format="PNG")
    print("saved foreground")


if __name__ == "__main__":
    main()
