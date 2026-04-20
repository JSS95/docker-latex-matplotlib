ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}

ARG TEXLIVE_VERSION=2026
ARG INSTALL_FFMPEG=false
ARG INSTALL_INKSCAPE=false
ARG TEX_ARCHIVE="https://ftp.math.utah.edu/pub/tex/historic"

ENV TLURL="${TEX_ARCHIVE}/systems/texlive/${TEXLIVE_VERSION}/install-tl-unx.tar.gz"
ENV TLREPO="${TEX_ARCHIVE}/systems/texlive/${TEXLIVE_VERSION}/tlnet-final"

# Install TeXLive
RUN cd /tmp && \
    wget "$TLURL" && \
    zcat < install-tl-unx.tar.gz | tar xf - && \
    cd $(ls | grep 'install-tl-[0-9]*') && \
    perl ./install-tl --no-interaction --no-doc-install --no-src-install --scheme=scheme-basic --repository "$TLREPO" && \
    ln -s $(find /usr/local/texlive/[0-9]*/bin/ -mindepth 1 | head -1) /usr/local/texlive/bin
ENV PATH="/usr/local/texlive/bin:${PATH}"

# Setup TeXLive
RUN tlmgr option repository "$TLREPO" && \
    tlmgr update --self && \
    tlmgr install \
        # Matplotlib requirements
        type1cm \
        cm-super \
        underscore \
        dvipng \
        svg \
        catchfile \
        xcolor \
        transparent \
        pgf

RUN pip install --break-system-packages matplotlib && \
    python3 -c "import matplotlib.font_manager"

RUN if [ "$INSTALL_FFMPEG" = "true" ] || [ "$INSTALL_INKSCAPE" = "true" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            $([ "$INSTALL_FFMPEG" = "true" ] && echo "ffmpeg") \
            $([ "$INSTALL_INKSCAPE" = "true" ] && echo "inkscape") && \
        rm -rf /var/lib/apt/lists/*; \
    fi

LABEL repository="https://github.com/JSS95/docker-latex-matplotlib" \
      maintainer="Jisoo Song <jeesoo9595@snu.ac.kr>"
