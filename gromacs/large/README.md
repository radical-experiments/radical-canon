
Description
===========

This system contains 500 MARTINI coarse grained diphenylalanine
peptides solvated in approximately 33,000 coarse grained water particles


[Publication](https://pubs.rsc.org/en/content/articlelanding/2018/ob/c8ob00130h#!divAbstract)

Abstract
--------

**`Designing phenylalanine-based hybrid biological materials: controlling
morphology via molecular composition'** 
in *'Organic & Biomolecular Chemistry (RSC Publishing)'

Harnessing the self-assembly of peptide sequences has demonstrated great promise
in the domain of creating high precision shape-tunable biomaterials. The unique
properties of peptides allow for a building block approach to material design.
In this study, self-assembly of mixed systems encompassing two peptid




-gmx grompp -f dynamic2.mdp -c em_results.gro -o equilibrium.tpr -p Martini.top
-gmx mdrun -s equilibrium.tpr -v -deffnm eq_results
