#!/bin/bash
#PBS -q workq
#PBS -l nodes=1:ppn=20
#PBS -l walltime=00:60:00
#PBS -o amber-remd.o
#PBS -j oe
#PBS -N AMBER_REMD
#PBS -A TG-MCB090174

start=$(date +%s.%N)

module load  amber/14/INTEL-140-MVAPICH2-2.0

# change this to your working directory!!!
cd /work/antontre/radical.pilot.sandbox/rp.session.antons-pc.antons.016763.0017-pilot.0000/unit.000002

mpirun -np 2 -machinefile $PBS_NODEFILE sander.MPI -O -i ace_ala_nme.mdin -o ace_ala_nme_remd.mdout -p ace_ala_nme.parm7 -c ace_ala_nme.inpcrd.0.0 -r ace_ala_nme_remd.rst -x ace_ala_nme_remd.mdcrd -inf ace_ala_nme_remd.mdinfo

end=$(date +%s.%N)

runtime=$(python -c "print(${end} - ${start})")

echo "Runtime was::: $runtime"

#Amber's timings can be found in ace_ala_nme_remd.mdout   

