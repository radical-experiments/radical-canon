run with:

gmx grompp -f dynamic2.mdp -c em_results.gro -o equilibrium.tpr -p Martini.top

gmx mdrun -s equilibrium.tpr -v -deffnm eq_results
