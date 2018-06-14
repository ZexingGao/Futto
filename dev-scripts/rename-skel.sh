#!/bin/bash
if [[ "$1" == "" ]]; then
  echo "Usage: rename.sh <newname>"
  exit 0
fi
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIRNAME=`dirname $ABSOLUTE_PATH`
echo $DIRNAME
cd $DIRNAME/..
PROJECT_DIR=`pwd`
ORIGINAL="RF Skeleton"
NEW="$1"
git mv "$PROJECT_DIR/$ORIGINAL.xcodeproj" "$PROJECT_DIR/$NEW.xcodeproj"
git mv "$PROJECT_DIR/$ORIGINAL.xcworkspace" "$PROJECT_DIR/$NEW.xcworkspace"
git mv "$PROJECT_DIR/$ORIGINAL" "$PROJECT_DIR/$NEW"
( cd *.xcodeproj/xcshareddata/xcschemes; mmv "RF Skeleton*.xcscheme" "$NEW\#1.xcscheme" )
find $PROJECT_DIR -path $PROJECT_DIR/.git -prune -o -path $PROJECT_DIR/dev-scripts -prune -o -type f -print0 | xargs -0 sed -i "s/$ORIGINAL/$NEW/g"
NEWSLUG=`echo "$NEW" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+//g | sed -r s/^-+\|-+$//g | tr A-Z a-z`
find $PROJECT_DIR -path $PROJECT_DIR/.git -prune -o -path $PROJECT_DIR/dev-scripts -prune -o -type f -print0 | xargs -0 sed -i "s/com\.rocketfarmstudios\.com.rfskel/com\.rocketfarmstudios\.$NEWSLUG/g"
git add "$PROJECT_DIR/$NEW.xcodeproj/xcshareddata/xcschemes"
git commit -a -m "Renamed to $NEW"