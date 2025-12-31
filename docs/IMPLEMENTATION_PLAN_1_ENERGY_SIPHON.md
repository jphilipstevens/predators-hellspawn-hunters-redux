# Implementation Plan: Energy Siphon (Accumulator)

**Feature:** Energy regeneration weapon system from AVP20
**Difficulty:** ⭐ Low (2-4 hours)
**Priority:** 🔥 HIGH - Recommended first implementation
**Dependencies:** None - self-contained feature

---

## Overview

The Accumulator is a passive energy regeneration weapon that allows predators to recharge their energy supply. When equipped, it automatically generates energy over time with visual and audio feedback, then auto-switches away when full.

## Current State Analysis

**Current Mod:**
- All predator classes start with 500 Energy
- Energy is used by various weapons (PlasmaCaster, EMPPistol, etc.)
- No energy regeneration mechanic exists
- Players must find energy pickups to replenish

**AVP20 System:**
- Accumulator weapon regenerates 1 energy per tic
- Maximum energy: 999 (current mod uses 500)
- Multiplied by berserk count for faster regeneration
- Auto-switches to previous weapon when full
- Cannot be dropped or thrown

---

## Implementation Steps

### PHASE 1: Asset Extraction (30 minutes)

#### Step 1.1: Extract Sprite Files
**Source:** `~/games/DooM/AVP20_Final_WIP/src/`

Need to find and copy TROF sprites:
```bash
# Search for TROF sprite files
find ~/games/DooM/AVP20_Final_WIP -name "TROF*.png"
```

**Required Sprites:**
- `TROFA0.png` - Frame A (idle)
- `TROFB0.png` - Frame B (charging)
- `TROFC0.png` - Frame C (charging)
- `TROFD0.png` - Frame D (charging)
- `TROFE0.png` - Frame E (bright charging)
- `TROFF0.png` - Frame F (bright charging)
- `TROFG0.png` - Frame G (bright charging)
- `TROFH0.png` - Frame H (bright charging)

**Destination:** `~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/ACCUMULATOR/`

**Commands:**
```bash
# Create accumulator sprite directory
mkdir -p "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/ACCUMULATOR"

# Copy sprites (once found)
cp /path/to/TROF*.png "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/ACCUMULATOR/"
```

#### Step 1.2: Extract Sound Files
**Source:** AVP20 sound directory

**Required Sounds:**
- `/predator/TRALOOP` - Charging loop sound
- `/predator/TRALOOPS` - Charge complete sound
- `/predator/TRAON` - Activation/selection sound

**Commands:**
```bash
# Create sound directory if needed
mkdir -p "~/workspace/personal/predators-hellspawn-hunters-redux/src/SOUNDS/WEAPONS/ACCUMULATOR"

# Find and copy sound files from AVP20
find ~/games/DooM/AVP20_Final_WIP -iname "*TRALOOP*" -o -iname "*TRALOOPS*" -o -iname "*TRAON*"
# Copy found files to destination
```

**Alternative:** If sounds can't be found, use placeholder sounds temporarily and create/source later.

#### Step 1.3: Register Sounds in SNDINFO
**File:** `src/SNDINFO`

**Add these lines:**
```
/predator/TRALOOP        SOUNDS/WEAPONS/ACCUMULATOR/TRALOOP
/predator/TRALOOPS       SOUNDS/WEAPONS/ACCUMULATOR/TRALOOPS
/predator/TRAON          SOUNDS/WEAPONS/ACCUMULATOR/TRAON
```

---

### PHASE 2: Actor Implementation (45 minutes)

#### Step 2.1: Create Accumulator Weapon Actor
**File:** `src/DECORATE.Weapons` (or create new file `src/DECORATE.Accumulator`)

**Add to DECORATE.Weapons after line 1300 (after PlasmaBomber section):**

```decorate
// ==============================================================================
// ACCUMULATOR - Energy Regeneration Weapon
// Ported from AVP20_Final_WIP
// ==============================================================================

actor HealthPointCount : Inventory
{
    Inventory.MaxAmount 300
}

actor SoundSTART : Inventory
{
    Inventory.MaxAmount 1
}

actor Accumulator : Weapon
{
    Game Doom
    +INVENTORY.UNTOSSABLE
    +INVENTORY.UNDROPPABLE
    Weapon.Kickback 0
    Weapon.AmmoUse1 0
    Weapon.AmmoUse2 0
    Weapon.AmmoType1 "Energy"
    Weapon.AmmoType2 "Energy"
    Weapon.SelectionOrder 7000  // Low priority (high number)
    weapon.bobrangeX 0.4
    weapon.bobrangeY 0.4
    Inventory.PickupMessage "Energy Accumulator - Passive Recharging Device"
    Obituary "$OB_MPCHAINSAW"
    +WEAPON.NOALERT
    -WEAPON.DONTBOB

    States
    {
    Ready:
        TNT1 A 0 A_JumpIfInventory ("PowerStrength", 1, "Ready2")
        TROF A 1 A_WeaponReady
        Goto PreFire

    Ready2:
        TROF A 1 A_WeaponReady
        Goto Fire

    EnergyFull:
        TROF A 1 A_PlaySound ("/predator/TRALOOPS")
        TNT1 A 0 A_TakeInventory("SoundSTART", 99)
        Goto DeselectPre

    DeselectPre:
        TROF A 0 A_StopSound (1)
        TROF BCD 1
        TROF ABCD 2
        Goto Deselect

    Deselect:
        TROF A 0 A_StopSound (1)
        TROF A 1 A_Lower
        NULL AAA 0 A_Lower
        Loop

    Select:
        TNT1 A 0 A_PlaySound ("/predator/TRAON")
        TROF A 1 A_Raise
        NULL AAA 0 A_Raise
        Loop

    PreFire:
        TNT1 A 0 A_JumpIfInventory("SoundSTART", 1, "Fire")
        TNT1 A 0 A_GiveInventory("SoundSTART", 1)
        TNT1 A 0 A_PlaySound ("/predator/TRALOOPS")
        Goto Fire

    Fire:
        TROF A 0 A_PlaySound ("/predator/TRALOOP", 1, 1, 1)
        TROF ABCD 2

    Charge:
        TROF A 1 A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF E 1 BRIGHT A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF B 1 A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF F 1 BRIGHT A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF C 1 A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF G 1 BRIGHT A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF D 1 A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF H 1 BRIGHT A_GiveInventory ("Energy", 1)
        TNT1 A 0 A_JumpIfInventory("Energy", 500, "EnergyFull")
        TROF A 1 A_WeaponReady
        Goto Charge

    Spawn:
        LAUN A -1
        Stop
    }
}
```

**Key Modifications from AVP20:**
- Removed self-destruct integration (not implemented yet)
- Removed cloak integration (not implemented yet)
- Removed berserk multiplier (`CallACS("BerserkCount")`) - using base regeneration only
- Changed max energy from 999 to 500 (matching current mod)
- Simplified for current mod compatibility

---

### PHASE 3: Integration with Player Classes (30 minutes)

#### Step 3.1: Add Accumulator to Starting Inventory

**Files to modify:**
- `src/DECORATE.LIGHT`
- `src/DECORATE.HUNTER`
- `src/DECORATE.HEAVY`
- `src/DECORATE.ASSAULT`

**For EACH player class file, add this line after existing Player.StartItem lines:**

**Example for Light Predator (DECORATE.LIGHT):**
```decorate
Player.StartItem "WristBlade"
Player.StartItem "Energy", 500
Player.StartItem "LightPredatorTag"
Player.StartItem "LightPlayer"
Player.StartItem "NewRocketAmmo", 20
Player.StartItem "Accumulator"  ← ADD THIS LINE
```

**Repeat for all predator classes:**
- DECORATE.HUNTER (line ~21)
- DECORATE.HEAVY (line ~22)
- DECORATE.ASSAULT (line ~21)

#### Step 3.2: Add Weapon Slot Assignment

**Choose a weapon slot number.** Current assignments:
- Slot 1: Melee weapons
- Slot 2: Varies by class
- Slot 3: Varies
- Slot 4: Varies
- Slot 5: PlasmaCaster
- Slot 6: PredatorDisk
- Slot 7: Special weapons (NetGun, AssaultRailgun)
- **Slot 8: AVAILABLE** ← Recommend using this

**Add to each player class:**

```decorate
Player.WeaponSlot 8, Accumulator
```

**OR** make it accessible via weapon switch only (no dedicated slot):
- Don't add weapon slot assignment
- Players can cycle to it with next/prev weapon keys

---

### PHASE 4: Testing & Balancing (45 minutes)

#### Test 4.1: Basic Functionality
**Objectives:**
- ✅ Weapon selects properly
- ✅ Sprite displays correctly
- ✅ Charging animation plays
- ✅ Sound loops correctly

**Test Procedure:**
```
1. Load mod in GZDoom
2. Start as any predator class
3. Switch to Accumulator (slot 8 or cycle weapons)
4. Verify sprite appears
5. Verify charging sound plays
6. Watch energy counter increase
```

**Expected Behavior:**
- Energy should increase by 8 per tic cycle (one full animation)
- Animation should loop smoothly
- Sound should loop without gaps

#### Test 4.2: Auto-Switch on Full Energy
**Objectives:**
- ✅ Weapon auto-switches when energy reaches 500
- ✅ Completion sound plays
- ✅ Switches to appropriate weapon (last used)

**Test Procedure:**
```
1. Deplete energy by using plasma caster
2. Switch to Accumulator
3. Wait for energy to reach 500
4. Verify auto-switch occurs
5. Verify completion sound plays
```

#### Test 4.3: Energy Economy Balance
**Objectives:**
- ✅ Regeneration rate feels balanced
- ✅ Not too fast (trivializes energy management)
- ✅ Not too slow (frustrating to use)

**Current Rate:** 8 energy per animation cycle (8 frames @ 1 tic each = ~0.23 seconds)
- Full charge from 0→500: ~62.5 cycles = ~14.4 seconds

**Balancing Options:**
1. **If too fast:** Reduce energy given per frame (e.g., `A_GiveInventory("Energy", 1)` every 2 frames)
2. **If too slow:** Increase energy per frame or add multiplier
3. **Add berserk bonus:** Restore `CallACS("BerserkCount")` if berserk exists in mod

**Recommended Balance:** Start with current implementation, adjust after playtesting

#### Test 4.4: Edge Cases
**Test scenarios:**
- ✅ Switching weapons mid-charge (should stop sound)
- ✅ Death while using accumulator
- ✅ Energy pickups while using accumulator (should auto-switch if reaches 500)
- ✅ Starting a new level with accumulator equipped

---

### PHASE 5: Optional Enhancements (1-2 hours)

#### Enhancement 5.1: Add Berserk Multiplier Support

**IF** your mod has berserk/powerup system:

**Check if these exist:**
```bash
grep -r "BerserkCount" src/
grep -r "PowerStrength" src/
```

**If found, add ACS function:**

**File:** `src/ACS/accumulator.acs` (create new)
```c
#library "ACCUMULATOR"
#include "zcommon.acs"

function int BerserkCount(void)
{
    if (CheckInventory("PowerStrength") > 0)
        return 2;  // 2x regeneration when berserked
    return 1;      // Normal regeneration
}
```

**Compile:**
```bash
cd src/ACS
acc -i /path/to/gzdoom/acc/includes accumulator.acs
```

**Update Accumulator actor:**
Change:
```decorate
TROF A 1 A_GiveInventory ("Energy", 1)
```

To:
```decorate
TROF A 1 A_GiveInventory ("Energy", 1*CallACS("BerserkCount"))
```

#### Enhancement 5.2: Visual HUD Integration

**Add energy regeneration indicator:**
- Display "CHARGING" text when accumulator active
- Show charge rate
- Show ETA to full charge

**Requires:** HUD scripting (ZScript or ACS)

#### Enhancement 5.3: Configurable Settings

**Add CVARs for customization:**

**File:** `src/cvarinfo.txt`
```
// Accumulator Settings
user int accumulator_rate = 1;         // Energy per frame (1-10)
user bool accumulator_autoswitch = true; // Auto-switch when full
user int accumulator_maxenergy = 500;  // Max energy level
```

**Update actor to read CVARs:**
```decorate
TROF A 1 A_GiveInventory("Energy", GetCVar("accumulator_rate"))
```

---

## Asset Checklist

### ✅ Before Implementation

- [ ] AVP20 mod accessible at `~/games/DooM/AVP20_Final_WIP`
- [ ] Backup current mod (git commit or zip)
- [ ] GZDoom installed for testing
- [ ] Text editor ready

### 📦 Required Assets

**Sprites (8 files):**
- [ ] TROFA0.png
- [ ] TROFB0.png
- [ ] TROFC0.png
- [ ] TROFD0.png
- [ ] TROFE0.png
- [ ] TROFF0.png
- [ ] TROFG0.png
- [ ] TROFH0.png

**Sounds (3 files):**
- [ ] TRALOOP (loop sound)
- [ ] TRALOOPS (complete sound)
- [ ] TRAON (activation sound)

**Code Files:**
- [ ] Accumulator actor definition (added to DECORATE.Weapons)
- [ ] Inventory actors (HealthPointCount, SoundSTART)

### 🔧 Modified Files

- [ ] `src/DECORATE.Weapons` (or new `src/DECORATE.Accumulator`)
- [ ] `src/DECORATE.LIGHT` (add StartItem + WeaponSlot)
- [ ] `src/DECORATE.HUNTER` (add StartItem + WeaponSlot)
- [ ] `src/DECORATE.HEAVY` (add StartItem + WeaponSlot)
- [ ] `src/DECORATE.ASSAULT` (add StartItem + WeaponSlot)
- [ ] `src/SNDINFO` (register sounds)

---

## Testing Checklist

### Basic Tests
- [ ] Mod loads without errors
- [ ] All predator classes start with Accumulator
- [ ] Accumulator appears in weapon slot 8 (or cycles correctly)
- [ ] Sprite displays correctly when selected
- [ ] Charging animation plays smoothly
- [ ] Charging sound loops correctly
- [ ] Energy counter increases during charge
- [ ] Energy stops at 500 maximum

### Functionality Tests
- [ ] Auto-switch occurs at 500 energy
- [ ] Completion sound plays on auto-switch
- [ ] Switches to correct previous weapon
- [ ] Charging stops when switching weapons manually
- [ ] Sound stops when switching away
- [ ] Works correctly after death/respawn
- [ ] Persists across level changes

### Balance Tests
- [ ] Charge rate feels appropriate (~15 seconds for full charge)
- [ ] Not exploitable (can't spam for infinite energy)
- [ ] Useful but not overpowered
- [ ] Encourages tactical weapon switching

### Edge Case Tests
- [ ] Picking up energy items while charging
- [ ] Using energy-consuming weapons while near full
- [ ] Attempting to use fire/altfire (should do nothing)
- [ ] Selecting accumulator when already at 500 energy
- [ ] Co-op multiplayer compatibility (if applicable)

---

## Troubleshooting

### Issue: Sprites not appearing
**Symptoms:** Invisible weapon or "TROF not found" error

**Solutions:**
1. Verify sprites are in correct directory: `src/SPRITES/WEAPONS/ACCUMULATOR/`
2. Check sprite names match exactly (case-sensitive)
3. Ensure sprites are valid PNG format
4. Rebuild PK3/WAD file if using packaged mod

### Issue: Sound not playing
**Symptoms:** Silent charging, no audio feedback

**Solutions:**
1. Check SNDINFO has correct sound paths
2. Verify sound files exist in `src/SOUNDS/WEAPONS/ACCUMULATOR/`
3. Test with different sound format (WAV vs OGG vs MP3)
4. Check GZDoom sound settings (volume, enabled)
5. Use `A_PlaySound` instead of `A_PlayWeaponSound` if issues persist

### Issue: Energy not increasing
**Symptoms:** Weapon selected but energy stays same

**Solutions:**
1. Verify "Energy" inventory type exists in mod
2. Check case-sensitive inventory name
3. Add debug print: `TNT1 A 0 A_Print("Charging...")`
4. Test with lower max energy (e.g., 100) to see faster results
5. Ensure `A_GiveInventory` syntax is correct

### Issue: No auto-switch
**Symptoms:** Stays on accumulator even at 500 energy

**Solutions:**
1. Verify energy max is actually 500 (check Energy ammo definition)
2. Test with manual switch to confirm functionality
3. Add debug: `TNT1 A 0 A_Print("Energy full!")` before switch
4. Check weapon selection order/priority
5. Ensure previous weapon history is tracked by engine

### Issue: Animation stutters
**Symptoms:** Choppy visual or sound gaps

**Solutions:**
1. Check all TROF frames exist (A through H)
2. Verify frame durations (all should be 1 tic)
3. Ensure bright frames (EFGH) are properly marked
4. Test on different performance settings
5. Reduce complexity if needed (fewer frames)

---

## Performance Considerations

**CPU Impact:** Minimal
- Simple A_GiveInventory calls
- No complex calculations
- No projectile spawning

**Memory Impact:** Low
- 8 sprite frames (~50-100KB total)
- 3 sound files (~100-500KB total)

**Network Impact (Multiplayer):** Low
- Inventory changes are lightweight
- No frequent network updates needed

**Compatibility:** High
- Uses standard DECORATE
- No ZScript dependencies
- No advanced GZDoom features required
- Should work on older GZDoom versions (3.0+)

---

## Future Expansion Ideas

1. **Tiered Accumulator System:**
   - Basic Accumulator: 1 energy/tic
   - Advanced Accumulator: 2 energy/tic
   - Elite Accumulator: 3 energy/tic + extended max energy

2. **Passive Background Charging:**
   - Small passive regen even when other weapons equipped
   - Requires ZScript or ACS ticker

3. **Visual Upgrades:**
   - Add particle effects during charging
   - Glowing sprite overlay
   - Energy arc visuals

4. **Sound Variations:**
   - Different pitch based on charge level
   - Escalating intensity as it nears full
   - Warning beep at 90% capacity

5. **Integration with Cloak:**
   - Auto-disable cloak when charging (as in AVP20)
   - Increased energy cost for cloak
   - Mutual exclusivity system

---

## Success Criteria

Implementation is successful when:

✅ **Functional:**
- Accumulator can be equipped and used
- Energy regenerates at consistent rate
- Auto-switches when full
- All sounds play correctly

✅ **Balanced:**
- Regeneration rate is neither too fast nor too slow
- Creates meaningful gameplay choice (switch to recharge vs keep fighting)
- Doesn't trivialize energy management

✅ **Polished:**
- Smooth animations
- Clear audio feedback
- No bugs or glitches
- Works across all predator classes

✅ **Integrated:**
- Fits with mod's existing systems
- Accessible to all predator types
- Doesn't conflict with other weapons
- Persists correctly across levels

---

## Estimated Timeline

**TOTAL: 2-4 hours**

- Asset extraction: 30 min
- Actor implementation: 45 min
- Player class integration: 30 min
- Testing & balancing: 45-90 min
- Bug fixes: 30-60 min

**Fast track (minimal):** 1.5 hours
**Complete implementation:** 4 hours
**With enhancements:** 6-8 hours

---

## Next Steps After Completion

1. ✅ Test extensively in actual gameplay
2. ✅ Gather player feedback on balance
3. ✅ Document in mod readme/changelog
4. ✅ Consider implementing Zoom system next (complementary feature)
5. ✅ Optional: Add cloak/self-destruct integration later

---

**END OF IMPLEMENTATION PLAN 1: ENERGY SIPHON**

For questions or issues during implementation, refer to:
- AVP20 source: `~/games/DooM/AVP20_Final_WIP/src/Actors/Weapons/Predator/Accumulator.txt`
- GZDoom Wiki: https://zdoom.org/wiki/
- This audit report: `AVP20_AUDIT_REPORT.md`
