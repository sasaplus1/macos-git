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
  --without-nghttp2 \
  --without-libidn2 \
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
  NEEDS_LIBICONV=YesPlease \
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
	@test -f '$(root)/usr/src/zlib-$(zlib_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/zlib-$(zlib_version).tar.gz' https://github.com/madler/zlib/releases/download/v$(zlib_version)/zlib-$(zlib_version).tar.gz

.PHONY: download-libiconv
download-libiconv: ## [subtarget] download libiconv archive
	@test -f '$(root)/usr/src/libiconv-$(libiconv_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/libiconv-$(libiconv_version).tar.gz' https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(libiconv_version).tar.gz

.PHONY: download-curl
download-curl: ## [subtarget] download curl archive
	@test -f '$(root)/usr/src/curl-$(curl_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/curl-$(curl_version).tar.gz' https://curl.se/download/curl-$(curl_version).tar.gz

.PHONY: download-expat
download-expat: ## [subtarget] download expat archive
	@test -f '$(root)/usr/src/expat-$(expat_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/expat-$(expat_version).tar.gz' https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(expat_version))/expat-$(expat_version).tar.gz

.PHONY: download-pcre2
download-pcre2: ## [subtarget] download pcre2 archive
	@test -f '$(root)/usr/src/pcre2-$(pcre2_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/pcre2-$(pcre2_version).tar.gz' https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(pcre2_version)/pcre2-$(pcre2_version).tar.gz

.PHONY: download-gettext
download-gettext: ## [subtarget] download gettext archive
	@test -f '$(root)/usr/src/gettext-$(gettext_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/gettext-$(gettext_version).tar.gz' https://ftp.gnu.org/gnu/gettext/gettext-$(gettext_version).tar.gz

.PHONY: download-git
download-git: ## [subtarget] download git archive
	@test -f '$(root)/usr/src/git-$(git_version).tar.gz' || \
		curl -fsSL -o '$(root)/usr/src/git-$(git_version).tar.gz' https://www.kernel.org/pub/software/scm/git/git-$(git_version).tar.gz

.PHONY: install-zlib
install-zlib: ## [subtarget] install zlib
	@test -d '$(root)/usr/src/zlib-$(zlib_version)' || \
		tar fvx '$(root)/usr/src/zlib-$(zlib_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/zlib-$(zlib_version)' && ./configure --prefix='$(prefix)' $(zlib_configs)
	make -j$(nproc) -C '$(root)/usr/src/zlib-$(zlib_version)'
	make install -C '$(root)/usr/src/zlib-$(zlib_version)'

.PHONY: install-libiconv
install-libiconv: ## [subtarget] install libiconv
	@test -d '$(root)/usr/src/libiconv-$(libiconv_version)' || \
		tar fvx '$(root)/usr/src/libiconv-$(libiconv_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/libiconv-$(libiconv_version)' && ./configure --prefix='$(prefix)' $(libiconv_configs)
	make -j$(nproc) -C '$(root)/usr/src/libiconv-$(libiconv_version)'
	make install -C '$(root)/usr/src/libiconv-$(libiconv_version)'

.PHONY: install-curl
install-curl: ## [subtarget] install curl
	@test -d '$(root)/usr/src/curl-$(curl_version)' || \
		tar fvx '$(root)/usr/src/curl-$(curl_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/curl-$(curl_version)' && PKG_CONFIG_PATH='$(pkg_config_path)' ./configure --prefix='$(prefix)' $(curl_configs)
	make -j$(nproc) -C '$(root)/usr/src/curl-$(curl_version)'
	make install -C '$(root)/usr/src/curl-$(curl_version)'

.PHONY: install-expat
install-expat: ## [subtarget] install expat
	@test -d '$(root)/usr/src/expat-$(expat_version)' || \
		tar fvx '$(root)/usr/src/expat-$(expat_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/expat-$(expat_version)' && ./configure --prefix='$(prefix)' $(expat_configs)
	make -j$(nproc) -C '$(root)/usr/src/expat-$(expat_version)'
	make install -C '$(root)/usr/src/expat-$(expat_version)'

.PHONY: install-pcre2
install-pcre2: ## [subtarget] install pcre2
	@test -d '$(root)/usr/src/pcre2-$(pcre2_version)' || \
		tar fvx '$(root)/usr/src/pcre2-$(pcre2_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/pcre2-$(pcre2_version)' && ./configure --prefix='$(prefix)' $(pcre2_configs)
	make -j$(nproc) -C '$(root)/usr/src/pcre2-$(pcre2_version)'
	make install -C '$(root)/usr/src/pcre2-$(pcre2_version)'

.PHONY: install-gettext
install-gettext: ## [subtarget] install gettext
	@test -d '$(root)/usr/src/gettext-$(gettext_version)' || \
		tar fvx '$(root)/usr/src/gettext-$(gettext_version).tar.gz' -C '$(root)/usr/src'
	cd '$(root)/usr/src/gettext-$(gettext_version)' && ./configure --prefix='$(prefix)' $(gettext_configs)
	make -j$(nproc) -C '$(root)/usr/src/gettext-$(gettext_version)'
	make install -C '$(root)/usr/src/gettext-$(gettext_version)'

.PHONY: install-git
install-git: CFLAGS := -I$(prefix)/include
install-git: LDFLAGS := -L$(prefix)/lib -framework CoreFoundation -framework Security -framework SystemConfiguration
install-git: EXTLIBS := $(prefix)/lib/libz.a $(prefix)/lib/libiconv.a $(prefix)/lib/libintl.a $(prefix)/lib/libpcre2-8.a -framework CoreFoundation -framework Security -framework SystemConfiguration
install-git: MAKE_VARS := PKG_CONFIG_PATH='$(pkg_config_path)' USE_LIBPCRE2=Yes ZLIB_PATH='$(prefix)'
install-git: ## [subtarget] install git
	@test -d '$(root)/usr/src/git-$(git_version)' || \
		tar fvx '$(root)/usr/src/git-$(git_version).tar.gz' -C '$(root)/usr/src'
	# Clean up Git-specific generated files for incremental builds (but keep source files)
	@test ! -d '$(root)/usr/src/git-$(git_version)' || \
		$(RM) -f '$(root)/usr/src/git-$(git_version)'/GIT-BUILD-OPTIONS \
			'$(root)/usr/src/git-$(git_version)'/GIT-CFLAGS \
			'$(root)/usr/src/git-$(git_version)'/GIT-LDFLAGS \
			'$(root)/usr/src/git-$(git_version)'/GIT-PREFIX \
			'$(root)/usr/src/git-$(git_version)'/GIT-PERL-DEFINES \
			'$(root)/usr/src/git-$(git_version)'/GIT-PERL-HEADER \
			'$(root)/usr/src/git-$(git_version)'/GIT-PYTHON-VARS \
			'$(root)/usr/src/git-$(git_version)'/GIT-SCRIPT-DEFINES \
			'$(root)/usr/src/git-$(git_version)'/GIT-TEST-SUITES \
			'$(root)/usr/src/git-$(git_version)'/GIT-USER-AGENT \
			'$(root)/usr/src/git-$(git_version)'/GIT-VERSION-FILE \
			'$(root)/usr/src/git-$(git_version)'/config.status
	cd '$(root)/usr/src/git-$(git_version)' && $(git_configs) $(MAKE_VARS) make prefix='$(prefix)' -j$(nproc) CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' EXTLIBS='$(EXTLIBS)'
	$(git_configs) $(MAKE_VARS) make install prefix='$(prefix)' -C '$(root)/usr/src/git-$(git_version)' EXTLIBS='$(EXTLIBS)'
