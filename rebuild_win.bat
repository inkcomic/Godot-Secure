@echo off
set GODOT_DIR=godot
set BRANCH_NAME=4.6
set MY_LOCAL_SOURCE=C:/Users/Admin/MyLocalNugetSource
@echo on
$env:SCRIPT_AES256_ENCRYPTION_KEY = Get-Content godot.gdkey


git clone https://github.com/godotengine/godot.git
cd godot
git fetch origin %BRANCH_NAME%
git checkout -b %BRANCH_NAME% origin/%BRANCH_NAME%
git pull origin %BRANCH_NAME%

openssl rand -hex 32 > godot/godot.gdkey 

py ../Godot.Secure.AES-256.py ./

scons platform=windows target=editor module_mono_enabled=yes

scons platform=windows target=template_debug module_mono_enabled=yes
scons platform=windows target=template_release module_mono_enabled=yes

scons platform=android target=template_release arch=arm32 module_mono_enabled=yes
scons platform=android target=template_release arch=arm64 generate_android_binaries=yes module_mono_enabled=yes

scons platform=android target=template_debug arch=arm32 module_mono_enabled=yes
scons platform=android target=template_debug arch=arm64 generate_android_binaries=yes module_mono_enabled=yes

bin/godot.windows.editor.x86_64.mono.exe --headless --generate-mono-glue modules/mono/glue
py ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir ./bin --push-nupkgs-local %MY_LOCAL_SOURCE%
dotnet nuget add source %MY_LOCAL_SOURCE% --name MyLocalNugetSource
