#!/bin/sh

set -e +x

# Find the installed version of a binary, if any
_installed() {
    VERSION=$($@ --version 2>/dev/null || echo "$@ none")
    echo $VERSION | rev | cut -d' ' -f1 | rev
}

# Find the latest available version of a binary on `crates.io`
_latest() {
    VERSION=$(cargo search -q "$@" | grep "$@" | cut -f2 -d"\"")
    echo $VERSION
}


### Setup sccache ##############################################################

echo -n "Fetching latest available 'sccache' version... "
INSTALLED=$(_installed sccache)
LATEST=$(_latest sccache)
echo "${LATEST} (installed: ${INSTALLED})"

if [ "$INSTALLED" = "$LATEST" ]; then
  echo "Using cached 'sccache'"
else
  echo "Installing latest 'sccache' from mozilla/sccache"
  URL="https://github.com/mozilla/sccache/releases/download/${LATEST}/sccache-${LATEST}-x86_64-unknown-linux-musl.tar.gz"
  curl -SsL $URL | tar xz -C /tmp
  mv /tmp/sccache-${LATEST}-x86_64-unknown-linux-musl/sccache $HOME/.cargo/bin/sccache
fi

mkdir -p $SCCACHE_DIR


### Setup cargo-make ###########################################################

echo -n "Fetching latest available 'cargo-make' version..."
INSTALLED=$(_installed cargo make)
LATEST=$(_latest cargo-make)
echo "${LATEST} (installed: ${INSTALLED})"

if [ "$INSTALLED" = "$LATEST" ]; then
  echo "Using cached 'cargo-make'"
else
  echo "Installing latest 'cargo-make' from source"
  cargo install --debug -f cargo-make
fi


### Setup vdpm #################################################################

echo "Fetching latest Vita SDK..."
RELEASES="https://api.github.com/repos/vitasdk/autobuilds/releases"
LINK=$(curl -u ${GH_API_USER}:${GH_API_TOKEN} -SsL "$RELEASES" | grep "master-linux" | grep "browser_download_url" | head -n 1 | cut -d '"' -f 4)

echo "Installing toolchain from $LINK..."
mkdir -p $VITASDK
curl -SsL "$LINK" | tar xj -C $VITASDK --strip-components=1
