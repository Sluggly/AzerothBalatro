# Azeroth Balatro

A [Balatro](https://www.playbalatro.com/) mod that brings the world of **Warcraft** into your poker runs. Face enemies, equip your jokers, complete quests, and build synergies around races, classes, and factions from Azeroth.

---

## New Mechanics

### Warcraft Jokers
Over 200 jokers inspired by iconic Warcraft characters, each with a **Race**, **Class**, **Faction**, and **Weapon** type. These attributes interact with each other and with the systems below.

### Equipment
Consumable items that attach to compatible jokers. Each piece of equipment has **item level (ilvl)** that scales its effect over time, **level and class requirements**, and optional **combo bonuses** when paired with specific jokers.

### Enemies
Hostile jokers that appear at the start of blinds. Each enemy has a **kill condition** — meet it during scoring to destroy them. Powerful enemies can apply debuffs or penalties if left alive. Boss enemies have stronger effects and harder conditions.

### Quests
A new consumable type. Each quest has a randomly rolled **condition** (have certain jokers, sell enemies, reach a level threshold) and a **reward** (level up jokers, gain ilvl, open a joker pack, earn gold, and more). Quests can also be completed by holding a specific **combo character** joker.

### Leveling System
Warcraft jokers gain **levels** over the course of a run, improving their effects. Equipment gains **ilvl** separately, scaling its own bonus independently of the joker's level.

---

## Installation

### Prerequisites
Both [Lovely](https://github.com/ethangreen-dev/lovely-injector/releases) and [Steamodded](https://github.com/Steamodded/smods/releases) must be installed. Use the latest release of each — older versions may cause issues.

### Steps
1. Download the zip file from this repository (**Code → Download ZIP**).
2. Navigate to your Balatro mods folder:
   - Windows: `%AppData%\Balatro\Mods`
3. Create a folder named `Warcraft` inside your mods folder.
4. Extract the zip and copy the contents so the structure looks like this:
```

Mods\Warcraft\main.lua
Mods\Warcraft\config.lua
Mods\Warcraft\functions\...
Mods\Warcraft\content\...
```
Make sure the files sit **directly** under the `Warcraft` folder and not under an extra subfolder (e.g. not `Mods\Warcraft\Warcraft\main.lua`).

5. Launch Balatro — the mod will load automatically.

---

## Thanks

This mod would not exist without the following projects:

- [**Steamodded**](https://github.com/Steamodded/smods) — the Balatro modding framework that makes all of this possible.
- [**Lovely**](https://github.com/ethangreen-dev/lovely-injector) — the Lua injector that powers Steamodded.

---

## Credits

- **Blizzard Entertainment** — all Warcraft artwork, characters, and lore belong to Blizzard Entertainment. This mod is a fan project and is not affiliated with or endorsed by Blizzard.
