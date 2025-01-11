# Stage 1: TeX Live Base
FROM alpine:latest AS builder-texlive

RUN apk add --no-cache git bash wget perl # Perl is required by tlmgr
RUN apk add --no-cache texlive --repository=http://dl-cdn.alpinelinux.org/alpine/v3.18/main
ENV PATH="/usr/local/texlive/2023/bin/x86_64-linux:$PATH"
RUN tlmgr update --self
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet

# Stage 2: Fonts and Packages
FROM builder-texlive AS builder-fonts

RUN tlmgr install xcharter
RUN tlmgr install enumitem hyperref titlesec xstring geometry fancyhdr etoolbox

# Stage 3: Final Image
FROM alpine:latest

WORKDIR /latex

# Copy necessary files
COPY --from=builder-fonts /usr/local/texlive/2023/texmf-dist /usr/local/texlive/2023/texmf-dist
COPY --from=builder-fonts /usr/local/texlive/2023/bin/x86_64-linux/xelatex /usr/local/texlive/2023/bin/x86_64-linux/xelatex
COPY --from=builder-fonts /usr/local/texlive/2023/bin/x86_64-linux/latexmk /usr/local/texlive/2023/bin/x86_64-linux/latexmk

ENV PATH="/usr/local/texlive/2023/bin/x86_64-linux:$PATH"
COPY entrypoint.sh /entrypoint.sh
COPY *.tex *.bib *.cls /latex/
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
