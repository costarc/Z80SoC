#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DEPTH 16384  // Adjust to the memory depth you need
#define WIDTH 8          // Memory width (in bits)

void convert_ihx_to_mif(const char *ihx_filename, const char *mif_filename) {
    FILE *ihx_file = fopen(ihx_filename, "r");
    if (ihx_file == NULL) {
        // Print a custom error message
        fprintf(stderr, "Error: Could not open the input file '%s'. Please check the file path.\n", ihx_filename);
        perror("Reason");
        return;
    }

    FILE *mif_file = fopen(mif_filename, "w");
    if (mif_file == NULL) {
        fprintf(stderr, "Error: Could not open the output file '%s'.\n", mif_filename);
        perror("Reason");
        fclose(ihx_file);
        return;
    }

    // Write MIF header
    fprintf(mif_file, "DEPTH = %d;\n", MAX_DEPTH);  // ROM depth
    fprintf(mif_file, "WIDTH = %d;\n", WIDTH);      // Memory width
    fprintf(mif_file, "ADDRESS_RADIX = HEX;\n");
    fprintf(mif_file, "DATA_RADIX = HEX;\n");
    fprintf(mif_file, "CONTENT BEGIN\n");

    uint32_t addr = 0x0000;  // Start from address 0x0000
    uint8_t data[256];   // Buffer to store data from each line (max 256 bytes per Intel Hex line)
    size_t data_len = 0;

    char line[512];
    while (fgets(line, sizeof(line), ihx_file) != NULL) {
        // Skip lines that do not start with a valid Intel Hex record
        if (line[0] != ':') {
            continue;
        }

        // Extract the data part of the Intel Hex record
        int byte_count, addr_low, addr_high, type, checksum;
        sscanf(line, ":%2x%2x%2x%2x", &byte_count, &addr_high, &addr_low, &type);
        
        uint16_t address = (addr_high << 8) | addr_low;
        
        // Skip lines that do not have data (e.g., end of file marker or invalid records)
        if (type == 1 || byte_count == 0) {
            continue;
        }

        // Extract the data bytes from the line (hex values)
        char *data_start = line + 9;  // Skip the ":NNNNNN" part
        for (int i = 0; i < byte_count; ++i) {
            sscanf(data_start + (i * 2), "%2hhx", &data[i]);
        }

        // Write the data to the .mif file
        for (size_t i = 0; i < byte_count; ++i) {
            if (addr >= MAX_DEPTH) {
                break;  // Stop writing if we exceed the defined depth
            }
            fprintf(mif_file, "%04X : %02X;\n", addr, data[i]);
            addr++;
        }

        // Stop if we've reached the maximum depth
        if (addr >= MAX_DEPTH) {
            break;
        }
    }

    // End the MIF file
    fprintf(mif_file, "END;\n");

    fclose(ihx_file);
    fclose(mif_file);

    printf("Conversion successful! MIF file created.\n");
}

int main(int argc, char *argv[]) {
    // Check if the correct number of arguments is provided
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input.ihx> <output.mif>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *ihx_filename = argv[1];  // Get the input file from command line argument
    const char *mif_filename = argv[2];  // Get the output file from command line argument

    convert_ihx_to_mif(ihx_filename, mif_filename);

    return EXIT_SUCCESS;
}
