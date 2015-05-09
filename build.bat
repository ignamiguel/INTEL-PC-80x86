del %1.exe
nasm -fOBJ %1.asm
alink -oEXE %1.obj
%1.exe
