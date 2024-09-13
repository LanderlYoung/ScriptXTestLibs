#! /bin/bash
set -e

PATH_TO_V8_GIT=$1
V8_CHANGES=$(realpath $(dirname "$0"))/changes
V8_INCLUDES=$(realpath $(dirname "$0"))/includes
SUPPORTED_VERSIONS_FILE=$(realpath $(dirname "$0"))/supported_versions.txt
V8_DIFF_FILES=(v8-platform.h v8-template.h)

if [[ -z $PATH_TO_V8_GIT ]]; then
  echo "$0 PATH_TO_V8_GIT"
  exit 1
fi

mkdir -p $V8_CHANGES
cd $PATH_TO_V8_GIT

git fetch origin

V8_VERSIONS=$(git branch --list --remote | egrep -e "origin/\d+\.\d+-lkgr" | sed -e "s/origin\///g" | sort --numeric-sort -t . -k 1,2)
V8_VERSIONS=($V8_VERSIONS)

SUPPORTED_VERSIONS=()
for VER in "${V8_VERSIONS[@]}"; do
  MAJOR=$(echo $VER | cut -d "." -f 1)
  MINOR=$(echo $VER | cut -d "." -f 2)

  # V8 version >= 7.4
  if [[ $MAJOR -gt 7 || ($MAJOR -eq 7 && $MINOR -ge 4) ]]; then
    SUPPORTED_VERSIONS+=($VER)
  fi
done

echo "${SUPPORTED_VERSIONS[@]}"
echo "${SUPPORTED_VERSIONS[@]}" > $SUPPORTED_VERSIONS_FILE

# gen diff
for ((i = 1; i < ${#SUPPORTED_VERSIONS[@]}; i++)); do
  PREV=${SUPPORTED_VERSIONS[$((i - 1))]};
  CURR=${SUPPORTED_VERSIONS[$i]};

  DIFF_DIR=$V8_CHANGES/"${PREV}..${CURR}"
  if [[ ! -e $DIFF_DIR ]]; then
    mkdir -p $DIFF_DIR
    for file in "${V8_DIFF_FILES[@]}"; do
      echo "diff $PREV $CURR"
      DIFF_FILE=$DIFF_DIR/${file}.diff
      git diff -U10 origin/$PREV origin/$CURR -- include/$file > $DIFF_FILE
      if [[ ! -s $DIFF_FILE ]]; then
        rm $DIFF_FILE
      fi
  done
  fi
done

# copy header
for VER in "${SUPPORTED_VERSIONS[@]}"; do
  DIR=${V8_INCLUDES}/${VER}
  if [[ ! -d $DIR ]]; then
    echo copy header of version $VER
    mkdir -p $DIR
    git checkout origin/$VER > /dev/null
    cp -R include/* ${DIR}
  fi
done

