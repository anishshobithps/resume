# Stage 1: Builder with all necessary packages
FROM alpine:latest AS builder

# Install build dependencies in a single layer to optimize caching
RUN apk add --no-cache --update \
    texlive \
    texlive-pdftex \
    texmf-dist-latexextra \
    texmf-dist-fontsextra \
    fontconfig \
    perl \
    make \
    && texhash

# Stage 2: Final image with only runtime dependencies
FROM alpine:latest

# Install minimal runtime dependencies for LaTeX compilation
RUN apk add --no-cache --update \
    texlive-pdftex \
    texmf-dist-latexextra \
    texmf-dist-fontsextra \
    fontconfig

# Copy only required texmf directories from builder to minimize image size
COPY --from=builder /usr/share/texmf-dist /usr/share/texmf-dist

# Set working directory
WORKDIR /latex

# Copy your LaTeX files and entrypoint script
COPY entrypoint.sh /entrypoint.sh
COPY *.tex *.cls *.sty ./

# Make entrypoint executable and refresh TeX file database
RUN chmod +x /entrypoint.sh && texhash

# Set default entrypoint
ENTRYPOINT ["/entrypoint.sh"]
