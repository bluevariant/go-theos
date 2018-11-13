# require
1. Build a [theos](https://github.com/theos/theos) command line tool using golang on a jail-broken iOS device.
1. Xcode

### Building

1. `git clone https://github.com/dccxx/golang-ios-jailbroken-tool`
1. `cd golang-ios-jailbroken-tool`
1. `bash ./build.sh`

## How It Works

1. cross build main.go on `GOOS=darwin GOARCH=arm GOARM=7` and `GOOS=darwin GOARCH=arm64` to get a static library on armv7 and arm64 respectively
1. join the lib of arm64 and armv7 library together into a universal lib using  `lipo`
1. link the static lib into a THEOS command line tool project and build it into a .deb package
