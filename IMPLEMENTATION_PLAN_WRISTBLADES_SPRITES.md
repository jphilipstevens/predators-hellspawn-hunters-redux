# Implementation Plan: Wrist Blades Sprite Upgrade (AVP20 Dual Blades First)

**Feature:** Replace wrist blade sprites with AVP20 dual-blade visuals (dual-blade classes only)
**Difficulty:** ⭐⭐ Medium (1-3 hours once source sprites are available)
**Priority:** 🔥 HIGH - Visual polish
**Dependencies:** AVP20 compiled PK3/WAD containing DBL* sprite frames

---

## Goal

Replace wrist blade sprites with AVP20 visuals **without changing weapon logic or behavior**. Phase 1 already covered dual blades (`DoubleBlades` for `HeavyPredator`). The remaining goal is to replace **single-blade** sprites (`WRST`/`PRAT`) while keeping the current `Wristblade` state machine intact.

---

## Current State (Project)

**Dual-blade weapon:**
- `ACTOR DoubleBlades : Weapon` in `src/DECORATE.Weapons`
- Restricted to `HeavyPredator`
- Uses sprite prefixes: `DBLD`, `DBLN`, `DBLA`, `DBLL`, `DBLF`

**Single-blade weapon:**
- `ACTOR Wristblade : Weapon` in `src/DECORATE.Weapons`
- `Inventory.ForbiddenTo HeavyPredator`
- Uses sprite prefixes: `WRST`, `PRAT`

**Class assignments:**
- `HeavyPredator` starts with `DoubleBlades`
- All other classes use `Wristblade`

---

## AVP20 Source Reality Check

AVP20 `src/` does **not** include the actual `DBL*` sprite frames (only references to them). We must extract sprites from the **compiled AVP20 PK3/WAD**.

---

## PHASE 1: Dual-Blade Sprite Swap (HeavyPredator only) ✅ Done

### Step 1.1: Locate AVP20 compiled PK3/WAD
We need the built file (not the src folder). Once you provide the path, we will extract the `DBL*` sprites.

**Required sprite prefixes to satisfy current `DoubleBlades` states:**
- `DBLD` (raise/lower)
- `DBLN` (ready/idle)
- `DBLA` (main attack chain)
- `DBLL` (heavy left chain)
- `DBLF` (fast attack chain)

If AVP20 only provides `DBLD/DBLN/DBLA`, we will duplicate or remap frames to cover `DBLL/DBLF` (see Step 1.4).

### Step 1.2: Extract AVP20 dual-blade sprites
**Source:** AVP20 compiled PK3/WAD

**Action:**
- Extract all `DBL*` frames
- Verify frame coverage vs prefixes above

### Step 1.3: Replace project dual-blade sprites
**Destination:** `src/SPRITES/WEAPONS/WRISTBLADES/`

**Action:**
- Replace existing `DBL*` frames with AVP20 versions
- Keep file names identical to current project naming

**Why:** This avoids any DECORATE changes and preserves current weapon behavior.

### Step 1.4: Fill missing prefixes if needed
If AVP20 does not provide `DBLL` or `DBLF` frames:
- **Minimal safe option:** duplicate closest matching AVP20 frames (usually `DBLA*`) and rename to `DBLL*` / `DBLF*` to satisfy state references.
- **No logic changes required**; this is a sprite-only compatibility shim.

### Step 1.5: Test checklist
- Load `HeavyPredator` and confirm `DoubleBlades` animations play cleanly.
- Verify all attack chains and fast chains animate without missing-frame placeholders.
- Confirm no visual glitches in ready/raise/lower sequences.

---

## Decision Points Before Phase 1 Execution

- Provide the AVP20 compiled PK3/WAD path so we can extract `DBL*` frames.
- Confirm that only `HeavyPredator` uses dual blades for Phase 1 (current behavior).

---

## Files In Scope (Phase 1)

- `src/SPRITES/WEAPONS/WRISTBLADES/` (sprite replacement only)
- No DECORATE/ZScript changes required unless sprite prefixes are missing

---

## Single-Blade Reference (AVP20) - Current Implementation

**Source:** `/home/jono/games/DooM/AVP20_Final_WIP/src/Actors/Weapons/Predator/Wristblades.txt`

**Actor:** `HuntersCLAWS : Weapon` (Replaces `Fist`)
- **Sprite prefixes used:** `DBLD` (raise/lower), `DBLN` (ready/idle), `DBLA` (attack chains).
- **Ready flow:** transitions into `RealReady`, supports zoom and laser-sight logic.
- **Zoom system:** uses `PredZoom`, `CancelZoom`, `PredZoomLatch` equivalents with `A_ZoomFactor`, `A_ReFire`, and `WRF_ALLOWZOOM`.
- **State wiring:** `Ready`/`RealReady`/`Select`/`Deselect`/`Fire`/`AltFire`/`Reload`/`Lunge`, with combo tracking (`LightCombo1/2`) and berserk variants.
- **Behavioral note:** AVP20’s “single-blade” weapon is still **dual-blade art** via `DBL*` sprites, not `WRST/PRAT`.

---

## Current Project Implementation (Single-Blade)

**Source:** `src/DECORATE.Weapons`

**Actor:** `Wristblade : Weapon` (Replaces `Fist`)
- **Sprite prefixes used:** `WRST` (ready/raise/lower), `PRAT` (attacks), `PRCL` (ready/zoom).
- **Zoom system:** simplified zoom state within the weapon (uses `PredZoom` + `PredZoomLatch`), `A_ZoomFactor`, `WRF_ALLOWZOOM`.
- **State wiring:** `Ready` → `RealReady` → `ReadyZoom`, `Select`, `Deselect`, `Fire`, `AltFire`, plus poison/berserk/light predator branches.
- **Behavioral note:** This is a single-blade logic path with many attack variants driven by inventory flags.

---

## Differences (AVP20 vs This Project)

- **Sprite families:** AVP20 uses `DBL*` for its wrist blades (even for single-blade role). This project uses `WRST`/`PRAT` for single blades.
- **State complexity:** AVP20 includes lunge/laser-sight subflows and more granular combo tracking; this project uses simpler but heavily branched `PRAT` attack variants.
- **Zoom wiring:** AVP20 zoom is tightly integrated with Ready/RealReady/CancelZoom and inventory toggles. This project uses a local zoom latch and fewer states.
- **Art availability:** AVP20 `src` does not ship the actual sprite frames; they are referenced only.

---

## Gap Fill Plan (Single-Blade Sprite Replacement)

**Objective:** Replace `WRST` and `PRAT` sprites with AVP20 visuals while preserving the current `Wristblade` states.

1. **Sprite source decision**
   - Use AVP20 dual-blade frames as a base (since AVP20’s “single-blade” still uses `DBL*`), or use AVP20 `PHAND*` art if that is the intended look.

2. **Mapping strategy**
   - **Ready/raise/lower (`WRST`):** map to an ordered subset that matches idle and draw/retract poses.
   - **Attack (`PRAT`):** map to frames that show blade-extended motion (avoid raise/lower frames).

3. **Implementation method (non-logic)**
   - Keep `Wristblade` state machine untouched.
   - Replace/define `WRST*` and `PRAT*` sprite frames (either as real PNGs or via `TEXTURES` composites) so the existing DECORATE references resolve to the new art.

4. **Validation checklist**
   - `Ready/Select/Deselect` show only new sprites.
   - `Fire/AltFire` cycles attack frames (not raise/lower).
   - No missing-frame placeholders.
