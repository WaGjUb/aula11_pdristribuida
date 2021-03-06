#!/bin/bash -xe

benchmark=vectoradd
PREFIX_BENCHMARK=omp
EXPERIMENT=experimento
echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

for size_of_data in 1048576 8388608; do
	for num_threads in 1 2 4 8; do
		for omp_schedule in STATIC DYNAMIC GUIDED; do
			for chunk_size in 16 32 64 128 256; do
					python2 csvize-experiments-results.py -i data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv -o terreno.csv
				done
			done
		done
	done
echo "End of tests at `date +'%d/%m/%Y-%T'`"
