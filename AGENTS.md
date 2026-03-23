# Project Instructions

Develop the game in an iterative fashion: develop a single piece of functionality and then stop so the progress can be playtested by a human. Always keep the game playable after each step so it can be validated by human testers. godot is available on the bash command line. You can run it to see errors in your godot scripts so you can fix them.

## Game Engine & Language

- **Engine**: Godot 4.5 (GDScript)
- **Target Platform**: Desktop (Windows, macOS, Linux) initially
- **Graphics**: 2D sprite-based with tilemaps
- **Audio**: Sound effects and background music

## Game Overview

**Paladin's Path** is a 2D dungeon crawler where the player acts as the paladin's patron deity, guiding their hero through randomly generated dungeons. The paladin automatically explores and fights monsters while the player manipulates the dungeon layout to create advantageous paths and prevent the paladin from taking on too-strong monsters before they are ready.

### Core Concept
- **Auto-Battler**: The paladin moves and fights automatically based on AI
- **Deity Role**: Player acts as the paladin's divine patron, influencing the dungeon
- **Unique Mechanic**: Click any floor tile to rotate walls/doorways around it clockwise. Shift-click will rotate counterclockwise.

## Game Mechanics

### The Paladin
- Automatically explores the dungeon grid by semi-randomly choosing an unblocked direction
- Prioritizes moving towards stairs then monsters and finally empty rooms.
- If a room is empty and is the previous one the paladin was in, they will avoid moving back to it.
- Fights monsters automatically when in range
- Gains XP from kills and levels up periodically
- Has health, attack power, and special abilities that improve with level

### Dungeon Generation
- Grid-based layout (e.g., 20x20 tiles per level)
- Each tile has four sides: North, East, South, West
- Each side is either a **Wall** or a **Doorway**
- Randomly generated at the start of each level
- Stairs are placed in a reachable location

### The Rotation Mechanic (Deity Power)
When the player clicks on any floor tile:
1. All four sides of that tile rotate clockwise
2. Example: If North=Wall, East=Doorway, South=Wall, West=Doorway
   - After rotation: North=Doorway, East=Wall, South=Doorway, West=Wall
   - The shared side of any adjoining rooms must be updated to reflect the state change of their wall/doorway.
3. This can create new paths or block enemy movement
4. Strategic use can funnel monsters or create safe zones

### Combat System
- Turn-based combat (paladin acts when ready)
- Monsters have health and attack power
- XP system for paladin progression
- Different monster types with varying behaviors

## Game Flow

1. **Level Generation**: Create new dungeon with random layout
2. **Paladin Spawning**: Place paladin at starting position
3. **Monster Placement**: Spawn monsters in various tiles, but not on paladin starting position.
4. **Stairs Placement**: Place exit stairs randomly, but not where paladin spawns.
5. **Game Loop**:
   - Paladin moves and fights automatically
   - Player can rotate walls/doorways to influence pathing
   - When paladin reaches stairs, generate next level
6. **Progression**: Each level may be harder. Game culminates with a final dungeon boss at the bottom of the dungeon (level 10?).

## Key Features to Implement

1. **Tile Rotation System**
   - Store wall/doorway configuration per tile side
   - Implement clockwise rotation logic
   - Visual feedback for rotation

2. **Pathfinding AI**
   - Paladin finds path to nearest monster or stairs
   - Respects current wall/doorway layout
   - Recalculates when layout changes

3. **Combat System**
   - Turn-based with cooldowns
   - Damage calculation based on levels
   - XP and leveling system

4. **Visual Feedback**
   - Show rotation capability on hover
   - Indicate current tile state clearly
   - Smooth rotation animation

## User Experience

1. Player sees the dungeon grid with clear visual distinction between walls and doorways
2. Hovering over a floor tile shows which sides would change
3. Clicking rotates the tile with satisfying animation
4. Paladin moves smoothly through the dungeon
5. Combat animations show damage dealt
6. UI displays paladin stats, current level, and XP

## Success Metrics

- Paladin can complete 10+ levels without dying
- Players find strategic uses for rotation mechanic
- Game feels responsive with smooth animations
- Random generation creates varied experiences each playthrough
