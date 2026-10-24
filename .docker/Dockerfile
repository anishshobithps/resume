ARG PLATFORM=linux/amd64
FROM --platform=${PLATFORM} debian:bookworm-slim

ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget xz-utils perl ca-certificates fontconfig gnupg && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO /tmp/install-tinytex.sh "https://yihui.org/tinytex/install-bin-unix.sh" && \
    sh /tmp/install-tinytex.sh && \
    rm /tmp/install-tinytex.sh && \
    # The rolling tlnet repo updates its tlmgr continuously, so the version
    # baked into the installer drifts out of date and `tlmgr install` refuses
    # to run. Self-update tlmgr first so the build never breaks on that skew.
    tlmgr update --self && \
    tlmgr install \
      enumitem titlesec xcharter xcharter-math fontaxes mweights carlisle etoolbox \
      xstring geometry fancyhdr xkeyval microtype hyperxmp \
      datetime2 datetime2-english embedfile accsupp && \
    tlmgr path add

WORKDIR /data
ENTRYPOINT ["pdflatex"]
