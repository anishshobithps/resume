# Stage 1: Install TeX Live and dependencies (Cached)
FROM alpine:latest AS builder

# Install system dependencies (these rarely change)
RUN apk add --no-cache git bash wget

# Install texlive and other tex related packages to cache
RUN apk add --no-cache \
    texlive \
    texlive-latex \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-xetex \
    texlive-bibtex-extra \
    latexmk \
    --repository=http://dl-cdn.alpinelinux.org/alpine/v3.18/main

# Stage 2: Final Image (Smaller and Faster)
FROM alpine:latest

WORKDIR /latex

# Copy only the necessary parts of TeX Live
COPY --from=builder /usr/share/texmf-dist /usr/share/texmf-dist
COPY --from=builder /usr/bin/latexmk /usr/bin/latexmk
COPY --from=builder /usr/bin/xelatex /usr/bin/xelatex

# Copy your project files AFTER the TeX Live setup
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
