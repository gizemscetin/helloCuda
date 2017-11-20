#include <iostream>
#include <random>
#include <chrono>
typedef std::chrono::high_resolution_clock Clock;

using namespace std;


__global__ void VectorAdd(int *res, int *op1, int *op2, int n)
{
	//int i = blockIdx.x;
	int i = threadIdx.x;
	//for (int i = 0; i < n; i++)
	if (i < n)
	{
		res[i] = op1[i] + op2[i];
	}
}

int main()
{
	const int N = 1000;//32000000;
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
	VectorAdd << <1, N >> > (c, a, b, N);
	auto t2 = Clock::now();
	cudaDeviceSynchronize();


	for (int i = 0; i < N; i++)
	{
		cout << c[i] << endl;
	}

	std::cout << "Time: "
		<< std::chrono::duration_cast<std::chrono::nanoseconds>(t2 - t1).count()
		<< " nanoseconds" << std::endl;

	//delete[] a;
	//delete[] b;
	//delete[] c;
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);

	//system("Pause");
	return 0;
}