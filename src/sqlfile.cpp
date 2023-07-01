/*
program that takes an sqlite3 file containing the multilingual aeronautical dictionary and converts it to stardict format
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include <unistd.h>
#include <sqlite3.h>
#include <locale.h>
#include <sstream>
#include <glib.h>

#include "libcommon.h"
#include "dpa_helper.h"

char buff_l0[LBUFF_SZ];
char buff_l1[LBUFF_SZ];
char buff_sql[LBUFF_SZ];
char keyword_lng_str[4] = {};

uint32_t buff_fill = 0;
uint16_t last_lng = 0;
uint16_t cur_lng = 0;
char *dict_buffer = NULL;
char *dict_ptr = NULL;
uint32_t dict_keyword_cnt = 0;
GArray *array;

void show_usage()
{
    printf(" dpa -d db_file -i <lang> -o <lang> [-h]\n\n \
options: \n \
   -d        path to db file\n \
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

static int callback(void *, int argc, char **argv, char **azColName)
{
    int i;
    uint16_t str_len;
    struct dict_item_t dict_item = { };
    char hrl[3];                // human readable language

    for (i = 0; i < argc; i++) {
        memset(buff_l0, 0, LBUFF_SZ);
        memset(buff_l1, 0, LBUFF_SZ);
        memset(hrl, 0, 3);

        snprintf(buff_l0, LBUFF_SZ, argv[i]);
        my_strstrip(buff_l0);
        g_strstrip(buff_l0);

        cur_lng = lng_to_int(azColName[i]);

        if (i == 0) {
            dict_item.keyword = dict_buffer + buff_fill;
            cur_lng |= D_KEYWORD;
            snprintf(buff_l1, LBUFF_SZ, "%s", buff_l0);
            str_len = strlen(buff_l1) + 1;      // add a zero at the end
        } else {
            if (i == 1) {
                dict_item.definition = dict_buffer + buff_fill;
            }
            if (((cur_lng == D_RD) && (last_lng == D_RK)) || ((cur_lng == D_ED) && (last_lng == D_EK))) {
                snprintf(buff_l1, LBUFF_SZ, "; %s\n", buff_l0);
                buff_fill--;    // remove last '\n'
            } else {
                lng_to_str(cur_lng, hrl);
                snprintf(buff_l1, LBUFF_SZ, " (%s) %s\n", hrl, buff_l0);
            }
            str_len = strlen(buff_l1);
        }
        memcpy(dict_buffer + buff_fill, buff_l1, str_len);
        buff_fill += str_len;
        last_lng = cur_lng;
    }
    // add a zero at the end of the definition
    buff_fill += 1;

    if (dict_item.definition == 0x0) {
        fprintf(stderr, "broken definition\n");
        return 0;
    }
    if (dict_item.keyword == 0x0) {
        fprintf(stderr, "broken keyword\n");
        return 0;
    }

    g_array_append_val(array, dict_item);

    return 0;
}

static int callback_cnt(void *, int argc, char **argv, char **)
{
    if (argc != 1) {
        return 1;
    }

    dict_keyword_cnt = strtol(argv[0], NULL, 10);
    //printf("got %u\n", dict_keyword_cnt);
    return 0;
}

int convert_sqlite(char *dbfile, char *lng)
{
    sqlite3 *db;
    int rc;
    char *zErrMsg = 0;
    uint32_t i;

    rc = sqlite3_open(dbfile, &db);
    if (rc) {
        die("Can't open database: %s\n", sqlite3_errmsg(db));
        //sqlite3_close(db);
    }

    snprintf(buff_sql, LBUFF_SZ, "select count(*) from defs;");
    rc = sqlite3_exec(db, buff_sql, callback_cnt, 0, &zErrMsg);
    if (rc != SQLITE_OK) {
        die("SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }

    for (i = 0; i < dict_keyword_cnt; i++) {
        snprintf(buff_sql, LBUFF_SZ, "select %s from defs where id is %u;", lng, i + 1);
        rc = sqlite3_exec(db, buff_sql, callback, 0, &zErrMsg);
        if (rc != SQLITE_OK) {
            die("SQL error: %s at id %u\n", zErrMsg, i + 1);
            sqlite3_free(zErrMsg);
        }
    }

    sqlite3_close(db);
    return EXIT_SUCCESS;
}

#define TITLE_SZ  64

int main(int argc, char *argv[])
{
    uint8_t ret = EXIT_SUCCESS;
    char *dbfile = NULL;
    //char lng[] = "ek, ed, rk, rd, fk, ik, sk, gk";
    char *lng = NULL;
    char title[TITLE_SZ];

    int c;

    if (argc < 3) {
        show_usage();
        die("");
    }

    while ((c = getopt(argc, argv, "hed:l:")) != -1) {
        switch (c) {
        case 'h':
            show_usage();
            break;
        case 'd':
            dbfile = optarg;
            break;
        case 'l':
            lng = optarg;
            break;
        default:
            show_usage();
            die("unknown option");
        }
    }

    if (lng == NULL) {
        show_usage();
        die("language not specified, exiting");
    }

    cur_lng = lng_to_int(lng);

    if (!cur_lng) {
        show_usage();
        die("unknown language specified, exiting");        
    }

    lng_to_str(cur_lng, keyword_lng_str);

    //printf("creating dictionary with %s as keyword language\n", keyword_lng_str);
    snprintf(title, TITLE_SZ, "dictionar_poliglot_de_aeronautica-%s", keyword_lng_str);

    dict_buffer = (char *)calloc(DBUFF_SZ, sizeof(char));
    dict_ptr = dict_buffer;
    array = g_array_sized_new(FALSE, FALSE, sizeof(struct dict_item_t), 20000);

    setlocale(LC_ALL, "");
    convert_sqlite(dbfile, lng);

    g_array_sort(array, comparefunc);

    if (!write_dictionary(title, array)) {
        ret = EXIT_FAILURE;
    }
    //print_buf((uint8_t *)dict_buffer, buff_fill);
    free(dict_buffer);
    g_array_free(array, TRUE);

    return ret;
}
