.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

root := $(makefile_dir)

prefix ?= $(abspath $(root)/usr)

nproc := $(shell getconf _NPROCESSORS_ONLN)

pkg_config_path := $(abspath $(prefix)/lib/pkgconfig)

zlib_version := 1.3.1
zlib_configs := $(strip \
  --static \
)

libiconv_version := 1.17
libiconv_configs := $(strip \
  --enable-static \
  --disable-shared \
  --enable-extra-encodings \
  --disable-rpath \
)

curl_version := 8.11.1
curl_configs := $(strip \
  --enable-static \
  --disable-shared \
  --with-secure-transport \
  --without-brotli \
  --without-zstd \
  --without-libpsl \
  --disable-ldap \
  --disable-ldaps \
)

expat_version := 2.6.4
expat_configs := $(strip \
  --enable-static \
  --disable-shared \
  --without-xmlwf \
  --without-examples \
  --without-tests \
)

pcre2_version := 10.44
pcre2_configs := $(strip \
  --enable-jit \
  --enable-pcre2-8 \
  --enable-static \
  --disable-shared \
  --enable-pcre2grep-libz \
)

gettext_version := 0.25.1
gettext_configs := $(strip \
  --enable-static \
  --disable-shared \
  --with-included-gettext \
  --with-libiconv-prefix=$(prefix) \
  --disable-java \
  --disable-csharp \
  --disable-rpath \
)

git_version := 2.50.1
git_configs := $(strip \
  NO_OPENSSL=YesPlease \
)

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-][0-9a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: clean
clean: ## remove files
	$(RM) -r $(root)/usr/bin/* $(root)/usr/include/* $(root)/usr/lib/* $(root)/usr/man/* $(root)/usr/share/* $(root)/usr/src/*

.PHONY: install
install: ## install git and dependencies
install: download-zlib install-zlib
install: download-libiconv install-libiconv
install: download-curl install-curl
install: download-expat install-expat
install: download-pcre2 install-pcre2
install: download-gettext install-gettext
install: download-git install-git

.PHONY: download-zlib
download-zlib: ## [subtarget] download zlib archive
	curl -fsSL -o '$(root)/usr/src/zlib-$(zlib_version).tar.gz' https://github.com/madler/zlib/releases/download/v$(zlib_version)/zlib-$(zlib_version).tar.gz

.PHONY: download-libiconv
download-libiconv: ## [subtarget] download libiconv archive
	curl -fsSL -o '$(root)/usr/src/libiconv-$(libiconv_version).tar.gz' https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(libiconv_version).tar.gz

.PHONY: download-curl
download-curl: ## [subtarget] download curl archive
	curl -fsSL -o '$(root)/usr/src/curl-$(curl_version).tar.gz' https://curl.se/download/curl-$(curl_version).tar.gz

.PHONY: download-expat
download-expat: ## [subtarget] download expat archive
	curl -fsSL -o '$(root)/usr/src/expat-$(expat_version).tar.gz' https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(expat_version))/expat-$(expat_version).tar.gz

.PHONY: download-pcre2
download-pcre2: ## [subtarget] download pcre2 archive
	curl -fsSL -o '$(root)/usr/src/pcre2-$(pcre2_version).tar.gz' https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(pcre2_version)/pcre2-$(pcre2_version).tar.gz

.PHONY: download-gettext
download-gettext: ## [subtarget] download gettext archive
	curl -fsSL -o '$(root)/usr/src/gettext-$(gettext_version).tar.gz' https://ftp.gnu.org/gnu/gettext/gettext-$(gettext_version).tar.gz

.PHONY: download-git
download-git: ## [subtarget] download git archive
	curl -fsSL -o '$(root)/usr/src/git-$(git_version).tar.gz' https://www.kernel.org/pub/software/scm/git/git-$(git_version).tar.gz

.PHONY: install-zlib
install-zlib: ## [subtarget] install zlib
	$(RM) -r '$(root)/usr/src/zlib-$(zlib_version)'
	tar fvx '$(root)/usr/src/zlib-$(zlib_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/zlib-$(zlib_version)' && ./configure --prefix='$(prefix)' $(zlib_configs)
	make -j$(nproc) -C '$(root)/usr/src/zlib-$(zlib_version)'
	make install -C '$(root)/usr/src/zlib-$(zlib_version)'

.PHONY: install-libiconv
install-libiconv: ## [subtarget] install libiconv
	$(RM) -r '$(root)/usr/src/libiconv-$(libiconv_version)'
	tar fvx '$(root)/usr/src/libiconv-$(libiconv_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/libiconv-$(libiconv_version)' && ./configure --prefix='$(prefix)' $(libiconv_configs)
	make -j$(nproc) -C '$(root)/usr/src/libiconv-$(libiconv_version)'
	make install -C '$(root)/usr/src/libiconv-$(libiconv_version)'

.PHONY: install-curl
install-curl: ## [subtarget] install curl
	$(RM) -r '$(root)/usr/src/curl-$(curl_version)'
	tar fvx '$(root)/usr/src/curl-$(curl_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/curl-$(curl_version)' && PKG_CONFIG_PATH='$(pkg_config_path)' ./configure --prefix='$(prefix)' $(curl_configs)
	make -j$(nproc) -C '$(root)/usr/src/curl-$(curl_version)'
	make install -C '$(root)/usr/src/curl-$(curl_version)'

.PHONY: install-expat
install-expat: ## [subtarget] install expat
	$(RM) -r '$(root)/usr/src/expat-$(expat_version)'
	tar fvx '$(root)/usr/src/expat-$(expat_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/expat-$(expat_version)' && ./configure --prefix='$(prefix)' $(expat_configs)
	make -j$(nproc) -C '$(root)/usr/src/expat-$(expat_version)'
	make install -C '$(root)/usr/src/expat-$(expat_version)'

.PHONY: install-pcre2
install-pcre2: ## [subtarget] install pcre2
	$(RM) -r '$(root)/usr/src/pcre2-$(pcre2_version)'
	tar fvx '$(root)/usr/src/pcre2-$(pcre2_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/pcre2-$(pcre2_version)' && ./configure --prefix='$(prefix)' $(pcre2_configs)
	make -j$(nproc) -C '$(root)/usr/src/pcre2-$(pcre2_version)'
	make install -C '$(root)/usr/src/pcre2-$(pcre2_version)'

.PHONY: install-gettext
install-gettext: ## [subtarget] install gettext
	$(RM) -r '$(root)/usr/src/gettext-$(gettext_version)'
	tar fvx '$(root)/usr/src/gettext-$(gettext_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/gettext-$(gettext_version)' && ./configure --prefix='$(prefix)' $(gettext_configs)
	make -j$(nproc) -C '$(root)/usr/src/gettext-$(gettext_version)'
	make install -C '$(root)/usr/src/gettext-$(gettext_version)'

.PHONY: install-git
install-git: ## [subtarget] install git
	$(RM) -r '$(root)/usr/src/git-$(git_version)'
	tar fvx '$(root)/usr/src/git-$(git_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/git-$(git_version)' && $(git_configs) PKG_CONFIG_PATH='$(pkg_config_path)' make prefix='$(prefix)' -j$(nproc) CFLAGS='-I$(prefix)/include' LDFLAGS='-L$(prefix)/lib -static-libgcc'
	$(git_configs) make install prefix='$(prefix)' -C '$(root)/usr/src/git-$(git_version)'
