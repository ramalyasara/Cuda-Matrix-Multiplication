#include <stdio.h>
#include <math.h>



__global__ void MatrixMul( float *Md , float *Nd , float *Pd , const int WIDTH )
{
	


int COL = threadIdx.x + blockIdx.x * blockDim.x;
int ROW = threadIdx.y + blockIdx.y * blockDim.y;



    if (ROW < WIDTH && COL < WIDTH) {        
        for (int i = 0; i < WIDTH; i++) {
           Pd[ROW * WIDTH + COL] += Md[ROW * WIDTH + i] * Nd [i * WIDTH + COL];
        }
    }
   
}




int main(int arg0, char *arg1[]){ 

  cudaThreadSynchronize();
	
  int WIDTH = 1024;
  int THREADS_PER_BLOCK = atoi(arg1[1]);
  int sqrtThreads = sqrt(THREADS_PER_BLOCK);
  int nBlocks = WIDTH/sqrtThreads;
  
	if (WIDTH % sqrtThreads != 0)
		{ 
			nBlocks++;
		}

  dim3 grid(nBlocks, nBlocks, 1);
  dim3 block(sqrtThreads, sqrtThreads, 1); 


  float *a_h, *b_h, *c_h, *d_h, *a_d, *b_d, *c_d;
  int size;

  cudaEvent_t start;
  cudaEvent_t stop;
  float elapsed1;

  size = WIDTH * WIDTH * sizeof(float);
  
  a_h = (float*) malloc(size);
  b_h = (float*) malloc(size);
  c_h = (float*) malloc(size);
  d_h = (float*) malloc(size);


	for (int i = 0; i < WIDTH; i++)
	{
		for (int j = 0; j < WIDTH; j++)
		{
			a_h[i * WIDTH + j] = i;
			b_h[i * WIDTH + j] = i;
		}
	}


  cudaMalloc((void**)&a_d, size);
  cudaMalloc((void**)&b_d, size);
  cudaMalloc((void**)&c_d, size);

  cudaMemcpy(a_d, a_h, size, cudaMemcpyHostToDevice);
  cudaMemcpy(b_d, b_h, size, cudaMemcpyHostToDevice);
  cudaMemcpy(c_d, c_h, size, cudaMemcpyHostToDevice);

  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cudaEventRecord(start, 0);

 MatrixMul<<<grid, block>>>(a_d, b_d, c_d, WIDTH);

  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed1, start, stop);

  printf("%f\n", elapsed1/1000);

  cudaMemcpy(c_h, c_d, size, cudaMemcpyDeviceToHost); 

  free(a_h);
  free(b_h);
  free(c_h);
  free(d_h);
  cudaFree(a_d);
  cudaFree(b_d);
  cudaFree(c_d);

  cudaEventDestroy(start);
  cudaEventDestroy(stop);

  return 0;
}
