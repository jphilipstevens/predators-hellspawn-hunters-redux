# Implementation Plan: Self-Destruct System

**Feature:** Predator self-destruct countdown from AVP20
**Difficulty:** ⭐⭐⭐ Medium-High (4-6 hours)
**Priority:** 🟡 MEDIUM - Fun feature but situational
**Dependencies:** ACS scripting knowledge recommended

---

## Overview

The self-destruct system is a classic Predator feature where the player can trigger a countdown sequence, culminating in a massive explosion. In AVP20, this integrates with multiple weapons and includes visual countdown, sound effects, and dramatic explosion.

## Current State Analysis

**Current Mod:**
- No self-destruct system found
- No countdown mechanism
- No self-destruct item or weapon

**AVP20 System:**
- Self-Destruct weapon/item (`Self_Destruct`)
- Activation trigger (`SelfDestuctTrigger` inventory)
- Usage tracking (`SelfDestUsed` inventory)
- Visual countdown display (SEDS sprites)
- Integrates with Accumulator weapon
- 3-2-1-0 countdown sequence (60 tics each = ~1.7 seconds per number)
- ACS script execution (`Destruct`)
- Massive explosion on completion

---

## Design Considerations

### Questions to Answer First:

1. **How is it activated?**
   - Option A: Dedicated item/weapon
   - Option B: Special key binding
   - Option C: Weapon altfire (e.g., on WristBlades)

2. **Can it be cancelled?**
   - Option A: No cancellation (AVP20 default)
   - Option B: Allow cancel with specific item/action
   - Option C: Automatic cancel on certain conditions

3. **What happens on explosion?**
   - Option A: Player dies, huge explosion kills nearby enemies
   - Option B: Player survives if far enough away
   - Option C: Player always dies (suicide bomb)

4. **Should it have cooldown/uses?**
   - Option A: One-time use per life
   - Option B: Unlimited uses with long cooldown
   - Option C: Limited uses (e.g., 3 per level)

**RECOMMENDED DESIGN:**
- Dedicated weapon slot (option 1A)
- No cancellation once started (option 2A)
- Player dies, massive explosion (option 3A)
- One-time use per life (option 4A)

---

## Implementation Steps

### PHASE 1: Asset Extraction (30 minutes)

#### Step 1.1: Extract Countdown Sprites
**Source:** `~/games/DooM/AVP20_Final_WIP/src/`

**Required Sprites:**
- `SEDSA0.png` - Countdown display "3"
- `SEDSB0.png` - Countdown display "2"
- `SEDSC0.png` - Countdown display "1"
- `SEDSD0.png` - Countdown display "0" / Detonation

**Commands:**
```bash
# Find SEDS sprites
find ~/games/DooM/AVP20_Final_WIP -name "SEDS*.png"

# Create self-destruct sprite directory
mkdir -p "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/SELFDESTRUCT"

# Copy sprites (once found)
cp /path/to/SEDS*.png "~/workspace/personal/predators-hellspawn-hunters-redux/src/SPRITES/WEAPONS/SELFDESTRUCT/"
```

#### Step 1.2: Extract Sound Files
**Source:** AVP20 sound directory

**Required Sounds:**
- `/predator/PCC` - Countdown beep (already exists for other weapons)
- Self-destruct activation sound (if exists)
- Countdown tick sounds (if exists)
- Detonation sound (use explosion sound)

**Commands:**
```bash
# Search for self-destruct related sounds
find ~/games/DooM/AVP20_Final_WIP -iname "*destruct*" -o -iname "*countdown*"

# Check for explosion sounds
find ~/games/DooM/AVP20_Final_WIP/src/SOUNDS -iname "*explo*"
```

**Note:** Can reuse existing sounds if self-destruct specific ones not found.

#### Step 1.3: Register Sounds in SNDINFO
**File:** `src/SNDINFO`

**Add:**
```
// Self-Destruct System
/predator/selfdestruct/activate   SOUNDS/PREDATOR/SD_ACTIVATE
/predator/selfdestruct/countdown  SOUNDS/PREDATOR/SD_COUNTDOWN
/predator/selfdestruct/detonate   SOUNDS/EXPLOSIONS/SD_DETONATE
```

**Or reuse existing:**
```
// Self-destruct uses existing sounds
// /predator/PCC for beeps
// Standard explosion for detonation
```

---

### PHASE 2: Core Actor Implementation (1 hour)

#### Step 2.1: Create Inventory Actors

**File:** `src/DECORATE.Predator` (or create `src/DECORATE.SelfDestruct`)

**Add these inventory types:**
```decorate
// ==============================================================================
// SELF-DESTRUCT SYSTEM
// Ported from AVP20_Final_WIP
// ==============================================================================

actor SelfDestuctTrigger : Inventory
{
    Inventory.MaxAmount 1
}

actor SelfDestUsed : Inventory
{
    Inventory.MaxAmount 1
}
```

#### Step 2.2: Create Self-Destruct Weapon

**Add to same file:**

```decorate
actor Self_Destruct : Weapon
{
    Game Doom
    +INVENTORY.UNTOSSABLE
    +INVENTORY.UNDROPPABLE
    Weapon.Kickback 0
    Weapon.AmmoUse1 0
    Weapon.AmmoUse2 0
    Weapon.SelectionOrder 9000  // Very low priority
    weapon.bobrangeX 0.1
    weapon.bobrangeY 0.1
    Inventory.PickupMessage "Self-Destruct Device - Use As Last Resort"
    +WEAPON.NOALERT
    -WEAPON.DONTBOB

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady
        Loop

    Select:
        TNT1 A 1 A_Raise
        NULL AAA 0 A_Raise
        Loop

    Deselect:
        TNT1 A 1 A_Lower
        NULL AAA 0 A_Lower
        Loop

    Fire:
        TNT1 A 0 A_JumpIfInventory("SelfDestUsed", 1, "AlreadyUsed")
        TNT1 A 0 A_GiveInventory("SelfDestuctTrigger", 1)
        Goto Activate

    AlreadyUsed:
        TNT1 A 20 A_Print("Self-Destruct Already Activated")
        Goto Ready

    Activate:
        TNT1 A 0 A_Print("SELF-DESTRUCT INITIATED")
        TNT1 A 0 A_PlaySound("/predator/PCC")
        SEDS A 60 A_Print("WARNING: SELF-DESTRUCT SEQUENCE ACTIVE")
        Goto Countdown

    Countdown:
        SEDS A 1 A_PlaySound("/predator/PCC")
        SEDS A 60 A_Print("3")
        SEDS B 60 A_Print("2")
        SEDS C 60 A_Print("1")
        SEDS D 10 A_Print("0")
        Goto Detonate

    Detonate:
        SEDS D 1 A_GiveInventory("SelfDestUsed", 1)
        SEDS D 1 A_TakeInventory("SelfDestuctTrigger", 99)
        SEDS D 1 ACS_NamedExecute("Destruct")
        Loop  // ACS script will kill player

    Spawn:
        TNT1 A -1
        Stop
    }
}
```

**Key Features:**
- Fire button triggers countdown
- Cannot be used twice (SelfDestUsed check)
- 60 tic countdown per number (~1.7 seconds)
- Calls ACS script "Destruct" for explosion
- Prevents weapon switching during countdown

---

### PHASE 3: ACS Script Implementation (1-2 hours)

#### Step 3.1: Create ACS Script

**File:** `src/ACS/selfdestruct.acs` (create new)

```c
#library "SELFDESTRUCT"
#include "zcommon.acs"

// Self-Destruct Explosion
script "Destruct" (void)
{
    // Visual effects - screen shake
    SetQuakeIntensity(1, 0, 0, 7.0, 2.0);
    Delay(35);  // 1 second delay

    // Flash screen white
    FadeTo(255, 255, 255, 1.0, 0.5);
    Delay(5);
    FadeTo(0, 0, 0, 0.0, 1.0);

    // Spawn massive explosion
    SpawnSpotForced("SelfDestructExplosion", 0, 0, 0);

    // Kill player
    Thing_Damage(0, 10000, MOD_SUICIDE);

    // Optional: Kill nearby monsters
    int radius = 512;  // Explosion radius
    int x = GetActorX(0);
    int y = GetActorY(0);
    int z = GetActorZ(0);

    // Damage all nearby actors
    Radius_Quake(10, 105, 0, 50, 0);

    // Print message
    Print(s:"SELF-DESTRUCT DETONATED");
}
```

**Compile:**
```bash
cd src/ACS
acc -i /path/to/gzdoom/acc/includes selfdestruct.acs
```

**Add to loadacs.txt:**
```
selfdestruct
```

#### Step 3.2: Create Explosion Actor

**File:** `src/DECORATE.SelfDestruct`

```decorate
actor SelfDestructExplosion
{
    +NOINTERACTION
    +NOBLOCKMAP
    +NOGRAVITY
    RenderStyle Add
    Alpha 1.0
    Scale 5.0

    States
    {
    Spawn:
        TNT1 A 0 A_Explode(500, 512, XF_HURTSOURCE)  // 500 damage, 512 radius
        TNT1 A 0 A_RadiusThrust(2000, 512, RTF_AFFECTSOURCE)  // Massive knockback
        TNT1 A 0 A_QuakeEx(10, 10, 10, 105, 0, 512, "", QF_SCALEDOWN)  // Screen shake

        // Explosion visual (reuse existing explosion sprites)
        MISL B 8 BRIGHT A_PlaySound("weapons/rocklx")
        MISL C 6 BRIGHT
        MISL D 4 BRIGHT

        // Spawn additional effects
        TNT1 AAAAAAAAAAAAAAA 0 A_CustomMissile("ExplosionParticle", 0, 0, random(0, 360), 2, random(0, 360))

        MISL E 10
        Stop
    }
}

actor ExplosionParticle
{
    +NOBLOCKMAP
    +NOGRAVITY
    +DONTSPLASH
    RenderStyle Add
    Alpha 0.9
    Scale 0.5

    States
    {
    Spawn:
        MISL BCD 2 BRIGHT
        Stop
    }
}
```

---

### PHASE 4: Weapon Integration (45 minutes)

#### Step 4.1: Add to Player Classes

**Files to modify:**
- `src/DECORATE.LIGHT`
- `src/DECORATE.HUNTER`
- `src/DECORATE.HEAVY`
- `src/DECORATE.ASSAULT`

**For EACH predator class:**

```decorate
Player.StartItem "WristBlade"
Player.StartItem "Energy", 500
Player.StartItem "Self_Destruct"  ← ADD THIS LINE
// ... other start items
```

**And add weapon slot:**

```decorate
Player.WeaponSlot 9, Self_Destruct  ← ADD THIS LINE
// Or choose slot 0 for "panic button" access
```

**Alternative:** Don't add to weapon slots, only accessible via weapon cycling.

#### Step 4.2: Optional - Integration with Accumulator

**If you implemented the Accumulator from Plan 1:**

**File:** `src/DECORATE.Weapons` (Accumulator actor)

**Modify Ready state to check for self-destruct:**

```decorate
Ready:
    TNT1 A 0 A_JumpIfInventory("SelfDestuctTrigger", 1, "SDActivated")  ← ADD
    TNT1 A 0 A_JumpIfInventory("PowerStrength", 1, "Ready2")
    TROF A 1 A_WeaponReady
    Goto PreFire

// ... later in states:

SDActivated:
    TNT1 A 0 A_JumpIfInventory("SelfDestUsed", 1, "NoDestruct")
    SEDS A 60 A_Print("Self-Destruct Initiated")
    SEDS A 1 A_PlaySound("/predator/PCC")
    SEDS A 60 A_Print("3")
    SEDS B 60 A_Print("2")
    SEDS C 60 A_Print("1")
    SEDS D 10 A_Print("0")
    SEDS D 1 A_TakeInventory("SelfDestuctTrigger", 99)
    SEDS D 1 ACS_NamedExecute("Destruct")
    Loop

NoDestruct:
    TROF A 1 ACS_NamedExecute("Destruct")
    TROF A 1 A_TakeInventory("SelfDestuctTrigger", 99)
    Goto Ready
```

**This allows self-destruct to interrupt accumulator charging (like AVP20).**

---

### PHASE 5: Advanced Features (1-2 hours, Optional)

#### Feature 5.1: Cancellation Mechanism

**Add ability to cancel before detonation:**

**Create cancel item:**
```decorate
actor SelfDestructCancel : CustomInventory
{
    Inventory.PickupMessage "Self-Destruct Cancellation Code"
    Inventory.MaxAmount 1
    +INVENTORY.AUTOACTIVATE

    States
    {
    Pickup:
        TNT1 A 0 A_JumpIfInventory("SelfDestuctTrigger", 1, "DoCancel")
        TNT1 A 0 A_Print("No active self-destruct to cancel")
        Fail

    DoCancel:
        TNT1 A 0 A_TakeInventory("SelfDestuctTrigger", 99)
        TNT1 A 0 A_Print("SELF-DESTRUCT CANCELLED")
        TNT1 A 0 A_PlaySound("misc/secret")
        Stop
    }
}
```

**Bind to key:**
```
bind X "use SelfDestructCancel"
```

**Or add altfire to self-destruct weapon for manual cancel.**

#### Feature 5.2: Variable Countdown Lengths

**Add configurable countdown duration:**

**File:** `src/cvarinfo.txt`
```
// Self-Destruct Settings
user int sd_countdown_duration = 60;  // Tics per number (default 60 = ~1.7 sec)
user bool sd_allow_cancel = false;     // Allow cancellation
user int sd_explosion_radius = 512;    // Explosion radius
user int sd_explosion_damage = 500;    // Explosion damage
```

**Modify countdown states:**
```decorate
Countdown:
    SEDS A 1 A_PlaySound("/predator/PCC")
    SEDS A 0 A_JumpIf(GetCVar("sd_countdown_duration") > 0, "CountdownCustom")
    SEDS A 60 A_Print("3")  // Default
    // ... rest

CountdownCustom:
    SEDS A 0 A_SetTics(GetCVar("sd_countdown_duration"))
    SEDS A 1 A_Print("3")
    // ... rest
```

#### Feature 5.3: Trophy Collection on Kill

**Award trophies for kills from self-destruct:**

**In ACS script:**
```c
script "Destruct" (void)
{
    // ... existing code ...

    // Count kills
    int killsBefore = GetActorProperty(0, APROP_KillCount);

    // Explosion happens...

    Delay(35);
    int killsAfter = GetActorProperty(0, APROP_KillCount);
    int trophyKills = killsAfter - killsBefore;

    if (trophyKills > 0)
    {
        Print(s:"Self-Destruct Trophy Kills: ", d:trophyKills);
        // Give bonus points or items
    }
}
```

#### Feature 5.4: Environmental Effects

**Add dramatic effects during countdown:**

**Modify countdown states:**
```decorate
Countdown:
    SEDS A 1 A_PlaySound("/predator/PCC")
    SEDS A 10 A_QuakeEx(2, 2, 2, 10, 0, 128, "")  // Escalating shake
    SEDS A 50 A_Print("3")

    SEDS B 1 A_PlaySound("/predator/PCC")
    SEDS B 10 A_QuakeEx(4, 4, 4, 10, 0, 128, "")  // Stronger shake
    SEDS B 50 A_Print("2")

    SEDS C 1 A_PlaySound("/predator/PCC")
    SEDS C 10 A_QuakeEx(6, 6, 6, 10, 0, 128, "")  // Even stronger
    SEDS C 50 A_Print("1")

    SEDS D 1 A_PlaySound("/predator/PCC")
    SEDS D 9 A_QuakeEx(8, 8, 8, 10, 0, 128, "")   // Maximum shake
    SEDS D 1 A_Print("0")
    Goto Detonate
```

#### Feature 5.5: HUD Warning Display

**Create persistent warning during countdown:**

**Requires ACS HUD script:**
```c
script "SDWarningHUD" (void) CLIENTSIDE
{
    while (CheckInventory("SelfDestuctTrigger") > 0)
    {
        HudMessage(s:"!! SELF-DESTRUCT ACTIVE !!";
                   HUDMSG_FADEOUT, 1, CR_RED,
                   0.5, 0.2, 0.1, 0.05);
        Delay(5);
    }
}
```

**Trigger from weapon:**
```decorate
Activate:
    TNT1 A 0 ACS_NamedExecute("SDWarningHUD")
    // ... rest
```

---

### PHASE 6: Testing & Balancing (1 hour)

#### Test 6.1: Basic Functionality
**Objectives:**
- ✅ Self-destruct weapon can be selected
- ✅ Fire button triggers countdown
- ✅ Countdown displays correctly (3-2-1-0)
- ✅ Sounds play at correct times
- ✅ Explosion occurs on completion
- ✅ Player dies from explosion

**Test Procedure:**
```
1. Start game as any predator
2. Switch to self-destruct weapon (slot 9)
3. Press fire
4. Watch countdown
5. Verify explosion and death
```

#### Test 6.2: Explosion Effects
**Objectives:**
- ✅ Explosion damages/kills nearby enemies
- ✅ Explosion has appropriate radius
- ✅ Visual effects are impressive
- ✅ Screen shake works
- ✅ Sound effects are dramatic

**Test Procedure:**
```
1. Spawn several enemies around player
2. Activate self-destruct
3. Wait for detonation
4. Verify enemies are killed/damaged
5. Check explosion radius (should be large)
```

#### Test 6.3: Edge Cases
**Objectives:**
- ✅ Cannot activate twice
- ✅ Works across all predator classes
- ✅ Persists across weapon switches (if integrated)
- ✅ No exploits or cheats possible

**Test Procedure:**
```
1. Activate self-destruct
2. Try to activate again (should fail)
3. Die and respawn
4. Verify can activate again after respawn
5. Test with different predator classes
6. Try switching weapons during countdown
```

#### Test 6.4: Balancing

**Explosion Radius:**
- Too small: < 256 units (not worth using)
- Good: 512 units (current setting)
- Too large: > 1024 units (too powerful)

**Explosion Damage:**
- Too weak: < 200 (doesn't kill tougher enemies)
- Good: 500 (current setting, kills most enemies)
- Too strong: > 1000 (overpowered)

**Countdown Duration:**
- Too fast: < 120 tics total (~3.4 seconds, no escape)
- Good: 240 tics total (~6.9 seconds, current setting)
- Too slow: > 600 tics (~17 seconds, boring)

**Adjustment Example:**
If explosion too weak:
```decorate
TNT1 A 0 A_Explode(750, 512, XF_HURTSOURCE)  // Increase damage
```

---

## Asset Checklist

### ✅ Before Implementation

- [ ] Backup current mod
- [ ] AVP20 accessible for asset extraction
- [ ] ACS compiler available (ACC)
- [ ] GZDoom ready for testing

### 📦 Required Assets

**Sprites (4 files):**
- [ ] SEDSA0.png (countdown "3")
- [ ] SEDSB0.png (countdown "2")
- [ ] SEDSC0.png (countdown "1")
- [ ] SEDSD0.png (countdown "0")

**Sounds (optional - can reuse existing):**
- [ ] Countdown beep sound
- [ ] Activation sound
- [ ] Detonation sound (can use rocket explosion)

**Code:**
- [ ] Self-Destruct weapon actor
- [ ] Inventory actors (SelfDestuctTrigger, SelfDestUsed)
- [ ] ACS script for explosion
- [ ] Explosion actor

### 🔧 Modified Files

- [ ] `src/DECORATE.SelfDestruct` (new file with all actors)
- [ ] `src/ACS/selfdestruct.acs` (new ACS script)
- [ ] `src/DECORATE.LIGHT` (add start item)
- [ ] `src/DECORATE.HUNTER` (add start item)
- [ ] `src/DECORATE.HEAVY` (add start item)
- [ ] `src/DECORATE.ASSAULT` (add start item)
- [ ] `src/SNDINFO` (register sounds if new)
- [ ] `src/loadacs.txt` (load ACS script)

---

## Testing Checklist

### Basic Functionality
- [ ] Self-destruct weapon exists
- [ ] Can select self-destruct
- [ ] Fire triggers countdown
- [ ] Countdown displays 3-2-1-0
- [ ] Player dies on detonation
- [ ] Explosion spawns correctly

### Visual Effects
- [ ] SEDS sprites display correctly
- [ ] Countdown numbers are visible
- [ ] Explosion effect is impressive
- [ ] Screen shake occurs
- [ ] Flash effect works

### Audio
- [ ] Countdown beeps play
- [ ] Activation sound plays
- [ ] Detonation sound plays
- [ ] Volume levels appropriate

### Gameplay
- [ ] Explosion kills nearby enemies
- [ ] Explosion radius is appropriate
- [ ] Damage is balanced
- [ ] Cannot use twice per life
- [ ] Resets on respawn

### Integration
- [ ] Works with all predator classes
- [ ] Doesn't break other weapons
- [ ] Accumulator integration works (if added)
- [ ] Multiplayer compatible (if applicable)

---

## Troubleshooting

### Issue: ACS script not executing
**Symptoms:** Countdown finishes but no explosion

**Solutions:**
1. Verify ACS script compiled successfully
2. Check loadacs.txt includes "selfdestruct"
3. Test ACS script directly: `puke Destruct`
4. Add debug: `Log(s:"Destruct executed")`
5. Check GZDoom console for errors

### Issue: Sprites not showing
**Symptoms:** Countdown invisible or wrong sprites

**Solutions:**
1. Verify SEDS sprites exist and correct names
2. Check sprite file format (PNG)
3. Ensure sprites in correct directory
4. Test with different sprites (TNT1, MISL, etc.)
5. Rebuild PK3/WAD

### Issue: Explosion too weak/strong
**Symptoms:** Doesn't kill enemies or too overpowered

**Solutions:**
1. Adjust `A_Explode` damage parameter
2. Increase/decrease radius
3. Add `XF_NOTMISSILE` flag if needed
4. Test with different enemy types
5. Balance based on playtesting

### Issue: Can use multiple times
**Symptoms:** Self-destruct works more than once

**Solutions:**
1. Verify SelfDestUsed inventory given
2. Check AlreadyUsed state logic
3. Add debug: `A_Print("Used count: ...")`
4. Ensure inventory persists
5. Check for inventory removal bugs

### Issue: Screen shake too intense/weak
**Symptoms:** Excessive shaking or barely noticeable

**Solutions:**
1. Adjust `A_QuakeEx` intensity values
2. Reduce/increase duration
3. Test on different screen sizes
4. Add gradual escalation
5. Make configurable via CVAR

---

## Performance Considerations

**CPU Impact:** Low-Medium
- ACS script execution is lightweight
- Explosion calculation is one-time
- Screen effects are temporary

**Visual Impact:** High (Intended)
- Large explosion effect
- Screen shake
- Flash effects
- Multiple particles

**Network Impact (Multiplayer):** Medium
- ACS execution must sync
- Explosion must sync to all clients
- Screen effects are client-side

**Balance Considerations:**
- One-time use prevents abuse
- Player death discourages casual use
- Should be "last resort" option
- Risk/reward: take enemies with you

---

## Success Criteria

Implementation is successful when:

✅ **Functional:**
- Countdown works reliably
- Explosion occurs on completion
- Player dies as expected
- Enemies are damaged/killed

✅ **Balanced:**
- Not overpowered or exploitable
- High risk (player death)
- High reward (massive damage)
- Appropriate for "last stand" situations

✅ **Polished:**
- Dramatic visual effects
- Clear countdown display
- Impressive explosion
- Satisfying audio feedback

✅ **Integrated:**
- Works with all predator classes
- Doesn't break other systems
- Optional integrations work (if added)
- Multiplayer compatible

---

## Estimated Timeline

**TOTAL: 4-6 hours**

- Asset extraction: 30 min
- Core actor implementation: 1 hour
- ACS script: 1-2 hours (if new to ACS)
- Player class integration: 45 min
- Testing & balancing: 1 hour
- Advanced features: 1-2 hours (optional)
- Bug fixes: 30-60 min

**Minimal implementation:** 3 hours (basic self-destruct)
**Complete implementation:** 5 hours (with polish)
**With all features:** 7-8 hours (includes advanced options)

---

## Design Alternatives

### Alternative 1: Key Binding Instead of Weapon

**Don't use weapon slot, bind to key:**

```decorate
actor SelfDestructActivator : CustomInventory
{
    +INVENTORY.AUTOACTIVATE
    Inventory.PickupMessage "Self-Destruct Activator"

    States
    {
    Pickup:
        TNT1 A 0 A_GiveInventory("SelfDestuctTrigger", 1)
        Stop
    }
}
```

**Bind in console:**
```
bind END "use SelfDestructActivator"
```

**Pros:** No weapon slot used, instant activation
**Cons:** Less dramatic, harder to discover

### Alternative 2: Timed Detonation

**Allow player to set timer before dying:**

**Add inventory for timer:**
```decorate
actor SDTimer : Inventory
{
    Inventory.MaxAmount 300  // Max 300 tics (~8.6 seconds)
}
```

**Weapon altfire sets timer:**
```decorate
AltFire:
    TNT1 A 0 A_GiveInventory("SDTimer", 35)  // Add 1 second
    TNT1 A 10 A_Print("Detonation Timer: +1 second")
    Goto Ready
```

**Explosion waits for timer:**
```c
script "Destruct" (void)
{
    int timer = CheckInventory("SDTimer");
    Delay(timer);
    // ... explosion code
}
```

### Alternative 3: Remote Detonation

**Allow player to trigger after setting:**

**Separate set and trigger:**
```decorate
Fire:
    // Set self-destruct (doesn't trigger yet)
    TNT1 A 0 A_GiveInventory("SDAr med", 1)
    TNT1 A 10 A_Print("Self-Destruct Armed - Altfire to Detonate")
    Goto Ready

AltFire:
    TNT1 A 0 A_JumpIfInventory("SDArmed", 1, "Trigger")
    Goto Ready

Trigger:
    TNT1 A 0 A_GiveInventory("SelfDestuctTrigger", 1)
    Goto Countdown
```

**Allows tactical placement then retreat.**

---

## Next Steps After Completion

1. ✅ Playtest extensively for balance
2. ✅ Gather feedback on explosion power
3. ✅ Adjust countdown duration if needed
4. ✅ Consider adding achievements/stats
5. ✅ Document in mod readme

---

**END OF IMPLEMENTATION PLAN 4: SELF-DESTRUCT SYSTEM**

For questions or issues during implementation, refer to:
- AVP20 source: `~/games/DooM/AVP20_Final_WIP/src/Actors/Weapons/Predator/SelfD.txt`
- GZDoom Wiki ACS: https://zdoom.org/wiki/ACS
- GZDoom Wiki A_Explode: https://zdoom.org/wiki/A_Explode
- This audit report: `AVP20_AUDIT_REPORT.md`
