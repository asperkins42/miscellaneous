#include <stdio.h>
#include <stdint.h>

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

