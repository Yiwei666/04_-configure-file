#!/bin/bash
#SBATCH -p amd_256
#SBATCH -N 1
#SBATCH -n 64
#export OMP_NUM_THREADS=1
source /public1/soft/modules/module.sh
module load cp2k/8.1
module load gcc/7.3.0-kd
export PATH=/public1/soft/cp2k/8.1/exe/local:$PATH
source /public1/soft/cp2k/8.1/tools/toolchain/install/setup
/public1/soft/cp2k/8.1/tools/toolchain/install/openmpi-4.0.5/bin/mpirun cp2k.psmp -i OT.inp -o tem.out
