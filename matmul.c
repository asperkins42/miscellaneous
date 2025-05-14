#include <stdio.h>

#include <stdlib.h>

#include <time.h>

 

#define SIZE 8192  // Size of the matrix (adjust to fit the memory bandwidth)

 

void matrix_multiply(double *A, double *B, double *C, int n) {
    for (int i = 0; i < n; i++) {
        // Print progress every 512 rows (adjust as needed)
        if (i % 128 == 0) {
            printf("Progress: %d / %d rows completed (%.2f%%)\n", i, n, (100.0 * i) / n);
            fflush(stdout); // ensure immediate printing
        }

        for (int j = 0; j < n; j++) {
            C[i * n + j] = 0;
            for (int k = 0; k < n; k++) {
                C[i * n + j] += A[i * n + k] * B[k * n + j];
            }
        }
    }
}

 

void initialize_matrix(double *matrix, int n) {

    for (int i = 0; i < n * n; i++) {

        matrix[i] = rand() % 1000;

    }

}

 

int main() {

    int n = SIZE;

    double *A, *B, *C;

 

    // Allocate memory for matrices A, B, and C

    A = (double *)malloc(n * n * sizeof(double));

    B = (double *)malloc(n * n * sizeof(double));

    C = (double *)malloc(n * n * sizeof(double));

 

    if (A == NULL || B == NULL || C == NULL) {

        printf("Memory allocation failed\n");

        return -1;

    }

 

    // Initialize matrices A and B with random values

    srand(time(NULL));

    initialize_matrix(A, n);

    initialize_matrix(B, n);

 

    clock_t start_time = clock();

    // Perform matrix multiplication

    matrix_multiply(A, B, C, n);

    clock_t end_time = clock();

 

    // Measure the time taken for the matrix multiplication

    double time_taken = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    printf("Matrix multiplication took %f seconds\n", time_taken);

 

    // Free the allocated memory

    free(A);

    free(B);

    free(C);

 

    return 0;

}
