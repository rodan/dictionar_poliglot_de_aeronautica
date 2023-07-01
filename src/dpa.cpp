
#include <ctype.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

void die(char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    fprintf(stderr, "\n");
    fflush(stderr);
    exit(1);
}

void usage()
{
    printf(" dpa -d db_file [-e] [-w] -l <search term> -i <lang> -o <lang> [-h]\n\n \
options: \n \
   -d        path to db file\n \
   -e        do exact match search\n \
   -l [term] lookup term\n \
   -i [lang] input language\n \
   -o [lang] output languages (delimited by ,)\n \
   -h        help\n \
lang can be one of:\n \
   ek        english keyword\n \
   ed        english definition\n \
   rk        romanian keyword\n \
   rd        romanian definition\n \
   fk        french keyword\n \
   ik        italian keyword\n \
   sk        spanish keyword\n \
   gk        german keyword\n");
}

static int callback(void *NotUsed, int argc, char **argv, char **azColName)
{
    int i;
    for (i = 0; i < argc; i++) {
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}

int main(int argc, char **argv)
{
    sqlite3 *db;
    char *zErrMsg = 0;
    int rc;

    int exact_match = 0;
    char *lookup = NULL;
    char *inlng = NULL;
    char *outlng = NULL;
    char *dbfile = NULL;
    int c;
    char buff[200];
    char lookupbuff[100];

    opterr = 0;

    if (argc < 6) {
        usage();
        die("");
    }

    while ((c = getopt(argc, argv, "hed:l:i:o:")) != -1)
        switch (c) {
        case 'h':
            usage();
            break;
        case 'e':
            exact_match = 1;
            break;
        case 'd':
            dbfile = optarg;
            break;
        case 'l':
            lookup = optarg;
            break;
        case 'i':
            inlng = optarg;
            break;
        case 'o':
            outlng = optarg;
            break;
        default:
            die("woot");
        }

    //die("l:%s,i:%s,o:%s,e:%d,",lookup,inlng,outlng,exact_match);
    if (exact_match) {
        snprintf(lookupbuff, 100, "%s", lookup);
    } else
        snprintf(lookupbuff, 100, "%%%s%%", lookup);

    snprintf(buff, 200, "select %s from defs where %s like '%s';", outlng, inlng, lookupbuff);

    rc = sqlite3_open(dbfile, &db);
    if (rc) {
        die("Can't open database: %s\n", sqlite3_errmsg(db));
        //sqlite3_close(db);
    }
    rc = sqlite3_exec(db, buff, callback, 0, &zErrMsg);
    if (rc != SQLITE_OK) {
        die("SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
    sqlite3_close(db);
    return 0;
}
