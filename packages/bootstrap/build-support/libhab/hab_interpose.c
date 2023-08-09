#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Declare original dlopen function
void *(*original_dlopen)(const char *, int) = NULL;

// Interposed dlopen
void *dlopen(const char *filename, int flag) {
    // Find the original dlopen function
    original_dlopen = (void *(*) (const char *, int)) dlsym(RTLD_NEXT, "dlopen");
	if (!original_dlopen) {
		fprintf(stderr, "libhab: failed to find the original 'dlopen' symbol. This seems like a bug, please notify the Habitat team\n");
		exit(EXIT_FAILURE);
	}

	char *ld_debug = getenv("LD_DEBUG");
	int print_debug = 0;
	if (ld_debug != NULL && *ld_debug != '\0') {
		if (strcmp(ld_debug, "all") == 0 || strcmp(ld_debug, "libs") == 0) {
			print_debug = 1;
		}
	}
	char *hab_debug = getenv("HAB_LD_DEBUG");
	if (hab_debug != NULL && *hab_debug != '\0') {
		if (strcmp(hab_debug, "1") == 0) {
			print_debug = 1;
		}
	}

	// Check if the filename is valid
	if (filename != NULL) {
		if (filename[0] == '/') {
			if (print_debug) fprintf(stderr, "libhab: passing through absolute library name '%s' to original dlopen\n", filename);
			return original_dlopen(filename, flag);
		}
		if (filename[0] == '\0') {
			if (print_debug) fprintf(stderr, "libhab: passing through empty library name to original dlopen\n");
			return original_dlopen(filename, flag);
		}
	} else {
		if (print_debug) fprintf(stderr, "libhab: passing through null library name to original dlopen\n");
		return original_dlopen(filename, flag);
	}
	
	// Check if the HAB_LD_LIBRARY_PATH environment variable is defined
	char *hab_ld_library_path = getenv("HAB_LD_LIBRARY_PATH");
	if (hab_ld_library_path != NULL && *hab_ld_library_path != '\0')
	{
		if (print_debug) fprintf(stderr, "libhab: interposed hab search path=%s\n", hab_ld_library_path);
		size_t filename_length = strlen(filename);
		char *current_directory = hab_ld_library_path;
		for (const char *current_char = hab_ld_library_path;; ++current_char) {
			if (*current_char == ':' || *current_char == ';' || *current_char == '\0') {
				size_t directory_path_length = current_char - current_directory;
				// Ensure we have a non-zero directory
				if (directory_path_length == 0) {
					// If this is the last character terminate the loop
					if (*current_char == '\0') {
						break;
					} else {
						current_directory++;
						continue;
					}
				}
				// Allocate and build a concatented string
				char *absolute_library_path = (char *) malloc(directory_path_length + filename_length + (2u * sizeof(char)));
				if (absolute_library_path == NULL) {
					fprintf(stderr, "libhab: failed to allocate memory for library lookup with HAB_LD_LIBRARY_PATH entry: HAB_LD_LIBRARY_PATH=%s.\n", hab_ld_library_path);
					exit(EXIT_FAILURE);
				}
				memset(absolute_library_path, 0, directory_path_length + filename_length + (2u * sizeof(char)));
				memcpy(absolute_library_path, current_directory, directory_path_length);
				absolute_library_path[(int) (directory_path_length / sizeof(char))] = '\0';
				strcat(absolute_library_path, "/");
				strcat(absolute_library_path, filename);
				if (print_debug) fprintf(stderr, "libhab:   trying file=%s\n", absolute_library_path);
				void *result = original_dlopen(absolute_library_path, flag);
				if (result != NULL) {
					if (print_debug) fprintf(stderr, "libhab:   found library at %s\n", absolute_library_path);
					free(absolute_library_path);
					return result;
				}
				free(absolute_library_path);
				current_directory += directory_path_length + 1;
			}
			// If this is the last character terminate the loop
			if (*current_char == '\0') break;
		}
		if (print_debug) fprintf(stderr, "libhab: completed searching HAD_LD_LIBRARY_PATH entries, passing through library name '%s' to original dlopen\n", filename);
		// Call original dlopen
		return original_dlopen(filename, flag);
	} else {
		if (print_debug) fprintf(stderr, "libhab: environment variable 'HAB_LD_LIBRARY_PATH' has not been set, passing through library name '%s' to original dlopen\n", filename);
		// Call original dlopen
		return original_dlopen(filename, flag);
	}
}