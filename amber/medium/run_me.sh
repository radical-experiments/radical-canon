#!/bin/sh

module load amber
AMBER="/opt/amber/bin/sander.MPI"

# here:
# ace_ala_nme.mdin - is input file
# ace_ala_nme.mdout - is output file
# ace_ala_nme.parm7 - is Amber parameters file
# ace_ala_nme.inpcrd - is Amber coordinates file
# ace_ala_nme.rst - is name of the restart file, this is output of successful simulation
# ace_ala_nme.mdcrd - is new trajectory file
# ace_ala_nme.mdinfo - new info file, summary of the performed simulation

$AMBER -O -i input/ace_ala_nme.mdin -o ace_ala_nme.mdout -p input/ace_ala_nme.parm7 -c input/ace_ala_nme.inpcrd -r ace_ala_nme.rst -x ace_ala_nme.mdcrd -inf ace_ala_nme.mdinfo
