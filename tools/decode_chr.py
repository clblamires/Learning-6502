from pathlib import Path
from PIL import Image

base_dir = Path(__file__).resolve().parent
chr_path = base_dir.parent / "graphics" / "chr" / "flee.chr"
output_path = base_dir.parent / "graphics" / "chr" / "flee_reconstructed.png"

# read the chr file
chr_data = chr_path.read_bytes()

if len(chr_data) != 64:
    raise ValueError(f"Expected 64 bytes for 4 tiles, got {len(chr_data)} bytes")

# convert a single tile back into pixels
def decode_tile(data):
    image = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    for y in range(8):
        plane0 = data[y]
        plane1 = data[y+8]
        for x in range(8):
            bit0 = (plane0 >> (7-x)) & 1
            bit1 = (plane1 >> (7-x)) & 1
            color_index = bit0 | ( bit1 << 1 )
            colors = {
                0: (0, 0, 0, 0),          # transparent
                1: (255, 255, 255, 255),  # white
                2: (207, 63, 40, 255),    # red
                3: (233, 197, 84, 255),   # gold
            }
            image.putpixel((x,y), colors[color_index])
    return image

result = Image.new("RGBA", (16,16))
positions = [
    (0, 0),
    (8, 0),
    (0, 8),
    (8, 8)
]
for i, position in enumerate(positions):
    start = i * 16
    tile_data = chr_data[start:start+16]
    tile = decode_tile(tile_data)
    result.paste(tile, position)
result.save(output_path)

print(f"Reconstructed image saved to {output_path}")