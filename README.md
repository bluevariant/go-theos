## Require
1. Build a [theos](https://github.com/theos/theos) command line tool using golang on a jail-broken iOS device.
1. Xcode.

## Building

1. `git clone https://github.com/nightbrain/go-theos.git`.
1. `cd go-theos`.
1. `bash ./build.sh`.

Your deb file in `./.theos_building/packages/`.
## How It Works

1. Cross build main.go on `GOOS=darwin GOARCH=arm GOARM=7` and `GOOS=darwin GOARCH=arm64` to get a static library on armv7 and arm64 respectively.
1. Join the lib of arm64 and armv7 library together into a universal lib using  `lipo`.
1. Link the static lib into a THEOS command line tool project and build it into a .deb package.
