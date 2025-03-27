# ---------------------------------------------
# devkit: os image + core devtools
# ---------------------------------------------

FROM fedora:41 AS devkit
ARG NVM_DIR=/root/.nvm
RUN dnf install -y python3 make g++ git git-lfs
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# ---------------------------------------------
# builder: 
#     - install additional tools for the
#       specific signal-desktop version, and
#     - package an appimage
# ---------------------------------------------

FROM devkit AS builder
WORKDIR /workdir
ARG SIGNAL_VERSION
ADD --keep-git-dir=true https://github.com/signalapp/Signal-Desktop.git#${SIGNAL_VERSION:-main} .

RUN <<EOF
    . $NVM_DIR/nvm.sh
    NODE_VERSION=$(cat .nvmrc)
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    npm i -g pnpm
EOF

ARG FIND="\"build:electron\": \"electron-builder --config.extraMetadata.environment=\$SIGNAL_ENV"
ARG REPLACE="$FIND --linux AppImage"
RUN sed -i "s/${FIND}/${REPLACE}/g" package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store source $NVM_DIR/nvm.sh && \
    pnpm install --frozen-lockfile && \
    pnpm run generate && \
    pnpm build-release

# ---------------------------------------------
# the appimage
# ---------------------------------------------

FROM scratch
COPY --from=builder /workdir/release/Signal*.AppImage /Signally
