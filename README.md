# toolkit

A Dockerfile and other stuff to quickly create a smallish container for utility work. This is totally specific to me. If you have suggestions on how I do things, please send them; if it's about what I include, don't.

One use-case is mounting a volume to work on without disturbing the host.

## Dockerfile

There are two branches, Ubuntu and Alpine. Each Dockerfile is adapted as needed (apt v. apk, etc.).

### User

This adds a new non-root superuser to the image. You can edit the Dockerfile defaults or use `--build-arg` on the build.
The ARGS include `USER`, `GROUP`, `UID`, `GID`, and `SHELL`.

### Tools

The added tools are things I like to have around for developing:

* `python3` (base image)
* `git`
* `less`
* `curl` and `wget`
* `zsh`, `tmux`, `byobu`, and `oh-my-zsh`
* `vim` and `antigen`
* `tree`
* `the_silver_searcher`, a.k.a. `ag`
* `stow`
* `sudo`

Lots of other stuff (e.g. Perl) gets installed via dependencies.

I `git clone` my `.dotfiles` and use `stow` to symbolic-link them to my home directory.
