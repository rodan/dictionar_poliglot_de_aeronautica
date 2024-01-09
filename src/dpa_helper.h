#ifndef __DPA_HELPER_H__
#define __DPA_HELPER_H__

#define  DBUFF_SZ  8000000
#define  LBUFF_SZ  4096

#define D_KEYWORD  0x0001
#define      D_EK  0x0002
#define      D_ED  0x0004
#define      D_RK  0x0008
#define      D_RD  0x0010
#define      D_FK  0x0020
#define      D_IK  0x0040
#define      D_SK  0x0080
#define      D_GK  0x0100

#define EXPORT_STARDICT  0x01
#define     EXPORT_MOBI  0x02

struct dict_item_t {
    char *keyword;
    char *definition;
};

void die(const char *fmt, ...);
uint16_t lng_to_int(char *buf);
uint8_t lng_to_str(const uint16_t lng_id, char *lng);
void my_strstrip(char *str);
void print_buf(uint8_t *data, const uint16_t size);
gint comparefunc(gconstpointer a, gconstpointer b);
bool write_dictionary(const char *filename, GArray *array);

#endif
