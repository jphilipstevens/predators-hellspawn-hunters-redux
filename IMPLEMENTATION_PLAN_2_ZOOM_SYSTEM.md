# Implementation Plan: Multi-Level Zoom System

**Feature:** 3-level progressive zoom with audio feedback from AVP20
**Difficulty:** ⭐⭐ Medium (3-6 hours)
**Priority:** 🔥 HIGH - Enhances existing weapons
**Dependencies:** None - standalone feature

---

## Overview

The multi-level zoom system allows predators to progressively zoom in on targets using three magnification levels (2x, 4x, 8x). Each zoom level has audio feedback and dedicated zoom sprites. The zoom button cycles through levels, with the fourth press returning to normal view.

## Current State Analysis

**Current Mod:**
- May have basic zoom on some weapons (need to verify)
- No multi-level progressive zoom found
- No dedicated zoom sprites (PPCZ)
- No zoom-specific weapon states

**AVP20 System:**
- 3 zoom levels: 2x, 4x, 8x magnification
- `PredZoom` inventory tracks current zoom level (max 3)
- Dedicated `PPCZ` sprite set for zoomed view
- Zoom button (reload key) cycles through levels
- Audio feedback: `/predator/pzoomin` (zoom in), `/predator/pzoomout` (zoom out)
- Laser sight spawns during zoom for precise aiming
- Separate fire states when zoomed
- Auto-cancels zoom on weapon switch

---

## Implementation Steps

### PHASE 1: Asset Extraction (30 minutes)

#### Step 1.1: Extract Sound Files
**Source:** `/home/jono/games/DooM/AVP20_Final_WIP/src/`

**Required Sounds:**
- `/predator/pzoomin` - Zoom in sound (plays when increasing zoom level)
- `/predator/pzoomout` - Zoom out sound (plays when returning to normal)

**Commands:**
```bash
# Find zoom sound files in AVP20
find /home/jono/games/DooM/AVP20_Final_WIP -iname "*zoom*" -type f

# Create sound directory
mkdir -p "/home/jono/workspace/personal/predators-hellspawn-hunters-redux/src/SOUNDS/PREDATOR"

# Copy found sound files
# (path will be determined by find command above)
```

**Alternative:** If sounds not found, create placeholder beep sounds:
- Zoom in: Rising pitch beep
- Zoom out: Falling pitch beep

#### Step 1.2: Extract PPCZ Sprites (Optional - Advanced)
**Note:** PPCZ sprites may be composite sprites defined in TEXTURES lump. For initial implementation, can use existing weapon sprites.

**Source:** `/home/jono/games/DooM/AVP20_Final_WIP/src/`

**Search for PPCZ:**
```bash
# Find PPCZ sprite files
find /home/jono/games/DooM/AVP20_Final_WIP -name "PPCZ*.png" -o -name "ppcz*.png"

# Check TEXTURES lump for PPCZ definitions
grep -A 10 "Sprite PPCZ" /home/jono/games/DooM/AVP20_Final_WIP/src/TEXTURES
```

**Decision Point:**
- **Option A (Simple):** Skip PPCZ sprites, use existing weapon sprites for zoom view
- **Option B (Advanced):** Extract/port PPCZ sprites for authentic AVP20 experience

**Recommendation:** Start with Option A, add PPCZ later if desired.

#### Step 1.3: Register Sounds in SNDINFO
**File:** `src/SNDINFO`

**Add these lines:**
```
// Zoom System Sounds
/predator/pzoomin        SOUNDS/PREDATOR/pzoomin
/predator/pzoomout       SOUNDS/PREDATOR/pzoomout
```

---

### PHASE 2: Inventory System Setup (20 minutes)

#### Step 2.1: Create PredZoom Inventory Type

**File:** `src/DECORATE.Predator` (or create `src/DECORATE.ZoomSystem`)

**Add this inventory actor:**
```decorate
// ==============================================================================
// ZOOM SYSTEM - Multi-Level Zoom Support
// Ported from AVP20_Final_WIP
// ==============================================================================

actor PredZoom : Inventory
{
    Inventory.MaxAmount 3  // 3 zoom levels
}
```

**This simple actor tracks zoom level:**
- 0 = No zoom (normal view)
- 1 = 2x zoom
- 2 = 4x zoom
- 3 = 8x zoom

---

### PHASE 3: Weapon Integration (PlasmaCaster first)

Goal: add zoom to **all predator weapons**, but implement and validate on **PlasmaCaster first**. Once PlasmaCaster is stable, apply the same pattern to the rest.

**Primary Target (first pass):** PlasmaCaster
**Follow-up (after validation):** all other predator weapons

#### Step 3.1: Modify PlasmaCaster to Support Zoom (First Pass)

**File:** `src/DECORATE.Weapons` (line 710+)

**Current PlasmaCaster Structure:**
```decorate
ACTOR PlasmaCaster : Weapon
{
    // Properties...
    States
    {
    Ready:
        PCAS A 1 A_WeaponReady
        Loop
    // ...
}
```

**Add Zoom States After Ready State:**

```decorate
ACTOR PlasmaCaster : Weapon
{
    Game Doom
    SpawnID 29
    Weapon.SlotNumber 5
    Weapon.SelectionOrder 2500
    +Weapon.NOALERT
    +Weapon.Ammo_Optional
    +WEAPON.ALT_AMMO_OPTIONAL
    +WEAPON.NOAUTOFIRE
    Inventory.PickupMessage "You got the Plasma Caster"

    States
    {
    Ready:
        PCAS A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
        Loop

    //
    // ========== ZOOM SYSTEM (NEW) ==========
    //
    Zoom:
        PCAS AAAAAA 1  // Brief pause for visual feedback
        TNT1 A 0 A_JumpIfInventory("PredZoom", 3, "ZoomOut")
        TNT1 A 0 A_JumpIfInventory("PredZoom", 2, "Zoom3")
        TNT1 A 0 A_JumpIfInventory("PredZoom", 1, "Zoom2")

    Zoom1:
        TNT1 A 1 A_ZoomFactor(2.0)
        TNT1 A 0 A_GiveInventory("PredZoom", 1)
        TNT1 A 0 A_PlaySound("/predator/pzoomin")
        Goto ReadyZoom

    Zoom2:
        TNT1 A 1 A_ZoomFactor(4.0)
        TNT1 A 0 A_GiveInventory("PredZoom", 1)
        TNT1 A 0 A_PlaySound("/predator/pzoomin")
        Goto ReadyZoom

    Zoom3:
        TNT1 A 1 A_ZoomFactor(8.0)
        TNT1 A 0 A_GiveInventory("PredZoom", 1)
        TNT1 A 0 A_PlaySound("/predator/pzoomin")
        Goto ReadyZoom

    ZoomOut:
        TNT1 A 1 A_ZoomFactor(1.0)
        TNT1 A 0 A_TakeInventory("PredZoom", 3)
        TNT1 A 0 A_PlaySound("/predator/pzoomout")
        Goto Ready

    ReadyZoom:
        PCAS A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
        Loop

    //
    // ========== ZOOMED FIRE STATES (NEW) ==========
    //
    Fire:
        TNT1 A 0 A_JumpIfInventory("PredZoom", 1, "ZoomedFire")
        // ... existing fire code ...
        Goto Ready

    ZoomedFire:
        // Zoomed fire behavior (can be same as normal or modified)
        // ... same fire code but returns to ReadyZoom ...
        Goto ReadyZoom

    //
    // ========== DESELECT - Auto-cancel zoom (MODIFY EXISTING) ==========
    //
    Deselect:
        TNT1 A 0 A_TakeInventory("PredZoom", 3)  // ← ADD THIS LINE
        TNT1 A 0 A_ZoomFactor(1.0)               // ← ADD THIS LINE
        PCAS A 1 A_Lower
        NULL AAA 0 A_Lower
        Loop

    // ... rest of states unchanged ...
    }
}
```

**Key Changes:**
1. **Ready:** Added `WRF_ALLOWRELOAD | WRF_ALLOWZOOM` to allow zoom button
2. **Zoom:** New state that checks current zoom level and advances to next
3. **Zoom1/2/3:** Individual zoom levels with increasing magnification
4. **ZoomOut:** Returns to normal view (1.0x)
5. **ReadyZoom:** Idle state while zoomed (allows fire and zoom adjustment)
6. **Fire:** Modified to check if zoomed and branch to zoomed fire
7. **ZoomedFire:** Separate fire state that returns to ReadyZoom instead of Ready
8. **Deselect:** Clears zoom state when switching weapons

---

### PHASE 4: Advanced Zoom Features (Optional - 1-2 hours)

#### Feature 4.1: Laser Sight Integration

**If laser sight already exists** (check for `LaserSightSpawner` actor):

**Modify ReadyZoom state:**
```decorate
ReadyZoom:
    PCAS A 0 A_FireCustomMissile("LaserSightSpawner", 0, 0, 0, 10)
    PCAS A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    Loop
```

**This spawns laser sight every tic while zoomed for continuous aim tracking.**

#### Feature 4.2: Zoom-Specific Crosshair

**Add crosshair changes per zoom level:**

**Modify zoom states:**
```decorate
Zoom1:
    TNT1 A 1 A_ZoomFactor(2.0)
    TNT1 A 0 A_SetCrosshair(11)  // ← Custom crosshair for 2x zoom
    TNT1 A 0 A_GiveInventory("PredZoom", 1)
    TNT1 A 0 A_PlaySound("/predator/pzoomin")
    Goto ReadyZoom

Zoom2:
    TNT1 A 1 A_ZoomFactor(4.0)
    TNT1 A 0 A_SetCrosshair(12)  // ← Custom crosshair for 4x zoom
    TNT1 A 0 A_GiveInventory("PredZoom", 1)
    TNT1 A 0 A_PlaySound("/predator/pzoomin")
    Goto ReadyZoom

Zoom3:
    TNT1 A 1 A_ZoomFactor(8.0)
    TNT1 A 0 A_SetCrosshair(13)  // ← Custom crosshair for 8x zoom
    TNT1 A 0 A_GiveInventory("PredZoom", 1)
    TNT1 A 0 A_PlaySound("/predator/pzoomin")
    Goto ReadyZoom

ZoomOut:
    TNT1 A 1 A_ZoomFactor(1.0)
    TNT1 A 0 A_SetCrosshair(9)   // ← Restore default crosshair
    TNT1 A 0 A_TakeInventory("PredZoom", 3)
    TNT1 A 0 A_PlaySound("/predator/pzoomout")
    Goto Ready
```

**Requires:** Custom crosshair graphics (PNG files)

#### Feature 4.3: Zoom Level HUD Display

**Add visual feedback showing current zoom level:**

**Requires:** ACS or ZScript HUD script

**Example ACS approach:**
```c
script "ZoomHUD" (void) CLIENTSIDE
{
    int zoomLevel = CheckInventory("PredZoom");

    if (zoomLevel == 1)
        HudMessage(s:"ZOOM: 2x"; HUDMSG_PLAIN, 1, CR_GREEN, 0.5, 0.1, 0.1);
    else if (zoomLevel == 2)
        HudMessage(s:"ZOOM: 4x"; HUDMSG_PLAIN, 1, CR_YELLOW, 0.5, 0.1, 0.1);
    else if (zoomLevel == 3)
        HudMessage(s:"ZOOM: 8x"; HUDMSG_PLAIN, 1, CR_RED, 0.5, 0.1, 0.1);
}
```

**Call from weapon:**
```decorate
Zoom1:
    TNT1 A 0 ACS_NamedExecute("ZoomHUD")
    TNT1 A 1 A_ZoomFactor(2.0)
    // ... rest of state
```

#### Feature 4.4: Projectile Speed Increase When Zoomed

**Make projectiles faster when firing while zoomed** (simulates focused shot):

**Modify zoomed fire:**
```decorate
ZoomedFire:
    TNT1 A 0 A_JumpIfInventory("PredZoom", 3, "ZoomedFire8x")
    TNT1 A 0 A_JumpIfInventory("PredZoom", 2, "ZoomedFire4x")
    TNT1 A 0 A_JumpIfInventory("PredZoom", 1, "ZoomedFire2x")
    Goto Fire  // Fallback

ZoomedFire2x:
    // Normal speed projectile
    PCAS A 2 A_FireCustomMissile("PlasmaShot1", 0, 1, 0, 0)
    PCAS B 2
    PCAS A 5
    Goto ReadyZoom

ZoomedFire4x:
    // 1.5x speed projectile (create faster variant)
    PCAS A 2 A_FireCustomMissile("PlasmaShot1Fast", 0, 1, 0, 0)
    PCAS B 2
    PCAS A 5
    Goto ReadyZoom

ZoomedFire8x:
    // 2x speed projectile (create even faster variant)
    PCAS A 2 A_FireCustomMissile("PlasmaShot1VeryFast", 0, 1, 0, 0)
    PCAS B 2
    PCAS A 5
    Goto ReadyZoom
```

**Requires:** Creating faster projectile variants

---

### PHASE 5: Rollout to Remaining Weapons (after PlasmaCaster is stable)

Once PlasmaCaster is validated in live gameplay, apply the same zoom system to the rest of the predator weapons.

#### Apply zoom to other weapons:

**5.1 SpearGun** (already exists in mod)
- Add same zoom system
- Good candidate for precision aiming

**5.2 EMPPistol** (Hunter class)
- Add zoom for long-range stuns
- Lower zoom levels (2x, 3x only)

**5.3 WristBlades** (Optional - tactical zoom)
- 2x zoom only for identifying distant threats
- No firing while zoomed (melee weapon)

**Template for adding zoom to any weapon:**

```decorate
ACTOR YourWeapon : Weapon
{
    States
    {
    Ready:
        WSPRITE A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)  // ← Add ALLOWZOOM
        Loop

    Zoom:
        // ... copy zoom states from PlasmaCaster ...
        // Adjust sprite names (WSPRITE instead of PCAS)

    Deselect:
        TNT1 A 0 A_TakeInventory("PredZoom", 3)   // ← Add zoom clear
        TNT1 A 0 A_ZoomFactor(1.0)
        WSPRITE A 1 A_Lower
        Loop
    }
}
```

---

### PHASE 6: Testing & Balancing (45-60 minutes)

#### Test 6.1: Basic Zoom Functionality
**Objectives:**
- ✅ Zoom button (reload key) works
- ✅ Cycles through 3 levels correctly
- ✅ Returns to normal on 4th press
- ✅ Sounds play at correct times
- ✅ Zoom factor applies correctly

**Test Procedure:**
```
1. Load mod with PlasmaCaster
2. Press zoom button (default: R)
3. Verify 2x zoom (view zooms in)
4. Press again → 4x zoom
5. Press again → 8x zoom
6. Press again → return to normal (1x)
7. Verify sounds play each time
```

**Expected Behavior:**
- Smooth transitions between zoom levels
- Clear audio feedback
- No screen jitter or glitches

#### Test 6.2: Zoom Auto-Cancel
**Objectives:**
- ✅ Zoom resets when switching weapons
- ✅ Zoom resets on death
- ✅ Zoom persists across level changes (optional)

**Test Procedure:**
```
1. Zoom in to 8x with PlasmaCaster
2. Switch to WristBlades
3. Switch back to PlasmaCaster
4. Verify zoom is at 1x (normal)

5. Zoom in again
6. Die (take fatal damage)
7. Respawn
8. Verify zoom is reset
```

#### Test 6.3: Zoomed Combat
**Objectives:**
- ✅ Can fire while zoomed
- ✅ Projectiles spawn correctly
- ✅ Returns to zoomed ready state after fire
- ✅ Weapon bob/sway works correctly when zoomed

**Test Procedure:**
```
1. Zoom to each level (2x, 4x, 8x)
2. Fire weapon at each zoom level
3. Verify projectile spawns correctly
4. Verify returns to ReadyZoom (not Ready)
5. Test rapid fire while zoomed
```

#### Test 6.4: Edge Cases
**Test scenarios:**
- ✅ Zoom while moving/strafing
- ✅ Zoom while jumping/falling
- ✅ Zoom underwater (if mod has water)
- ✅ Zoom while taking damage
- ✅ Zoom with low framerate
- ✅ Zoom in multiplayer (if applicable)

#### Test 6.5: Balancing Considerations

**Zoom Magnification:**
- **2x:** Comfortable for mid-range
- **4x:** Good for long-range sniping
- **8x:** Extreme zoom, may be too much?

**If 8x feels excessive:**
- Reduce to 6x: `A_ZoomFactor(6.0)`
- Or remove Zoom3 entirely (only 2x and 4x)

**Field of View Adjustment:**
If zoom feels claustrophobic, can adjust FOV:
```decorate
Zoom1:
    TNT1 A 1 A_ZoomFactor(2.0)
    TNT1 A 0 A_SetFOV(80)  // ← Slightly reduce FOV tunnel effect
    // ...
```

---

### PHASE 7: Polish & Optional Features (1-2 hours)

#### Polish 7.1: PPCZ Sprite Integration

**If you want authentic AVP20 zoom view:**

**Extract PPCZ sprites from AVP20:**
```bash
# Find PPCZ graphics
find /home/jono/games/DooM/AVP20_Final_WIP -name "*PPCZ*"

# Check TEXTURES for definitions
grep -B 5 -A 15 "Sprite PPCZ" /home/jono/games/DooM/AVP20_Final_WIP/src/TEXTURES > ppcz_sprites.txt
```

**Replace PCAS sprites in zoom states:**
```decorate
ReadyZoom:
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)  // ← Use PPCZ instead
    Loop
```

**Requires:** Extracting and porting PPCZ sprites (may need TEXTURES lump)

#### Polish 7.2: Scope Overlay Graphics

**Add scope reticle overlay when zoomed:**

**Requires:** HUD graphics + ACS/ZScript

**Basic approach:**
1. Create scope reticle PNG graphic
2. Display via HUD when PredZoom > 0
3. Scale reticle based on zoom level

#### Polish 7.3: Variable Zoom Speed

**Make zoom-in/out animated instead of instant:**

```decorate
Zoom1:
    TNT1 A 0 A_ZoomFactor(1.2)
    TNT1 A 1 A_ZoomFactor(1.4)
    TNT1 A 1 A_ZoomFactor(1.6)
    TNT1 A 1 A_ZoomFactor(1.8)
    TNT1 A 1 A_ZoomFactor(2.0)  // ← Final 2x
    TNT1 A 0 A_GiveInventory("PredZoom", 1)
    TNT1 A 0 A_PlaySound("/predator/pzoomin")
    Goto ReadyZoom
```

**Effect:** Smooth zoom transition over 5 tics (~0.14 seconds)

#### Polish 7.4: Breathing/Sway While Zoomed

**Add subtle weapon sway at higher zoom levels:**

**Requires:** `A_WeaponOffset` or `A_SetPitch` calls

**Example:**
```decorate
ReadyZoom:
    TNT1 A 0 A_JumpIfInventory("PredZoom", 3, "ReadyZoom8x")
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    Loop

ReadyZoom8x:
    PPCZ A 1 A_WeaponOffset(0, 32)    // Slight downward
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    PPCZ A 1 A_WeaponOffset(1, 33)    // Right and down
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    PPCZ A 1 A_WeaponOffset(0, 32)    // Center
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    PPCZ A 1 A_WeaponOffset(-1, 33)   // Left and down
    PPCZ A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM)
    Loop
```

**Effect:** Simulates breathing/heartbeat for realism

---

## Asset Checklist

### ✅ Before Implementation

- [ ] Backup current mod (git commit)
- [ ] AVP20 accessible for asset extraction
- [ ] GZDoom ready for testing
- [ ] Current weapons identified for zoom support

### 📦 Required Assets

**Sounds (2 files):**
- [ ] `/predator/pzoomin` - Zoom in sound
- [ ] `/predator/pzoomout` - Zoom out sound

**Sprites (Optional - PPCZ set):**
- [ ] PPCZA0.png (if implementing proper zoom sprites)
- [ ] Or use existing weapon sprites initially

**Code:**
- [ ] PredZoom inventory actor
- [ ] Zoom states for each weapon
- [ ] Modified deselect states

### 🔧 Modified Files

**Core Files:**
- [ ] `src/DECORATE.Predator` (add PredZoom inventory)
- [ ] `src/SNDINFO` (register zoom sounds)

**Weapon Files:**
- [ ] `src/DECORATE.Weapons` - PlasmaCaster zoom states
- [ ] `src/DECORATE.Weapons` - SpearGun zoom states (optional)
- [ ] `src/DECORATE.Weapons` - Other weapons as desired

---

## Testing Checklist

### Basic Functionality
- [ ] PredZoom inventory exists
- [ ] Zoom button works (reload key)
- [ ] Cycles through 3 levels (2x, 4x, 8x)
- [ ] Returns to normal on 4th press
- [ ] Zoom-in sound plays correctly
- [ ] Zoom-out sound plays correctly
- [ ] View magnification matches expected level

### Weapon Integration
- [ ] PlasmaCaster supports zoom
- [ ] Can fire while zoomed
- [ ] Returns to correct state after fire
- [ ] Deselect clears zoom state
- [ ] Other weapons support zoom (if added)

### Edge Cases
- [ ] Weapon switch resets zoom
- [ ] Death resets zoom
- [ ] Works with all predator classes
- [ ] No conflicts with other features
- [ ] Multiplayer compatible (if applicable)

### Polish
- [ ] Laser sight works during zoom (if added)
- [ ] Crosshair changes per level (if added)
- [ ] HUD shows zoom level (if added)
- [ ] Smooth transitions
- [ ] No visual glitches

---

## Troubleshooting

### Issue: Zoom button doesn't work
**Symptoms:** Pressing reload key does nothing

**Solutions:**
1. Check weapon Ready state has `WRF_ALLOWZOOM` flag
2. Verify reload key is bound correctly in GZDoom settings
3. Test with different key binding
4. Add debug: `TNT1 A 0 A_Print("Zoom pressed")`
5. Ensure PredZoom inventory exists

### Issue: Zoom stuck at one level
**Symptoms:** Can't cycle through zoom levels

**Solutions:**
1. Verify PredZoom MaxAmount is 3
2. Check jump logic in Zoom state
3. Add debug prints to show current zoom level
4. Test `A_GiveInventory("PredZoom", 1)` is working
5. Clear zoom manually with console: `take PredZoom`

### Issue: View doesn't zoom
**Symptoms:** Zoom level changes but view stays same

**Solutions:**
1. Check `A_ZoomFactor` values are correct (2.0, 4.0, 8.0)
2. Verify no other effects overriding zoom
3. Test FOV settings in GZDoom options
4. Try higher zoom factors to confirm it works
5. Check for conflicting zoom modifications

### Issue: Sounds don't play
**Symptoms:** Silent zoom changes

**Solutions:**
1. Verify sounds registered in SNDINFO
2. Check sound file paths are correct
3. Test sound files exist and are valid format
4. Try `A_PlaySound` with different sound
5. Check GZDoom sound volume settings

### Issue: Zoom doesn't reset on weapon switch
**Symptoms:** Zoom persists when changing weapons

**Solutions:**
1. Add zoom clear to Deselect state
2. Verify `A_TakeInventory("PredZoom", 3)` in deselect
3. Add `A_ZoomFactor(1.0)` in deselect
4. Test each weapon's deselect state
5. Check for weapon that doesn't properly deselect

---

## Performance Considerations

**CPU Impact:** Minimal
- Simple inventory checks
- No complex calculations
- Standard zoom function calls

**Visual Impact:** Low
- Zoom is engine-level feature
- May reduce FPS at extreme zoom (8x) due to more detail visible
- Can add `+INTERPOLATEANGLES` to weapon for smoother zoom

**Network Impact (Multiplayer):** Low
- Zoom is client-side
- Inventory sync is lightweight

**Compatibility:** High
- A_ZoomFactor available in GZDoom 1.0+
- No advanced features required
- Works on all platforms

---

## Success Criteria

Implementation is successful when:

✅ **Functional:**
- Zoom cycles through 3 levels smoothly
- Audio feedback is clear
- View magnification works correctly
- Resets properly on weapon switch

✅ **Balanced:**
- Zoom levels are useful but not overpowered
- Doesn't trivialize combat
- Provides tactical advantage at range

✅ **Polished:**
- Smooth transitions
- Clear user feedback
- No bugs or glitches
- Works across all supported weapons

✅ **Integrated:**
- Fits with existing mod systems
- No conflicts with other features
- Accessible and intuitive to use
- Consistent behavior across weapons

---

## Estimated Timeline

**TOTAL: 3-6 hours**

- Asset extraction: 30 min
- Inventory setup: 20 min
- PlasmaCaster integration: 1 hour
- Additional weapons: 30 min each
- Testing & balancing: 1 hour
- Polish features: 1-2 hours (optional)

**Minimal implementation:** 2 hours (PlasmaCaster only)
**Complete implementation:** 4 hours (multiple weapons)
**With all polish features:** 6-8 hours

---

## Next Steps After Completion

1. ✅ Test zoom extensively in actual gameplay
2. ✅ Gather player feedback on zoom levels
3. ✅ Adjust magnification if needed (balance)
4. ✅ Consider adding zoom to more weapons
5. ✅ Optional: Integrate with target lock system (if implemented)

---

**END OF IMPLEMENTATION PLAN 2: ZOOM SYSTEM**

For questions or issues during implementation, refer to:
- AVP20 source: `/home/jono/games/DooM/AVP20_Final_WIP/src/Actors/Weapons/Predator/`
- GZDoom Wiki A_ZoomFactor: https://zdoom.org/wiki/A_ZoomFactor
- This audit report: `AVP20_AUDIT_REPORT.md`
