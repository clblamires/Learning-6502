# here we go!!!!

from pathlib import Path
from PIL import Image

# locate folders
BASE_DIR = Path(__file__).resolve().parent
SOURCE_DIR = BASE_DIR.parent / "graphics" / "original"
OUTPUT_DIR = BASE_DIR.parent / "graphics" / "chr"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True) # make the director just in case

# discover colors in an image
def getColorMap( image ):
    pixels = list(image.getdata())
    visible_colors = {
        pixel for pixel in pixels if pixel[3] == 255
    } # ignores transparent pixels, which is important for NES sprites

    if len(visible_colors) > 3:
        raise ValueError(f"Too many colors in image: {len(visible_colors)}. NES sprites can only have 3 visible colors.")
    
    sorted_colors = sorted(visible_colors)

    color_map = {
        color: index + 1 for index, color in enumerate(sorted_colors)
    }
    return color_map


# convert tile to bitplanes
def encodeTile( image, color_map ):
    plane0 = []
    plane1 = []

    for y in range(8):
        byte0 = 0
        byte1 = 0
        for x in range(8):
            pixel = image.getpixel((x,y))
            if pixel[3] == 0:
                color_index = 0 # transparent!
            else:
                color_index = color_map[pixel]
            
            bit0 = color_index & 1
            bit1 = (color_index >> 1) & 1
            byte0 |= (bit0 << (7-x))
            byte1 |= (bit1 << (7-x))
        plane0.append(byte0)
        plane1.append(byte1)
    return bytes(plane0 + plane1)


# convert character image
def encodeCharacter(image):
    width, height = image.size
    if width % 8 != 0 or height % 8 != 0:
        raise ValueError(f"Image dimensions must be multiples of 8. Got {width}x{height}.")

    color_map = getColorMap(image)
    chr_data = bytearray()
    
    for tile_y in range(0, height, 8):
        for tile_x in range(0,width,8):
            tile = image.crop((
                tile_x,
                tile_y,
                tile_x + 8,
                tile_y + 8
            ))
            tile_data = encodeTile(tile, color_map)
            chr_data.extend(tile_data)
    return chr_data, color_map


# process all images in the source folder
png_files = sorted(SOURCE_DIR.glob("*.png"))
if not png_files:
    print(f"No PNG files found in {SOURCE_DIR}.")
    raise SystemExit(1)

successful = 0
failed = 0

for png_path in png_files:
    print(f"Processing {png_path.name}...")
    try:
        image = Image.open(png_path).convert("RGBA")
        chr_data, color_map = encodeCharacter(image)
        output_path = OUTPUT_DIR / f"{png_path.stem}.chr"
        output_path.write_bytes(chr_data)
        print("  Dimensions:", image.size)
        print("  Colors:")

        for color, index in color_map.items():
            print(f"    Index {index}: {color}")

        print("  CHR bytes:", len(chr_data))
        print("  Saved:", output_path.name)

        successful += 1
    except Exception as e:
        print(f"  Failed to process {png_path.name}: {e}")
        failed += 1


# final report
print("\nProcessing complete.")
print(f"  Successful: {successful}")
print(f"  Failed: {failed}")
print(f"  Output directory: {OUTPUT_DIR}")