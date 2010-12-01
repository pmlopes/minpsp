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
#define PATH_SUFFIX "/bin/smpeg-config.exe"
#else
#define PATH_SUFFIX "/bin/smpeg-config"
#endif
/************************/

enum ConfigMode
{
	CONFIG_UNKNOWN,
	CONFIG_PREFIX,
	CONFIG_EXEC_PREFIX,
	CONFIG_VERSION,
	CONFIG_CFLAGS,
	CONFIG_LIB
};

/* Specifies that the current usage is to the print the pspsdk path */
static enum ConfigMode g_configmode;

static struct option arg_opts[] =
{
	{"prefix", optional_argument, NULL, 'p'},
	{"exec-prefix", optional_argument, NULL, 'e'},
	{"version", no_argument, NULL, 'v'},
	{"cflags", no_argument, NULL, 'c'},
	{"libs",  no_argument, NULL, 'l'},
	{ NULL, 0, NULL, 0 }
};

void print_path(char *name);

/* Process the arguments */
int process_args(int argc, char **argv)
{
	int ret = 0;
	int ch;

	g_configmode = CONFIG_UNKNOWN;

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

	ch = getopt_long(argc, argv, "pevclL", arg_opts, NULL);
	while(ch != -1)
	{
		switch(ch)
		{
			case 'p' : g_configmode = CONFIG_PREFIX;
					   ret = 1;
					   break;
			case 'e' : g_configmode = CONFIG_EXEC_PREFIX;
					   ret = 1;
					   break;
			case 'v' : g_configmode = CONFIG_VERSION;
					   ret = 1;
					   break;
			case 'c' : g_configmode = CONFIG_CFLAGS;
					   ret = 1;
					   break;
			case 'l' : g_configmode = CONFIG_LIB;
					   ret = 1;
					   break;
			default  : fprintf(stderr, "Invalid option '%c'\n", ch);
					   break;
		};

		print_path(psp_config_path);

		// fetch the next item
		ch = getopt_long(argc, argv, "pevclL", arg_opts, NULL);
	}

	return ret;
}

void print_help(void)
{
	fprintf(stderr, "Usage: smpeg-config [--prefix[=DIR]] [--exec-prefix[=DIR]] [--version] [--cflags] [--libs]\n");
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
			fprintf(stderr, "Error, path not large enough for creating the smpeg path\n");
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
			case CONFIG_PREFIX :
				puts(pspdev_env);
				if(strlen(PREFIX) > 0)
					printf("/%s", PREFIX);
				printf("\n");
				exit(0);
			case CONFIG_EXEC_PREFIX :
				puts(pspdev_env);
				if(strlen(PREFIX) > 0)
					printf("/%s", EXEC_PREFIX);
				printf("\n");
				exit(0);
			case CONFIG_VERSION :
				printf("%s\n", VERSION);
				exit(0);
			case CONFIG_CFLAGS :
				printf("-I%s/psp/include/smpeg -I%s/psp/include/SDL -Dmain=SDL_main ", pspdev_env, pspdev_env);
				break;
			case CONFIG_LIB:
				printf("-L%s/psp/lib -lsmpeg -lSDLmain -lSDL -lm -lGL -lpspvfpu -L%s/psp/sdk/lib -lpspirkeyb -lpsppower -lpspdebug -lpspgu -lpspctrl -lpspge -lpspdisplay -lpsphprm -lpspsdk -lpsprtc -lpspaudio -lc -lpspuser -lpsputility -lpspkernel -lpspnet_inet ", pspdev_env, pspdev_env);
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
