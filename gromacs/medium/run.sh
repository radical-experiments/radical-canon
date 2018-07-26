#!/bin/sh

# This has been tested with gromacs-4.6.5. It was unsuccessful with gromacs-5.0.*.

BASE=`pwd`
REPS=1
STEPS="50000"

GROMPP_OPTS=""   # additional grompp options
NDXFILE_OPTS=""  # additional grompp options to set ndxfile 
MDRUN_OPTS=""    # additional mdrun options
THREADNUM=8      # number of threads for mdrun

# ------------------------------------------------------------------------------
#
run_experiment()
{
    # run one experiment.  We get the number of steps passed which is then
    # set in grompp.mdp, and the repetition ID.

    steps=$1
    rep=$2

    experiment=`printf "experiment_%d_%03d" $steps $rep`

    # create that experiment in the given base dir (we fail if that exists)
    cd       $BASE
    test  -e $experiment && echo "experiment $experiment exists in base $BASE/"
    test  -e $experiment && return
    mkdir -p $experiment/
    cd       $experiment/
    
    echo "running experiment $experiment"

    # prepare input data.  Vivek can motivate this magic I think :)
    cat ../rawdata/start.gro  > start_tmp.gro
    cat ../rawdata/grompp.mdp | sed -e "s/###STEPS###/$steps/g" > grompp.mdp
    cat ../rawdata/topol.top  > topol.top
    cat ../rawdata/index.ndx  > index.ndx
    cp ../rawdata/*.itp .

    echo "grompp now  `date`"
    
    # run the preprocessor (one thread, very quick)
    time grompp \
           $GROMPP_OPTS \
           $NDXFILE_OPTS \
           -n  index.ndx \
           -f  grompp.mdp \
           -p  topol.top \
           -c  start_tmp.gro \
           -o  topol.tpr \
           -po mdout.mdp \
           -maxwarn 1 \
         > log 2>&1
    
    echo "grompp done `date`"
    echo "mdrun  now  `date`"

    # this is the real application
    echo time mdrun  \
           $MDRUN_OPTS \
           -nt  $THREADNUM \
           -o   traj.trr \
           -e   ener.edr \
           -s   topol.tpr \
           -g   mdlog.log \
           -cpo state.cpt \
           -c   outgro \
        >> log 2>&1
    echo "mdrun  done `date`"
}


# ------------------------------------------------------------------------------
#

# one set of experiments for each given number of steps
for steps in $STEPS
do

    # run $REPS numbers of experiments for this $steps
    rep=0
    while ! test $rep = $REPS
    do
        rep=$((rep+1))
        run_experiment $steps $rep
    done

done
