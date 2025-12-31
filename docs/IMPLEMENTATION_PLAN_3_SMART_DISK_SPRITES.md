# Implementation Plan: Smart Disk Sprite Update

**Feature:** Replace current disk sprites with higher-quality AVP20 sprites
**Difficulty:** ⭐ Very Low (1-2 hours)
**Priority:** 🟡 MEDIUM - Visual improvement only
**Dependencies:** None - sprite replacement

---

## Overview

The current mod has a functional PredatorDisk weapon but with older/lower quality sprites. AVP20 has higher quality smart disk sprites that can be directly swapped in to improve visual fidelity. This is a purely cosmetic upgrade that doesn't change gameplay mechanics.

## Current State Analysis

**Current Mod:**
- Weapon: `PredatorDisk` (DECORATE.Weapons:933)
- Weapon view sprites: `PDSA` (A-E frames)
- Pickup sprite: `PDSKG0.png`
- Ammo icon: `PDSKV0.png`
- **Current sprite files:**
  - PDSAA0.png - PDSAE0.png (5 weapon view frames)
  - PDSKG0.png (pickup sprite)
  - PDSKV0.png (HUD icon)

**AVP20:**
- Weapon: `SmartDisk`
- Uses PHAND composite system + SDISK patches for weapon view
- Simpler sprite set in dedicated folder
- **Available sprites:**
  - PDSKF0.png (projectile flying)
  - PDSKG0.png (pickup)
  - PDSKT0.png (projectile thrown)
  - PDSKV0.png (HUD icon)
- **Plus composite patches:**
  - SDISK1.png - SDISK4.png (4 large weapon view patches)

**Comparison:**
| Current Mod | AVP20 | Notes |
|-------------|-------|-------|
| 5 weapon frames (14-15KB each) | 4 weapon patches (23-28KB each) | AVP20 higher resolution |
| PDSKG0: 817 bytes | PDSKG0: 836 bytes | Similar |
| PDSKV0: 4307 bytes | PDSKV0: 3523 bytes | Current slightly larger |
| Direct sprites | Composite system | AVP20 uses TEXTURES |

---

## Implementation Strategy

### Strategy Options:

#### **Option A: Simple Sprite Swap (RECOMMENDED)**
**Approach:** Copy AVP20 sprite files directly, replacing current ones
**Pros:** Fast, simple, no code changes needed
**Cons:** May not get full composite system benefits
**Time:** 30-45 minutes

#### **Option B: Full Composite System Port**
**Approach:** Port entire TEXTURES definitions + SDISK patches
**Pros:** Authentic AVP20 implementation, better animation
**Cons:** Complex, requires TEXTURES lump integration
**Time:** 2-4 hours

#### **Option C: Hybrid Approach**
**Approach:** Use SDISK patches to create new PDSA sprites manually
**Pros:** Best quality, keeps current code compatibility
**Cons:** Requires image editing skills
**Time:** 1-2 hours

**RECOMMENDATION: Option A** for quick visual upgrade, can always upgrade to Option B later.

---

## Implementation Steps (Option A: Simple Swap)

### PHASE 1: Asset Extraction (20 minutes)

#### Step 1.1: Backup Current Sprites
**Create backup before replacing:**

```bash
# Backup current disk sprites
mkdir -p "~/workspace/personal/predators-hellspawn-hunters-redux/backups/DISK_SPRITES_ORIGINAL"
cp ~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/* \
   "~/workspace/personal/predators-hellspawn-hunters-redux/backups/DISK_SPRITES_ORIGINAL/"
```

**Backed up files:**
- PDSAA0.png (14908 bytes)
- PDSAB0.png (14539 bytes)
- PDSAC0.png (14149 bytes)
- PDSAD0.png (13891 bytes)
- PDSAE0.png (13891 bytes)
- PDSKG0.png (817 bytes)
- PDSKV0.png (4307 bytes)

#### Step 1.2: Extract AVP20 Sprites
**Source locations:**
- Weapon view: `~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/`
- Pickup/HUD: `~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/`

**Copy AVP20 sprites:**
```bash
# Copy projectile and pickup sprites
cp "~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/PDSKF0.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/"

cp "~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/PDSKG0.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/"

cp "~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/PDSKT0.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/"

cp "~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/PDSKV0.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/"
```

**Note:** AVP20 doesn't have PDSAA-E sprites (uses composite system). Need to handle weapon view differently.

---

### PHASE 2: Weapon View Sprite Handling (30 minutes)

#### Option 2A: Use AVP20 Composite System (Better Quality)

**This requires porting TEXTURES definitions.**

**Step 2A.1: Find PDSK definitions in AVP20 TEXTURES:**
```bash
grep -n -A 20 "Sprite PDSK" ~/games/DooM/AVP20_Final_WIP/src/TEXTURES > pdsk_textures.txt
```

**Step 2A.2: Create/Edit TEXTURES file:**

**File:** `src/TEXTURES` (create if doesn't exist)

**Add these definitions** (extracted from AVP20):
```
// Smart Disk Weapon View Sprites
// Using SDISK composite patches

Sprite PDSAA0, 300, 200
{
    XScale 1.800
    YScale 1.800
    Offset 150, -100
    Patch SDISK1, 0, 0
}

Sprite PDSAB0, 300, 200
{
    XScale 1.800
    YScale 1.800
    Offset 150, -100
    Patch SDISK2, 0, 0
}

Sprite PDSAC0, 300, 200
{
    XScale 1.800
    YScale 1.800
    Offset 150, -100
    Patch SDISK3, 0, 0
}

Sprite PDSAD0, 300, 200
{
    XScale 1.800
    YScale 1.800
    Offset 150, -100
    Patch SDISK4, 0, 0
}

Sprite PDSAE0, 300, 200
{
    XScale 1.800
    YScale 1.800
    Offset 150, -100
    Patch SDISK1, 0, 0  // Reuse frame 1 for frame E
}
```

**Step 2A.3: Copy SDISK patch files:**
```bash
# Create patch directory
mkdir -p "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/patches"

# Copy SDISK patches
cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK1.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/patches/"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK2.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/patches/"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK3.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/patches/"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK4.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/patches/"
```

**Note:** TEXTURES file must be in root of PK3/WAD, not in subdirectory.

#### Option 2B: Quick Fix - Rename SDISK to PDSA (Simple but Lower Quality)

**If TEXTURES seems too complex, can rename AVP20 patches:**

```bash
# Create simple sprites from patches (loses composite benefits)
cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK1.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/PDSAA0.png"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK2.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/PDSAB0.png"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK3.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/PDSAC0.png"

cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK4.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/PDSAD0.png"

# Reuse SDISK1 for E frame
cp "~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/SDISK1.png" \
   "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/DISK/PDSAE0.png"
```

**This approach:**
- ✅ Works immediately, no TEXTURES needed
- ✅ Simple to implement
- ❌ Sprites may be offset incorrectly (need manual adjustment)
- ❌ Doesn't use composite system benefits

**Recommended:** Option 2A (TEXTURES) if comfortable, Option 2B for quick test

---

### PHASE 3: Sprite Adjustment (30 minutes)

#### Step 3.1: Test Initial Sprite Placement

**Load mod and check:**
```
1. Start game with any predator class
2. Pick up or equip PredatorDisk
3. Observe weapon sprite positioning
```

**Common issues:**
- Sprite offset too high/low
- Sprite too large/small
- Sprite shifted left/right

#### Step 3.2: Adjust TEXTURES Offsets (if using Option 2A)

**If sprite appears misaligned, adjust Offset values:**

**File:** `src/TEXTURES`

**Example adjustments:**
```
Sprite PDSAA0, 300, 200
{
    XScale 1.800   // Increase/decrease for size
    YScale 1.800
    Offset 150, -100  // X: left/right, Y: up/down (negative = up)
    Patch SDISK1, 0, 0
}
```

**Typical corrections:**
- **Sprite too low:** Decrease Y offset (e.g., -100 → -120)
- **Sprite too high:** Increase Y offset (e.g., -100 → -80)
- **Sprite too far left:** Increase X offset (e.g., 150 → 160)
- **Sprite too far right:** Decrease X offset (e.g., 150 → 140)
- **Sprite too small:** Increase XScale/YScale (e.g., 1.800 → 2.000)
- **Sprite too large:** Decrease XScale/YScale (e.g., 1.800 → 1.600)

#### Step 3.3: Match AVP20 Exact Offsets (Advanced)

**For pixel-perfect accuracy, extract exact offsets from AVP20 TEXTURES:**

```bash
# Extract Smart Disk TEXTURES section from AVP20
grep -B 5 -A 15 "PDSK" ~/games/DooM/AVP20_Final_WIP/src/TEXTURES | grep -A 15 "Sprite"
```

**Copy exact values from AVP20 for best results.**

---

### PHASE 4: Testing (20 minutes)

#### Test 4.1: Visual Appearance
**Objectives:**
- ✅ Weapon sprite appears correctly positioned
- ✅ Weapon sprite is appropriate size
- ✅ Weapon sprite animates smoothly
- ✅ No visual glitches or clipping

**Test Procedure:**
```
1. Equip disk weapon
2. Observe ready animation (PDSA A-E cycle)
3. Check sprite position on screen
4. Verify size looks appropriate
5. Test in different resolutions
```

#### Test 4.2: Pickup Sprite
**Objectives:**
- ✅ Pickup sprite (PDSKG0) appears in world
- ✅ Icon sprite (PDSKV0) appears in HUD/inventory

**Test Procedure:**
```
1. Spawn disk pickup in world: `summon Disk`
2. Verify pickup sprite appears
3. Pick up disk
4. Check HUD ammo icon
```

#### Test 4.3: Projectile Sprites
**Objectives:**
- ✅ Flying disk sprite (PDSKF0) appears
- ✅ Thrown disk sprite (PDSKT0) if used

**Test Procedure:**
```
1. Throw disk at enemy
2. Observe projectile sprite
3. Verify it spins/animates correctly
4. Check on impact
```

#### Test 4.4: Comparison with Original
**Objectives:**
- ✅ New sprites are higher quality
- ✅ Improvement is noticeable
- ✅ Fits with mod's art style

**Test Procedure:**
```
1. Load backup mod (with old sprites)
2. Take screenshot of disk weapon
3. Load new mod (with AVP20 sprites)
4. Take screenshot of disk weapon
5. Compare side-by-side
```

---

### PHASE 5: Optional Enhancements (30-60 minutes)

#### Enhancement 5.1: Add Spinning Disk Animation

**AVP20 disk may have rotation sprites.** Can enhance projectile:

**Check for animated disk sprites:**
```bash
find ~/games/DooM/AVP20_Final_WIP -name "*DISK*" -type f | grep -i sprite
```

**If multiple rotation frames found (e.g., PDSKF0-F7):**

**Modify SeekerDisk actor (DECORATE.Weapons:1029):**
```decorate
ACTOR SeekerDisk
{
    // ... existing properties ...

    States
    {
    Spawn:
        PDSK FGHIJKLM 1 Bright  // ← Add more frames for rotation
        Loop

    Death:
        // ... existing death state ...
    }
}
```

#### Enhancement 5.2: Improve Weapon Bob/Sway

**Make disk weapon feel heavier/lighter based on AVP20:**

**File:** `src/DECORATE.Weapons` (PredatorDisk actor)

**Add/modify bob settings:**
```decorate
ACTOR PredatorDisk : Weapon
{
    Weapon.SelectionOrder 2500
    Scale 0.7
    Weapon.SlotNumber 6
    +WEAPON.NOALERT
    weapon.bobrangeX 0.5  // ← Add these
    weapon.bobrangeY 0.4  // ← Subtle weapon sway

    // ... rest of actor
}
```

**Values:**
- bobrangeX: Horizontal sway (0.0 = none, 1.0 = full)
- bobrangeY: Vertical bob (0.0 = none, 1.0 = full)

**AVP20 uses:**
- bobrangeX 0.4
- bobrangeY 0.4

#### Enhancement 5.3: Add Disk Glow Effect

**Make disk glow when ready to throw:**

**Requires:** Bright frame sprites or dynamic light

**Simple approach - mark sprites as bright:**
```decorate
Ready:
    // ... existing ready states ...
RealReady:
    PDSA A 1 BRIGHT A_WeaponReady  // ← Add BRIGHT for glow
    Loop
```

**Advanced approach - add dynamic light:**
```decorate
RealReady:
    PDSA A 0 A_Light1  // Add light
    PDSA A 1 A_WeaponReady
    Loop
```

---

## Asset Checklist

### ✅ Before Implementation

- [ ] Backup current disk sprites
- [ ] AVP20 accessible for extraction
- [ ] GZDoom installed for testing
- [ ] Image viewer for sprite comparison

### 📦 Required Assets from AVP20

**From `/src/Sprites/Weapons/SmartDisk/`:**
- [ ] PDSKF0.png (flying projectile)
- [ ] PDSKG0.png (pickup)
- [ ] PDSKT0.png (thrown)
- [ ] PDSKV0.png (HUD icon)

**From `/src/Graphics/Weapons/Predator/SMART DISK/`:**
- [ ] SDISK1.png (weapon view patch 1)
- [ ] SDISK2.png (weapon view patch 2)
- [ ] SDISK3.png (weapon view patch 3)
- [ ] SDISK4.png (weapon view patch 4)

### 🔧 Modified/Created Files

- [ ] `src/SPRITES/WEAPONS/DISK/` (sprite files replaced)
- [ ] `src/TEXTURES` (created or modified - Option 2A only)
- [ ] Backup folder created with original sprites

---

## Testing Checklist

### Visual Quality
- [ ] Sprites are higher resolution than originals
- [ ] Colors match predator aesthetic
- [ ] No pixelation or artifacts
- [ ] Transparency/alpha channels correct

### Positioning
- [ ] Weapon view sprite centered correctly
- [ ] Weapon view sprite at correct vertical position
- [ ] Weapon sprite doesn't clip screen edges
- [ ] Scale is appropriate

### Animation
- [ ] Ready animation cycles smoothly
- [ ] Raising animation looks good
- [ ] Lowering animation looks good
- [ ] Fire animation works correctly
- [ ] Recall animation works (if applicable)

### Projectile
- [ ] Flying disk sprite appears
- [ ] Spinning animation works (if added)
- [ ] Impact sprite/effect works
- [ ] Disk return animation works

### Compatibility
- [ ] Works at different resolutions
- [ ] Works with different predator classes
- [ ] Works in multiplayer (if applicable)
- [ ] No conflicts with other mods

---

## Troubleshooting

### Issue: Sprite not appearing
**Symptoms:** Invisible weapon or missing sprite

**Solutions:**
1. Check sprite file is PNG format
2. Verify filename matches exactly (case-sensitive)
3. Ensure sprite is in correct directory
4. Check for TEXTURES syntax errors (if using)
5. Rebuild PK3/WAD file

### Issue: Sprite offset wrong
**Symptoms:** Weapon too high, too low, or shifted

**Solutions:**
1. Adjust Offset values in TEXTURES
2. Start with AVP20 exact values
3. Increment/decrement by 10 until correct
4. Test at different resolutions
5. Compare with other weapon offsets

### Issue: Sprite too large/small
**Symptoms:** Weapon fills screen or too tiny

**Solutions:**
1. Adjust XScale and YScale in TEXTURES
2. Try values between 1.0 and 2.5
3. Match other weapons in mod for consistency
4. Check original sprite resolution
5. Resize source PNG if necessary

### Issue: TEXTURES not loading
**Symptoms:** TEXTURES definitions ignored

**Solutions:**
1. Verify TEXTURES file is in root of PK3
2. Check for syntax errors (missing braces, commas)
3. Ensure patch files exist in correct location
4. Test with simpler TEXTURES entry first
5. Check GZDoom console for error messages

### Issue: Animation stutters
**Symptoms:** Choppy weapon animation

**Solutions:**
1. Verify all frame files exist (PDSA A-E)
2. Check frame durations in DECORATE
3. Ensure sprites are same resolution
4. Test on different performance settings
5. Reduce number of frames if needed

### Issue: Colors don't match
**Symptoms:** Disk sprites look off-color vs rest of mod

**Solutions:**
1. Check PNG color profile (sRGB recommended)
2. Adjust brightness/contrast in image editor
3. Apply color grading to match existing weapons
4. Use GZDoom brightness settings
5. Add brightness keyword in TEXTURES if needed

---

## Performance Considerations

**File Size Impact:**
- Current sprites: ~72KB total
- AVP20 sprites: ~110KB total (weapon patches)
- **Increase:** ~40KB (+55%)

**Loading Time:** Negligible increase

**Memory Impact:** Minimal (~40KB additional RAM)

**Visual Impact:**
- Higher resolution sprites
- Better detail at high resolutions
- May look better on modern displays

**Compatibility:**
- PNG format compatible with all GZDoom versions
- TEXTURES lump requires GZDoom 1.0+
- No performance concerns on any modern hardware

---

## Success Criteria

Implementation is successful when:

✅ **Visual Improvement:**
- Sprites are noticeably higher quality
- Better detail and clarity
- Professional appearance

✅ **Functional:**
- All sprites display correctly
- Weapon works identically to before
- No new bugs introduced

✅ **Polished:**
- Proper positioning and scaling
- Smooth animations
- Consistent with mod art style

✅ **Complete:**
- All disk sprites replaced
- Pickup, HUD, weapon view, projectile
- No missing sprites

---

## Comparison Guide

### Before and After

**Current Mod Sprites:**
- Resolution: Medium (roughly 300x200px weapon view)
- Art style: Older pixel art
- Detail level: Moderate
- File size: ~14KB per frame

**AVP20 Sprites:**
- Resolution: High (weapon patches 400x500px+)
- Art style: Higher fidelity
- Detail level: High
- File size: ~23-28KB per patch

**Expected Result:**
- Crisper edges
- More detail on disk
- Better defined weapon
- More professional look

---

## Estimated Timeline

**TOTAL: 1-2 hours**

**Quick Swap (Option 2B):**
- Asset extraction: 15 min
- File replacement: 10 min
- Basic testing: 15 min
- **TOTAL: 40 minutes**

**Proper Implementation (Option 2A with TEXTURES):**
- Asset extraction: 20 min
- TEXTURES creation: 30 min
- Offset adjustment: 30 min
- Testing: 20 min
- **TOTAL: 1 hour 40 minutes**

**With Enhancements:**
- Add enhancement features: 30-60 min
- **TOTAL: 2-3 hours**

---

## Alternative: Manual Sprite Creation

**If AVP20 sprites don't work well:**

**Option:** Create custom sprites using AVP20 as reference

**Process:**
1. Open SDISK patches in image editor
2. Composite manually for weapon view
3. Adjust positioning for optimal look
4. Export as PDSAA-E frames
5. Test and refine

**Tools needed:**
- GIMP, Photoshop, or similar
- Sprite editing skills
- 1-3 hours additional time

---

## Next Steps After Completion

1. ✅ Compare before/after screenshots
2. ✅ Get community feedback on visual quality
3. ✅ Document change in mod changelog
4. ✅ Consider updating other weapon sprites similarly
5. ✅ Optional: Create sprite comparison video

---

**END OF IMPLEMENTATION PLAN 3: SMART DISK SPRITE UPDATE**

For questions or issues during implementation, refer to:
- AVP20 sprites: `~/games/DooM/AVP20_Final_WIP/src/Sprites/Weapons/SmartDisk/`
- AVP20 patches: `~/games/DooM/AVP20_Final_WIP/src/Graphics/Weapons/Predator/SMART DISK/`
- GZDoom Wiki TEXTURES: https://zdoom.org/wiki/TEXTURES
- This audit report: `AVP20_AUDIT_REPORT.md`
