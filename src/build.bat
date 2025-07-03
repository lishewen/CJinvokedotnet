@echo off
cjc mylib.cj --output-type=dylib
dotnet publish .\CSLibrary\CSLibrary.csproj -c Release -r win-x64 -o .
cjc -L . -l CSLibrary ./main.cj