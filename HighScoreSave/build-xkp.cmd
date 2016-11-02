@echo off

echo Removing current build...

del .\out\ZAMN-SavePatch.sfc

echo Copying original (Base) ROM...


copy ".\base\Zombies Ate My Neighbors (U).sfc" .\out\ZAMN-SavePatch.sfc


echo Building...

..\Tools\xkas-plus\xkas.exe -o .\out\ZAMN-SavePatch.sfc .\SavePatch.asm 

echo Done.
pause