# Cocos2d-x Project Template

A purely CMake-based (minimal amount of platform- or IDE-specific files) project template for new cross-platform (Win32/Linux/macOS/Android/iOS) Cocos2d-x C++14 (or newer) projects.

## To-do
- Script for renaming the project.
- Windows x64 build support
- Support for using the latest code from https://github.com/cocos2d/cocos2d-x
- Support suppressing engine code's build warnings (fully) on macOS, iOS, and Android/Clang.
- `cocos deploy` support.
- Possibility to enforce C++17 or newer.
- CMakeLists.txt cleanup.

## Usage
**1)** Obtain Cocos2d-x and unzip it to e.g. `C:\Cocos\cocos2d-x-3.17.1`

**2)** Obtain this repository and copy it to e.g. `C:\Cocos\MyGame`

**3)** In order to rename the project to your liking, see the following files and filenames:
- `CMakeLists.txt`
- `.cocos-project.json`
- `src/AppMacros.h`
- `android/app/AndroidManifest.xml`
- `android/app/build.gradle`
- `android/app/res/values/strings.xml`
- `android/settings.gradle`
- `win32/Cocos2dxTemplate.rc`

**4a)** Win32/Linux/macOS:
- macOS:
    - Install [Homebrew](https://brew.sh/) and then CMake using the `brew` command.
    - You can use either the "Xcode" or the "Unix Makefiles" generator.
    - If using Xcode, in case of a "CMake Error: Xcode 1.5 not supported", make sure you have a non-beta version of Xcode available and set as the default.
- Linux:
  1. Install the dependencies: https://docs.cocos2d-x.org/cocos2d-x/en/installation/Linux.html.
  2. Currently there is a bug (https://github.com/cocos2d/cocos2d-x/issues/19246) causing linking to libfreetype to fail on newer (> 16.04) Ubuntus. As a workaround:
    ```
    $ git clone https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src.git
    $ cd cocos2d-x-3rd-party-libs-src/build
    $ ./build.sh -p=linux --libs=freetype --arch=x86_64 --mode=debug
    $ cp linux/freetype/prebuilt/x86_64/libfreetype.a /path/to/cocos2d-x-3.17.1/external/freetype2/prebuilt/linux/64-bit/libfreetype.a
    ```
- Windows:
    -  Note that Cocos2d-x doesn't currently support Windows x64 build out of the box.
- `cd C:\Cocos\ && mkdir MyGame-build && cd MyGame-build`
- `cmake ../Cocos2dxTemplate -DCOCOS2DX_ROOT_PATH=C:/Cocos/cocos2d-x-3.17.1`

**4b)** Android:
- Set `COCOS2DX_ROOT_PATH` environment variable to point to e.g. `C:\Cocos\cocos2d-x-3.17.1` before opening Android Studio.
- Make sure `ninja` is in `PATH` (shouble be if using CMake 3.10 or newer installed via Android Studio).

**4c)** iOS:
- `cd /Cocos && mkdir MyGame-build && cd MyGame-build`
- `cmake .. -G"Xcode" -DCOCOS2DX_ROOT_PATH=/Cocos/cocos2d-x-3.17.1 -DCMAKE_TOOLCHAIN_FILE=../cocos2d-x-3.17.1/cmake/ios.toolchain.cmake`
- The default build is for running on actual hardware, add `-DIOS_PLATFORM=SIMULATOR` (32-bit) or `-DIOS_PLATFORM=SIMULATOR64` (64-bit) for a simulator build.
- iOS 10.x simulator appears to be required currently, so make sure it is installed.
- Remember to set `Cocos2dxTemplate` as the active scheme in order to be able to run the application from Xcode.

**5)** Open/build the solution/project:
- open the Visual Studio solution / Xcode project / `android` folder in Android Studio, or
- `cmake --build . -- -j4` (`/m:4` is the MSVC equivalent), or
- `cd ../Cocos2dxTemplate && cocos compile -p linux`
  - for `win32` and `linux`, modify the paths in `.cocos-project.json` to match you build directories

**6)** **TODO** Deploying the project:
- `cd ../Cocos2dxTemplate && cocos deploy -p win32 -m release`
- The deployed application can be found in the `bin/` folder of this project.