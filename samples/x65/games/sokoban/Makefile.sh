WUDSN_TOOLS_FOLDER="/home/jac/jac/wudsn/daily/Tools"
ENUM_PATH="/home/jac/jac/system/Linux/Programming/Repositories/emu/emu"

# For building with the published version.
export MP_FOLDER="${WUDSN_TOOLS_FOLDER}/PAS/MP"
export MP_PATH="${MP_FOLDER}/bin/linux/mp"

# For building the head revision version.
export MP_FOLDER="/home/jac/jac/system/Atari800/Programming/Repositories/Mad-Pascal"
export MP_PATH="${MP_FOLDER}/bin/linux_x86_64/mp"

export BASE_PATH="${MP_FOLDER}/base"
export MADS_FOLDER="${WUDSN_TOOLS_FOLDER}/ASM/MADS"
export MADS_PATH="${MADS_FOLDER}/mads.linux-x86-64"

#${MP_PATH}
#${MADS_PATH}
./xexcreator.sh main.pas main.xex 2000

# Use cursor keys and SPACE.
${ENUM_PATH} --joy main.xex

