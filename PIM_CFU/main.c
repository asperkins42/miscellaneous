#include <stdio.h>
#include <stdint.h>
#include "cfu.h"  // gives cfu_op0()

// Prototype for your outer product matmul
void matmul_outer(int32_t *A, int32_t *B, int32_t *C, int M, int N, int K);

int main(void) {
    // Example: Multiply a 2x4 by a 4x2 to get a 2x2 matrix
    int M = 2, K = 4, N = 2;

    int32_t A[8] = {
        1, 2, 3, 4,
        5, 6, 7, 8
    };
    int32_t B[8] = {
        1, 2,
        3, 4,
        5, 6,
        7, 8
    };
    int32_t C[4];

    matmul_outer(A, B, C, M, N, K);

    // Print the resulting C matrix
    printf("Result C = \n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", C[i*N + j]);
        }
        printf("\n");
    }
    return 0;
}

void matmul_outer(int32_t *A, int32_t *B, int32_t *C, int M, int N, int K) {
    // Initialize C to zero
    for (int i = 0; i < M * N; i++) {
        C[i] = 0;
    }

    // Outer product dataflow
    for (int k = 0; k < K; k += 4) {
        for (int i = 0; i < M; i++) {
            // Load 4 elements from A's column (broadcasted across B's row)
            uint32_t a_vals = *((uint32_t *)(A + i*K + k));

            for (int j = 0; j < N; j++) {
                uint32_t b_vals = *((uint32_t *)(B + k*N + j*4));
                // Call CFU: funct7=0, in0=a_vals, in1=b_vals
                int32_t partial_sum = cfu_op0(0, a_vals, b_vals);
                C[i*N + j] += partial_sum;
            }
        }
    }
}

