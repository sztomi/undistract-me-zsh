# undistract-me-zsh

This is largely based on https://github.com/jml/undistract-me and especially its zsh
fork: https://github.com/rgreenblatt/undistract-me

For explaining what this does, I'll refer to the original README:

<blockquote>
You're doing some work, and as part of that you need to run a command on the terminal that
takes a little while to finish. You run the command, watch it for maybe a second and then
switch to doing something else – checking email or something.

You get so deeply involved in your email that twenty minutes fly by. When you switch back to
your terminal the command has finished, but you've got no idea whether it was nineteen seconds
ago or nineteen minutes ago.

This happens to me a lot. I'm just not disciplined enough to sit and watch commands, and I'm
not prescient enough to add something to each invocation to tell me. What I want is something
that alerts me whenever long running commands finish.

This is it.

Install this, and then you'll get a notification when any command finishes that took longer
than ten seconds to finish.
</blockquote>

What this fork does is a little unification of the env var names and adding a top-level function
call so that the script can be installed via `zplug`. That's it.

## Installation

```
zplug 'sztomi/undistract-me-zsh'
```

## Configuration

| Environment variable | Description | Default |
|---|---|---|
| `UMZ_COMMAND_TIMEOUT` | Commands that take longer than this value (in seconds) will trigger a notification | `10` |
| `UMZ_PLAY_SOUND` | Controls if a sound should be played along with the notification. `0` means no, any other value means yes. | `0` |
| `UMZ_SOUND_FILE` | Sound file to play upon completion (if `UMZ_PLAY_SOUND` is set to a non-zero value) | `/usr/share/sounds/freedesktop/stereo/complete.oga` |