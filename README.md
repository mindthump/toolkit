# toolkit

A Dockerfile and other stuff to quickly create a smallish container for utility work. This is totally specific to me. If you have suggestions on how I do things, please send them; if it's about what I include, don't.

One use-case is mounting a volume to work on without disturbing the host.

## Dockerfile

### User

This adds a new non-root superuser to the image. You can edit the Dockerfile defaults or use `--build-arg` on the build.
The ARGS include `USER`, `GROUP`, `UID`, `GID`, and `SHELL`.

### Tools

The added tools are things I like to have around for developing:

#### Comes with my base image:

* `python3`

#### Installed by apk:

* `git`
* `curl`
* `zsh`
* `byobu`
* `stow`
* `tmux`
* `vim`
* `less`
* `mc`
* `tree`
* `sudo`

#### Installed by scripts:

* `oh-my-zsh`
* `antigen`

Lots of other stuff (e.g. Perl) gets installed via dependencies.

I `git clone` my `.dotfiles` and use `stow` to symbolic-link them to my home directory.

#### byobu

byobu gets installed, but not auto-started because it's not usually needed in the toolkit. (The dotfiles are for use anywhere, not just docker.) Use 'byobu' to launch it, or 'byobu-enable' if you intend to have the container to stick around and use "docker exec" to create new shells.
