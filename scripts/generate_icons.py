import os
from PIL import Image, ImageDraw, ImageFont

def draw_lyheng_icon(size, maskable=False):
    # Create image with transparent background or solid background if maskable
    bg_color = (15, 23, 42, 255) # Deep Navy #0F172A
    img = Image.new("RGBA", (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Dimensions
    padding = size * 0.1 if maskable else size * 0.05
    box = [padding, padding, size - padding, size - padding]
    
    # Inner circular badge
    center = size / 2
    badge_radius = (size / 2) * (0.75 if maskable else 0.88)
    
    # Outer subtle glow/ring
    ring_color = (30, 58, 138, 255) # #1E3A8A
    draw.ellipse(
        [center - badge_radius, center - badge_radius, center + badge_radius, center + badge_radius],
        fill=ring_color,
        outline=(16, 185, 129, 200), # Emerald outline
        width=max(2, int(size * 0.025))
    )
    
    # Center circle
    inner_radius = badge_radius * 0.82
    draw.ellipse(
        [center - inner_radius, center - inner_radius, center + inner_radius, center + inner_radius],
        fill=(15, 23, 42, 255)
    )
    
    # Draw currency exchange arrows (2 curved arrows forming circle)
    arrow_color = (16, 185, 129, 255) # Emerald Green #10B981
    arrow_width = max(3, int(size * 0.045))
    
    arc_radius = inner_radius * 0.65
    draw.arc(
        [center - arc_radius, center - arc_radius, center + arc_radius, center + arc_radius],
        start=30, end=150, fill=arrow_color, width=arrow_width
    )
    draw.arc(
        [center - arc_radius, center - arc_radius, center + arc_radius, center + arc_radius],
        start=210, end=330, fill=(239, 68, 68, 255), width=arrow_width # Coral Red #EF4444
    )
    
    # Draw '$' symbol in center
    try:
        font_size = int(size * 0.35)
        # Try finding a bold font
        font = ImageFont.truetype("arialbd.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    symbol = "$"
    # Get text bbox
    left, top, right, bottom = draw.textbbox((0, 0), symbol, font=font)
    text_w = right - left
    text_h = bottom - top
    text_x = center - (text_w / 2) - left
    text_y = center - (text_h / 2) - top
    
    draw.text((text_x, text_y), symbol, fill=(255, 255, 255, 255), font=font)
    
    return img

def main():
    icons_dir = "web/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    sizes = [
        ("web/favicon.png", 64, False),
        ("web/icons/Icon-192.png", 192, False),
        ("web/icons/Icon-512.png", 512, False),
        ("web/icons/Icon-maskable-192.png", 192, True),
        ("web/icons/Icon-maskable-512.png", 512, True),
    ]
    
    for path, sz, maskable in sizes:
        icon = draw_lyheng_icon(sz, maskable)
        icon.save(path, "PNG")
        print(f"Generated: {path} ({sz}x{sz}, maskable={maskable})")

if __name__ == "__main__":
    main()
