# Stage 1: TeX Live Base
FROM alpine:latest AS builder-texlive

RUN apk add --no-cache git bash wget perl # Perl is required by tlmgr

# Install TeX Live and set PATH in one step
RUN apk add --no-cache texlive texlive-full --repository=http://dl-cdn.alpinelinux.org/alpine/v3.18/main \
  && echo "/usr/local/texlive/2024/bin/x86_64-linux:$PATH" > /etc/profile.d/texlive.sh

# Stage 2: Fonts and Packages
FROM builder-texlive AS builder-fonts

RUN tlmgr install xcharter enumitem hyperref titlesec xstring geometry fancyhdr etoolbox

# Stage 3: Final Image
FROM alpine:latest

WORKDIR /latex

# Copy necessary files
COPY --from=builder-fonts /usr/local/texlive/2024/texmf-dist /usr/local/texlive/2024/texmf-dist
COPY --from=builder-fonts /usr/local/texlive/2024/bin/x86_64-linux/xelatex /usr/local/texlive/2024/bin/x86_64-linux/xelatex
COPY --from=builder-fonts /usr/local/texlive/2024/bin/x86_64-linux/latexmk /usr/local/texlive/2024/bin/x86_64-linux/latexmk

# No need to set PATH again, it's already set in Stage 1
COPY entrypoint.sh /entrypoint.sh
COPY *.tex *.bib *.cls /latex/
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
