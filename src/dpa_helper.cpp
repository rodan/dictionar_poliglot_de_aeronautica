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

extern char keyword_lng_str[3];

void die(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    fprintf(stderr, "\n");
    fflush(stderr);
    exit(1);
}

uint16_t lng_to_int(char *buf)
{
    if (buf == 0) {
        return 0;
    }

    if (memcmp(buf, "ek", 2) == 0) {
        return D_EK;
    } else if (memcmp(buf, "ed", 2) == 0) {
        return D_ED;
    } else if (memcmp(buf, "rk", 2) == 0) {
        return D_RK;
    } else if (memcmp(buf, "rpk", 3) == 0) {
        return D_RK;
    } else if (memcmp(buf, "rd", 2) == 0) {
        return D_RD;
    } else if (memcmp(buf, "fk", 2) == 0) {
        return D_FK;
    } else if (memcmp(buf, "ik", 2) == 0) {
        return D_IK;
    } else if (memcmp(buf, "sk", 2) == 0) {
        return D_SK;
    } else if (memcmp(buf, "gk", 2) == 0) {
        return D_GK;
    }

    return 0;
}

uint8_t lng_to_str(const uint16_t lng_id, char *lng)
{
    switch (lng_id) {
    case D_EK:
        strncpy(lng, "en", 3);
        break;
    case D_ED:
        strncpy(lng, "en", 3);
        break;
    case D_RK:
        strncpy(lng, "ro", 3);
        break;
    case D_RD:
        strncpy(lng, "ro", 3);
        break;
    case D_FK:
        strncpy(lng, "fr", 3);
        break;
    case D_IK:
        strncpy(lng, "it", 3);
        break;
    case D_SK:
        strncpy(lng, "es", 3);
        break;
    case D_GK:
        strncpy(lng, "de", 3);
        break;
    default:
        lng[0] = 0;
        break;
    }

    return EXIT_SUCCESS;
}

void my_strstrip(char *str)
{
    char *p1, *p2;
    p1 = str;
    p2 = str;
    while (*p1 != '\0') {
        if (*p1 == '\\') {
            p1++;
            if (*p1 == 'n') {
                *p2 = '\n';
                p2++;
                p1++;
                continue;
            } else if (*p1 == '\\') {
                *p2 = '\\';
                p2++;
                p1++;
                continue;
            } else if (*p1 == 't') {
                *p2 = '\t';
                p2++;
                p1++;
                continue;
            } else if (*p1 == '\0') {
                g_warning("Warning: end by \\.");
                *p2 = '\\';
                p2++;
                continue;
            } else {
                g_warning("Warning: \\%c is unsupported escape sequence.", *p1);
                *p2 = '\\';
                p2++;
                *p2 = *p1;
                p2++;
                p1++;
                continue;
            }
        } else {
            *p2 = *p1;
            p2++;
            p1++;
            continue;
        }
    }
    *p2 = '\0';
}


void print_buf(uint8_t *data, const uint16_t size)
{
    uint16_t bytes_remaining = size;
    uint16_t bytes_to_be_printed, bytes_printed = 0;
    uint16_t i;

    while (bytes_remaining > 0) {

        if (bytes_remaining > 16) {
            bytes_to_be_printed = 16;
        } else {
            bytes_to_be_printed = bytes_remaining;
        }

        printf("%08x: ", bytes_printed);

        for (i = 0; i < bytes_to_be_printed; i++) {
            printf("%02x", data[bytes_printed + i]);
            if (i & 0x1) {
                printf(" ");
            }
        }

        printf("\n");
        bytes_printed += bytes_to_be_printed;
        bytes_remaining -= bytes_to_be_printed;
    }
}

gint comparefunc(gconstpointer a, gconstpointer b)
{
    gint x;
    x = stardict_strcmp(((struct dict_item_t *)a)->keyword, ((struct dict_item_t *)b)->keyword);
    if (x == 0)
        return ((struct dict_item_t *)a)->definition - ((struct dict_item_t *)b)->definition;
    else
        return x;
}

bool write_dictionary(const char *filename, GArray *array)
{
    glib::CharStr basefilename(g_path_get_basename(filename));
    gchar *ch = strrchr(get_impl(basefilename), '.');
    if (ch)
        *ch = '\0';
    glib::CharStr dirname(g_path_get_dirname(filename));

    const std::string fullbasefilename = build_path(get_impl(dirname), get_impl(basefilename));
    const std::string ifofilename = fullbasefilename + ".ifo";
    const std::string idxfilename = fullbasefilename + ".idx";
    const std::string dicfilename = fullbasefilename + ".dict";
    clib::File ifofile(g_fopen(ifofilename.c_str(), "wb"));
    if (!ifofile) {
        g_critical("Write to ifo file %s failed!", ifofilename.c_str());
        return false;
    }
    clib::File idxfile(g_fopen(idxfilename.c_str(), "wb"));
    if (!idxfile) {
        g_critical("Write to idx file %s failed!", idxfilename.c_str());
        return false;
    }
    clib::File dicfile(g_fopen(dicfilename.c_str(), "wb"));
    if (!dicfile) {
        g_critical("Write to dict file %s failed!", dicfilename.c_str());
        return false;
    }

    guint32 offset_old;
    guint32 tmpglong;
    struct dict_item_t *pdict_item;
    gint definition_len;
    gint keyword_len;
    gulong i;
    for (i = 0; i < array->len; i++) {
        pdict_item = &g_array_index(array, struct dict_item_t, i);
        definition_len = strlen(pdict_item->definition);
        keyword_len = strlen(pdict_item->keyword);
        //fwrite(pdict_item->keyword, sizeof(gchar), keyword_len, get_impl(dicfile));
        //fwrite("\n", sizeof(gchar), 1, get_impl(dicfile));
        offset_old = ftell(get_impl(dicfile));
        fwrite(pdict_item->definition, 1, definition_len, get_impl(dicfile));
        fwrite(pdict_item->keyword, sizeof(gchar), keyword_len + 1, get_impl(idxfile));
        tmpglong = g_htonl(offset_old);
        fwrite(&(tmpglong), sizeof(guint32), 1, get_impl(idxfile));
        tmpglong = g_htonl(definition_len);
        fwrite(&(tmpglong), sizeof(guint32), 1, get_impl(idxfile));
    }
    idxfile.reset(NULL);
    dicfile.reset(NULL);

    g_message("%s wordcount: %d.", get_impl(basefilename), array->len);

#ifndef _WIN32
    std::stringstream command;
    command << "dictzip \"" << dicfilename << "\"";
    int result;
    result = system(command.str().c_str());
    if (result == -1) {
        g_print("system() error!\n");
    }
#endif

    stardict_stat_t stats;
    g_stat(idxfilename.c_str(), &stats);
    fprintf(get_impl(ifofile), "StarDict's dict ifo file\nversion=2.4.2\nwordcount=%d\n"
            "idxfilesize=%ld\nbookname=Dicționar poliglot de aeronautică (%s)\nsametypesequence=m\n", array->len, (long)stats.st_size, keyword_lng_str);
    return true;
}


