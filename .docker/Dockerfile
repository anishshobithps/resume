FROM pandoc/latex:latest

RUN tlmgr update --self && \
    tlmgr install \
    enumitem \
    titlesec \
    xcharter \
    etoolbox \
    xstring \
    geometry \
    fancyhdr \
    xkeyval \
    fontaxes

WORKDIR /data
ENTRYPOINT ["pdflatex"]
