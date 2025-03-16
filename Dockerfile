FROM fedora:41 AS devkit
RUN dnf install -y python3 make g++ git git-lfs
ARG NVM_DIR=/root/.nvm
ARG NODE_VERSION=20.18.2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    npm i -g pnpm

FROM devkit AS builder
ARG SIGNAL_VERSION
WORKDIR /workdir
ADD --keep-git-dir=true https://github.com/signalapp/Signal-Desktop.git#${SIGNAL_VERSION:-main} .
ARG FIND="\"build:electron\": \"electron-builder --config.extraMetadata.environment=\$SIGNAL_ENV"
ARG REPLACE="$FIND --linux AppImage"
RUN sed -i "s/${FIND}/${REPLACE}/g" package.json
RUN source $NVM_DIR/nvm.sh && \
    pnpm install && \
    pnpm run generate && \
    pnpm build-release

FROM scratch
ARG SIGNAL_VERSION
COPY --from=builder /workdir/release/Signal*.AppImage /Signally
