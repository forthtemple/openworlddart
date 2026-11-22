Known-good ANGLE build (libEGL.dll + libGLESv2.dll) for Windows.

windows/CMakeLists.txt copies these two files over whatever ANGLE DLLs the
plugins bundle, because another plugin's older/mismatched copies make the game
run at about half the frame rate.

They were originally staged by flutter_angle at build/windows/x64/ANGLE/.
Keep them here (not in build/), so `flutter clean` doesn't delete them.

ANGLE is open source (BSD licence): https://chromium.googlesource.com/angle/angle
