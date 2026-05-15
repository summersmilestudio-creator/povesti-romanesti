"""Generate iPhone 6.7" (1290x2796) screenshots from existing Play Store images
   using padding/scaling so dimensions match Apple's required size."""
import os
from PIL import Image, ImageDraw, ImageFilter

IOS_W, IOS_H = 1284, 2778
SRC_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SRC_DIR, "ios_screenshots")
os.makedirs(OUT_DIR, exist_ok=True)

# Background: warm cream gradient similar to app theme
BG_TOP = (255, 248, 240)
BG_BOTTOM = (250, 230, 200)


def make_bg():
    bg = Image.new("RGB", (IOS_W, IOS_H), BG_TOP)
    draw = ImageDraw.Draw(bg)
    for y in range(IOS_H):
        ratio = y / IOS_H
        r = int(BG_TOP[0] * (1 - ratio) + BG_BOTTOM[0] * ratio)
        g = int(BG_TOP[1] * (1 - ratio) + BG_BOTTOM[1] * ratio)
        b = int(BG_TOP[2] * (1 - ratio) + BG_BOTTOM[2] * ratio)
        draw.line([(0, y), (IOS_W, y)], fill=(r, g, b))
    return bg


def place_screenshot(src_path: str, out_path: str) -> None:
    bg = make_bg()
    if not os.path.exists(src_path):
        bg.save(out_path)
        return
    img = Image.open(src_path).convert("RGB")
    # Scale to ~85% of width, preserving aspect
    target_w = int(IOS_W * 0.85)
    ratio = target_w / img.width
    target_h = int(img.height * ratio)
    if target_h > int(IOS_H * 0.85):
        target_h = int(IOS_H * 0.85)
        target_w = int(img.width * (target_h / img.height))
    img = img.resize((target_w, target_h), Image.LANCZOS)
    # Add subtle shadow
    shadow = Image.new("RGBA", (target_w + 80, target_h + 80), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rectangle([(40, 40), (target_w + 40, target_h + 40)], fill=(0, 0, 0, 80))
    shadow = shadow.filter(ImageFilter.GaussianBlur(20))
    x = (IOS_W - target_w) // 2
    y = (IOS_H - target_h) // 2
    bg.paste(shadow, (x - 40, y - 40), shadow)
    bg.paste(img, (x, y))
    bg.save(out_path, "PNG", optimize=True)


def main():
    sources = [
        ("screenshot_1_stories.png", "ios_1_stories.png"),
        ("screenshot_2_categories.png", "ios_2_categories.png"),
        ("screenshot_3_night_mode.png", "ios_3_night_mode.png"),
        ("screenshot_4_safe.png", "ios_4_reading.png"),
    ]
    for src, dst in sources:
        place_screenshot(os.path.join(SRC_DIR, src),
                         os.path.join(OUT_DIR, dst))
        print(f"OK: {dst}")


if __name__ == "__main__":
    main()
