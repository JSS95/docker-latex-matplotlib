FROM jeesoo9595/latex-matplotlib:latest AS build_manuscript
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /workspace

COPY . .
RUN make

ENTRYPOINT [ "/bin/bash" ]

FROM scratch
WORKDIR /

COPY --from=build_manuscript /workspace/main.pdf ./
