all: secp256k1

.PHONY: secp256k1
secp256k1:
	$(MAKE) -C apps/secp256k1
