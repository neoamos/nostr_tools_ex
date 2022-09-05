# Erlang libraries
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

# secp256k1 libraries
CFLAGS += -I src/secp256k1 -I src/secp256k1/src -I src/secp256k1/include

CFLAGS += -fPIC
LDFLAGS += src/secp256k1/.libs/libsecp256k1.a -lgmp

all: src/secp256k1/.libs/libsecp256k1.so priv/schnorr.so

priv/schnorr.so: src/utils.h src/schnorr.c
	$(CC) $(CFLAGS) -shared -o $@ src/utils.h src/schnorr.c $(LDFLAGS)

src/secp256k1/.libs/libsecp256k1.so:
	cd src/secp256k1 && \
	  ./autogen.sh &&	\
		./configure --enable-module-ecdh --enable-module-recovery --enable-module-extrakeys --enable-module-schnorrsig --enable-examples
	$(MAKE) -C src/secp256k1
