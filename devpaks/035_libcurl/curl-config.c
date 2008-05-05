#include <windows.h>

#include <stdio.h>
#include <getopt.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define PATH_ENV "PATH"

#ifndef MAX_PATH
#define MAX_PATH 256
#endif

/* Might need to change these for different platforms */
#define PATH_SEP ":"
#define DIR_SEP '/'
#define DIR_SEP_STR "/"

/* The suffix to the path to strip off, if this is not there then we have an error */
#define PATH_SUFFIX "/bin/curl-config.exe"
/************************/

enum CURLConfigMode
{
	CURL_CONFIG_UNKNOWN,
	CURL_CONFIG_CC,
	CURL_CONFIG_CA,
	CURL_CONFIG_CFLAGS,
	CURL_CONFIG_FEATURES,
	CURL_CONFIG_PROTOCOLS,
	CURL_CONFIG_HELP,
	CURL_CONFIG_LIBS,
	CURL_CONFIG_PREFIX,
	CURL_CONFIG_VERSION,
	CURL_CONFIG_VERNUM
};

/* Specifies that the current usage is to the print the pspsdk path */
static enum CURLConfigMode g_configmode;

static struct option arg_opts[] = 
{
	{"cc", no_argument, NULL, 'c'},
	{"ca", no_argument, NULL, 'C'},
	{"cflags", no_argument, NULL, 'f'},
	{"features", no_argument, NULL, 'F'},
	{"protocols",  no_argument, NULL, 'P'},
	{"help", no_argument, NULL, 'h'},
	{"libs", no_argument, NULL, 'l'},
	{"prefix", no_argument, NULL, 'p'},
	{"version",  no_argument, NULL, 'v'},
	{"vernum", no_argument, NULL, 'V'},
	{ NULL, 0, NULL, 0 }
};

void print_path(char *name);

/* Process the arguments */
int process_args(int argc, char **argv)
{
	int ret = 0;
	int ch;

	g_configmode = CURL_CONFIG_UNKNOWN;

	// this will store the fully-qualified path
	char psp_config_path[MAX_PATH] = "";

	// fetch the path of the executable
	if(GetModuleFileName(0, psp_config_path, sizeof(psp_config_path) - 1) == 0)
	{
		// fall back
		strcpy(psp_config_path, argv[0]);
	}
	
	ch = getopt_long(argc, argv, "cCfFPhlpvV", arg_opts, NULL);
	while(ch != -1)
	{
		switch(ch)
		{
			case 'c' : g_configmode = CURL_CONFIG_CC;
					   ret = 1;
					   break;
			case 'C' : g_configmode = CURL_CONFIG_CA;
					   ret = 1;
					   break;
			case 'f' : g_configmode = CURL_CONFIG_CFLAGS;
					   ret = 1;
					   break;
			case 'F' : g_configmode = CURL_CONFIG_FEATURES;
					   ret = 1;
					   break;
			case 'P' : g_configmode = CURL_CONFIG_PROTOCOLS;
					   ret = 1;
					   break;
			case 'h' : g_configmode = CURL_CONFIG_HELP;
					   ret = 1;
					   break;
			case 'l' : g_configmode = CURL_CONFIG_LIBS;
					   ret = 1;
					   break;
			case 'p' : g_configmode = CURL_CONFIG_PREFIX;
					   ret = 1;
					   break;
			case 'v' : g_configmode = CURL_CONFIG_VERSION;
					   ret = 1;
					   break;
			case 'V' : g_configmode = CURL_CONFIG_VERNUM;
					   ret = 1;
					   break;
			default  : fprintf(stderr, "Invalid option '%c'\n", ch);
					   break;
		};
		
		print_path(psp_config_path);

		// fetch the next item
		ch = getopt_long(argc, argv, "cCfFPhlpvV", arg_opts, NULL);
	}

	return ret;
}

void print_help(int err)
{
	FILE * file;
	
	if(err) {
		file = stderr;
	} else {
		file = stdout;
	}
	fprintf(file, "Usage: curl-config [OPTION]\n\
Available values for OPTION include:\n\
  --ca        ca bundle install path\n\
  --cc        compiler\n\
  --cflags    pre-processor and compiler flags\n\
  --features  newline separated list of enabled features\n\
  --protocols newline separated list of enabled protocols\n\
  --help      display this help and exit\n\
  --libs      library linking information\n\
  --prefix    curl install prefix\n\
  --version   output version information\n\
  --vernum    output the version information as a number (hexadecimal)\n");
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
			fprintf(stderr, "Error, path not large enough for creating the SDL path\n");
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
			case CURL_CONFIG_CC :
				printf("psp-gcc ");
				break;
			case CURL_CONFIG_CA :
				printf("");
				break;
			case CURL_CONFIG_CFLAGS :
				printf("-I%s%cpsp%cinclude ", pspdev_env, DIR_SEP, DIR_SEP);
				break;
			case CURL_CONFIG_FEATURES :
				printf("");
				break;
			case CURL_CONFIG_PROTOCOLS :
				printf("HTTP\n");
				printf("FTP\n");
				printf("GOPHER\n");
				printf("TELNET\n");
				printf("FILE\n");
				printf("LDAP\n");
				printf("DICT\n");
				printf("TFTP");
				break;
			case CURL_CONFIG_HELP :
				print_help(0);
				exit(0);
			case CURL_CONFIG_LIBS :
				printf("-L%s%cpsp%clib -lcurl -L%s%cpsp%csdk%clib -lc -lpspnet_inet -lpspnet_resolver -lpspuser ", pspdev_env, DIR_SEP, DIR_SEP, pspdev_env, DIR_SEP, DIR_SEP, DIR_SEP);
				break;
			case CURL_CONFIG_PREFIX :
				printf("%s\n", pspdev_env);
				exit(0);
			case CURL_CONFIG_VERSION :
				printf("libcurl 7.15.1\n");
				exit(0);
			case CURL_CONFIG_VERNUM :
				printf("070f01\n");
				exit(0);
			default :
				fprintf(stderr, "Error, invalid configuration mode\n");
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
		print_help(1);
	}

	return 0;
}
