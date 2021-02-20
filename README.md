# toolkit:alpine

A Dockerfile and other stuff to quickly create a smallish container for utility work. This is totally specific to me. If you have suggestions on how I do things, please send them; if it's about what I include, don't.

The Dockerfile copies the context directory on build so you can drop the Dockerfile into a directory and build a container with necessary files. One use-case mounting mounting a volume to work on without disturbing the host.

## Dockerfile

There are two branches. alpine (this branch) is very basic but useful for certain actions. master is Ubuntu-based and has a shit-ton of tools and features. Each Dockerfile can be adapted as needed (apt v. apk, etc.).

## User

This adds a new non-root passwordless superuser (default 'morty') to the image. You can edit the Dockerfile defaults or use `--build-arg`.

## Tools

The added tools are things I like to have around for developing such as bash, less, wget, vim, tree, mc, silver searcher, sudo, etc. See the Dockerfile for the current list of tools.
