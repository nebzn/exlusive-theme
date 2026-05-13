# Exclusive — Color Palette

Reference of all colors used in the Exclusive theme family, in hex and RGB. Useful for porting the theme to other tools (VS Code, Neovim, tmux, Alacritty, etc.).

All five variants share the same accents (purple, red, green, beige, blue, mauve, cerulean) and differ only in the **foreground** (text) tone.

## Shared base (all variants)

| Role | Hex | RGB | Notes |
|---|---|---|---|
| Background | `#1c1a24` | `28, 26, 36` | dark warm cream-black |
| Cursor | `#6d28d9` | `109, 40, 217` | deep grape purple |

## Shared ANSI accents (all variants)

| ANSI # | Role | Hex | RGB |
|---|---|---|---|
| 0 | Black | `#2a2533` | `42, 37, 51` |
| 1 | **Red** (errors) | `#e63946` | `230, 57, 70` |
| 2 | **Purple** (prompt / commands) | `#8b5cf6` | `139, 92, 246` |
| 4 | Blue (directories) | `#5b6ba8` | `91, 107, 168` |
| 5 | **Green** (success) | `#3ddc84` | `61, 220, 132` |
| 6 | Mauve | `#b894b8` | `184, 148, 184` |
| 8 | **Cerulean** (comments) | `#7eb1d6` | `126, 177, 214` |
| 9 | Bright red | `#ff5a6e` | `255, 90, 110` |
| 10 | Bright purple | `#a78bfa` | `167, 139, 250` |
| 12 | Bright blue | `#7a8ac8` | `122, 138, 200` |
| 13 | Bright green | `#5eff9f` | `94, 255, 159` |
| 14 | Bright mauve | `#c8a8c8` | `200, 168, 200` |

## Per-variant differences

### ExclusiveBone ⭐ (recommended)

| Slot | Hex | RGB |
|---|---|---|
| Foreground | `#fbf6ed` | `251, 246, 237` |
| Foreground bright (15) | `#fdfaf4` | `253, 250, 244` |
| Warning (3) | `#c4a78a` | `196, 167, 138` |
| Warning bright (11) | `#d4baa0` | `212, 186, 160` |

### ExclusiveAsh

| Slot | Hex | RGB |
|---|---|---|
| Foreground | `#d8d2cc` | `216, 210, 204` |
| Foreground bright | `#ebe5df` | `235, 229, 223` |
| Warning | `#c4a78a` | `196, 167, 138` |
| Warning bright | `#d4baa0` | `212, 186, 160` |

### ExclusiveTea

| Slot | Hex | RGB |
|---|---|---|
| Foreground | `#bdb5ac` | `189, 181, 172` |
| Foreground bright | `#d4ccc2` | `212, 204, 194` |
| Warning | `#c4a78a` | `196, 167, 138` |
| Warning bright | `#d4baa0` | `212, 186, 160` |

### ExclusiveSand

| Slot | Hex | RGB |
|---|---|---|
| Foreground | `#d4c5a9` | `212, 197, 169` |
| Foreground bright | `#e0d2b8` | `224, 210, 184` |
| Warning | `#c9a96e` | `201, 169, 110` |
| Warning bright | `#d9bc88` | `217, 188, 136` |

### ExclusiveMidnight

| Slot | Hex | RGB |
|---|---|---|
| Foreground | `#e8e0d0` | `232, 224, 208` |
| Foreground bright | `#f5efe0` | `245, 239, 224` |
| Warning | `#d4b483` | `212, 180, 131` |
| Warning bright | `#e8c9a0` | `232, 201, 160` |

## Design notes

- **Color 2 and Color 5 are swapped** versus the conventional ANSI mapping, so the Kali zsh prompt (which uses Color 2) renders in purple instead of green. Success messages and other Color 5 outputs end up in green automatically.
- **Color 0 Intense** is reused for comments by `zsh-syntax-highlighting` — it's deliberately set to a soft cerulean pastel for legibility against the dark background.
- **Color 1** (red) is kept strong (ruby red) so errors never get lost.
- No bright/neon yellow anywhere: the warning slot uses a soft beige/sand for a calmer overall feel.
