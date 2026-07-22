ARG PLATFORM=linux/amd64
FROM --platform=${PLATFORM} debian:bookworm-slim

ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget xz-utils perl ca-certificates fontconfig && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO /tmp/install-tinytex.sh "https://yihui.org/tinytex/install-bin-unix.sh" && \
    sh /tmp/install-tinytex.sh && \
    rm /tmp/install-tinytex.sh && \
    tlmgr install \
      enumitem titlesec xcharter xcharter-math fontaxes mweights carlisle etoolbox \
      xstring geometry fancyhdr xkeyval microtype hyperxmp \
      datetime2 datetime2-english embedfile accsupp && \
    tlmgr path add

WORKDIR /data
ENTRYPOINT ["pdflatex"]
