from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageColor, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = ROOT / "output" / "raw"
FINAL_DIR = ROOT / "output" / "final"


@dataclass(frozen=True)
class ShotSpec:
    slug: str
    title: str
    accent: str


SPECS = [
    ShotSpec("home", "Home Dashboard", "#2FE0C5"),
    ShotSpec("tree", "Knowledge Tree", "#7DD3FC"),
    ShotSpec("learn", "Learning Catalog", "#F6C453"),
    ShotSpec("ai", "AI Mentor", "#8B7BFF"),
    ShotSpec("profile", "Profile Center", "#FF8C69"),
]


def ensure_output_dirs() -> None:
    FINAL_DIR.mkdir(parents=True, exist_ok=True)


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates: list[str]
    if bold:
        candidates = [
            r"C:\Windows\Fonts\segoeuib.ttf",
            r"C:\Windows\Fonts\arialbd.ttf",
        ]
    else:
        candidates = [
            r"C:\Windows\Fonts\segoeui.ttf",
            r"C:\Windows\Fonts\arial.ttf",
        ]

    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def make_vertical_gradient(size: tuple[int, int], top: str, bottom: str) -> Image.Image:
    width, height = size
    top_rgb = ImageColor.getrgb(top)
    bottom_rgb = ImageColor.getrgb(bottom)
    gradient = Image.new("RGB", size, top_rgb)
    draw = ImageDraw.Draw(gradient)
    for y in range(height):
        mix = y / max(height - 1, 1)
        color = tuple(
            int(top_rgb[index] * (1 - mix) + bottom_rgb[index] * mix)
            for index in range(3)
        )
        draw.line((0, y, width, y), fill=color)
    return gradient


def add_soft_glow(base: Image.Image, center: tuple[int, int], radius: int, color: str, alpha: int) -> None:
    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    x, y = center
    draw.ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        fill=ImageColor.getrgb(color) + (alpha,),
    )
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius // 2))
    base.alpha_composite(overlay)


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def paste_with_mask(base: Image.Image, image: Image.Image, position: tuple[int, int], radius: int) -> None:
    mask = rounded_mask(image.size, radius)
    base.paste(image, position, mask)


def fit_image(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    fitted = image.copy()
    fitted.thumbnail(target_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    left = (target_size[0] - fitted.width) // 2
    top = (target_size[1] - fitted.height) // 2
    canvas.paste(fitted, (left, top))
    return canvas


def build_base_canvas(size: tuple[int, int], accent: str) -> Image.Image:
    canvas = make_vertical_gradient(size, "#06111E", "#0C1D34").convert("RGBA")
    add_soft_glow(canvas, (int(size[0] * 0.18), int(size[1] * 0.22)), 260, accent, 85)
    add_soft_glow(canvas, (int(size[0] * 0.82), int(size[1] * 0.72)), 300, "#0EA5E9", 55)
    add_soft_glow(canvas, (int(size[0] * 0.65), int(size[1] * 0.18)), 200, "#FFFFFF", 18)
    return canvas


def draw_header(base: Image.Image, title: str, subtitle: str, accent: str) -> None:
    draw = ImageDraw.Draw(base)
    font_title = load_font(54, bold=True)
    font_subtitle = load_font(24, bold=False)
    draw.text((110, 80), title, fill="#F6FBFF", font=font_title)
    draw.text((112, 148), subtitle, fill="#B5C7DA", font=font_subtitle)
    draw.rounded_rectangle((110, 198, 260, 206), radius=4, fill=accent)


def laptop_mockup(source: Path, destination: Path, label: str, accent: str) -> None:
    shot = Image.open(source).convert("RGBA")
    base = build_base_canvas((2200, 1500), accent)
    draw_header(base, "ZerdeStudy Desktop UX/UI", label, accent)

    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((270, 300, 1930, 1180), radius=52, fill=(0, 0, 0, 170))
    shadow_draw.ellipse((430, 1110, 1770, 1350), fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(44))
    base.alpha_composite(shadow)

    bezel_rect = (280, 290, 1920, 1170)
    screen_rect = (340, 350, 1860, 1080)
    draw = ImageDraw.Draw(base)
    draw.rounded_rectangle(bezel_rect, radius=48, fill="#10151D", outline="#2C3A49", width=3)
    draw.rounded_rectangle((334, 344, 1866, 1086), radius=36, outline=accent, width=2)

    fitted = fit_image(shot, (screen_rect[2] - screen_rect[0], screen_rect[3] - screen_rect[1]))
    paste_with_mask(base, fitted, (screen_rect[0], screen_rect[1]), radius=24)

    bar_height = 56
    draw.rounded_rectangle(
        (screen_rect[0], screen_rect[1], screen_rect[2], screen_rect[1] + bar_height),
        radius=24,
        fill=(16, 22, 30, 215),
    )
    for idx, color in enumerate(("#F87171", "#FBBF24", "#34D399")):
        left = screen_rect[0] + 26 + idx * 24
        draw.ellipse((left, screen_rect[1] + 18, left + 12, screen_rect[1] + 30), fill=color)
    draw.text((screen_rect[0] + 110, screen_rect[1] + 13), "zerdestudy.app", fill="#C4D2E1", font=load_font(18))

    base_top = 1178
    base_polygon = [
        (500, base_top),
        (1700, base_top),
        (1840, 1290),
        (360, 1290),
    ]
    draw.polygon(base_polygon, fill="#C7D1DD")
    draw.rounded_rectangle((820, 1200, 1380, 1242), radius=18, fill="#A5B4C3")
    draw.rounded_rectangle((362, 1284, 1838, 1304), radius=10, fill="#9AA9B7")

    base.save(destination)


def phone_mockup(source: Path, destination: Path, label: str, accent: str) -> None:
    shot = Image.open(source).convert("RGBA")
    base = build_base_canvas((1400, 1800), accent)
    draw_header(base, "ZerdeStudy Mobile UX/UI", label, accent)

    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((390, 270, 1010, 1590), radius=110, fill=(0, 0, 0, 190))
    shadow = shadow.filter(ImageFilter.GaussianBlur(48))
    base.alpha_composite(shadow)

    draw = ImageDraw.Draw(base)
    body_rect = (405, 250, 995, 1570)
    screen_rect = (445, 320, 955, 1500)
    draw.rounded_rectangle(body_rect, radius=102, fill="#090B10", outline="#2A3645", width=4)
    draw.rounded_rectangle((434, 300, 966, 1521), radius=78, outline=accent, width=2)

    fitted = fit_image(shot, (screen_rect[2] - screen_rect[0], screen_rect[3] - screen_rect[1]))
    paste_with_mask(base, fitted, (screen_rect[0], screen_rect[1]), radius=56)

    draw.rounded_rectangle((560, 288, 840, 346), radius=29, fill="#05070C")
    draw.ellipse((705, 300, 738, 333), fill="#1F2937")
    draw.ellipse((744, 300, 777, 333), fill="#111827")
    draw.rounded_rectangle((615, 1524, 785, 1540), radius=8, fill="#1F2937")

    base.save(destination)


def multidevice_showcase(desktop_source: Path, mobile_source: Path, destination: Path) -> None:
    desktop = Image.open(desktop_source).convert("RGBA")
    mobile = Image.open(mobile_source).convert("RGBA")
    base = build_base_canvas((2400, 1500), "#2FE0C5")
    draw_header(
        base,
        "ZerdeStudy Responsive Showcase",
        "Desktop and smartphone presentation mockup",
        "#2FE0C5",
    )

    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((210, 300, 1770, 1160), radius=58, fill=(0, 0, 0, 165))
    shadow_draw.rounded_rectangle((1450, 360, 2060, 1460), radius=96, fill=(0, 0, 0, 180))
    shadow = shadow.filter(ImageFilter.GaussianBlur(50))
    base.alpha_composite(shadow)

    draw = ImageDraw.Draw(base)
    desktop_bezel = (220, 290, 1760, 1150)
    desktop_screen = (274, 344, 1706, 1060)
    draw.rounded_rectangle(desktop_bezel, radius=54, fill="#10151D", outline="#2C3A49", width=3)
    draw.rounded_rectangle((266, 336, 1714, 1068), radius=40, outline="#2FE0C5", width=2)
    desk_fit = fit_image(desktop, (desktop_screen[2] - desktop_screen[0], desktop_screen[3] - desktop_screen[1]))
    paste_with_mask(base, desk_fit, (desktop_screen[0], desktop_screen[1]), radius=28)

    mobile_body = (1470, 340, 2050, 1460)
    mobile_screen = (1510, 410, 2010, 1390)
    draw.rounded_rectangle(mobile_body, radius=94, fill="#090B10", outline="#2A3645", width=4)
    draw.rounded_rectangle((1498, 390, 2022, 1412), radius=74, outline="#7DD3FC", width=2)
    mobile_fit = fit_image(mobile, (mobile_screen[2] - mobile_screen[0], mobile_screen[3] - mobile_screen[1]))
    paste_with_mask(base, mobile_fit, (mobile_screen[0], mobile_screen[1]), radius=54)
    draw.rounded_rectangle((1648, 378, 1874, 430), radius=26, fill="#05070C")

    draw.text((220, 1240), "Desktop view", fill="#E2EDF7", font=load_font(30, bold=True))
    draw.text((220, 1286), "Wide-screen learning dashboard for laptop or PC presentation.", fill="#ADC2D5", font=load_font(22))
    draw.text((1470, 1320), "Mobile view", fill="#E2EDF7", font=load_font(30, bold=True))
    draw.text((1470, 1366), "Compact adaptive layout for smartphone screenshots.", fill="#ADC2D5", font=load_font(22))

    base.save(destination)


def render_all() -> None:
    ensure_output_dirs()

    for spec in SPECS:
        desktop_source = RAW_DIR / f"desktop-{spec.slug}.png"
        mobile_source = RAW_DIR / f"mobile-{spec.slug}.png"
        laptop_mockup(
            desktop_source,
            FINAL_DIR / f"desktop-{spec.slug}-mockup.png",
            spec.title,
            spec.accent,
        )
        phone_mockup(
            mobile_source,
            FINAL_DIR / f"mobile-{spec.slug}-mockup.png",
            spec.title,
            spec.accent,
        )

    multidevice_showcase(
        RAW_DIR / "desktop-home.png",
        RAW_DIR / "mobile-home.png",
        FINAL_DIR / "responsive-home-showcase.png",
    )


if __name__ == "__main__":
    render_all()
