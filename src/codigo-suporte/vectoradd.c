#include "macros.h"
#include "timing.h"
#include <stdlib.h>
#include <stdio.h>

#define PRINT false

void init(long int* v, long int qnt, long int val)
{
	long int i;
	for(i=0;i<qnt;i++)
	{
		v[i] = val;
	}
}

void imprime(long int* v1, long int* v2, long int* res, long int size)
{
	long int i;
	for(i=0; i<size; i++)
	{
		printf("%d + %d = %d\n", v1[i],v2[i],res[i]);
	}
}

int main(int argc, char* argv[]){

	size_t QNTD = atoi(argv[1]);
	long int* v1;
    long int* v2;
    long int* res;
	v1 = (long int*) malloc(sizeof(long int)*QNTD);
	v2 = (long int*) malloc(sizeof(long int)*QNTD);
	res = (long int*) malloc(sizeof(long int)*QNTD);
	
	init(v1, QNTD, 1);
	init(v2, QNTD, 1);
	init(res, QNTD, 0);

	HOOKOMP_TIMING_SEQ_START;

//	printf("Sem Thread: \n");
	for(size_t i=0; i<QNTD; i++)
	{
		res[i] = v1[i] + v2[i];
	}

	if (PRINT)
	{
		imprime(v1,v2,res,QNTD);
	}
	HOOKOMP_TIMING_SEQ_STOP;

	//zera o vetor de resposta
	init(res, QNTD, 0);

	HOOKOMP_TIMING_OMP_START;
	
	#pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  	{
  		#pragma omp for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
		
    	for(size_t i=0;i<QNTD;i++)
		{
			res[i] = v1[i] + v2[i];
		}
  	}

  	HOOKOMP_TIMING_OMP_STOP;

  	fprintf(stdout, "version = OMP, num_threads = %d, N = %d, ", OPENMP_NUM_THREADS, QNTD);
  	HOOKOMP_PRINT_TIME_RESULTS;

	return 0;
}
