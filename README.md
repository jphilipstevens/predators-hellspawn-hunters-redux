# Predators Hellspawn Hunters Redux

A customized version of the **Predators Hellspawn Hunters** mod for GZDoom/Zandronum.

## About

This is my personal fork of the original Predators Hellspawn Hunters mod, created to experiment with gameplay changes and add features that suit my playstyle. All core mechanics and assets are from the original mod with modifications and enhancements.

## Original Mod Credit

**Original Mod:** Predators Hellspawn Hunters
**Original Author:** jdredalert
**Forum Thread:** https://forum.zdoom.org/viewtopic.php?t=46444

This mod would not exist without jdredalert's excellent work. Please visit the original thread to show support and see the original version of the mod.

### Additional Credits

**Alternate Partial Invisibility Mechanics** - Based on TehRealSalt's "Alternate take on Partial Invisibility"
**Forum Thread:** https://forum.zdoom.org/viewtopic.php?f=43&t=70683

The improved cloaking behavior uses TehRealSalt's decoy-based invisibility system, which creates a more tactical and power-fantasy friendly stealth experience.

**Universal Enhanced AI** - By Joshua Hard (josh771), based on original work by Sterling Parker (Caligari87)
**GitHub Repository:** https://github.com/JRHard771/Universal-Enhanced-AI

This mod integrates the Universal Enhanced AI system to provide monsters with advanced pathfinding, group coordination, and intelligent search behavior. The implementation has been adapted to work seamlessly with the Predator cloak mechanics.

## Description

Predators Hellspawn Hunters is a gameplay mod that lets you play as a Predator (Yautja) from the Predator franchise. Hunt demons across the Doom universe with iconic Predator weapons and abilities including:

- **Cloaking Device** - Turn invisible to stalk your prey
- **Plasma Caster** - The iconic shoulder-mounted energy weapon
- **Wrist Blades** - Get up close and personal
- **Vision Modes** - Track your targets through walls
- And more weapons and gadgets from the films

## Changes from Original

### Improved Cloaking Mechanics
Integrated TehRealSalt's alternate invisibility system that replaces the vanilla partial invisibility behavior. Instead of enemies having inaccurate aim, the cloak now creates a "decoy" target at your last known position when you make noise (attacking or taking damage). This allows for more tactical stealth gameplay:

- **Tactical Distraction** - Make noise to redirect enemies to a decoy position, then attack from a different angle
- **True Stealth** - Sneak past enemies undetected if you remain silent
- **Power Fantasy** - Feels more like the Predator's iconic cloaking from the films, rather than just making enemies miss more often

This creates a more engaging stealth experience that rewards tactical positioning and timing.

### Enhanced Monster AI
Integrated the Universal Enhanced AI system with adaptations for Predator-specific mechanics:

- **Advanced Search Behavior** - Monsters remember your last known position and actively hunt you down, creating tense cat-and-mouse gameplay
- **Intelligent Pathfinding** - Enemies use smart navigation to track you through complex level geometry
- **Group Coordination** - Monsters communicate and coordinate their search efforts, flanking and converging on your position
- **Persistent Hunting** - Demons don't immediately give up when you break line of sight; they'll search for 1-2 minutes before giving up
- **Cloak Integration** - The Enhanced AI system has been modified to work seamlessly with the Predator cloak and decoy mechanics

## TODO - Planned Changes

Features and modifications I plan to implement:

1. **Optional Energy-Free Cloaking** - Add a setting to disable energy drain on the cloaking device for a more power fantasy-focused gameplay experience

## Installation

1. Make sure you have [GZDoom](https://zdoom.org/) or Zandronum installed
2. Download or clone this repository
3. Load the mod with your GZDoom-compatible IWAD (DOOM, DOOM2, etc.)

## License

This is a derivative work based on jdredalert's original mod. Please respect the original author's work and refer to the original forum thread for any licensing information.

---

*This is a personal modification project for learning and entertainment purposes.*
