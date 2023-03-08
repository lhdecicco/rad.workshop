#!/bin/bash

# sbatch --chdir=/home/l944d476/work/rad.project/

# sbatch --nodes=1 --cpus-per-task=15 --mem-per-cpu=1gb --time=06:00:00 --partition=sixhour stacks.prelim.sh

files="P_iliaca_119300
P_iliaca_119384
P_iliaca_119875
P_iliaca_119926
P_iliaca_14936
P_iliaca_20392
P_iliaca_30340
P_iliaca_30343
P_iliaca_31497
P_iliaca_34095
P_iliaca_34099
P_iliaca_34110
P_iliaca_34528
P_iliaca_36901
P_iliaca_37204
P_iliaca_37207
P_iliaca_37210
P_iliaca_37506
P_iliaca_38225
P_iliaca_38230
P_iliaca_38815
P_iliaca_38937
P_iliaca_40396
P_iliaca_40401
P_iliaca_40407
P_iliaca_41097
P_iliaca_42685
P_iliaca_44466
P_iliaca_80673
P_iliaca_80686
S_arborea_35787
Z_querula_26548"


#load stacks
module load stacks

#run ustacks in a loop for each sample, with all parameters set to default, using 15 threads
id=1
for sample in $files
do
ustacks -f fastq/${sample}.fq -o stacks.prelim -i $id -p 15
let "id+=1"
done

## Run cstacks to compile stacks between samples. Popmap is a file in working directory called 'pipeline_popmap.txt'
cstacks -P stacks.prelim -M passerella.popmap.txt -p 15

## Run sstacks. Match all samples supplied in the population map against the catalog.
sstacks -P stacks.prelim -M passerella.popmap.txt -p 15

## Run tsv2bam to transpose the data so it is stored by locus, instead of by sample.
tsv2bam -P stacks.prelim -M passerella.popmap.txt -t 15

## Run gstacks: align reads per sample, call variant sites in the population, genotypes in each individual.
gstacks -P stacks.prelim -M passerella.popmap.txt -t 15

## Run populations completely unfiltered and output unfiltered vcf, we will do filtering using the SNPfiltR package
populations -P stacks.prelim -M passerella.popmap.txt --vcf -t 15

