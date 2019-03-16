# Cocos2dxTemplate

This will be a purely CMake-based (minimal amount of platform- or IDE-specific files) project template for new cross-platform (Win32/Linux/macOS/Android) Cocos2d-x C++17 (or newer) projects.

## Usage
**1)** Obtain Cocos2d-x and unzip it to e.g. `C:\Cocos\cocos2d-x-3.17.1`

**2)** Obtain this repository and copy it to e.g. `C:\Cocos\MyGame`

**3)** TODO: renaming/rebranding the project

**4)** `cd C:\Cocos\ && mkdir MyGame-build && cd MyGame-build`

**5a)** Win32/Linux/macOS: `cmake ../Cocos2dxTemplate -DCOCOS2DX_ROOT_PATH=C:/Cocos/cocos2d-x-3.17.1`  
**5b)** Android/iOS: TODO

**5b)** Android:
-  Set `COCOS2DX_ROOT_PATH` environment variable to point to Cocos2d-x's location.
- Make sure `ninja` is in `PATH`.

**5c)** iOS: TODO

**6)** Open/build the solution/project

