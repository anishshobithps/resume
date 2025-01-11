# Stage 1: Builder with all necessary packages
FROM alpine:latest AS builder

# Install build dependencies in a single layer to optimize caching
RUN apk add --no-cache \
    texlive \
    texlive-xetex \
    texmf-dist \
    texmf-dist-latexextra \
    texmf-dist-fontsextra \
    perl \
    fontconfig \
    make \
    && texhash

# Stage 2: Final image with only runtime dependencies
FROM alpine:latest

# Install minimal runtime dependencies
RUN apk add --no-cache \
    texlive-xetex \
    texmf-dist \
    fontconfig

# Copy texmf files from builder
COPY --from=builder /usr/share/texmf-dist /usr/share/texmf-dist

WORKDIR /latex

# Copy your LaTeX files
COPY entrypoint.sh /entrypoint.sh
COPY *.tex *.cls *.sty ./

# Make entrypoint executable and refresh TeX file database
RUN chmod +x /entrypoint.sh && \
    texhash

ENTRYPOINT ["/entrypoint.sh"]
