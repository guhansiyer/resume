# Resume

This repository holds the most updated version of my resume, including the source code and build scripts.

## Prerequisites

To build, you'll need:
* A LaTeX distribution with pdflatex installed (MiKTeX on Windows, TeX Live on macOS/Linux)
* `PowerShell` for the Windows script or `Bash` for the macOS/Linux script

## PowerShell and Bash scripts

The scripts allow me to change the section ordering at compile-time. 

By default, my resume compiles with this ordering:
* Header
* Education
* Experience
* Projects
* Skills

### Windows

```sh
./scripts/compile.ps1 # -WWOrdering flag switches the skills and education sections
```

### MacOS, Linux

```sh
chmod +x compile.sh
./scripts/compile.sh # -ww-ordering flag switches the skills and education sections
```