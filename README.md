# Quick Rebind (Openplanet Plugin for TM2020)

This plugin adds a menu to the Openplanet menubar that let's you rebind any button very quickly.
It (hopefully!) can do everything that the main menu input settings can do.

### Menu Structure

* Section: Selected Input
  * [ ] Mouse
  * [x] Keyboard
  * [ ] Gamepad1
  * [ ] Gamepad2
* Section: Device
  * Unbind one button
* Section: Player Bindings
  * Accelerate: Up
  * Brake: Down, Shift
  * ...
* Section: Other Bindings
  * Show/Hide Ghost: G
  * ...

### Feedback options

- @XertroV on [OpenPlanet Discord](https://openplanet.dev/link/discord)
- [Create GitHub Issue](https://github.com/XertroV/tm-never-give-up/issues/)

### Dialog Bug Details

**FIXED:** *v0.2.4 Adds a workaround for this issue to abort the dialog and prevent the bug from happening! Yay!*

If you have the bind/unbind dialog open, and the game does certain things (like joining maps, or certain in-game events), then the game becomes unplayable. The dialog goes away, but nearly all inputs are dropped after this point.

I guess that the 'bind input' dialog needs to redirect inputs to itself, but when they game removes the dialog it does not clean up the input redirection.

### Code

GitHub Repo: [https://github.com/XertroV/tm-never-give-up](https://github.com/XertroV/tm-never-give-up)

License: MIT

GL HF
