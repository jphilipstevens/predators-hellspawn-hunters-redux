# Zoom System Review + Implementation Plan (Predators - Hellspawn Hunters Redux)

## Purpose
Review `IMPLEMENTATION_PLAN_2_ZOOM_SYSTEM.md` against AVP20 and this mod, then provide a concrete, minimal plan to add predator-style zoom to all current predator classes.

---

## Review Notes (Plan vs AVP20 vs Current Mod)

### Input wiring
- **Plan says reload key**. In AVP20 the zoom behavior is driven by `A_WeaponReady(WRF_ALLOWZOOM)`, which uses the engine **Weapon Zoom** binding (not reload). Reload is separate (`WRF_ALLOWRELOAD`).
- **Default bind**: if you want a mod-side default (like cloak/vision), add a KEYCONF alias and bind it to `X`.

### Inventory actors
- **AVP20** defines `PredZoom` as an `Inventory` actor (max 3) and uses it across predator weapons.
- **Current mod** does not define `PredZoom` at all. Best placement is `src/DECORATE.Predator` alongside other shared predator inventory items.
- **AVP20** also uses a `CancelZoom` inventory + ACS to force a cancel (optional but useful). The plan does not mention it.

### Sprites
- **Plan references `PPCZ` zoom sprites**. Those sprites do not exist in this mod.
- **AVP20** uses `PPCZ` for zoomed-ready frames. Without PPCZ, use each weapon's normal ready sprites.

### Sounds
- **Current mod** already defines `pzoomin` and `pzoomout` in `src/SNDINFO` but **without** the `/predator/` prefix. The plan references `/predator/pzoomin` and `/predator/pzoomout`.
- **Fix**: either use `pzoomin`/`pzoomout` directly in weapon states, or add aliases in `src/SNDINFO`.

### Weapon behavior
- **AVP20** uses explicit `Zoom`, `ReadyZoom`, and zoomed fire states (e.g., `ZoomedShot`, `ZoomedAlt`) and clears zoom on `Deselect`.
- **Current mod** has no zoom states in any weapon; PlasmaCaster already spawns `LaserSightSpawner` in Ready, which can be reused in ReadyZoom.

---

## Implementation Plan (Current Mod)

### Step 0: Optional default keybinding (X)
**File:** `src/KEYCONF`
```
addmenukey "Predator Weapon Zoom" predzoom
alias predzoom "+zoom"
defaultbind x predzoom
```

### Step 1: Add zoom inventory
**File:** `src/DECORATE.Predator`
```decorate
// ZOOM SYSTEM
actor PredZoom : Inventory
{
    Inventory.MaxAmount 3
}

// Optional: manual cancel hook (use if you add ACS to force-cancel)
actor CancelZoom : Inventory
{
    Inventory.MaxAmount 1
}
```

### Step 2: Normalize zoom sounds
**File:** `src/SNDINFO`
Option A (alias to match AVP20 paths):
```
/predator/pzoomin  pzoomin
/predator/pzoomout pzoomout
```
Option B (keep current and use `pzoomin`/`pzoomout` in weapon states).

### Step 3: Add zoom state template to weapons
Use this **template** for each weapon that should support the predator zoom cycle (2x, 4x, 8x). This mirrors the AVP20 flow but uses your weapon sprites.

**Core template (DECORATE):**
```decorate
Ready:
    <SPR> A 1 A_WeaponReady(WRF_ALLOWZOOM)
    Loop

Zoom:
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
    <SPR> A 1 A_WeaponReady(WRF_ALLOWZOOM)
    Loop

Fire:
    TNT1 A 0 A_JumpIfInventory("PredZoom", 1, "ZoomedFire")
    // existing fire code
    Goto Ready

ZoomedFire:
    // copy the normal fire code
    Goto ReadyZoom

Deselect:
    TNT1 A 0 A_TakeInventory("PredZoom", 3)
    TNT1 A 0 A_ZoomFactor(1.0)
    <SPR> A 1 A_Lower
    Loop
```

**Notes:**
- Replace `<SPR>` with the weapon’s ready sprite (e.g., `PCAS`, `WRST`, `PDSA`).
- If a weapon has multiple Ready loops (like PlasmaCaster), use a dedicated `ReadyZoom` block that matches the zoom-ready visuals.
- If you do not want zoomed fire differences, `ZoomedFire` can literally duplicate `Fire` and return to `ReadyZoom`.

### Step 4: Apply to weapons used by all predator classes
Because the classes share weapon actors, **editing the weapons once** covers all four predator classes.

**PredatorHunter** (`src/DECORATE.HUNTER`):
- WristBlade, Spear, EMPPistol, SpearGun, PlasmaCaster, PredatorDisk, NetGun, Accumulator

**AssaultPredator** (`src/DECORATE.ASSAULT`):
- WristBlade, Whip, WristMissileLauncher, PlasmaBomber, DoubleCaster, PredatorDisk, AssaultRailgun, Accumulator

**HeavyPredator** (`src/DECORATE.HEAVY`):
- DoubleBlades, Axe, WristMissileLauncher, Sword, PlasmaCaster, PredatorDisk, Accumulator

**LightPredator** (`src/DECORATE.LIGHT`):
- WristBlade, ThrowingDaggers, SpearGun, PlasmaCaster, PredatorDisk, Accumulator

**Recommendation:**
- Start with **ranged weapons** (PlasmaCaster, SpearGun, PredatorDisk, NetGun, DoubleCaster, AssaultRailgun, PlasmaBomber, WristMissileLauncher, EMPPistol, ThrowingDaggers).
- Add melee weapons later if desired (WristBlade, DoubleBlades, Axe, Sword, Whip, Spear). AVP20 allows zoom even on melee, but you may prefer 2x-only for clarity.

### Step 5: PlasmaCaster-specific notes
**File:** `src/DECORATE.Weapons` (PlasmaCaster)
- PlasmaCaster already spawns `LaserSightSpawner` in `Ready`. Mirror that in `ReadyZoom` so the laser remains visible while zoomed.
- Keep the existing energy checks and shot logic; only wrap `Fire` to branch to `ZoomedFire` when `PredZoom > 0`.

Example `ReadyZoom` for PlasmaCaster:
```decorate
ReadyZoom:
    PCAS A 0 A_FireCustomMissile("LaserSightSpawner", 0, 0, 0, 8)
    PCAS A 1 A_WeaponReady(WRF_ALLOWZOOM)
    Loop
```

### Step 6: Optional manual cancel key (ACS)
If you want a dedicated cancel key like AVP20:
- Add a `KEYCONF` alias that calls a small ACS script.
- The script should give `CancelZoom` when `PredZoom > 0` and take it immediately after.
- Weapons should check `CancelZoom` in `Ready`/`ReadyZoom` and jump to a `CZOOM` state that clears `PredZoom` and sets `A_ZoomFactor(1.0)`.

This is optional; the `Deselect` reset is usually enough.

---

## Quick Checklist
- `PredZoom` inventory actor exists (`src/DECORATE.Predator`).
- Zoom sound aliases exist or state calls use `pzoomin`/`pzoomout`.
- Each zoom-capable weapon has `Zoom`, `ReadyZoom`, `ZoomedFire`, and `Deselect` reset.
- `A_WeaponReady` uses `WRF_ALLOWZOOM` in both Ready and ReadyZoom.
- PlasmaCaster keeps LaserSight while zoomed.

---

## Suggested Test Pass
1. Equip PlasmaCaster, press Weapon Zoom key three times (2x, 4x, 8x), fourth returns to 1x.
2. Fire while zoomed; ensure it returns to `ReadyZoom` and keeps the zoom level.
3. Switch weapons while zoomed; ensure zoom resets to 1x.
4. Repeat with at least one weapon from each class list.

---

## Key Corrections to the Original Plan
- Use **Weapon Zoom** input (`WRF_ALLOWZOOM`), not reload.
- No `PPCZ` sprites available in this mod; use normal sprites.
- Add `/predator/pzoomin` and `/predator/pzoomout` aliases or use current sound names.
- PredZoom must be defined in this mod (not currently present).
