# Building LaTeX in Docker

If you just want to build the document once, use build command.
If you want to continuously edit the document and rebuild, use development container.

## Build command

```
docker build --output type=local,dest=./ .
```

This command creates `main.pdf` file in this local directory.

## Development container

```
docker build --target build_manuscript . -t latex-matplotlib-example
docker create --name latex-matplotlib-example -it latex-matplotlib-example
docker start latex-matplotlib-example
docker attach latex-matplotlib-example
```

This command lets you attach to development container.
You can edit files and run `make` to build `main.pdf`.

To copy the built manuscript to your host machine, run

```
docker cp latex-matplotlib-example:/workspace/main.pdf .
```

You can also attach to container in IDE such as VSCode.
