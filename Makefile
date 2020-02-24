OPENRESTY_PREFIX=/usr/local/Cellar/openresty/1.15.8.2
NGINX_PATH=nginx/sbin

INSTALL ?= install

.PHONY: all test install

all: ;

install: all
	$(INSTALL) -d t/servroot/
	$(INSTALL) *.lua t/servroot/

local_build:
	jet steps

test: all
	PATH=$(OPENRESTY_PREFIX)/$(NGINX_PATH):$$PATH prove -v -r t
