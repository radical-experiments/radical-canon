
Execute this small Gromacs example with `./run.sh`.  The following parameters
can be adjusted at the top of the script:

* `BASE`:  dir where to create runtime data and results of experiments
* `REPS`:  number of runs for each experiment
* `ITERS`: list of iteration numbes -- the script will run one set of
           experiments for each number given

Several Gromacs command line parameters can also be set in the script,
specifically the number of threads to use -- but the default settings
should work all right.  The settings have been tested with
Gromacs-v5.0.4.

