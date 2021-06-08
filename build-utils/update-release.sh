#!/bin/bash

VERSION="$(git rev-list --count HEAD)"
BRANCH="$(git branch | grep '*' | cut -d' ' -f2)"


# get repo name and owner
REPO_NAME="tos-desktop-environment"
REPO_OWNER="ODEX-TOS"

if [[ "$(command -v gh)" == "" ]]; then
    echo "Install github cli first"
    echo "Then run gh auth login to authenticate"
    exit 1
fi


# create the tag of this release and push it
git tag "$BRANCH-$VERSION"
git push origin "$BRANCH-$VERSION"


cd build-utils || exit 1
rm tde-* || true
cp PKGBUILD PKGBUILD_BLANK

sed -i -E 's/BRANCH=".*"/BRANCH="'$BRANCH'"/g' PKGBUILD

# build the package
makepkg -f || exit 1

# cleanup build
mv PKGBUILD_BLANK PKGBUILD
rm -rf tos-desktop-enviroment src pkg || true
cd ../ || exit 1

file="$(find . -type f -iname 'tde-*.pkg.*' | head -n1)"
gh release create "$BRANCH-$VERSION" -F NEWS.md $file -t "$BRANCH-$VERSION: Pre-release package" -R "$REPO_OWNER/$REPO_NAME"
