# Stage 1: Builder with all necessary packages
FROM ubuntu:latest AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        texlive-full \
        perl \
        fontconfig \
        && rm -rf /var/lib/apt/lists/*

# Stage 2: Final image with only runtime dependencies
FROM ubuntu:latest

# Install minimal runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-pictures \
        fontconfig \
    && rm -rf /var/lib/apt/lists/*

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
