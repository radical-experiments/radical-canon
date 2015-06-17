#!/bin/sh

# This was tested with gromacs/4.6.5 and runs successfully. It fails for gromcas-5.0*

BASE=`pwd`
REPS=10
ITERS="10000 100000"

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
    
    echo "running experiment $experiment"

    # prepare input data.  Vivek can motivate this magic I think :)
    cat ../rawdata/min.in > min.in
    cat ../rawdata/mdshort.in > mdshort.in
    cat ../rawdata/1yu5b.top > topol.top
    cat ../rawdata/1yu5b.crd > 1yu5b.crd
    cp 1yu5b.crd min0.crd
    
    # run the minimization step
    pmemd.MPI -O -i min.in -o min0.out -inf min0.inf -r md0.crd -p topol.top -c 1yu5b.crd -ref min0.crd > log 2>&1

    # run the simulation step
    pmemd.MPI -O -i mdshort.in -o md0.out -inf md0.inf -x md0.ncdf -r md0.rst -p topol.top -c md0.crd > log 2>&1
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
