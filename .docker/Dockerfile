# Base image with LaTeX tools
FROM pandoc/latex:latest

# Update TeX Live Manager and install required packages
RUN tlmgr update --self && \
    tlmgr install enumitem titlesec xcharter etoolbox xstring geometry fancyhdr xkeyval fontaxes

# Default working directory
WORKDIR /data

# Set pdflatex as the default entrypoint
ENTRYPOINT ["pdflatex"]
