import os
import sys
import math
import json
import time
import random
from mpi4py import MPI
from subprocess import *
import subprocess

#-------------------------------------------------------------------------------
#
if __name__ == '__main__':

    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    out = "ace_ala_nme_{0}.mdout".format( rank )
    inf = "ace_ala_nme_{0}.mdinfo".format( rank )

    cmd = "/home/antontre/amber14/bin/sander " + "-O " + \
          "-i " + "ace_ala_nme.mdin " + \
          "-o " + out + " " + \
          "-p " + "ace_ala_nme.parm7 " + \
          "-c " + "ace_ala_nme.inpcrd.0.0 " + \
          "-r " + "ace_ala_nme.rst " + \
          "-x " + "ace_ala_nme.mdcrd " + \
          "-inf " + inf + " "
    process = [Popen(cmd, subprocess.PIPE, shell=True)]
    #process.wait()

    comm.Barrier()

