# mindthump's container (Docker/K8s) toolkit

A Dockerfile and other stuff to quickly create a smallish container for utility work. This is totally specific to me. If you have suggestions on how I do things, please send them; if it's about what I include, don't.

### User

This adds a new non-root superuser to the image. You can edit the Dockerfile defaults or use `--build-arg` on the build.
The ARGS include `USER`, `GROUP`, `UID`, `GID`, and `SHELL`.

### Tools

See the Dockerfile for added tools I like to have around for developing.
Lots of other stuff gets installed via dependencies.

I `git clone` my `.dotfiles` and use `stow` to symbolic-link them to my home directory.
