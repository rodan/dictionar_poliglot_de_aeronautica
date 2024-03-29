
PROJ = dpa

TLPI_DIR  = ../lib/tlpi-lib
TLPI_SRC  = ${TLPI_DIR}/error_functions.cpp ${TLPI_DIR}/get_num.cpp
TLPI_OBJ  = $(patsubst ${TLPI_DIR}/%.cpp,build/lib/tlpi/%.o,${TLPI_SRC})

SD_DIR    = ../lib/stardict
SD_SRC    = ${SD_DIR}/ifo_file.cpp ${SD_DIR}/lib_binary_dict_parser.cpp ${SD_DIR}/lib_chars.cpp ${SD_DIR}/lib_dict_data_block.cpp ${SD_DIR}/lib_dict_verify.cpp ${SD_DIR}/lib_res_store.cpp ${SD_DIR}/libcommon.cpp
SD_OBJ    = $(patsubst ${SD_DIR}/%.cpp,build/lib/stardict/%.o,${SD_SRC})

LIBS_OBJ = $(TLPI_OBJ) $(SD_OBJ)

INCLUDES  := -I ./ -I $(TLPI_DIR) -I $(SD_DIR) $(shell pkgconf --cflags glib-2.0) $(shell pkgconf --cflags libxml-2.0)
LOCAL_SRC := dpa.cpp
SRC        = $(LOCAL_SRC) $(TLPI_SRC) $(SD_SRC)
#EXOBJECT   = $(PROJ).o
EXOUTPUT   = $(PROJ)
LOCAL_OBJECTS     = $(patsubst %.cpp,build/%.o,${LOCAL_SRC})

LOCAL_SQLFILE_SRC = sqlfile.cpp dpa_helper.cpp
LOCAL_SQLFILE_OBJ = $(patsubst %.cpp,build/%.o,${LOCAL_SQLFILE_SRC})

# Append specific CFLAGS/LDFLAGS
CFLAGS_REL	 += -O3
LDFLAGS_REL	 += -Wl,-s
CFLAGS_DBG	 += -O1 -ggdb -DNDEBUG # -pg
LDFLAGS_DBG	 += # -pg

TARGET_CFLAGS=-fPIC -pedantic -Wall -Wextra -Wno-write-strings -Wno-type-limits -Wno-format-truncation -Wno-deprecated-copy -Wno-format-security -Wa,-ahl=$(@:.o=.s)
TARGET_LDFLAGS=$(shell pkgconf --libs sqlite3)

DEBUG := $(shell grep "^#define CONFIG_DEBUG" config.h)
ifeq ($(DEBUG),)
TARGET	:= RELEASE
TARGET_CFLAGS	+= $(CFLAGS_REL)
TARGET_LDFLAGS	+= $(LDFLAGS_REL)
else
TARGET	:= DEBUG
TARGET_CFLAGS	+= $(CFLAGS_DBG)
TARGET_LDFLAGS	+= $(LDFLAGS_DBG)
endif

TARGET_CXXFLAGS+=-std=c++17

#COVERITY_SCAN_TOKEN := $(shell cat ../.secrets.COVERITY_SCAN_TOKEN)

.PHONY: all
.PHONY: clean
.PHONY: tags
.PHONY: lib

all : libs $(EXOUTPUT) stardict-sqlfile
libs : $(LIBS_OBJ)
$(EXOUTPUT) : libs

version.h: $(SRC)
	@./tools/setver.sh

build/lib/tlpi/%.o: ${TLPI_DIR}/%.cpp
	@mkdir -p build/lib/tlpi
	@echo -e " * $(@F)"
	@$(CXX) $(INCLUDES) $(TARGET_CFLAGS) $(TARGET_CXXFLAGS) -c $< -o $@

build/lib/stardict/%.o: ${SD_DIR}/%.cpp
	@mkdir -p build/lib/stardict
	@echo -e " * $(@F)"
	@$(CXX) $(INCLUDES) $(TARGET_CFLAGS) $(TARGET_CXXFLAGS) -c $< -o $@

build/%.o: %.cpp
	@mkdir -p build
	@echo -e " * $(@F)"
	@$(CXX) $(INCLUDES) $(TARGET_CFLAGS) $(TARGET_CXXFLAGS) -c $< -o $@

%.o: %.cpp
	@echo -e " * $(@F)"
	@$(CXX) $(INCLUDES) $(TARGET_CFLAGS) $(TARGET_CXXFLAGS) -c $< -o $@

%.o: %.c
	@echo -e " * $(@F)"
	@$(CC) $(INCLUDES) $(TARGET_CFLAGS) -c $< -o $@

$(EXOUTPUT): $(LOCAL_OBJECTS) $(TLPI_OBJ)
	@echo -e "\n>> Building $@ as target $(TARGET)"
	@$(CXX) $(TARGET_LDFLAGS) $(LOCAL_OBJECTS) $(TLPI_OBJ) -o $@ && size $@

stardict-sqlfile: $(LOCAL_SQLFILE_OBJ) $(TLPI_OBJ) $(SD_OBJ)
	@echo -e "\n>> Building tool sqlfile $@ as target $(TARGET)"
	@$(CXX) $(TARGET_LDFLAGS) $(LOCAL_SQLFILE_OBJ) $(TLPI_OBJ) $(SD_OBJ) $(shell pkgconf --libs glib-2.0) $(shell pkgconf --libs libxml-2.0) $(shell pkgconf --libs zlib) -o $@ && size $@

clean :
	@${RM} build/*.o build/*.s ${PROJ} stardict-sqlfile build/*.dict.dz build/*.index build/*.txt
	@${RM} -rf cov-int

clean-lib:
	@${RM} -rf build/lib

tags: $(SRCS)
	@echo "Generating tags .."
	@exuberant-ctags -R

cppcheck: $(PROJ)
	@cppcheck --quiet --force --enable=warning --enable=performance --enable=information --enable=performance --enable=portability -I ./ ./

scan-build: clean
	@scan-build make

coverity: clean clean-lib
	@cov-build --dir cov-int make
	@tar czvf /tmp/$(PROJ).tgz cov-int
	@curl --form token=$(COVERITY_SCAN_TOKEN) \
	  --form email=2b4eda@subdimension.ro \
	  --form file=@/tmp/$(PROJ).tgz \
	  --form version="$(shell ./tools/getver.sh -i ./version.h -t MAJ.MINbBUILD)" \
	  --form description="Description" \
	  https://scan.coverity.com/builds?project=rodan%2Fthpp

force_look:
	@true
