ARG PYTHON_VERSION=latest
FROM python:${PYTHON_VERSION}

ARG TEXLIVE_VERSION=latest
ARG INSTALL_FFMPEG=false
ARG INSTALL_INKSCAPE=false

# Install TeXLive
RUN cd /tmp && \
    if [ "$TEXLIVE_VERSION" = "latest" ]; then \
        TLURL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"; \
        TLREPO="https://mirror.ctan.org/systems/texlive/tlnet"; \
    else \
        TLURL="https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VERSION}/install-tl-unx.tar.gz"; \
        TLREPO="https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VERSION}/tlnet-final"; \
    fi && \
    wget --no-check-certificate "$TLURL" && \
    zcat < install-tl-unx.tar.gz | tar xf - && \
    cd $(ls | grep install-tl-[0-9]*) && \
    perl ./install-tl --no-interaction --no-doc-install --no-src-install --scheme=scheme-basic --repository "$TLREPO" && \
    ln -s $(find /usr/local/texlive/[0-9]*/bin/ -mindepth 1 | head -1) /usr/local/texlive/bin
ENV PATH="/usr/local/texlive/bin:${PATH}"

# Setup TeXLive
RUN if [ "$TEXLIVE_VERSION" != "latest" ]; then \
        tlmgr option repository "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VERSION}/tlnet-final"; \
    fi && \
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
        pgf \
        # Font
        helvetic \
        sansmath \
        newtxsf

RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --break-system-packages matplotlib && \
    python3 -c "import matplotlib.font_manager"

RUN if [ "$INSTALL_FFMPEG" = "true" ] || [ "$INSTALL_INKSCAPE" = "true" ]; then \
        apt-get update && \
        apt-get install -y \
            $([ "$INSTALL_FFMPEG" = "true" ] && echo "ffmpeg") \
            $([ "$INSTALL_INKSCAPE" = "true" ] && echo "inkscape"); \
    fi

LABEL repository="https://github.com/JSS95/docker-latex-matplotlib" \
      maintainer="Jisoo Song <jeesoo9595@snu.ac.kr>"
