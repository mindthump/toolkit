# toolkit:alpine

### NOTE: This currently starts right into `tmux` with a `bash` shell!

A Dockerfile and other stuff to quickly create a smallish container for utility work. This is totally specific to me. If you have suggestions on how I do things, please send them; if it's about what I include, don't.

The Dockerfile copies the context directory on build so you can drop the Dockerfile into a directory and build a container with necessary files (except .dockerignore of course). One use-case is mounting a volume to work on without disturbing the host. It should also be usable as a kubernetes ephemeral pod:

```kubectl debug foo --image=mindthump/toolkit:alpine --target=wonky_container```

## Dockerfile

There are multiple branches. `alpine` (this branch) is very basic but useful for certain actions. `main` is Ubuntu-based and has a shit-ton of tools and features. Each Dockerfile can be adapted as needed (apt v. apk, etc.). Also edit `.entrypoint.sh` to add container start-up code that runs before the CMD itself.

## User

This adds a new non-root passwordless superuser (default 'morty') to the image. You can edit the Dockerfile defaults or use `--build-arg`.

## Tools

The added tools are things I like to have around for developing and debugging. See the Dockerfile $TOOLS for the current list.
