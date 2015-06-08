#!/bin/sh

BASE=`pwd`
ITERS=10
STEPS="10000 100000"

GROMPP_OPTS=""   # additional grompp options
NDXFILE_OPTS=""  # additional grompp options to set ndxfile 
MDRUN_OPTS=""    # additional mdrun options
THREADNUM=1      # number of threads for mdrun

# ------------------------------------------------------------------------------
#
run_application()
{
    step=$1
    iter=$2

    experiment=`printf "experiment_%d_%03d" $step $iter`

    echo "running experiment $experiment"

    cd       $BASE
    rm   -rf $experiment/
    mkdir -p $experiment/
    cd       $experiment/
    
    cat ../rawdata/start.gro  | sed "1"','"25"'!d'            > start_tmp.gro
    cat ../rawdata/grompp.mdp | sed -e "s/###STEP###/$step/g" > grompp.mdp
    cat ../rawdata/topol.top  > topol.top
    
    grompp \
           $GROMPP_OPTS \
           $NDXFILE_OPTS \
           -f  grompp.mdp \
           -p  topol.top \
           -c  start_tmp.gro \
           -o  topol.tpr \
           -po mdout.mdp \
         > log 2>&1

    mdrun  \
           $MDRUN_OPTS \
           -nt  $THREADNUM \
           -o   traj.trr \
           -e   ener.edr \
           -s   topol.tpr \
           -g   mdlog.log \
           -cpo state.cpt \
           -c   outgro \
        >> log 2>&1

}


# ------------------------------------------------------------------------------
#
for step in $STEPS
do

    iter=0
    while ! test $iter = $ITERS
    do
        iter=$((iter+1))
        run_application $step $iter
    done

done

