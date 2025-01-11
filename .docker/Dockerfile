# Stage 1: Builder with all necessary packages
FROM alpine:latest AS builder

# Install build dependencies
RUN apk add --no-cache \
    texlive \
    texlive-xetex \
    texmf-dist \
    texmf-dist-latexextra \
    texmf-dist-fontsextra \
    perl \
    fontconfig \
    make

# Stage 2: Final image with only runtime dependencies
FROM alpine:latest

# Install only runtime dependencies
RUN apk add --no-cache \
    texlive-xetex \
    texmf-dist \
    fontconfig

# Copy necessary files from builder
COPY --from=builder /usr/share/texmf-dist /usr/share/texmf-dist
COPY --from=builder /usr/share/texlive /usr/share/texlive
COPY --from=builder /var/lib/texmf /var/lib/texmf

WORKDIR /latex

# Copy your LaTeX files
COPY entrypoint.sh /entrypoint.sh
COPY *.tex *.cls *.sty ./

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
