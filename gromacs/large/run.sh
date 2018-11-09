#!/bin/sh

BASE=`pwd`
REPS=1
ITERS="10000"

GROMPP_OPTS=""   # additional grompp options
NDXFILE_OPTS=""  # additional grompp options to set ndxfile 
MDRUN_OPTS=""    # additional mdrun options

PROCNUM=1        # number of processes for mdrun (MPI)
THREADNUM=2      # number of threads   for mdrun

# ------------------------------------------------------------------------------
#
run_experiment()
{
    # run one experiment.  We get the number of iterations passed which is then
    # set in grompp.mdp, and the repetition ID.

    iter=$1
    rep=$2

    experiment=`printf "experiment_%d_%d_%d_%03d" $PROCNUM $THREADNUM $iter $rep`

    # create that experiment in the given base dir (we fail if that exists)
    cd       $BASE
    test  -e $experiment && echo "experiment $experiment exists in base $BASE/"
    test  -e $experiment && return
    mkdir -p $experiment/
    cd       $experiment/
    
    echo
    echo "run experiment $experiment"

    # prepare input data.  Vivek can motivate this magic I think :)
    cat ../rawdata/dynamic2.mdp | sed -e "s/###ITER###/$iter/g" > dynamic2.mdp
    cp  ../rawdata/FF.itp           ./
    cp  ../rawdata/FNF.itp          ./
    cp  ../rawdata/Martini.top      ./
    cp  ../rawdata/WF.itp           ./
    cp  ../rawdata/em_results.gro   ./
    cp  ../rawdata/eq_results.gro   ./
    cp  ../rawdata/eq_results.log   ./
    cp  ../rawdata/martini_v2.2.itp ./
    
    
    # run the preprocessor (one thread, very quick)
    cmd=$(echo "gmx_mpi grompp $GROMPP_OPTS $NDXFILE_OPTS
                -f dynamic2.mdp
                -c em_results.gro
                -o equilibrium.tpr
                -p Martini.top
                " | xargs echo)  # collapse spaces
    echo "run $cmd"
    $cmd > grompp.log 2>&1


    # this is the real application
    export OMP_NUM_THREADS=$THREADNUM
    cmd=$(echo "mpirun -oversubscribe -np $PROCNUM
                gmx_mpi mdrun $MDRUN_OPTS
                -s equilibrium.tpr
                -v -deffnm
                eq_results
                " | xargs echo)  #  collapse spaces

    echo "run $cmd"
    $cmd | tee -a mdrun.log 2>&1
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

