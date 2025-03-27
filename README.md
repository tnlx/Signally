# Signally

As of Mar 2025, Signal only offers Debian-based distributions of its desktop application.

This repository contains the Dockerfile to build the Signal Desktop [AppImage](https://appimage.org/)
using this slight tweak in the build command (package.json).

```diff
--    "build:electron": "electron-builder --config.extraMetadata.environment=$SIGNAL_ENV",
++    "build:electron": "electron-builder --config.extraMetadata.environment=$SIGNAL_ENV --linux AppImage",
```

## Build

The below command will generate the AppImage in `${PWD}/bin` directory.

```sh
docker build --output bin --build-arg SIGNAL_VERSION=v7.46.0 .
```

which can then be run with this command:

```sh
./bin/Signally
```

## References

- [xai.sh](https://xai.sh/2023/01/04/Signal-desktop.html)
- [Signal-Desktop's developer guide](https://github.com/signalapp/Signal-Desktop/blob/main/CONTRIBUTING.md#developer-setup)
