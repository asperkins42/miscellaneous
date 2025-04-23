
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <libbase/uart.h>
#include <libbase/console.h>
#include <generated/csr.h>
#include <generated/mem.h>

#include <bios/readline.h>
#include <bios/sim_debug.h>
#include <bios/helpers.h>

#define ARRAY_SIZE(array) (sizeof(array) / sizeof((array)[0]))

#define MAX_PARAM 8

static char buffer[CMD_LINE_BUFFER_SIZE];
static char *command;
static char *params[MAX_PARAM];
static int nb_params;
static int input_rows = 4;
static int input_cols = 4;
static int kernel_rows = 2;
static int kernel_cols = 2;

static void reboot(void)
{
    ctrl_reset_write(1);
}

static void prompt(void)
{
    printf("\e[92;1mornl\e[0m> ");
}

static void help(void)
{
    puts("\nFirmware built "__DATE__" "__TIME__"\n");
    puts("Available commands:\n");
    puts("help               - Show this command");
    puts("convolve           - Perform hardcoded convolution");
    puts("reboot             - Reboot CPU");
}


static void convolve(void)
{
    const int input[4][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12},
        {13, 14, 15, 16}
    };

    const int kernel[2][2] = {
        {1, 0},
        {0, -1}
    };

    const int output_rows = 4 - 2 + 1;
    const int output_cols = 4 - 2 + 1;
    int output[output_rows][output_cols];

    // Perform convolution
    for (int i = 0; i < output_rows; i++) {
        for (int j = 0; j < output_cols; j++) {
            int sum = 0;
            for (int ki = 0; ki < 2; ki++) {
                for (int kj = 0; kj < 2; kj++) {
                    sum += input[i + ki][j + kj] * kernel[ki][kj];
                }
            }
            output[i][j] = sum;
        }
    }

    // Print result
    puts("Convolution input:");
    for (int i = 0; i < input_rows; i++) {
        for (int j = 0; j < input_cols; j++) {
            printf("%4d", input[i][j]);
        }
        printf("\n");
    }

    // Print result
    puts("Convolution kernel:");
    for (int i = 0; i < kernel_rows; i++) {
        for (int j = 0; j < kernel_cols; j++) {
            printf("%4d", kernel[i][j]);
        }
        printf("\n");
    }
    
    // Print result
    puts("Convolution output:");
    for (int i = 0; i < output_rows; i++) {
        for (int j = 0; j < output_cols; j++) {
            printf("%4d", output[i][j]);
        }
        printf("\n");
    }
}


static bool dispatch_cmd(char *command, int nb_params, char **params)
{
    if (strcmp(command, "help") == 0) {
        help();
        return true;
    }

    if (strcmp(command, "convolve") == 0) {
        convolve();
        return true;
    }

    if (strcmp(command, "reboot") == 0) {
        reboot();
        return true;
    }

    return false;
}

int main(void)
{
#ifdef CONFIG_CPU_HAS_INTERRUPT
    irq_setmask(0);
    irq_setie(1);
#endif

    uart_init();

#ifndef CONSOLE_DISABLE
    hist_init();

    help();

	while(1) {
        prompt();
		readline(buffer, CMD_LINE_BUFFER_SIZE);
        printf("\n");
		if (buffer[0] != 0) {
			nb_params = get_param(buffer, &command, params);
			if (!dispatch_cmd(command, nb_params, params)) {
				printf("Invalid command: %s\n", command);
            }
		}
	}
#else
    sim_finish();
#endif

    return 0;
}

