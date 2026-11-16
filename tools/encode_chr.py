from pathlib import Path
from PIL import Image

base_dir = Path(__file__).resolve().parent
tile_dir = base_dir.parent / "graphics" / "tiles" / "flee"
output_dir = base_dir.parent / "graphics" / "chr"
output_dir.mkdir(parents=True, exist_ok=True)

# map our PNG colors to NES color indices
color_map = {
    (255,255,255,255): 1,    #white
    (207,63,40,255): 2,      #red
    (233,197,84,255): 3,     #gold
}

def encode_tile(image):
    plane0 = []
    plane1 = []

    # process rows
    for y in range(8):
        byte0 = 0
        byte1 = 0
        for x in range(8):
            pixel = image.getpixel((x,y))
            if pixel[3] == 0:
                color_index = 0 # transparent
            else:
                color_index = color_map[pixel]
            
            bit0 = color_index & 1
            bit1 = (color_index >> 1) & 1
            byte0 |= (bit0 << (7-x))
            byte1 |= (bit1 << (7-x))
        plane0.append(byte0)
        plane1.append(byte1)
    return bytes(plane0 + plane1)

tile_names = [
    "tile_0_top_left.png",
    "tile_1_top_right.png",
    "tile_2_bottom_left.png",
    "tile_3_bottom_right.png"
]

chr_data = bytearray()

for name in tile_names:
    image = Image.open(tile_dir / name).convert("RGBA")
    if image.size != (8,8):
        raise ValueError(f"Expected an 8x8 tile, got {image.size} for {name}")
    tile_data = encode_tile(image)
    chr_data.extend(tile_data)
    
    print(f"Encoded {name}: {len(tile_data)} bytes")
    print(" ".join(f"{b:02X}" for b in tile_data))

output_file = output_dir / "flee.chr"
output_file.write_bytes(chr_data)

print(f"CHR data written to {output_file} ({len(chr_data)} bytes)")