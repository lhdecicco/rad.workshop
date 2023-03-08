#!/bin/bash

# sbatch --chdir=/home/l944d476/work/rad.project/

# sbatch --nodes=1 --cpus-per-task=15 --mem-per-cpu=1gb --time=06:00:00 --partition=sixhour stacks.prelim.sh

files="119300
119384
119875
119926
14936
20392
30340
30343
31497
34095
34099
34110
34528
36901
37204
37207
37210
37506
38225
38230
38815
38937
40396
40401
40407
41097
42685
44466
80673
80686
35787
26548"


#load stacks
module load stacks

#run ustacks in a loop for each sample, with all parameters set to default, using 15 threads
id=1
for sample in $files
do
ustacks -f fastq/P_iliaca_${sample}.fq -o stacks.prelim -i $id -p 15
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
