FROM texlive/texlive:latest

RUN tlmgr option repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final && \
    tlmgr update --self && \
    tlmgr install \
    enumitem \
    titlesec \
    xcharter \
    xcharter-math \
    fontaxes \
    etoolbox \
    xstring \
    geometry \
    fancyhdr \
    xkeyval \
    microtype \
    hyperxmp \
    datetime2 \
    datetime2-english \
    embedfile

WORKDIR /data
ENTRYPOINT ["pdflatex"]
