#!/bin/sh

BASE=`pwd`
REPS=1
ITERS="2500000"

GROMPP_OPTS=""   # additional grompp options
NDXFILE_OPTS=""  # additional grompp options to set ndxfile 
MDRUN_OPTS=""    # additional mdrun options
THREADNUM=8      # number of threads for mdrun

# ------------------------------------------------------------------------------
#
run_experiment()
{
    # run one experiment.  We get the number of iterations passed which is then
    # set in grompp.mdp, and the repetition ID.

    iter=$1
    rep=$2

    experiment=`printf "experiment_%d_%03d" $iter $rep`

    # create that experiment in the given base dir (we fail if that exists)
    cd       $BASE
    test  -e $experiment && echo "experiment $experiment exists in base $BASE/"
    test  -e $experiment && return
    mkdir -p $experiment/
    cd       $experiment/
    
    echo
    echo "run experiment $experiment"

    # prepare input data.  Vivek can motivate this magic I think :)
    cat ../rawdata/start.gro  | sed "1"','"25"'!d'            > start_tmp.gro
    cat ../rawdata/grompp.mdp | sed -e "s/###ITER###/$iter/g" > grompp.mdp
    cat ../rawdata/topol.top  > topol.top
    
    # run the preprocessor (one thread, very quick)
    cmd=$(echo "gmx  grompp
           $GROMPP_OPTS
           $NDXFILE_OPTS
           -f  grompp.mdp
           -p  topol.top
           -c  start_tmp.gro
           -o  topol.tpr
           -po mdout.mdp" | xargs echo)  #  collapse spaces
    echo "run $cmd"
    $cmd > log 2>&1
    

    # this is the real application
    cmd=$(echo "gmx mdrun
           $MDRUN_OPTS
           -nt  $THREADNUM
           -o   traj.trr
           -e   ener.edr
           -s   topol.tpr
           -g   mdlog.log
           -cpo state.cpt
           -c   outgro" | xargs echo)  #  collapse spaces
    echo "run $cmd"
    $cmd >> log 2>&1
}


# ------------------------------------------------------------------------------
#

# one set of experiments for each given number of iterations
for iter in $ITERS
do
    # run $REPS numbers of experiments for this $iter
    rep=0
    while ! test $rep = $REPS
    do
        rep=$((rep+1))
        run_experiment $iter $rep
    done

done

