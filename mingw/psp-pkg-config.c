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

/* Might need to change these for different platforms */
#define PATH_SEP ":"
#define DIR_SEP '/'
#define DIR_SEP_STR "/"

/* The suffix to the path to strip off, if this is not there then we have an error */
#ifdef __WIN32
#define PATH_SUFFIX "/bin/psp-pkg-config.exe"
#else
#define PATH_SUFFIX "/bin/psp-pkg-config"
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/************************/

enum ConfigMode
{
  CONFIG_UNKNOWN,
//  CONFIG_MODVERSION,
  CONFIG_HELP,
  CONFIG_PRINT_ERRORS,
//  CONFIG_SILENCE_ERRORS,
  CONFIG_CFLAGS,
  CONFIG_LIBS,
//  CONFIG_LIBS_ONLY_LCAP,
//  CONFIG_LIBS_ONLY_LSMALL,
//  CONFIG_CFLAGS_ONLY_I,
//  CONFIG_VARIABLE,
//  CONFIG_DEFINE_VARIABLE,
//  CONFIG_PRINT_VARIABLES,
//  CONFIG_UNINSTALLED,
  CONFIG_EXISTS,
  CONFIG_ATLEAST_VERSION,
  CONFIG_EXACT_VERSION,
  CONFIG_MAX_VERSION,
//  CONFIG_LIST_ALL,
//  CONFIG_PRINT_PROVIDES,
//  CONFIG_PRINT_REQUIRES,
//  CONFIG_PRINT_REQUIRES_PRIVATE,
  CONFIG_ERRORS_TO_STDOUT
};

/* action */
static enum ConfigMode g_configmode;
/* flags */
static int g_printerrors;
static int g_errors_to_stdout;
/* libs to analyze */
static char **g_libraries;
static int g_librariesc;

void print_help(int);
int process_exists();
int process_cflags(char *);
int process_libs(char *);
/* helpers */
char *find_path(char *);

/* Process the arguments */
int process_args(int argc, char **argv)
{
  int i;
  int ret = 0;
  
  g_printerrors = FALSE;
  g_errors_to_stdout = FALSE;
  g_configmode = CONFIG_UNKNOWN;
  g_librariesc = 0;

  /* this will store the fully-qualified path */
  char psp_config_path[MAX_PATH] = "";

  /* fetch the path of the executable */
#ifdef __WIN32
  if(GetModuleFileName(0, psp_config_path, sizeof(psp_config_path) - 1) == 0)
  {
    /* fall back */
    strcpy(psp_config_path, argv[0]);
  }
#else
  strcpy(psp_config_path, argv[0]);
#endif
  
  for(i = 1; i<argc; i++)
  {
    if(strcmp("--help", argv[i]) == 0) {
      print_help(0);
      return 0;
    }
    if(strcmp("--print-errors", argv[i]) == 0) {
      g_printerrors = TRUE;
      continue;
    }
    if(strcmp("--exists", argv[i]) == 0) {
      g_configmode = CONFIG_EXISTS;
      continue;
    }
    if(strcmp("--cflags", argv[i]) == 0) {
      g_configmode = CONFIG_CFLAGS;
      continue;
    }
    if(strcmp("--libs", argv[i]) == 0) {
      g_configmode = CONFIG_LIBS;
      continue;
    }
    if(strcmp("--errors-to-stdout", argv[i]) == 0) {
      g_printerrors = TRUE;
      g_errors_to_stdout = TRUE;
      continue;
    }
    /* Ignore version checks */
    if(strcmp("--atleast-version", argv[i]) == 0) {
      return EXIT_SUCCESS;
    }
    if(strcmp("--atleast-pkgconfig-version", argv[i]) == 0) {
      return EXIT_SUCCESS;
    }
    if(strcmp("--exact-version", argv[i]) == 0) {
      return EXIT_SUCCESS;
    }
    if(strcmp("--max-version", argv[i]) == 0) {
      return EXIT_SUCCESS;
    }
    g_librariesc++;
  }
  
  g_libraries = argv + (argc - g_librariesc);
  char *pspdev_env = find_path(psp_config_path);
  
  switch(g_configmode)
  {
    case CONFIG_EXISTS:
      return process_exists();
    case CONFIG_CFLAGS:
      return process_cflags(pspdev_env);
    case CONFIG_LIBS:
      return process_libs(pspdev_env);
    default :
      return EXIT_FAILURE;
  }
        
  return ret;
}

void print_help(int err)
{
  fprintf((err ? stdout : stderr), "Usage: psp-pkg-config [OPTION...]\nThis ia hack for the minpspw-project it is not complete and may break other projects.\n");
}

void print_error(const char* fmt, void* arg) {
  if(g_printerrors)
  {
    fprintf((g_errors_to_stdout ? stdout : stderr), fmt, arg);
  }
}

int process_exists() {
  int i;
  for(i=0; i<g_librariesc; i++)
  {
    if(strstr(g_libraries[i], "ogg"))
    {
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "sdl"))
    {
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "libpng"))
    {
      return EXIT_SUCCESS;
    }
    print_error("Package %s was not found in the pkg-config search path.\n", g_libraries[i]);
    print_error("No package '%s' found\n", g_libraries[i]);
    return EXIT_FAILURE;
  }
  return EXIT_FAILURE;
}

int process_cflags(char *pspdev_env) {
  int i;
  for(i=0; i<g_librariesc; i++)
  {
    if(strstr(g_libraries[i], "ogg"))
    {
      printf("-I%s%cpsp%cinclude\n", pspdev_env, DIR_SEP, DIR_SEP);
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "libpng"))
    {
      printf("-I%s%cpsp%cinclude\n", pspdev_env, DIR_SEP, DIR_SEP);
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "sdl"))
    {
      printf("-I%s%cpsp%cinclude%cSDL -Dmain=SDL_main\n", pspdev_env, DIR_SEP, DIR_SEP, DIR_SEP);
      return EXIT_SUCCESS;
    }

    print_error("Package %s was not found in the pkg-config search path.\n", g_libraries[i]);
    print_error("No package '%s' found\n", g_libraries[i]);
    return EXIT_FAILURE;
  }
  return EXIT_FAILURE;
}

int process_libs(char *pspdev_env) {
  int i;
  for(i=0; i<g_librariesc; i++)
  {
    if(strstr(g_libraries[i], "ogg"))
    {
      printf("-L%s/psp/lib -logg\n", pspdev_env);
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "libpng"))
    {
      printf("-L%s/psp/lib -lpng\n", pspdev_env);
      return EXIT_SUCCESS;
    }
    if(strstr(g_libraries[i], "sdl"))
    {
      printf("-L%s/psp/lib -lSDLmain -lSDL -lm -lGL -lpspvfpu -L%s/psp/sdk/lib -lpspirkeyb -lpsppower -lpspdebug -lpspgu -lpspctrl -lpspge -lpspdisplay -lpsphprm -lpspsdk -lpsprtc -lpspaudio -lc -lpspuser -lpsputility -lpspkernel -lpspnet_inet\n", pspdev_env, pspdev_env);
      return EXIT_SUCCESS;
    }
    print_error("Package %s was not found in the pkg-config search path.\n", g_libraries[i]);
    print_error("No package '%s' found\n", g_libraries[i]);
    return EXIT_FAILURE;
  }
  return EXIT_FAILURE;
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
      fprintf(stderr, "Error, path not large enough for creating the path variable\n");
    }

  }
  free(writableName);

  return result;
}

int main(int argc, char **argv)
{
  if(process_args(argc, argv))
  {
    printf("\n");
  }

  return 0;
}
