# MadStrap  

Simple Atari Mad-Pascal project bootstrap.  

MadStrap is designed to accelerate project setup by providing a starting set of useful, optional features:  

- Two startup files: `start_os.pas` for OS-dependent applications and `start_nos.pas` for full RAM access.  
- Memory layout defined in a separate file (`memory.inc`).  
- Constants defined in a separate file (`const.inc`).  
- Type definitions in a separate file (`types.inc`).  
- External resource loading (RMT, ASM, strings).  
- External library path definition (uses [blibs](https://gitlab.com/bocianu/blibs) by default).  
- Custom user-defined charset loading.  
- Player/missile graphics initialization and usage.  
- User-defined display list in a separate file (`dlist.asm`).  
- Custom vertical blank interrupt.  
- Custom display list interrupt.  
- Interrupt routines declared in a separate file (`interrupts.inc`).  
- `utils` folder containing useful tools and scripts.  
- Example `$DEFINE` macros.  
- Example `$EVAL` tables.  
- `packed` folder with batch tools for generating packed assets from PNG files (`packed/rebuild.sh`).  
- Example Bash scripts for image conversion and APL/ZX compression (`assets/rebuild.sh`).  
- Example batch file for building the executable (`build.bat`).  
- Example `intro.pas` merged as an INIT block (set `ADDINTRO=0/1` in `build.bat` to disable/enable).  
- Example `.vscode` settings.  

## Getting Started  

You can simply download or clone the repository, rename `start*.pas` manually, and then enable, disable, or remove the features as needed for your project.  

Alternatively, you can use an automated approach by fetching the Bash script [utils/mpinit.sh](https://gitlab.com/bocianu/madstrap/-/raw/master/utils/mpinit.sh?inline=false) and executing it.  

```
Usage: ./mpinit.sh project_name [nos]
```

This will:  
- Clone MadStrap into a folder named `project_name`.  
- Rename `start*.pas` to `project_name.pas`.  
- Update the build file accordingly.  

### Optional Parameter  
The optional `nos` parameter specifies whether the project should use the OS-dependent or non-OS template:  
- **Default (no parameter):** Uses the OS-dependent template.  
- **`nos` parameter:** Uses the non-OS template with full RAM access.  

### Example of Use  

```
curl https://gitlab.com/bocianu/madstrap/-/raw/master/utils/mpinit.sh?inline=false > mpinit.sh
chmod +x mpinit.sh
./mpinit.sh supergame nos
```  

