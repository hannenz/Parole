PACKAGES 	= glib-2.0 gtk+-3.0 granite libxml-2.0 libarchive gpgme
SOURCES 	= $(wildcard src/*.vala)

#CC 			= gcc
VALAC 		= valac
#CFLAGS 		= -W -Wall
VALAFLAGS	= --target-glib=2.38 -X -lssl -X -lcrypto -X -lgmp -X -g --save-temps
#LDFLAGS		=

VALAFLAGS 	+= $(PACKAGES:%=--pkg=%)
#CFLAGS 		+= $(shell pkg-config --cflags $(PACKAGES))
#LDFLAGS 	+= $(shell pkg-config --libs $(PACKAGES))

#CSOURCES 	= $(SOURCES:.vala=.c)
#OBJS 		= $(CSOURCES:.c=.o)

# parole: $(OBJS)
# 	$(CC) $^ -o $@ $(LDFLAGS)

# %.o: %.c
#  	$(CC) $^ -c -o $@ -fPIC $(CFLAGS)

# %.c: %.vala
#  	$(VALAC) $^ -C -o $@ $(VALAFLAGS)

parole:	$(SOURCES) src/generator.c src/resources.c
	$(VALAC) -o parole $^  $(VALAFLAGS) --gresources data/parole.gresource.xml 

src/resources.c: data/window.ui data/parole.gresource.xml data/parole.css
	cd data ; glib-compile-resources parole.gresource.xml --target=../src/resources.c --generate-source

