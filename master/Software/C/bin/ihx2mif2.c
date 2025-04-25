#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 1024

// Function to parse a single line of Intel HEX and convert it to MIF format
void convert_hex_line_to_mif(FILE *mif_file, const char *line) {
    unsigned int address, length, i;
    unsigned char data[256];  // Max data length per record in Intel HEX
    unsigned char checksum;
    
    // Check if the line starts with ':'
    if (line[0] != ':') {
        fprintf(stderr, "Invalid HEX line: %s\n", line);
        return;
    }

    // Parse the length of data and address
    sscanf(line + 1, "%2X", &length);    // Length is the second field
    sscanf(line + 3, "%4X", &address);   // Address is the fourth field

    // Parse the data bytes
    for (i = 0; i < length; i++) {
        sscanf(line + 9 + (i * 2), "%2X", &data[i]);  // Each byte is two hex characters
    }

    // Write the address and data to the MIF file
    for (i = 0; i < length; i++) {
        fprintf(mif_file, "%04X : %02X;\n", address + i, data[i]);
    }
}

// Function to convert Intel HEX file to MIF format
void convert_ihx_to_mif(const char *ihx_filename, const char *mif_filename) {
    FILE *ihx_file = fopen(ihx_filename, "r");
    FILE *mif_file = fopen(mif_filename, "w");

    if (!ihx_file) {
        perror("Error opening .ihx file");
        return;
    }

    if (!mif_file) {
        perror("Error opening .mif file");
        fclose(ihx_file);
        return;
    }

    // Write the MIF header
    fprintf(mif_file, "DEPTH = 16384;\n");
    fprintf(mif_file, "WIDTH = 8;\n");
    fprintf(mif_file, "ADDRESS_RADIX = HEX;\n");
    fprintf(mif_file, "DATA_RADIX = HEX;\n");
    fprintf(mif_file, "CONTENT BEGIN\n");

    // Process each line from the .ihx file
    char line[MAX_LINE_LENGTH];
    while (fgets(line, sizeof(line), ihx_file)) {
        if (line[0] == ':') {
            convert_hex_line_to_mif(mif_file, line);
        }
    }

    // Write the MIF footer
    fprintf(mif_file, "END;\n");

    // Close the files
    fclose(ihx_file);
    fclose(mif_file);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input.ihx> <output.mif>\n", argv[0]);
        return 1;
    }

    const char *ihx_filename = argv[1];  // Input .ihx file
    const char *mif_filename = argv[2];  // Output .mif file

    // Convert the Intel HEX file to MIF format
    convert_ihx_to_mif(ihx_filename, mif_filename);

    return 0;
}
