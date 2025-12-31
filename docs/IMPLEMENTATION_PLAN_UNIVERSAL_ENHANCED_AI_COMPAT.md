# Universal Enhanced AI - Predator Mod Integration Plan

## Goal
Integrate Universal Enhanced AI into Predators: Hellspawn Hunters Redux while preserving the Predator cloak decoy behavior. The decoy must continue to redirect monsters when cloaked, and Enhanced AI must not override cloak visibility.

## Sources Of Truth
- Predator cloak + decoy logic: `src/zscript.txt`
- Predator cloak inventory + invis powerups: `src/DECORATE.Predator`
- Predator cloak toggle logic: `src/PREDSPE.acs`
- Predator event handler registration: `src/MAPINFO`
- Enhanced AI core + stealth: `~/games/DooM/Universal_Enhanced_AI/zscript/enhancedAI/main.txt`
- Enhanced AI stealth: `~/games/DooM/Universal_Enhanced_AI/zscript/enhancedAI/stealth.txt`
- Enhanced AI mapinfo: `~/games/DooM/Universal_Enhanced_AI/mapinfo.txt`

## Compatibility Risks To Address
- **bSHADOW ownership:** Enhanced AI stealth toggles `bSHADOW` every tic; Predator cloak uses `bSHADOW` + a decoy. If Enhanced AI clears `bSHADOW`, the cloak breaks.
- **Decoy scope:** Predator decoy currently spawns on any `bSHADOW` player. Enhanced AI stealth can set `bSHADOW` in darkness, which would spawn decoys when not cloaked.
- **Event handlers:** Both mods need to register event handlers. `AddEventHandlers` must include both `PredInvisHandler` and `EnhancedAIHandler`.

## Implementation Plan

### 1) Import Enhanced AI files into the Predator mod
Copy these files (or include the mod as a merged pk3):
- `~/games/DooM/Universal_Enhanced_AI/zscript/enhancedAI/*` -> `src/zscript/enhancedAI/`
- `~/games/DooM/Universal_Enhanced_AI/zscript.txt` -> merge into `src/zscript.txt`
- `~/games/DooM/Universal_Enhanced_AI/cvarinfo.txt` -> merge into `src/cvarinfo.txt`
- `~/games/DooM/Universal_Enhanced_AI/menudef.txt` -> merge into `src/MENUDEF`
- `~/games/DooM/Universal_Enhanced_AI/gldefs.txt` -> merge into `src/GLDEFS` (or equivalent)
- `~/games/DooM/Universal_Enhanced_AI/shaders/eai_stealth.fp` -> `src/shaders/eai_stealth.fp`

**ZScript include snippet (add to `src/zscript.txt`):**
```c
// Enhanced AI
#include "zscript/enhancedAI/main.txt"
#include "zscript/enhancedAI/search.txt"
#include "zscript/enhancedAI/path.txt"
#include "zscript/enhancedAI/group.txt"
#include "zscript/enhancedAI/stealth.txt"
```

### 2) Register both EventHandlers
Update `src/MAPINFO` to include both handlers.

**Target snippet in `src/MAPINFO`:**
```c
gameinfo
{
  AddEventHandlers = "PredInvisHandler", "EnhancedAIHandler"
}
```

If you keep the mods separate, the last-loaded `MAPINFO` may overwrite `AddEventHandlers`. Merging into a single pk3 is safest.

### 3) Gate the Predator decoy to CloakOn only
Update `PredInvisHandler` so decoys only spawn when the Predator cloak is active (`CloakOn` inventory). This prevents Enhanced AI stealth from triggering decoys.

**Where:** `src/zscript.txt` in `PredInvisHandler::PredMoveInvisTarget` and `PredInvisHandler::PredInvisTargetStatus`.

**Target behavior:**
- If `CloakOn` is **not** in inventory, destroy any existing decoy.
- If `CloakOn` **is** in inventory, allow decoy logic to run as it does now.

**Minimal check to add:**
```c
bool cloakActive = (mo.FindInventory("CloakOn") != null);
```

Use `cloakActive` alongside the existing `bShadow` checks to keep behavior stable.

### 4) Prevent Enhanced AI stealth from overriding Predator cloak
Enhanced AI’s stealth script changes `bSHADOW` every tic. Add a guard so it does nothing while the Predator cloak is active.

**Where:** `~/games/DooM/Universal_Enhanced_AI/zscript/enhancedAI/stealth.txt` (after merge, `src/zscript/enhancedAI/stealth.txt`).

**Target snippet:**
```c
if (owner.FindInventory("CloakOn") != null) { return; }
```

This ensures:
- Predator cloak controls `bSHADOW`.
- Enhanced AI stealth remains available for non-Predator players (or when cloak is off).

### 5) Optional: Disable Enhanced AI stealth shader for Predator vision modes
If Predator thermal/vision modes use their own shaders, consider disabling the Enhanced AI shader while cloaked or while a vision mode is active.

**Where:** `src/zscript/enhancedAI/stealth.txt`

**Suggested condition:**
```c
if (owner.FindInventory("CloakOn") != null) { return; }
```
This also prevents shader conflicts during cloak.

## Expected Results
- Cloaked Predator still spawns a decoy and monsters chase the decoy.
- Enhanced AI’s search, pathing, and coordination work normally with the decoy as the target.
- Enhanced AI stealth no longer interferes with Predator cloak state.

## Verification Checklist
- Cloak on/off: decoy appears only when `CloakOn` is active.
- Monster target switches to `PredInvisibleActor` while cloaked.
- When cloak is off, Enhanced AI stealth does not spawn decoys.
- Enhanced AI still enters chasing/searching modes when LOS is broken.

