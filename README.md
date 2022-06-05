# Never Give Up (Openplanet Plugin for TM2020)

This plugin will give you an easy button to unbind 'Give Up' in COTD (and ranked), along with a high-visibility reminder prompt that will automatically disappear when 'Give Up' is unbound.
When you return to a menu or different game mode, you'll be prompted to rebind 'Give Up' (with a button to do so).

To experiment with the plugin, uncheck the "Hide UI in menus and for other game modes?" setting. The UI should be visible.

To use the buttons, the OpenPlanet overlay must be shown/visible -- otherwise buttons don't work.

*Warning: there's a notable bug in Trackmania that matters for this plugin. You can safely rebind only at certain times. There is a warning shown when you hover over the bind/rebind button which explains this.*

You can easily hide the prompt with one-click if you want it to go away for that session. (It will show up again the next time you're in an appropriate game mode.)

You can optionally set additional game modes.

### Feedback options

- @XertroV on [OpenPlanet Discord](https://openplanet.dev/link/discord)
- [Create GitHub Issue](https://github.com/XertroV/tm-never-give-up/issues/)

### Dialog Bug Details

If you have the bind/unbind dialog open, and the game does certain things (like joining maps, or certain in-game events), then the game becomes unplayable. The dialog goes away, but nearly all inputs are dropped after this point.

I guess that the 'bind input' dialog needs to redirect inputs to itself, but when they game removes the dialog it does not clean up the input redirection.

### Code

GitHub Repo: [https://github.com/XertroV/tm-never-give-up](https://github.com/XertroV/tm-never-give-up)

License: MIT

GL HF
