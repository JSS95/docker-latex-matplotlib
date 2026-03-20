**cmd**:

```
docker run --rm -v %cd%:/usr/src/app -w /usr/src/app jeesoo9595/latex-matplotlib:latest make
```

**powershell**:

```
docker run --rm -v ${pwd}:/usr/src/app -w /usr/src/app jeesoo9595/latex-matplotlib:latest make
```

**bash**:

```
docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app jeesoo9595/latex-matplotlib:latest make
```
