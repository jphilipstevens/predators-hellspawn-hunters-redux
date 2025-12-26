# Accumulator (Energy Siphon) Implementation Summary

**Implementation Date:** December 26, 2025
**Status:** ✅ COMPLETE - Ready for Testing
**Based on:** IMPLEMENTATION_PLAN_1_ENERGY_SIPHON.md

---

## What Was Implemented

The **Accumulator** is a passive energy regeneration weapon that allows predators to recharge their energy supply. When equipped, it automatically generates energy over time with visual and audio feedback, then auto-switches to the previous weapon when energy reaches maximum (500).

---

## Files Created

### 1. Sprite Assets
**Location:** `src/SPRITES/WEAPONS/ACCUMULATOR/`

Copied 8 ACCUM patch files from AVP20:
- ACCUM1.png through ACCUM8.png (61-65KB each)
- Total size: ~510KB

### 2. Sound Assets
**Location:** `src/SOUNDS/WEAPONS/ACCUMULATOR/`

Copied 3 sound files from AVP20:
- `TRALOOP.ogg` - Charging loop sound (75KB)
- `TRALOOPS.ogg` - Charge complete sound (23KB)
- `TRAON.ogg` - Activation/selection sound (11KB)
- Total size: ~109KB

### 3. TEXTURES File
**Location:** `src/TEXTURES` (NEW FILE)

Created composite sprite definitions for 8 TROF frames (A-H):
- Maps ACCUM patches to TROF sprite names
- Scale: 1.800 (180%)
- Offset: -155, -128
- Canvas: 260x203 pixels

### 4. Accumulator Actor Definition
**Location:** `src/DECORATE.Accumulator` (NEW FILE)

Created complete weapon actor with:
- **Inventory Actors:**
  - `HealthPointCount` (max 300)
  - `SoundSTART` (max 1)
  - `Accumulator` (main weapon)

- **Weapon Properties:**
  - Slot 8
  - Selection order: 7000 (low priority)
  - Cannot be dropped or thrown
  - Uses Energy ammo type
  - Weapon bob: 0.4 (X and Y)

- **States:**
  - Ready → PreFire → Fire → Charge (loop)
  - Generates 8 energy per animation cycle
  - Bright frames (E, F, G, H) for visual feedback
  - Auto-switches to previous weapon when energy = 500
  - Sound loops during charging
  - Stops sound on deselect

---

## Files Modified

### 1. SNDINFO
**File:** `src/SNDINFO`

**Lines 87-89 added:**
```
//ACCUMULATOR (Energy Siphon)
/predator/TRALOOP        SOUNDS/WEAPONS/ACCUMULATOR/TRALOOP
/predator/TRALOOPS       SOUNDS/WEAPONS/ACCUMULATOR/TRALOOPS
```

Note: `TRAON` was already registered (line 84)

### 2. Player Class Files

#### DECORATE.LIGHT
**Lines 22 and 29 added:**
```
Player.StartItem "Accumulator"
Player.WeaponSlot 8, Accumulator
```

#### DECORATE.HUNTER
**Lines 22 and 30 added:**
```
Player.StartItem "Accumulator"
Player.WeaponSlot 8, Accumulator
```

#### DECORATE.HEAVY
**Lines 22 and 29 added:**
```
Player.StartItem "Accumulator"
Player.WeaponSlot 8, Accumulator
```

#### DECORATE.ASSAULT
**Lines 22 and 30 added:**
```
Player.StartItem "Accumulator"
Player.WeaponSlot 8, Accumulator
```

---

## How It Works

### Energy Regeneration Mechanic

**Charge Rate:** 8 energy per animation cycle
- 8 frames @ 1 tic each = 8 tics per cycle (~0.23 seconds)
- Full charge (0→500): ~62.5 cycles = ~14.4 seconds

**Charge Loop:**
```
TROF A: +1 energy
TROF E (BRIGHT): +1 energy
TROF B: +1 energy
TROF F (BRIGHT): +1 energy
TROF C: +1 energy
TROF G (BRIGHT): +1 energy
TROF D: +1 energy
TROF H (BRIGHT): +1 energy
→ Total: 8 energy per cycle
```

### Auto-Switch Behavior

When energy reaches 500:
1. Plays completion sound ("/predator/TRALOOPS")
2. Stops charging loop sound
3. Plays deselect animation (TROF BCD @ 1 tic, ABCD @ 2 tics)
4. Switches to previous weapon

### Visual Feedback

- **Frames A-D:** Normal weapon view (ACCUM1-4)
- **Frames E-H:** Bright frames (ACCUM5-8) - visible energy glow effect
- Alternates between normal and bright for "pulsing" effect

### Audio Feedback

- **Activation:** TRAON sound on weapon select
- **Charging:** TRALOOP loops continuously while charging
- **Complete:** TRALOOPS plays when reaching 500 energy
- **Deselect:** Stops all sounds

---

## Testing Checklist

Before marking as production-ready, test:

### ✅ Basic Functionality
- [ ] Weapon appears in slot 8 for all predator classes
- [ ] Weapon can be selected with "8" key
- [ ] Sprite displays correctly when equipped
- [ ] Charging animation plays smoothly
- [ ] Energy counter increases during charge
- [ ] Energy stops at 500 maximum

### ✅ Audio
- [ ] TRAON plays on weapon select
- [ ] TRALOOP loops without gaps during charge
- [ ] TRALOOPS plays on reaching 500 energy
- [ ] Sound stops when switching weapons manually
- [ ] Sound stops on player death

### ✅ Auto-Switch
- [ ] Weapon auto-switches when energy = 500
- [ ] Switches to correct previous weapon
- [ ] Completion sound plays before switch
- [ ] Deselect animation plays

### ✅ Edge Cases
- [ ] Works with all 4 predator classes (Light, Hunter, Heavy, Assault)
- [ ] Persists across level changes
- [ ] Works correctly after death/respawn
- [ ] No conflicts with other weapons
- [ ] Energy pickups work while using accumulator
- [ ] Can switch away manually mid-charge

### ✅ Visual Quality
- [ ] Sprite positioned correctly on screen
- [ ] Sprite size appropriate (not too large/small)
- [ ] Bright frames visible (EFGH glow)
- [ ] No sprite clipping or artifacts
- [ ] Works at different screen resolutions

### ✅ Balance
- [ ] Charge rate feels appropriate (~14 seconds full)
- [ ] Not too fast (doesn't trivialize energy management)
- [ ] Not too slow (not frustrating to use)
- [ ] Tactical weapon switching encouraged

---

## Known Differences from AVP20

### Simplified for Current Mod

1. **Removed self-destruct integration** - Not implemented yet
2. **Removed cloak integration** - Not implemented yet
3. **Removed berserk multiplier** - Simplified to base regeneration only
4. **Energy max changed** - 999 → 500 (matching current mod)
5. **Removed ACS dependencies** - Direct inventory checks only

### Future Enhancements (Optional)

If desired, can add:
- Berserk multiplier (2x regen when berserked)
- Cloak auto-disable when charging
- Self-destruct interruption
- Variable regen rates via CVAR
- HUD charge indicator
- Configurable max energy

---

## File Structure Summary

```
src/
├── DECORATE.Accumulator          (NEW - 118 lines)
├── TEXTURES                       (NEW - 74 lines)
├── SNDINFO                        (MODIFIED - added 3 lines)
├── DECORATE.LIGHT                 (MODIFIED - added 2 lines)
├── DECORATE.HUNTER                (MODIFIED - added 2 lines)
├── DECORATE.HEAVY                 (MODIFIED - added 2 lines)
├── DECORATE.ASSAULT               (MODIFIED - added 2 lines)
├── SPRITES/WEAPONS/ACCUMULATOR/   (NEW DIR)
│   ├── ACCUM1.png
│   ├── ACCUM2.png
│   ├── ACCUM3.png
│   ├── ACCUM4.png
│   ├── ACCUM5.png
│   ├── ACCUM6.png
│   ├── ACCUM7.png
│   └── ACCUM8.png
└── SOUNDS/WEAPONS/ACCUMULATOR/    (NEW DIR)
    ├── TRALOOP.ogg
    ├── TRALOOPS.ogg
    └── TRAON.ogg
```

---

## Next Steps

### 1. Testing
Load the mod in GZDoom and test all functionality (see checklist above).

**Test Command:**
```bash
gzdoom -iwad doom2.wad -file your_mod.pk3 +map map01
```

### 2. Balance Adjustment (if needed)

**If charge rate too fast:**
```decorate
// Change from +1 to +1 every 2 frames
TROF A 1 A_GiveInventory("Energy", 1)
TROF A 1  // Extra frame delay
```

**If charge rate too slow:**
```decorate
// Increase energy per frame
TROF A 1 A_GiveInventory("Energy", 2)  // Was 1, now 2
```

### 3. Sprite Adjustment (if needed)

**If sprite offset wrong:**
Edit `src/TEXTURES` offset values:
```
Offset -155, -128  // X (left/right), Y (up/down)
// Decrease Y to move up: -155, -140
// Increase Y to move down: -155, -120
```

### 4. Documentation

Add to mod README/changelog:
```
## Version X.X - Accumulator Update

### New Features
- Added Accumulator weapon (Energy Siphon) to all predator classes
  - Passive energy regeneration system
  - Located in weapon slot 8
  - Auto-switches when energy is full
  - Visual and audio feedback during charging
  - Approximately 14 seconds for full charge (0→500)

### Credits
- Accumulator system ported from AVP20_Final_WIP
```

---

## Troubleshooting

### Issue: Sprites not appearing
**Fix:** Ensure ACCUM*.png files are in `src/SPRITES/WEAPONS/ACCUMULATOR/`

### Issue: Sounds not playing
**Fix:** Check SNDINFO has correct paths, verify .ogg files exist

### Issue: Weapon not in slot 8
**Fix:** Verify Player.WeaponSlot 8 added to all player classes

### Issue: Energy not increasing
**Fix:** Ensure "Energy" inventory type exists in mod

### Issue: TEXTURES errors
**Fix:** TEXTURES file must be in `src/` root, not subdirectory

---

## Performance Impact

**Total Added Assets:** ~620KB
- Sprites: 510KB (8 PNG files)
- Sounds: 109KB (3 OGG files)
- Code: <1KB (text files)

**Runtime Performance:** Negligible
- Simple inventory operations
- No complex calculations
- No projectile spawning
- Standard weapon state machine

**Compatibility:** High
- Pure DECORATE implementation
- No ZScript dependencies
- Works on GZDoom 3.0+

---

## Credits

- **Original Implementation:** AVP20_Final_WIP mod
- **Port:** Implementation Plan 1 - Energy Siphon
- **Assets:** Sprites and sounds from AVP20
- **Integration:** Modified for Predators: Hellspawn Hunters Redux

---

**END OF IMPLEMENTATION SUMMARY**

**Status:** Ready for testing! Press 8 to equip the Accumulator and start charging energy.
