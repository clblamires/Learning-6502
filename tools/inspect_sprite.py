from PIL import Image

# Open the image
image = Image.open("../graphics/original/flee.png") # start with Flee

image = image.convert("RGBA")  # Convert to RGBA mode
width, height = image.size

print(f"Image size: {width}x{height}")

colors = set(image.getdata())

print(f"Number of unique colors: {len(colors)}")

for color in colors:
    print(color)