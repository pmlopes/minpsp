#ifdef __WIN32
#include <windows.h>
#endif

#include <stdio.h>
#include <getopt.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define PATH_ENV "PATH"

#ifndef MAX_PATH
#define MAX_PATH 256
#endif

/***** Might need to change these for different platforms */
#define PATH_SEP ":"
#define DIR_SEP '/'
#define DIR_SEP_STR "/"

/* The suffix to the path to strip off, if this is not there then we have an error */
#ifdef __WIN32
#define PATH_SUFFIX "/bin/freetype-config.exe"
#else
#define PATH_SUFFIX "/bin/freetype-config"
#endif
/************************/

enum FTConfigMode
{
	FT_CONFIG_UNKNOWN,
	FT_CONFIG_PREFIX,
	FT_CONFIG_EXEC_PREFIX,
	FT_CONFIG_VERSION,
	FT_CONFIG_FTVERSION,
	FT_CONFIG_LIB,
	FT_CONFIG_LIBTOOL,
	FT_CONFIG_CFLAGS
};

/* Specifies that the current usage is to the print the pspsdk path */
static enum FTConfigMode g_configmode;

static struct option arg_opts[] = 
{
	{"prefix", optional_argument, NULL, 'p'},
	{"exec-prefix", optional_argument, NULL, 'e'},
	{"version", no_argument, NULL, 'v'},
	{"ftversion", no_argument, NULL, 'V'},
	{"libs",  no_argument, NULL, 'l'},
	{"libtool",  no_argument, NULL, 'L'},
	{"cflags", no_argument, NULL, 'c'},
	{ NULL, 0, NULL, 0 }
};

void print_path(char *name);

/* Process the arguments */
int process_args(int argc, char **argv)
{
	int ret = 0;
	int ch;

	g_configmode = FT_CONFIG_UNKNOWN;

	// this will store the fully-qualified path
	char psp_config_path[MAX_PATH] = "";

#ifdef __WIN32
	// fetch the path of the executable
	if(GetModuleFileName(0, psp_config_path, sizeof(psp_config_path) - 1) == 0)
	{
		// fall back
		strcpy(psp_config_path, argv[0]);
	}
#else
	strcpy(psp_config_path, argv[0]);
#endif
	
	ch = getopt_long(argc, argv, "pevVlLc", arg_opts, NULL);
	while(ch != -1)
	{
		switch(ch)
		{
			case 'p' : g_configmode = FT_CONFIG_PREFIX;
					   ret = 1;
					   break;
			case 'e' : g_configmode = FT_CONFIG_EXEC_PREFIX;
					   ret = 1;
					   break;
			case 'v' : g_configmode = FT_CONFIG_VERSION;
					   ret = 1;
					   break;
			case 'V' : g_configmode = FT_CONFIG_FTVERSION;
					   ret = 1;
					   break;
			case 'l' : g_configmode = FT_CONFIG_LIB;
					   ret = 1;
					   break;
			case 'L' : g_configmode = FT_CONFIG_LIBTOOL;
					   ret = 1;
					   break;
			case 'c' : g_configmode = FT_CONFIG_CFLAGS;
					   ret = 1;
					   break;
			default  : fprintf(stderr, "Invalid option '%c'\n", ch);
					   break;
		};
		
		print_path(psp_config_path);

		// fetch the next item
		ch = getopt_long(argc, argv, "pevVlLc", arg_opts, NULL);
	}

	return ret;
}

void print_help(void)
{
	fprintf(stderr, "Usage: freetype-config [OPTION]...\n");
	fprintf(stderr, "Get FreeType compilation and linking information.\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  --prefix               display `--prefix' value used for building the\n");
	fprintf(stderr, "                         FreeType library\n");
	fprintf(stderr, "  --prefix=PREFIX        override `--prefix' value with PREFIX\n");
	fprintf(stderr, "  --exec-prefix          display `--exec-prefix' value used for building\n");
	fprintf(stderr, "                         the FreeType library\n");
	fprintf(stderr, "  --exec-prefix=EPREFIX  override `--exec-prefix' value with EPREFIX\n");
	fprintf(stderr, "  --version              display libtool version of the FreeType library\n");
	fprintf(stderr, "  --ftversion            display FreeType version number\n");
	fprintf(stderr, "  --libs                 display flags for linking with the FreeType library\n");
	fprintf(stderr, "  --libtool              display library name for linking with libtool\n");
	fprintf(stderr, "  --cflags               display flags for compiling with the FreeType\n");
	fprintf(stderr, "                         library\n");
}

void normalize_path (char *out)
{
       int i;
       int j;

       /* Convert "//" to "/" */
       for (i = 0; out[i + 1]; i++) {
               if (out[i] == '/' && out[i + 1] == '/') {
                       for (j = i + 1; out[j]; j++) {
                               out[j] = out[j + 1];
                       }
                       i--;
               }
       }
}

char *find_path(char *name)
{
	static char path[MAX_PATH];
	int found = 0;

	/* Check if name is an absolute path, if so our job is done */
	char *writableName = malloc(strlen(name) + 2);
	char *ptr = writableName;
	char temp;

	while (*(name)) {
		temp = *(name++);
		if (temp == '\\') temp = '/';
		*(ptr++) = temp;
	}

	*(ptr) = '\0';
	name = writableName;

	if(name[0] == DIR_SEP || name[1] == ':')
	{
		/* Absolute path */
		strncpy(path, name, MAX_PATH);
		/* Ensure NUL termination */
		path[MAX_PATH-1] = 0;
		found = 1;
	}
	else 
	{
		/* relative path */
		if(strchr(name, DIR_SEP) != NULL)
		{
			if(getcwd(path, MAX_PATH) != NULL)
			{
				strncat(path, DIR_SEP_STR, MAX_PATH-1);
				strncat(path, name, MAX_PATH-1);
				found = 1;
			}
			else
			{
				fprintf(stderr, "Error getting current working directory\n");
			}
		}
		else
		{
			char *path_env;
			/* Scan the PATH variable */
			path_env = getenv(PATH_ENV);
			if(path_env != NULL)
			{
				char *curr_tok;
				char new_path[MAX_PATH];

				/* Should really use the path separator from the 
				   environment but who on earth changes it? */
				curr_tok = strtok(path_env, PATH_SEP);
				while(curr_tok != NULL)
				{
					strcpy(new_path, curr_tok);
					strcat(new_path, DIR_SEP_STR);
					strcat(new_path, name);

					if(access(new_path, X_OK) == 0)
					{
						found = 1;
						strcpy(path, new_path);
						break;
					}
					
					curr_tok = strtok(NULL, PATH_SEP);
				}
			}
			else
			{
				fprintf(stderr, "Error, couldn't get PATH environment variable\n");
			}
		}
	}

	normalize_path(path);
	char *result = NULL;

	if(found)
	{
		int suffix_len;
		int path_len;

		suffix_len = strlen(PATH_SUFFIX);
		path_len = strlen(path);

		if(suffix_len <= path_len)
		{
			if(strcmp(PATH_SUFFIX, &path[path_len - suffix_len]) == 0)
			{
				/* Oki valid path add a NUL */
				path[path_len - suffix_len] = 0;
				result = path;
			}
			else
			{
				fprintf(stderr, "Error, invalid suffix on the end of the path. Should be %s\n", PATH_SUFFIX);
			}
		}
		else
		{
			fprintf(stderr, "Error, path not large enough for creating the freetype path\n");
		}

	}
	free(writableName);

	return result;
}

void print_path(char *name)
{
	char *pspdev_env = find_path(name);

	if (pspdev_env != NULL) {
		switch(g_configmode)
		{
			case FT_CONFIG_PREFIX :
				printf(pspdev_env);
				if(strlen(PREFIX) > 0)
					printf("/%s", PREFIX);
				printf("\n");
				exit(0);
			case FT_CONFIG_EXEC_PREFIX :
				printf(pspdev_env);
				if(strlen(PREFIX) > 0)
					printf("/%s", EXEC_PREFIX);
				printf("\n");
				exit(0);
			case FT_CONFIG_VERSION :
				printf("%s\n", "9.8.3");
				exit(0);
			case FT_CONFIG_FTVERSION :
				printf("%s\n", FTVERSION);
				exit(0);
			case FT_CONFIG_LIB:
				printf("-L%s/psp/lib -lfreetype ", pspdev_env);
				break;
			case FT_CONFIG_LIBTOOL :
				printf("-L%s/psp/lib/libfreetype.la ", pspdev_env);
				break;
			case FT_CONFIG_CFLAGS :
				printf("-I%s/psp/include/freetype2 ", pspdev_env);
				break;
			default : fprintf(stderr, "Error, invalida configuration mode\n");
					  break;
		};
	}
}

int main(int argc, char **argv)
{
	if(process_args(argc, argv))
	{
		printf("\n");
	}
	else
	{
		print_help();
	}

	return 0;
}
