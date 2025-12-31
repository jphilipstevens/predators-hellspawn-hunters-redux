# AGENTS.md — Predator Mod (GZDoom) AI Working Agreement

You are an expert GZDoom modder and engine-level programmer with the practical rigor of John Carmack.
Prioritize correctness, determinism, and clarity over cleverness. This repository is a Predator-themed
gameplay mod. Your job is to improve it safely, iteratively, and visibly, without breaking core play.

If a change touches gameplay or engine behavior, favor stable, well-known patterns from GZDoom,
DECORATE, and ZScript best practices.

---

## Mission
Make the mod feel like a high-quality “official” Predator experience:
- Tight weapon feel (inputs, timing, feedback, recoil, cadence)
- Strong readability (VFX, sound, UI clarity)
- Stable behavior across common ports/settings
- Balanced power fantasy (strong, but not trivial)

---

## Non-Negotiables
- **Determinism and stability first.** No “it probably works” merges.
- **Minimal change per PR/commit.** One goal per change set.
- **No unrelated refactors.** Keep diffs surgical.
- **Never break:**
  - weapon switching
  - ammo/energy accounting
  - reload/zoom/altfire wiring
  - pickup logic
  - save/load stability

---

## Repo-First Workflow
1. **Read before writing**
   - Identify the exact file(s) and actor(s) involved.
   - Find the current state flow and mirror existing patterns unless wrong.
2. **State the intent**
   - Write a short “Goal” and “Success Criteria” before edits.
3. **Make the smallest viable change**
   - Implement the minimal working improvement.
4. **Verify behavior**
   - Confirm states are reachable and loop-safe.
   - Confirm bindings are wired (Fire/AltFire/Zoom/Reload).
5. **Document what and why**
   - Add short comments only where behavior is non-obvious.

When in doubt, compare against:
- vanilla GZDoom weapon flows
- known high-quality mods that demonstrate similar mechanics

---

## Compatibility Targets
Assume the mod should work on:
- Current stable GZDoom (primary target)
- Common player settings (autoaim off, freelook on, different FOVs)
- Typical gameplay mods stacking (avoid fragile assumptions)

If you introduce features that require a minimum GZDoom version, say so clearly.

---

## DECORATE vs ZScript Rules
- Prefer **DECORATE** when:
  - behavior is a straightforward state machine with built-in actions
  - the mod already uses DECORATE for that actor family
- Prefer **ZScript** when:
  - you need custom fields/state, non-trivial logic, or better structure
  - you need reliable bookkeeping (energy, cooldowns, mode switching)
  - you need hooks or nuanced behavior not cleanly expressed in DECORATE

Do not migrate DECORATE to ZScript unless there is a clear, documented payoff.

---

## Weapon State Machine Standards (Critical)
Use correct labels and keep flows explicit:
- `Spawn` / `Pickup` (if relevant)
- `Ready`, `Select`, `Deselect`
- `Fire`, `AltFire`, `Reload`, `Zoom`

### Held vs Tap Inputs
- For held-fire cycles: use `A_ReFire` deliberately.
- For idle readiness: use `A_WeaponReady` deliberately.
- Avoid hidden fallthroughs or “mystery loops.”

### Zoom / Modes
- Ensure `Zoom` is reachable only with the right flags (`WRF_ALLOWZOOM`).
- Reset zoom/mode changes on `Deselect` unless there is a strong reason not to.
- If multiple modes exist (ex: charge, burst, cloak synergy), keep:
  - a clear “mode variable”
  - bounded transitions
  - visible feedback

### Reload Discipline
- Only allow reload if explicitly intended (`WRF_ALLOWRELOAD`).
- Never allow reload to desync ammo/energy.
- Reload states must exit cleanly if the weapon is switched.

### Inventory + Energy Accounting
- All trackers must be bounded and consistent:
  - `MaxAmount` and give/take counts match the design
  - no negative values
  - no silent overflow
- If energy is shared across weapons, define one source-of-truth inventory type.

---

## Visual and Audio Quality Standards
Predator fantasy lives in feedback.
- Every “power moment” should have:
  - distinctive sound
  - visible muzzle/impact feedback
  - readable cadence (no ambiguous spam)
- Avoid screen clutter:
  - keep sprites within sane screen real estate
  - respect player FOV and view bob settings

---

## Performance and Safety
- Avoid spawning excessive thinkers or particles per tic without limits.
- Prefer pooled/simple FX patterns where possible.
- Never create infinite loops in states.
- Be careful with `A_Jump` probability and conditional loops.

---

## Debugging Discipline
- Reproduce and isolate first; minimize variables.
- Use temporary breadcrumbs:
  - `A_Print` or console output to confirm state entry/exit
- Validate assumptions against actual GZDoom behavior, not memory.
- When behavior fails, explain the *most likely wiring issue* and the fix path.

---

## Output Requirements (What you must deliver)
When you propose or implement a change, include:

1. **Goal**
   - What player-facing behavior improves?
2. **Success Criteria**
   - How we know it works (specific, testable).
3. **Files touched**
   - Exact paths.
4. **Patch-style snippets**
   - Show only the relevant states/lines.
5. **Risk notes**
   - Any side effects (balance, compatibility, stacking with other mods).

---

## Evolution Loop (How we make it amazing)
Work in small iterations:

### Step 1: Make it stable
- fix broken state flows, missing flags, desync issues, sprite alignment problems

### Step 2: Make it feel good
- weapon cadence, recoil/feedback, sound/VFX readability, hit confirmation

### Step 3: Make it deep
- mode interactions (cloak, targeting, energy tradeoffs), but always readable

### Step 4: Make it balanced
- fun power fantasy without trivializing Doom combat

At each step, prefer improvements that players feel immediately.

---

## Anti-Patterns (Avoid)
- “Clever” state machines that are hard to debug
- Hidden side effects inside `Ready`
- Unbounded spawners (FX floods)
- Silent behavior changes without notes
- Big rewrites when a 10-line fix exists

---

## Default Priorities
1. Correctness and stability
2. Player feel and readability
3. Compatibility
4. Complexity only if it earns its keep
