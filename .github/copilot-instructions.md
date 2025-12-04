# Copilot Instructions for MazeOfAsterion-AQ

## Project Overview
MazeOfAsterion-AQ is a character-based first-person dungeon crawler for the Aquarius and Aquarius+ computers. The project is primarily written in assembly language, targeting retro hardware constraints and custom graphics routines.

## Architecture & Key Files
- `src/`: Main source code, including:
  - `asterion.asm`: Entry point and core logic
  - `asterion_high_rom.asm`, `asterion_func_low.asm`, `asterion_gfx.asm`: Major subsystems (high ROM routines, low-level functions, graphics)
  - `aquarius.inc`: Shared constants, macros, and hardware definitions
  - `asterion.inc`: Shared game-specific constants and macros
- `res/`: Game assets (ROMs, screens, graphics, maps)
- `build.ps1`: PowerShell build script for assembling and packaging the ROM
- `docs/`: Developer documentation and technical notes

## Build & Workflow
- **Build:** Use the provided PowerShell script:
  - NOTICE: Agent is NOT to perform a BUILD without explicit direction!
    - Agent should not make declarations such as "The code is error free!" or "The code works perfectly!" as these are frequently unfounded and untrue.
  - Standard build: `powershell.exe -ExecutionPolicy Bypass -File .\build.ps1`
  - Verbose: Add `-Verbose` argument
  - Clean: Add `-Clean` argument
- **Output:** Built ROMs and binaries are placed in `build/` and `res/`.
- **No automated tests:** Manual playtesting and inspection are standard.
- **Commit / Push:** Agent is NOT to perform a COMMIT or PUSH without explicit direction!

## Coding Conventions
- **Assembly Style:**
  - Use `.inc` files for shared macros and hardware definitions
  - Subroutines are labeled with clear, descriptive names
  - Inline comments are encouraged for non-obvious logic (see Documentation, below)
  - If Agent is requested to perform label updates, here is the process:
    - Review section of code related to the label, including CALL or JP references to it
    - Make a brief recommendation of the updated label to the user, ensuring first that the recommended replacement does not conflict with other labels in code files in the src folder
    - When instructed to do so (and not before), perform the requested label change, ensuring that all references are updated
    - Summarize and cite all lines of code changed in all files, ensuring that duplicate labels have not been created and that labels have not inadvertently merged disparate sections of code

- **Graphics:**
  - Custom graphics routines in `asterion_gfx.asm` and related files
  - Screen layouts and assets in `res/screens/`
- **Documentation:**
  - In-code documentation
    - Each function or routine should have a header:
      - describes the routine
      - includes a brief synopsis of the routine events
      - enumerates the start, in process, and end values of registers used
      - Use the standardized header template below
    - Each line of code should have a brief comment after that describes the action being taken
  - Technical notes and architecture decisions in `docs/`
  - Update documentation when making major changes to subsystems

### Standard Routine Header Template

Use this exact structure for all routine headers:

```
; <LABEL_NAME>  
;==============================================================================
; <One-line description of routine purpose.>
;
; Registers:
; --- Start ---
;   <registers at entry>
; --- In Process ---
;   <transient register usage/changes>
; ---  End  ---
;   <registers at exit>
;   F  = <final flags>
;
; Memory Modified: <None or precise locations/ranges>
; Calls: <called routines (not internal jumps)>
;==============================================================================
```

Notes:
- Keep Description ≤ 2 lines; move detail into Inputs/Outputs.
- Prefer compact, specific lists over prose.
- Use the exact `--- Start --- / --- In Process --- / ---  End  ---` block for Registers.

## Integration & Dependencies
- No external libraries; all code is custom for Aquarius hardware
- Build script (`build.ps1`) handles all assembly and packaging steps

## Example Patterns
- To add a new game feature, create/modify a subroutine in the appropriate `.asm` file and update any relevant macros in `.inc` files
- For graphics changes, update both the assembly routines and the asset files in `res/`
- Document new features or changes in `docs/` with a brief technical note

## Quick Reference
- **Build:** `.\build.ps1` (PowerShell)
- **Main entry:** `src/asterion.asm`
- **Graphics:** `src/asterion_gfx.asm`, `res/screens/`
- **Documentation:** `docs/`

---
For questions or unclear conventions, review `docs/` or ask for clarification. Please suggest improvements to this guide if you find missing or outdated information.
