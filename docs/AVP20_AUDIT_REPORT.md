# AVP20 Mod Audit Report
## Predator Features Analysis for Hellspawn Hunters Redux Integration

**Audit Date:** December 26, 2025
**Source Mod:** AVP20_Final_WIP
**Target Mod:** predators-hellspawn-hunters-redux
**Focus:** Predator-only features and mechanics

---

## Executive Summary

This report analyzes the AVP20_Final_WIP mod to identify predator-related features that could potentially enhance the predators-hellspawn-hunters-redux mod. The analysis focuses on two main areas:

1. **Weapon Sprite System** - Advanced composite sprite architecture
2. **Mechanics** - Energy management and special abilities

### Key Findings

- **Sprite System**: AVP20 uses a sophisticated modular sprite system that is significantly more advanced than the current implementation
- **Energy Siphon**: AVP20 implements an "Accumulator" weapon that regenerates energy
- **Weapon Variety**: AVP20 has a more extensive predator arsenal with better visual consistency
- **Target Lock System**: Advanced target acquisition with progressive lock-on mechanics

---

## 1. Weapon Sprites & Textures Analysis

### 1.1 Current Mod Implementation (Hellspawn Hunters Redux)

**Architecture:**
- Uses standard DECORATE sprite definitions
- Direct sprite file references (e.g., `WRST`, `PRCL`, `DBLD`, `DPCA`)
- Individual PNG files per sprite frame
- Located in: `src/SPRITES/WEAPONS/PLASMACASTER/`

**Sprite Files Found:**
```
DPCAA0.png - DPCAF0.png (6 frames)
PCASA0.png - PCASC0.png (3 frames)
PCIGA0.png (1 frame)
LSITA0.png (laser sight)
```

**Current Plasma Caster:**
- Actor defined in: `src/DECORATE.Weapons:710`
- Uses simpler sprite animation
- No composite sprite system
- Less sophisticated visual effects

### 1.2 AVP20 Implementation

**Architecture:**
- **Modular Composite Sprite System**
- Base patch library: 22 PHAND*.png files
- TEXTURES lump defines sprite composition (3517 lines)
- Multiple weapons share same base patches
- Located in: `src/Graphics/Weapons/Predator/WRISTS/`

**Base Patch Library:**
```
PHAND01.png - PHAND06.png  → Wrist/hand poses
PHAND07.png - PHAND14.png  → Extended hand animations
PHAND15.png                → Shoulder-mounted plasma caster device
PHAND16.png - PHAND24.png  → Additional weapon elements
```

**Special Files:**
```
src/Graphics/Weapons/Predator/SPEARGUN/PHAND17.png
src/Graphics/Weapons/Predator/SPEARGUN/PHAND18.png
```

**Plasma Caster Sprite Prefixes (AVP20):**

| Prefix | Purpose | Definition Location |
|--------|---------|---------------------|
| `PCSL` | Weapon select/deselect and firing animations | TEXTURES:2925-3187 |
| `PCSN` | Idle/ready state animations | TEXTURES (referenced) |
| `PPCZ` | Zoomed view (laser sight active) | Used in code, shared across weapons |

**Example Sprite Definition (from TEXTURES):**
```
Sprite PCSLA0, 439, 176
{
    XScale 1.800
    YScale 1.800
    Offset 57, -152
    Patch PHAND06, -163, 112
    Patch PHAND06, 200, 83
    {
        FlipX
    }
}
```

### 1.3 Key Differences

| Feature | Current Mod | AVP20 |
|---------|-------------|-------|
| **Sprite System** | Direct sprite files | Composite patch system |
| **Resource Efficiency** | 1 sprite = 1 file | 22 patches → hundreds of sprites |
| **Consistency** | Individual artwork per weapon | Shared patches ensure consistency |
| **Flexibility** | Limited to pre-rendered sprites | Mix/match patches dynamically |
| **File Size** | Larger (duplicate elements) | Smaller (shared resources) |
| **Animation Quality** | Good | Excellent (smoother transitions) |
| **Weapon Raising Animation** | Simple | Complex multi-stage (PCSL A-G) |
| **Idle Animation** | Static or simple | Breathing cycle (PCSN A-E) |
| **Zoom View** | Basic | Dedicated PPCZ sprites |

### 1.4 Wrist Blades Comparison

**Current Mod (Hellspawn Hunters):**
- Actor: `Wristblade` (DECORATE.Weapons:5)
- Sprites: `WRST` (ready), `PRCL` (idle), `PRAT` (attack)
- Simple animation sequences
- Direct sprite references

**AVP20:**
- Actor: `HuntersCLAWS` (Wristblades.txt:1)
- Sprites: `DBLD` (deploy), `DBLN` (ready), `DBLA` (attack), `PPCZ` (zoom)
- Complex combo system with left/right attacks
- Uses composite PHAND patches for consistency
- Target lock-on integration
- Zoom functionality
- Laser sight support

---

## 2. Mechanics Analysis

### 2.1 Energy Siphon / Accumulator System

**AVP20 Implementation:**

**File:** `src/Actors/Weapons/Predator/Accumulator.txt`

**Core Concept:**
- Replaces the Fist weapon
- Passive energy regeneration weapon
- Cannot be dropped or tossed
- Restricted to Predator class only

**Key Features:**

1. **Energy Regeneration:**
   - Generates 1 energy per tic (multiplied by berserk count)
   - Maximum capacity: 999 energy
   - Auto-switches away when full
   - Loop sound while charging: `/predator/TRALOOP`
   - Completion sound: `/predator/TRALOOPS`

2. **Visual Feedback:**
   - Sprite: `TROF` with animated frames A-H
   - Bright frames (E, F, G, H) indicate active charging
   - Smooth animation cycle during energy accumulation

3. **Special Interactions:**
   - Automatically cancels invisibility/cloak when activated
   - Integrates with self-destruct system
   - Cannot be used while self-destruct is active
   - Checks for berserk powerup to boost regeneration

4. **Code Structure:**
```decorate
Charge:
    TROF A 1 A_GiveInventory ("Energy", 1*CallACS("BerserkCount"))
    TNT1 A 0 A_JumpIfInventory("Energy", 999, "EnergyFull")
    TROF E 1 BRIGHT A_GiveInventory ("Energy", 1*CallACS("BerserkCount"))
    [... continues through animation cycle ...]
```

**Energy Usage in AVP20:**

All predator weapons consume "Energy" ammo:
- **Plasma Caster:** 50 energy (normal), 100 energy (charged railshot)
- **Plasma Blaster:** Energy-based (file: PlasmaBlaster.txt)
- **Smart Disk:** 25 energy per throw
- **Spear Gun:** Energy consumption
- **Combi Stick:** Energy integration

**Current Mod Status:**
- No equivalent energy siphon/accumulator weapon found
- Weapons appear to use different ammo systems
- No unified energy regeneration mechanic

### 2.2 Target Lock-On System

**AVP20 Implementation:**

**Features:**
- Progressive 5-stage lock-on system
- Visual feedback through crosshair changes
- Audio cues for each lock stage
- ACS script integration (`TargetLockOn`, `TargetLock2-5`)
- Shared across multiple weapons (Plasma Caster, Smart Disk, Wrist Blades)

**Lock-On Stages:**
```
Stage 1: Initial detection → TargetLockOn
Stage 2: Tracking begins  → TargetLock2
Stage 3: Lock building    → TargetLock3
Stage 4: Near lock        → TargetLock4
Stage 5: Full lock        → TargetLock5 + CrosshairLockedOn
```

**Integration:**
- Plasma Caster: Enhances projectile seeking behavior
- Smart Disk: Improves disk tracking
- Wrist Blades: Zoom targeting assistance

**Current Mod:**
- No progressive lock-on system found
- Basic targeting only

### 2.3 Zoom System

**AVP20 Implementation:**

**Multi-Level Zoom:**
- Level 1: 2.0x zoom
- Level 2: 4.0x zoom
- Level 3: 8.0x zoom
- Progressive cycling with audio feedback
- Dedicated `PPCZ` sprite set for zoomed view
- Inventory-based tracking (`PredZoom` with max 3)

**Weapons with Zoom:**
- Plasma Caster (primary weapon with zoom)
- Wrist Blades (tactical zoom)
- Smart Disk (targeting zoom)
- Spear Gun (referenced in docs)
- Combi Stick (referenced in docs)

**Zoom Features:**
- Laser sight integration (spawns LaserSightSpawner while zoomed)
- Separate fire states when zoomed
- Automatic zoom cancellation on weapon switch
- Sound effects: `/predator/pzoomin`, `/predator/pzoomout`

**Current Mod:**
- Basic zoom may exist but less sophisticated
- No multi-level progressive zoom found

### 2.4 Laser Sight System

**AVP20 Implementation:**

**Components:**
1. **LaserSightSpawner:** Projectile that places laser sight
2. **PlasmaCasterLasersight:** Visual indicator actor
3. Integration with zoom system
4. Toggle-able feature (`LSToggler` inventory)

**Features:**
- Spawns at crosshair position
- Visual feedback for aim point
- Works in both normal and zoomed modes
- Small scale (0.08) for precision
- Continuously updated during ready state

**Current Mod:**
- `LaserSightSpawner` exists (DECORATE.Weapons:825)
- `PlasmaCasterLasersight` exists (DECORATE.Weapons:845)
- Similar but possibly less sophisticated implementation

### 2.5 Additional AVP20 Mechanics

**Self-Destruct System:**
- File: `src/Actors/Weapons/Predator/SelfD.txt`
- Countdown sequence (3-2-1-0)
- Visual sprites: `SEDS A-D`
- Integrates with multiple weapons
- Cannot use Accumulator during countdown
- ACS script: `Destruct`

**Hack System:**
- File: `src/Actors/Weapons/Predator/Hack.txt`
- Predator-specific utility
- Started with player class

**HProtect (Health Protection):**
- File: `src/Actors/Weapons/Predator/HProtect.txt`
- Defensive capability
- Started with player class

**Cloak/Invisibility:**
- Integration with Accumulator (auto-disables cloak)
- Cloak sounds: `/predator/cloakoff`
- Inventory flags: `XXPowerInvisibility`, `CloakON`

---

## 3. Weapon Arsenal Comparison

### 3.1 AVP20 Predator Weapons

Complete arsenal from `src/Actors/Weapons/Predator/`:

1. **Accumulator.txt** - Energy regeneration weapon
2. **Wristblades.txt** (HuntersCLAWS) - Melee weapon with combos
3. **CombiStick.txt** - Throwable/melee hybrid
4. **PlasmaCaster.txt** - Shoulder-mounted plasma weapon
5. **PlasmaBlaster.txt** - Handheld plasma weapon
6. **SmartDisk.txt** - Throwable disc weapon
7. **SpearGun.txt** - Projectile weapon
8. **HProtect.txt** - Defensive utility
9. **Hack.txt** - Utility tool
10. **SelfD.txt** - Self-destruct device
11. **PredAmmo.txt** - Ammo definitions

**Weapon Slot Assignment (PredatorClass.txt:56-62):**
```
Slot 1: HuntersCLAWS
Slot 2: CombiSTICK
Slot 3: PlasmaBLASTER
Slot 4: SpearGun
Slot 5: SmartDisk
Slot 6: PlasmaCASTER
Slot 7: Accumulator
```

### 3.2 Current Mod Predator Weapons

From `src/DECORATE.Weapons`:

1. **Wristblade** - Basic melee (line 5)
2. **PlasmaCaster** - Plasma weapon (line 710)
3. **PlasmaBomber** - Grenade launcher (line 1089, AssaultPredator only)

**Additional References:**
- Various predator classes (Light, Hunter, Heavy, Assault)
- Class-specific weapon restrictions

### 3.3 Missing Weapons in Current Mod

The following AVP20 weapons are not present:

1. **Accumulator** - Energy regeneration system
2. **CombiStick** - Versatile spear weapon
3. **PlasmaBlaster** - Secondary plasma weapon
4. **SmartDisk** - Disc weapon
5. **SpearGun** - Ranged spear launcher
6. **HProtect** - Defensive utility
7. **Hack** - Utility tool
8. **SelfD** - Self-destruct

---

## 4. Integration Recommendations

### 4.1 HIGH PRIORITY - Easy Wins

#### 4.1.1 Accumulator / Energy Siphon

**Recommendation:** **IMPLEMENT**

**Rationale:**
- Self-contained weapon system
- Enhances gameplay loop (energy management)
- Unique predator mechanic
- Low complexity, high value

**Implementation Steps:**
1. Copy `Accumulator.txt` to current mod
2. Add TROF sprite frames
3. Add sound files (`/predator/TRALOOP`, `/predator/TRALOOPS`, `/predator/TRAON`)
4. Integrate with player class starting inventory
5. Ensure Energy inventory type exists
6. Test energy regeneration rates

**Compatibility:**
- Should work with existing weapon system
- May need to adjust energy costs on current weapons
- No sprite system dependencies

**Estimated Effort:** Low (2-4 hours)

#### 4.1.2 Target Lock-On System

**Recommendation:** **CONSIDER**

**Rationale:**
- Enhances weapon feel and player feedback
- Works with existing weapons
- Moderate complexity

**Requirements:**
- Copy lock-on ACS scripts
- Add PredatorCrosshair inventory tracking
- Modify weapon ready states
- Add audio cues

**Estimated Effort:** Medium (4-8 hours)

### 4.2 MEDIUM PRIORITY - Enhanced Features

#### 4.2.1 Multi-Level Zoom System

**Recommendation:** **ENHANCE EXISTING**

**Rationale:**
- Current mod may have basic zoom
- AVP20's 3-level system is more polished
- Improves ranged weapon usability

**Implementation:**
- Add PredZoom inventory (max 3)
- Implement progressive zoom levels (2x, 4x, 8x)
- Add zoom sounds
- Optionally add PPCZ sprite set

**Estimated Effort:** Low-Medium (3-6 hours)

#### 4.2.2 Additional Weapons

**Recommendation:** **SELECTIVE PORTING**

**Priority Order:**
1. **SmartDisk** - Iconic predator weapon, adds variety
2. **CombiStick** - Melee/ranged hybrid, fills gameplay niche
3. **SpearGun** - Additional ranged option
4. **PlasmaBlaster** - Lower priority (similar to Plasma Caster)

**Considerations:**
- Each weapon requires sprites, sounds, and balancing
- May overlap with existing mod weapons
- Smart Disk has complex recall mechanics

**Estimated Effort per Weapon:** Medium-High (8-16 hours each)

### 4.3 LOW PRIORITY - Major Overhauls

#### 4.3.1 Composite Sprite System

**Recommendation:** **NOT RECOMMENDED FOR CURRENT MOD**

**Rationale:**
- Requires complete sprite asset overhaul
- TEXTURES lump is 3517 lines of sprite definitions
- Would need to recreate or port all 22+ PHAND patches
- Breaks existing weapon sprites
- Very high effort for visual improvement

**If Implemented:**
- Must port entire PHAND*.png library (22+ files)
- Copy relevant TEXTURES lump sections (2000+ lines)
- Rewrite all weapon actor sprite references
- Test every weapon animation
- Create new sprites for any unique current mod weapons

**Estimated Effort:** Very High (40-80+ hours)

**Alternative:**
- Keep current sprite system
- Optionally improve individual sprite quality
- Use composite system for NEW weapons only

#### 4.3.2 Self-Destruct System

**Recommendation:** **LOW PRIORITY**

**Rationale:**
- Fun feature but situational
- Requires careful balancing
- Integration with all weapons needed
- Better as "nice to have" than core feature

**Estimated Effort:** Medium (6-10 hours)

---

## 5. Technical Compatibility Assessment

### 5.1 Code Format

- **Current Mod:** DECORATE format
- **AVP20:** DECORATE format
- **Compatibility:** ✅ High - Same scripting language

### 5.2 Asset Dependencies

**Sound Files:**
- AVP20 uses `/predator/*` sound namespace
- Current mod likely has similar sounds
- May need to port specific sound files

**Sprite Dependencies:**
- Accumulator: Needs TROF sprites
- Weapons: Need respective sprite sets
- Composite system: Needs PHAND library + TEXTURES

**ACS Scripts:**
- Target lock system needs ACS implementation
- `BerserkCount` function used throughout
- `TargetLockOn` through `TargetLock5` functions
- `Destruct` function for self-destruct

### 5.3 Inventory System Integration

**AVP20 Inventory Types Used:**
- Energy (primary ammo)
- PredZoom (zoom level tracking)
- PredatorCrosshair (lock-on stages)
- CrosshairLockedOn (full lock flag)
- LSToggler (laser sight toggle)
- SelfDestuctTrigger (self-destruct activation)
- PowerStrength (berserk powerup)
- XXPowerInvisibility (cloak state)
- CloakON (cloak active)

**Current Mod:**
- Likely has Energy inventory
- May need to add AVP20-specific inventories

---

## 6. Recommended Integration Path

### Phase 1: Core Mechanics (Week 1-2)

1. **Accumulator Implementation**
   - Port Accumulator.txt
   - Add required sprites
   - Add sound files
   - Test energy regeneration

2. **Energy System Unification**
   - Ensure all weapons use "Energy" ammo type
   - Balance energy costs
   - Test energy economy

3. **Testing**
   - Verify energy regeneration rates
   - Check weapon switching
   - Ensure no conflicts with existing systems

### Phase 2: Enhanced Features (Week 3-4)

1. **Multi-Level Zoom**
   - Implement 3-level zoom system
   - Add PredZoom inventory
   - Add zoom sounds
   - Update Plasma Caster to use new zoom

2. **Target Lock-On (Optional)**
   - Port ACS scripts
   - Add crosshair tracking
   - Integrate with Plasma Caster
   - Test seeking missile behavior

### Phase 3: Additional Content (Month 2+)

1. **Smart Disk**
   - Port actor definition
   - Port sprites
   - Port sounds
   - Implement recall mechanics
   - Balance damage and energy cost

2. **CombiStick**
   - Port actor definition
   - Port sprites and sounds
   - Test throw/recall mechanics
   - Balance melee vs. ranged modes

### Phase 4: Polish (Ongoing)

1. **Wrist Blade Enhancement**
   - Optionally port AVP20's advanced combo system
   - Add left/right attack variations
   - Integrate zoom if desired

2. **Sound and Visual Polish**
   - Review all weapon sounds
   - Check sprite alignment
   - Ensure visual consistency

---

## 7. Asset Porting Checklist

### For Accumulator (Recommended First Port)

**Required Files:**

**Actor Definition:**
- [x] `Accumulator.txt` → Port to current mod DECORATE

**Sprites:**
- [ ] TROF sprites (A-H frames, with some bright variants)
  - Need to extract from AVP20 or create new

**Sounds:**
- [ ] `/predator/TRALOOP` (charging loop)
- [ ] `/predator/TRALOOPS` (charge complete)
- [ ] `/predator/TRAON` (activation)

**Inventory Types:**
- [x] Energy (likely already exists)
- [ ] HealthPointCount (max 300)
- [ ] SoundSTART (max 1)
- [ ] SelfDestuctTrigger (if implementing self-destruct)
- [ ] SelfDestUsed (if implementing self-destruct)
- [ ] PowerStrength (berserk, may already exist)
- [ ] XXPowerInvisibility (cloak, may already exist)
- [ ] CloakON (cloak state, may already exist)

**ACS Functions:**
- [x] `BerserkCount` (referenced in CallACS)
- [ ] Verify this function exists in current mod

**Integration Points:**
- [ ] Add to player class starting inventory
- [ ] Add to weapon slot (slot 7 in AVP20)
- [ ] Ensure energy max is 999

### For Smart Disk

**Required Files:**

**Actor Definition:**
- [ ] `SmartDisk.txt`
- [ ] Disk projectile actors
- [ ] Recall mechanics

**Sprites:**
- [ ] PDSK sprites (weapon view)
- [ ] Disk projectile sprites
- [ ] Effect sprites

**Sounds:**
- [ ] Launch sound
- [ ] Return sound
- [ ] Hit sounds
- [ ] Lock-on sounds (if using target lock)

**Inventory Types:**
- [ ] SDiskA (ammo)
- [ ] RecallDisk (recall flag)
- [ ] DiskCounter (tracking)

### For Target Lock System

**Required Files:**

**ACS Scripts:**
- [ ] `TargetLockOn`
- [ ] `TargetLock2`
- [ ] `TargetLock3`
- [ ] `TargetLock4`
- [ ] `TargetLock5`

**Inventory Types:**
- [ ] PredatorCrosshair (max 4)
- [ ] CrosshairLockedOn (max 1)

**Sounds:**
- [ ] Lock stage progression sounds (5 stages)
- [ ] Full lock sound

**Crosshair Graphics:**
- [ ] Stage 1-5 crosshair graphics
- [ ] Locked-on crosshair

---

## 8. Known Challenges and Risks

### 8.1 Sprite System Incompatibility

**Challenge:**
- AVP20's composite system is fundamentally different from current mod
- Porting individual weapons may require sprite recreation

**Mitigation:**
- Port weapons that don't rely on PHAND patches first (Accumulator)
- For PHAND-dependent weapons, either:
  - Option A: Port entire TEXTURES system (high effort)
  - Option B: Create standalone sprites (medium effort)
  - Option C: Use current mod's sprite style (low effort, less polished)

### 8.2 Energy Economy Balance

**Challenge:**
- AVP20's energy costs may not match current mod balance
- Accumulator regeneration rate needs tuning

**Mitigation:**
- Start with AVP20 values as baseline
- Playtest extensively
- Adjust regeneration rate per tic
- Adjust weapon energy costs
- Monitor energy availability during gameplay

### 8.3 ACS Script Dependencies

**Challenge:**
- Target lock and other features require ACS scripts
- ACS script IDs may conflict with current mod
- `BerserkCount` and other functions must exist

**Mitigation:**
- Review all ACS script numbers before porting
- Use named scripts where possible (`ACS_NamedExecute`)
- Create wrapper functions for compatibility
- Document all ACS dependencies

### 8.4 Sound File Licensing

**Challenge:**
- AVP20 sound files may have licensing restrictions
- Current mod may use different sound sources

**Mitigation:**
- Verify AVP20 license permits asset reuse
- If licensing unclear, create/source replacement sounds
- Document sound file origins

### 8.5 Feature Bloat

**Challenge:**
- Porting too many features may dilute current mod identity
- Increased complexity can introduce bugs

**Mitigation:**
- Port selectively based on value/effort ratio
- Maintain current mod's design philosophy
- Get community feedback on desired features
- Implement in phases with testing between

---

## 9. Conclusion

### 9.1 Summary of Findings

**Strengths of AVP20 System:**
1. Sophisticated composite sprite architecture (PHAND patches + TEXTURES)
2. Comprehensive energy management (Accumulator)
3. Advanced targeting system (progressive lock-on)
4. Extensive weapon variety (10+ predator weapons)
5. Polished multi-level zoom system
6. Strong visual consistency across weapons

**Current Mod Strengths:**
1. Simpler, more maintainable sprite system
2. Established player base and balance
3. Existing predator class variety (Light, Hunter, Heavy, Assault)
4. Working weapon implementations

### 9.2 Recommended Integrations

**HIGHEST VALUE - IMPLEMENT:**
1. ✅ **Accumulator/Energy Siphon** - Low effort, high value, unique mechanic
2. ✅ **Multi-Level Zoom** - Medium effort, good value, enhances existing weapons

**GOOD VALUE - CONSIDER:**
3. ⚠️ **Target Lock-On System** - Medium effort, medium value, polished feel
4. ⚠️ **Smart Disk** - High effort, high value, iconic weapon
5. ⚠️ **CombiStick** - High effort, medium value, gameplay variety

**LOW PRIORITY - OPTIONAL:**
6. ❌ **Composite Sprite System** - Very high effort, low value (visual improvement only)
7. ❌ **Self-Destruct** - Medium effort, low value (situational feature)
8. ❌ **Additional Weapons** (PlasmaBlaster, SpearGun) - High effort, low value (redundant)

### 9.3 Final Recommendation

**Phased Approach:**

**Immediate (This Month):**
- Implement Accumulator/Energy Siphon weapon
- Standardize energy system across all weapons
- Test and balance energy economy

**Short Term (Next 1-3 Months):**
- Enhance zoom system to 3 levels
- Optionally add target lock-on
- Polish existing weapon animations

**Long Term (3-6 Months):**
- Port Smart Disk if desired
- Port CombiStick if desired
- Community feedback for additional features

**Do NOT Implement:**
- Complete sprite system overhaul (not worth effort)
- All weapons at once (too much complexity)
- Features without clear value proposition

### 9.4 Success Criteria

A successful integration should:
1. Add meaningful gameplay mechanics (energy management)
2. Enhance existing weapons (zoom, targeting)
3. Maintain current mod's identity and balance
4. Not introduce excessive complexity
5. Be achievable within reasonable timeframe
6. Receive positive player feedback

---

## 10. Appendix

### 10.1 File Locations Reference

**AVP20 Structure:**
```
~/games/DooM/AVP20_Final_WIP/
├── PREDATOR_WEAPON_SPRITE_SYSTEM.md
└── src/
    ├── Actors/
    │   ├── Weapons/Predator/
    │   │   ├── Accumulator.txt ⭐
    │   │   ├── Wristblades.txt
    │   │   ├── PlasmaCaster.txt
    │   │   ├── PlasmaBlaster.txt
    │   │   ├── SmartDisk.txt ⭐
    │   │   ├── CombiStick.txt ⭐
    │   │   ├── SpearGun.txt
    │   │   ├── HProtect.txt
    │   │   ├── Hack.txt
    │   │   ├── SelfD.txt
    │   │   └── PredAmmo.txt
    │   └── PlayerClasses/
    │       └── PredatorClass.txt
    ├── Graphics/Weapons/Predator/
    │   ├── WRISTS/PHAND*.png (22 files)
    │   └── SPEARGUN/PHAND17-18.png
    └── TEXTURES (3517 lines)
```

**Current Mod Structure:**
```
~/workspace/personal/predators-hellspawn-hunters-redux/
└── src/
    ├── DECORATE.Weapons
    ├── DECORATE.Predator
    ├── SPRITES/
    │   └── WEAPONS/
    │       └── PLASMACASTER/
    └── SOUNDS/
```

### 10.2 Key Actor Names

**AVP20:**
- `PREDATOR` (player class)
- `Accumulator` (energy siphon)
- `HuntersCLAWS` (wrist blades)
- `PlasmaCASTER` (shoulder cannon)
- `SmartDisk` (throwing disc)
- `CombiSTICK` (spear)
- `PlasmaBLASTER` (handheld plasma)
- `SpearGun` (spear launcher)

**Current Mod:**
- `Wristblade` (melee)
- `PlasmaCaster` (plasma weapon)
- `PlasmaBomber` (AssaultPredator only)
- Various predator classes (LightPredator, HunterPredator, etc.)

### 10.3 Energy Costs Reference (AVP20)

| Weapon | Action | Energy Cost | Notes |
|--------|--------|-------------|-------|
| Plasma Caster | Normal Shot | 50 | Seeking projectile |
| Plasma Caster | Charged Shot (Rail) | 100 | Hold 105 tics + railgun |
| Smart Disk | Throw | 25 | Per throw |
| Accumulator | Regeneration | +1 per tic | × BerserkCount multiplier |

Maximum Energy: 999

### 10.4 Sprite Prefix Quick Reference

**AVP20 Weapon Sprites:**
- `PCSL` - Plasma Caster Select/Fire
- `PCSN` - Plasma Caster Idle
- `PPCZ` - Predator Zoom View (shared)
- `DBLD` - Dual Blades Deploy
- `DBLN` - Dual Blades Ready
- `DBLA` - Dual Blades Attack
- `PDSK` - Predator Disk
- `TROF` - Tri-laser (Accumulator)
- `SEDS` - Self-Destruct countdown

**Current Mod Sprites:**
- `WRST` - Wrist blade ready
- `PRCL` - Predator Claw
- `PRAT` - Predator Attack
- `DPCA` - Dual Plasma Caster (?)
- `PCAS` - Plasma Caster

### 10.5 Sound Files to Port

**Accumulator:**
- `/predator/TRALOOP` - Charging loop
- `/predator/TRALOOPS` - Charge complete
- `/predator/TRAON` - Activation

**Zoom:**
- `/predator/pzoomin` - Zoom in
- `/predator/pzoomout` - Zoom out

**Plasma Caster:**
- `/predator/fire` - Plasma shot
- `/predator/PCC` - Charging sound
- `/predator/pcready` - Ready sound
- `castersel` - Selection sound
- `PSHOT2` - Charged shot
- `failshot` - No energy

**Wrist Blades:**
- `/predator/HCLAWSEL` - Selection
- `/predator/HCLAWDE` - Deselection
- `PRMELEE` - Melee attack

**General:**
- `/predator/laughta` - Pickup taunt
- `/predator/cloakoff` - Cloak deactivation

---

**END OF REPORT**

**Next Steps:**
1. Review this document with mod team
2. Prioritize features based on recommendations
3. Begin with Accumulator implementation (highest value, lowest effort)
4. Test thoroughly before moving to next phase
5. Gather community feedback on energy system changes

**Questions or Clarifications:**
- What is the current mod's vision for energy management?
- Are there licensing concerns with AVP20 assets?
- What is the target timeline for new features?
- Which weapons are considered "core" to the current mod identity?
