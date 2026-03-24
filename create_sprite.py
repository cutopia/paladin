from PIL import Image, ImageDraw
import os

# Ensure assets/sprites directory exists
os.makedirs('assets/sprites', exist_ok=True)

# Create a 64x64 spritesheet with all 16 possible wall/doorway combinations (2^4)
# Each row = North state, each column = East state. South and West are determined by rotation.
# Image dimensions: 16 tiles x 4 rows? Wait no - we need 4 sides for each tile configuration.

# Actually: 4 sides -> 16 states total
# We'll create a grid where:
#   X-axis (columns) = East state (0=Wall, 1=Door)
#   Y-axis (rows) = North state (0=Wall, 1=Door)
# Then South and West are computed from the rotation.

# But for visualization, we want to see all four sides at once per tile.
# Let's create a 4x4 grid of tiles in the spritesheet.

sprite_size = 64
total_tiles = 16

# Create new image with space for all 16 tiles (4x4)
img_width = sprite_size * 4
img_height = sprite_size * 4
spritesheet = Image.new('RGB', (img_width, img_height), (255, 255, 255))
draw = ImageDraw.Draw(spritesheet)

def get_tile_sprite(north, east, south, west):
    # Create a single tile with the specified states
    # This will be drawn on the spritesheet at position (x * sprite_size, y * sprite_size)
    
    # For each side:
    #   Wall = black border line
    #   Doorway = white border line
    
    # Draw the tile background
    for x in range(sprite_size):
        for y in range(sprite_size):
            r, g, b = 80, 80, 90
            if (x % 16 == 0) or (y % 16 == 0):  # Grid lines
                r, g, b = 60, 60, 70
            draw.point((x, y), (r, g, b))
    
    # Draw borders based on states:
    if north == 0:  # Wall top
        for x in range(sprite_size):
            draw.line([(x, 0), (x, 1)], fill=(0, 0, 0))  # Top border is black wall
    else:  # Door top
        for x in range(sprite_size):
            draw.line([(x, 0), (x, 1)], fill=(255, 255, 255))  # White door
    
    if east == 0:  # Wall right
        for y in range(sprite_size):
            draw.line([(sprite_size-1, y), (sprite_size, y)], fill=(0, 0, 0))
    else:
        for y in range(sprite_size):
            draw.line([(sprite_size-1, y), (sprite_size, y)], fill=(255, 255, 255))
    
    if south == 0:  # Wall bottom
        for x in range(sprite_size):
            draw.line([(x, sprite_size-1), (x, sprite_size)], fill=(0, 0, 0))
    else:
        for x in range(sprite_size):
            draw.line([(x, sprite_size-1), (x, sprite_size)], fill=(255, 255, 255))
    
    if west == 0:  # Wall left
        for y in range(sprite_size):
            draw.line([(0, y), (1, y)], fill=(0, 0, 0))
    else:
        for y in range(sprite_size):
            draw.line([(0, y), (1, y)], fill=(255, 255, 255))
    
    return spritesheet

# Generate all combinations
for i in range(16):  # 16 possible states (4 bits)
    north = (i >> 3) & 1  # Bit 3
    east = (i >> 2) & 1   # Bit 2
    south = (i >> 1) & 1  # Bit 1
    west = i & 1          # Bit 0
    
    # Calculate position in grid
    x_pos = (i % 4) * sprite_size
    y_pos = (i // 4) * sprite_size
    
    # Create the tile image and paste it into spritesheet
    tile_img = get_tile_sprite(north, east, south, west)
    spritesheet.paste(tile_img, (x_pos, y_pos))

# Save the final spritesheet
spritesheet.save('assets/sprites/tile_sprites.png')
print("Created assets/sprites/tile_sprites.png with all 16 wall/doorway combinations")