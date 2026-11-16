from pathlib import Path
from PIL import Image

base_dir = Path(__file__).resolve().parent
image_path = base_dir.parent / "graphics" / "original" / "flee.png"

# open the image
image = Image.open(image_path).convert("RGBA")  # Convert to RGBA mode

if image.size != (16,16):
    raise ValueError("Expected a 16x16 sprite")

# output directory
output_dir = base_dir.parent / "graphics" / "tiles" / "flee"
output_dir.mkdir(parents=True, exist_ok=True)

# define our four tiles!
tiles = [
    ("tile_0_top_left", 0, 0 ),
    ("tile_1_top_right", 8, 0 ),
    ("tile_2_bottom_left", 0, 8 ),
    ("tile_3_bottom_right", 8, 8 )
]

for name, x, y in tiles:
    tile = image.crop((x,y,x+8,y+8))
    tile.save(output_dir / f"{name}.png")
    print(f"Saved {name}.png at {output_dir}")

print("All tiles saved successfully.")

