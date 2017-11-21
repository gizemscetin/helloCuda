#include <iostream>
#include <random>
#include <chrono>
typedef std::chrono::high_resolution_clock Clock;

using namespace std;

__global__ void VectorMult(int *res, int *op1, int *op2, int n)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int step = blockDim.x * gridDim.x;
	for (; i < n; i += step)
	{
		res[i] = op1[i] * op2[i];
	}
}


__global__ void VectorAdd(int *res, int *op1, int *op2, int n)
{
	//int i = threadIdx.x;
	//int step = blockDim.x;
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int step = blockDim.x * gridDim.x;
	for (; i < n; i+=step)
	{
		res[i] = op1[i] + op2[i];
	}
}

int main()
{
	const int N = 1000000;//1048576;//32000000;
	int *a, *b, *c;

	//a = new int[N];
	//b = new int[N];
	//c = new int[N];
	cudaMallocManaged(&a, N * sizeof(int));
	cudaMallocManaged(&b, N * sizeof(int));
	cudaMallocManaged(&c, N * sizeof(int));

	for (int i = 0; i < N; i++)
	{
		a[i] = rand() % 100;
		b[i] = rand() % 100;
	}

	auto t1 = Clock::now();
	//VectorAdd(c, a, b, N);
	int blockSize = 1024;
	int numBlocks = (N + blockSize - 1) / blockSize;
	//VectorAdd <<<numBlocks, blockSize >>> (c, a, b, N);
	VectorMult << <numBlocks, blockSize >> > (c, a, b, N);
	auto t2 = Clock::now();
	cudaDeviceSynchronize();


	for (int i = N-5; i < N; i++)
	{
		cout << c[i] << endl;
	}

	std::cout << "Time: "
		<< std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count()
		<< " milliseconds" << std::endl;

	//delete[] a;
	//delete[] b;
	//delete[] c;
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);

	//system("Pause");
	return 0;
}