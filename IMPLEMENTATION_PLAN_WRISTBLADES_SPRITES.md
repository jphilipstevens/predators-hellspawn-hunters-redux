# Implementation Plan: Wrist Blades Sprite Upgrade (AVP20 Dual Blades First)

**Feature:** Replace wrist blade sprites with AVP20 dual-blade visuals (dual-blade classes only)
**Difficulty:** ⭐⭐ Medium (1-3 hours once source sprites are available)
**Priority:** 🔥 HIGH - Visual polish
**Dependencies:** AVP20 compiled PK3/WAD containing DBL* sprite frames

---

## Goal

Keep current wrist-blade behavior and weapon logic, but swap in better-looking AVP20 sprites. Start with **dual-blade classes only** (currently `HeavyPredator` using `DoubleBlades`). Single-blade classes stay unchanged for now; we will evaluate single-blade options after dual-blade testing passes.

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

## PHASE 1: Dual-Blade Sprite Swap (HeavyPredator only)

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

## PHASE 2 (Later): Single-Blade Sprite Options

After dual blades are validated:
- Review AVP20 single-blade options (if any) or create a custom single-blade set derived from dual-blade sprites.
- Map `WRST/PRAT` to the new single-blade frames.
- Keep `Wristblade` logic unchanged.

---

## Decision Points Before Phase 1 Execution

- Provide the AVP20 compiled PK3/WAD path so we can extract `DBL*` frames.
- Confirm that only `HeavyPredator` uses dual blades for Phase 1 (current behavior).

---

## Files In Scope (Phase 1)

- `src/SPRITES/WEAPONS/WRISTBLADES/` (sprite replacement only)
- No DECORATE/ZScript changes required unless sprite prefixes are missing

