# Universal Enhanced AI - Mod Documentation

## Overview

**Universal Enhanced AI** is a comprehensive GZDoom mod that dramatically enhances monster artificial intelligence with advanced pathfinding, group coordination, and optional stealth mechanics. Created by Joshua Hard (josh771), based on original work by Sterling Parker (Caligari87).

**Version:** 3.5
**Source Location:** `~/games/DooM/Universal_Enhanced_AI/`
**Type:** Universal compatibility mod (works with any IWAD/mod)

## Core Features

### 1. Advanced Search & Chase AI

The mod replaces Doom's simple "see player → attack, lose sight → forget" AI with a sophisticated three-state system:

#### Normal Mode
- Standard Doom AI behavior
- Monster tracks player while in line of sight
- Builds up "aggro cooldown" (1-5 seconds) while seeing the player
- When LOS is lost for the full cooldown period, transitions to Chasing mode

#### Chasing Mode (1-2 minutes)
- Monster remembers the player's **last known position** and **velocity vector**
- Creates a dynamic search path using intelligent prediction
- Sets the first path node as a goal and actively pursues it
- Reaches waypoints progressively along the path
- If monster reacquires the player as a target, immediately returns to Normal mode
- When reaching the final waypoint OR timer drops below 30 seconds, transitions to Searching mode

#### Searching Mode (30-120 seconds)
- Monster actively wanders the area around last known position
- Uses `A_Wander()` calls every 5 tics for realistic patrol behavior
- Continues searching until timer expires or player is reacquired
- After timeout, returns to Normal mode and gives up the hunt

**Key Implementation Details:**
- State machine in `search.txt:18-131`
- Countdown timer ranges: 35-175 tics (aggro), 60-120 seconds (chase), 30 seconds minimum (search)
- Monsters ignore SHADOW-flagged targets (stealth integration)
- Works seamlessly with Doom's existing AI states (Pain, Death, etc.)

### 2. Intelligent Pathfinding System

The mod creates invisible path nodes to guide monsters through complex level geometry:

#### Path Node Generation
- Creates `EAI_PathNode` actors (invisible, non-solid markers)
- **Node 0:** Last seen position of player
- **Node 1:** Predicted position = last position + (velocity × random multiplier 17.5-52.5)
- **Nodes 2-7:** Six random radial search points around the predicted position

#### Path Management
- Uses line tracing (`LineTrace`) to ensure paths don't penetrate walls
- Nodes positioned 8 units before obstacles for clearance
- Path array acts as FILO queue (first-in-last-out)
- Automatically destroys nodes when:
  - Monster reaches them (`PopPath()`)
  - Monster reacquires player (`ClearPath()`)
  - Monster dies (`ClearPath()`)

**Debug Mode:**
- Nodes visible as AMRK sprites when `EAI_Debug = true`
- Useful for visualizing AI behavior and troubleshooting

**Implementation:** `path.txt:1-79`

### 3. Group Coordination & Intelligence Sharing

Monsters communicate and coordinate their search efforts:

#### Intelligence Sharing (`GetHelp()`)
- Triggered when monster sees the player OR creates a search path
- Scans 512-unit radius for allied monsters
- Shares intel including:
  - Last known player position (`pathPos`)
  - Player velocity vector (`pathHeading`)
  - Time since last sighting (`seeTics`)
  - Search timer (60-120 seconds)

#### Intel Acceptance Criteria
Nearby monsters only accept shared intel if:
- They have no target OR worse intel (higher `seeTics`)
- They aren't ambush-flagged or dead
- They're visible to the sharing monster
- They don't have a different, better target

#### Coordinated Search Behavior
- Alerted monsters create their own search paths
- If ally is closer to last known position, includes ally position as first waypoint
- Creates flanking/converging search patterns
- All monsters transition to Chasing mode simultaneously

**Implementation:** `group.txt:1-63`

### 4. Light-Based Stealth System

**Optional Feature** - Configurable via menu settings

#### Stealth Mechanics
The mod calculates real-time visibility based on:
- **Sector light level:** Base ambient lighting
- **Dynamic lights:** Torches, projectiles, monster attacks, etc.
  - Distance falloff calculation
  - Spotlight angle considerations
  - RGB average intensity
  - Very close lights (<2× player radius) heavily penalize stealth
- **Player movement:** Velocity reduces stealth
- **Crouching:** Increases stealth effectiveness

#### Stealth Value (0-100)
- Increases when in darkness below threshold
- Decreases when in bright areas above threshold
- Rate: ±5 points per frame (clamped)
- **At 100:** Player gains `SHADOW` flag (monsters cannot see you)
- **At 0:** Player loses `SHADOW` flag (fully visible)

#### Stealth Threshold Formula
```
threshold = (EAI_StealthFactor / crouchfactor) - velocity.length()
```
- **Default StealthFactor:** 24
- **Crouching** (0.5 factor): Doubles effective threshold to 48
- **Moving fast:** Reduces threshold proportionally

#### Visual Feedback Shader
- Post-process shader (`eai_stealth.fp`) provides player feedback
- **Effect:**
  - Desaturates screen colors (converts to grayscale) based on stealth level
  - Adds blue tint to indicate hidden status
  - Intensity scales linearly with stealth value (0-100)
- **Purpose:** Player knows how hidden they are without HUD elements

**Implementation:** `stealth.txt:1-70`, `shaders/eai_stealth.fp:1-5`

## Technical Architecture

### Event Handler System
```
EnhancedAIHandler (main.txt:1-13)
├── WorldThingSpawned: Gives EnhancedAIScript to all spawned monsters
└── PlayerEntered: Gives EAI_StealthScript to all players
```

### Inventory-Based AI
- `EnhancedAIScript`: Attached to every monster
  - Runs `DoEffect()` every tic
  - Manages AI state machine
  - Handles pathfinding and coordination
  - Self-destructs if attached to player (safety check)

- `EAI_StealthScript`: Attached to players
  - Calculates light levels and stealth value
  - Sets/clears SHADOW flag
  - Controls visual shader

### Module Structure
```
zscript.txt (entry point)
├── main.txt - Event handlers, base AI script class
├── search.txt - Three-state AI behavior, search logic
├── path.txt - Pathfinding, node creation/management
├── group.txt - Coordination, intel sharing
└── stealth.txt - Light calculations, stealth mechanics
```

## Configuration

### CVars (`cvarinfo.txt`)
```
server bool EAI_Debug = false
  - Enables console logging of AI state transitions
  - Makes path nodes visible (AMRK sprites)
  - Shows light level calculations in stealth mode

server bool EAI_Stealth = true
  - Enables/disables entire stealth system
  - No performance impact when disabled

server float EAI_StealthFactor = 24
  - Light level threshold for stealth detection
  - Range: 24-64 (adjustable in menu)
  - Higher = easier to hide in shadows
  - Lower = requires darker areas
```

### In-Game Menu
Access via: **Options → Universal Enhanced AI**

- **Light-based Stealth:** On/Off toggle
- **Stealth Threshold:** Slider (24-64, step 8)
  - 24 (Default): Balanced stealth
  - 32-40: Moderate difficulty
  - 48-64: Easy stealth, hide in dimmer areas

## Gameplay Impact

### Monster Behavior Changes
- **Persistence:** Monsters don't immediately forget when you break LOS
- **Prediction:** They anticipate where you're going based on your movement
- **Coordination:** Groups search more effectively than individuals
- **Duration:** Can hunt for 2+ minutes before giving up
- **Ambush Flag:** Respected - ambush monsters don't coordinate until first activated

### Player Strategy Implications
1. **Hit-and-run is harder:** Breaking LOS is just the start, not the end
2. **Movement matters:** Velocity affects both prediction and stealth
3. **Light awareness:** Dark areas become tactical assets with stealth enabled
4. **Sound discipline:** While mod doesn't add sound detection, monsters will coordinate if one spots you
5. **Timeout exploitation:** Can wait out search timers in safe locations

### Stealth Gameplay
- **Viable in dark sectors:** <24 light level with default settings
- **Crouching essential:** Doubles effective threshold
- **Movement penalty:** Sprinting makes you visible even in darkness
- **Dynamic light awareness:** Fireballs, explosions, and torch-wielding enemies reveal you
- **SHADOW flag:** When fully hidden, you're completely invisible (not just harder to see)

## Compatibility

### Works With
- **Any IWAD:** Doom, Doom II, Heretic, Hexen, etc.
- **Monster mods:** Automatically applies to all monsters with `bIsMonster` flag
- **Map packs:** No special map features required
- **Other gameplay mods:** Non-intrusive design

### Potential Conflicts
- **Other AI mods:** May conflict if they also modify monster behavior
- **Stealth mods:** Disable `EAI_Stealth` if using another stealth system
- **Custom monster AI:** Monsters with custom DoEffect() may not receive EnhancedAIScript

### Requirements
- **GZDoom** (version supporting ZScript 3.5+)
- **Hardware:** Shader support for stealth visual effects (optional)

## Performance Considerations

### Optimizations
- Path nodes only created when needed (on LOS loss)
- Maximum 8 nodes per monster (1 + 1 + 6)
- Nodes automatically cleaned up
- Intelligence sharing limited to 512-unit radius
- Stealth calculations only run for players
- Light iteration skips non-visible lights

### Performance Impact
- **Minimal:** Event handler overhead is negligible
- **Path creation:** Brief spike when monster loses LOS
- **Stealth:** Light iteration is most expensive, but only affects players
- **Coordination:** Scales with monster density (more monsters = more intel sharing)

## Debug Features

Enable with `EAI_Debug = true`:

### Console Output
```
[MonsterClass] switch to chasing
[MonsterClass] path marker reached; continuing
[MonsterClass] switch to searching
[MonsterClass] searching for [seconds]
[MonsterClass] reacquired
[MonsterClass] gave up the search
[MonsterClass][A] found ally [AllyClass][B]
...but [AllyClass][B] had better intel.
...and shared intel with them!
Stealth [value] - LightLevel [level] - threshold [threshold]
```

### Visual Indicators
- Path nodes visible as purple markers (AMRK sprite)
- Helps visualize search patterns and AI decision-making

## Credits

**Original Code:** Sterling Parker (Caligari87)
- Original SearchBehavior() implementation
- Stealth system adapted from "Ugly as Sin" module for Hideous Destructor

**Universal Enhanced AI Modification:** Joshua Hard (josh771)
- Universal compatibility adaptation
- Pathfinding system
- Group coordination features
- Stealth integration and refinement

## Integration Notes for Predators: Hellspawn Hunters Redux

This mod could complement the Predator-themed gameplay:

### Thematic Fit
- **Hunter AI:** Enhanced monster intelligence matches Predator's tactical hunting
- **Stealth synergy:** Predator's cloaking device + light-based stealth = dual stealth layers
- **Group tactics:** Coordinated monster hunts mirror Predator's strategic approach

### Potential Integration Points
1. **Stealth threshold tuning:** Adjust `EAI_StealthFactor` to balance with cloak effectiveness
2. **Energy siphon interaction:** Could make stealth harder when energy is low (increases light threshold)
3. **Smart disk coordination:** Monsters might coordinate more when disk is being used
4. **Self-destruct finale:** Enhanced AI makes escape more challenging during countdown

### Implementation Considerations
- Test interaction between `SHADOW` flag and existing cloak mechanics
- Verify path nodes don't interfere with smart disk collision
- Consider disabling stealth shader if it conflicts with predator vision modes
- May need to adjust search timers for faster-paced Predator gameplay

## File Reference

```
Universal_Enhanced_AI/
├── cvarinfo.txt          - Console variable definitions
├── gldefs.txt            - Shader registration
├── mapinfo.txt           - Event handler registration
├── menudef.txt           - In-game options menu
├── zscript.txt           - ZScript entry point
├── shaders/
│   └── eai_stealth.fp    - Stealth vision shader (GLSL)
└── zscript/enhancedAI/
    ├── main.txt          - Event handlers, base classes
    ├── search.txt        - AI state machine logic
    ├── path.txt          - Pathfinding system
    ├── group.txt         - Coordination system
    └── stealth.txt       - Light-based stealth
```

## License

Original work by Caligari87 and josh771. License not specified in mod files - check with original authors for usage permissions.
