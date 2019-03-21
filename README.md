# Cocos2d-x Project Template

This will be a purely CMake-based (minimal amount of platform- or IDE-specific files) project template for new cross-platform (Win32/Linux/macOS/Android) Cocos2d-x C++14 (or newer) projects.

## Usage
**1)** Obtain Cocos2d-x and unzip it to e.g. `C:\Cocos\cocos2d-x-3.17.1`

**2)** Obtain this repository and copy it to e.g. `C:\Cocos\MyGame`

**3)** TODO: renaming/rebranding the project

**5a)** Win32/Linux/macOS:
- macOS: TODO
- Linux
  1. Install the dependencies: https://docs.cocos2d-x.org/cocos2d-x/en/installation/Linux.html.
  2. Currently there is a bug (https://github.com/cocos2d/cocos2d-x/issues/19246) causing linking to libfreetype to fail on newer (> 16.04) Ubuntus. As a workaround:
    ```
    $ git clone https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src.git
    $ cd cocos2d-x-3rd-party-libs-src/build
    $ ./build.sh -p=linux --libs=freetype --arch=x86_64 --mode=debug
    $ cp linux/freetype/prebuilt/x86_64/libfreetype.a path/to/Cocos/cocos2d-x-3.17.1/external/freetype2/prebuilt/linux/64-bit/libfreetype.a
    ```
- `cd C:\Cocos\ && mkdir MyGame-build && cd MyGame-build`
- `cmake ../Cocos2dxTemplate -DCOCOS2DX_ROOT_PATH=C:/Cocos/cocos2d-x-3.17.1`

**5b)** Android:
- Set `COCOS2DX_ROOT_PATH` environment variable to point to e.g. `C:\Cocos\cocos2d-x-3.17.1` before opening Android Studio.
- Make sure `ninja` is in `PATH` (shouble be if using CMake 3.10 or newer installed via Android Studio).

**5c)** iOS: TODO

**6)** Open/build the solution/project:
- open the Visual Studio solution or `android` folder in Android Studio, or
- `cmake --build . -- -j4` (use `/m:4` is the MSVC equivalent), or
- `cd ../Cocos2dxTemplate && cocos compile -p linux`
  - for `win32` and `linux`, modify the paths in `.cocos-project.json` to match you build directories