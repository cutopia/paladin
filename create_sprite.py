from PIL import Image
import random

# Create a 64x64 dungeon floor sprite
img = Image.new('RGB', (64, 64), (80, 80, 90))
pixels = img.load()

# Add some texture and variation to the floor tiles
for y in range(64):
    for x in range(64):
        # Base color with slight variations
        base_r, base_g, base_b = 80, 80, 90
        
        # Add noise for texture
        noise = random.randint(-15, 15)
        
        r = max(0, min(255, base_r + noise))
        g = max(0, min(255, base_g + noise))
        b = max(0, min(255, base_b + noise))
        
        pixels[x, y] = (r, g, b)

# Add some grid lines to make it look like tiles
for x in range(0, 64, 16):
    for y in range(64):
        pixels[x, y] = (60, 60, 70)
        
for y in range(0, 64, 16):
    for x in range(64):
        pixels[x, y] = (60, 60, 70)

# Save the image
img.save('dungeon_floor.png')
print("Created dungeon_floor.png")
