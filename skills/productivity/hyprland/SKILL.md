---
name: hyprland
description: "Computer use on a Linux Hyprland desktop through the shell, with no computer-use tool required: see the screen, click and type into apps, and read or arrange monitors, windows and workspaces. Use when the user asks you to control their computer, look at their screen, work an app, or move windows."
---

# Hyprland

You are working on the user's live desktop, and they are probably sitting at it. Every focus change, cursor move and keystroke lands where they are working.

## Preflight

Run once per session, before the first action:

1. `hyprctl version` must succeed. If it fails, there is no reachable Hyprland session: stop and tell the user.
2. `hyprctl dispatch 'hl.dsp.no_op()'` must print `ok`. That confirms the Lua dispatch API this skill uses. An error means the compositor runs the legacy hyprlang API: dispatch as `hyprctl dispatch <name> <args>` and take dispatcher names from <https://wiki.hypr.land/Configuring/Dispatchers/>.
3. `command -v grim wlrctl wtype`: `grim` takes screenshots, `wlrctl` clicks and scrolls, and `wtype` types. If any is missing, ask the user to install it. On Nix, `nix shell nixpkgs#grim nixpkgs#wlrctl nixpkgs#wtype -c <cmd>` works for this session. Without them you can still read state and dispatch.
4. Record the focused window (`hyprctl activewindow -j`) and `hyprctl cursorpos`. Restore both when you finish.

## The loop

Every action is **closed-loop**: _observe → act → read back_.

1. **Observe**: read the state with `hyprctl -j`. Take a screenshot when what matters is on screen, not in a window's properties.
2. **Act**: one dispatch or one input.
3. **Read back**: query the state the action should have changed. `hyprctl dispatch` prints `ok` even for many wrong arguments, so `ok` proves nothing. The step is done when the read-back shows the target state.

## Reading state

`hyprctl -j <command>` returns JSON for `monitors`, `clients`, `workspaces`, `activewindow`, `activeworkspace`, `layers` and `devices`. `hyprctl cursorpos` prints plain `x, y`. `hyprctl --help` lists the rest. `hyprctl binds -j` shows the user's own shortcuts and launch commands; check it before you invent a key combination.

**Coordinates** are global layout pixels. They are logical: physical pixels divided by the monitor's scale. All monitors tile one shared plane, so the origin can be negative: a monitor left of the primary has a negative `x`.

- Monitor `x`, `y` is its top-left corner on the plane. `width` and `height` are the physical mode. Logical size is `width/scale` × `height/scale`, swapped when `transform` is odd.
- Client `at` and `size` are already logical and global.
- A client is visible only on a workspace that is active on some monitor. Special workspaces have a negative `workspace.id`, and `hidden` or `mapped: false` clients are not drawn.

## Screenshots

Always pass `-s 1`. Then one image pixel is one logical pixel, and a point in the image maps to `origin + (px, py)` on the plane, whatever the monitor's scale or rotation.

| Capture | Command | Origin |
| --- | --- | --- |
| One monitor | `grim -s 1 -o <name> out.png` | the monitor's `x`, `y` |
| One window | `grim -s 1 -g "<x>,<y> <w>x<h>" out.png` | the client's `at` |
| Every monitor | `grim -s 1 out.png` | the smallest monitor `x` and smallest `y` |

A window capture grabs whatever is drawn in that rectangle. The window has to be on an active workspace with nothing on top of it.

Then view the file with your image-reading tool. Screenshots catch everything on screen, including private messages and credentials. Keep them in your scratch directory, describe only what the task needs, and delete them when you finish.

## Acting

Dispatch with `hyprctl dispatch '<hl.dsp expression>'`. List every dispatcher with:

```sh
hyprctl repl 'local o={} for k,v in pairs(hl.dsp) do if type(v)=="table" then for k2 in pairs(v) do o[#o+1]=k.."."..k2 end else o[#o+1]=k end end table.sort(o) return table.concat(o," ")'
```

Call a dispatcher with no arguments to get the table shape it expects, for example `send_shortcut: expected a table { mods, key, window? }`. The `hl.bind` lines in `~/.config/hypr/hyprland.lua` are working examples.

Target windows with `window = "address:0x…"`, using the address from `clients -j`. It names exactly one window. `class:<regex>` and `title:<regex>` also work, but they can match the wrong window.

| Goal | Expression |
| --- | --- |
| Focus a window | `hl.dsp.focus({ window = "address:0x…" })` |
| Switch workspace | `hl.dsp.focus({ workspace = 3 })` |
| Send a key chord | `hl.dsp.send_shortcut({ mods = "CTRL", key = "v", window = "address:0x…" })` |
| Launch an app | `hl.dsp.exec_cmd("firefox")` |
| Move the cursor | `hl.dsp.cursor.move({ x = 1200, y = 640 })` (global coordinates) |

Launch apps with `exec_cmd`. That parents the app to the compositor, so it outlives your shell. Then wait for its window with `wlrctl toplevel waitfor app_id:<class>`.

### Pointer and keyboard

`wlrctl pointer move` is relative, so position the pointer with Hyprland's absolute `cursor.move`. Then click with `wlrctl`. Put both in one shell command so the user's hand can't move the mouse between them:

```sh
hyprctl dispatch 'hl.dsp.cursor.move({ x = 1200, y = 640 })' && wlrctl pointer click left
```

- Scroll: `wlrctl pointer scroll <dy> <dx>`
- Type into the focused window: `wtype '<text>'`. Named keys: `wtype -k Return`. Chords: `wtype -M ctrl -k a -m ctrl`.

Type with `wtype` only. `wlrctl keyboard type` uploads a keymap that can fire the user's compositor binds: typing `k` with it opened a screenshot menu bound to `Print`.

Input goes to whatever has focus when it arrives. Before each click or typed string, read `activewindow` back and confirm it is still your target. `activewindow` misses layer-shell overlays (launchers, menus, panels), which sit above every window and take clicks and keys. So also check `hyprctl layers -j`, or take a fresh screenshot of the target area, right before you act.

## Guardrails

- Tell the user before you take over the cursor or keyboard, so they keep their hands off while you work.
- Ask first before any action that is irreversible or reaches other people: sending a message, submitting a form, paying, closing or killing a window that may hold unsaved work.
- When you finish, restore the focus and cursor position you recorded in preflight.
