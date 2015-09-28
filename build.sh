#!/bin/sh

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

case "$SIGN" in
  "/")
        DIR=$dir
        ;;
  ".")
        DIR=$pwd/$dir
        ;;
   *)
        echo "Error while getting directory"
        exit -1
        ;;
esac

if [ "x$CONFIG" = "x" ]; then
  CONFIG=./brn-backports.config
fi

. $CONFIG

get_branch() {
  BRANCH=`(cd $1; git branch | grep "\*" | awk '{print $2}')`
  echo $BRANCH
}

delete_branch() {
 if [ "x$2" != "xmaster" ]; then
   (cd $1; git branch -D $2)
 fi
}

pull_branch() {
  (cd $1; git pull)
}

switch_to_branch() {
  CURRENT_BRANCH=$(get_branch $1)

  if [ "x$CURRENT_BRANCH" != "x$2" ]; then
    (cd $1;git checkout $2)
  fi
}

create_and_switch_branch() {
  CURRENT_BRANCH=$(get_branch $1)

  if [ "x$CURRENT_BRANCH" != "x$2" ]; then
    (cd $1;git checkout -b $2 $3)
  fi
}

clone_repo() {
  if [ ! -e $2 ]; then
    git clone $1 $2
  fi
}

case "$1" in
  "release")
     clone_repo $BACKPORTS_URL $BACKPORTS_DIR
     clone_repo $LINUX_NEXT_URL $LINUX_NEXT_DIR

     $0 master

     create_and_switch_branch $BACKPORTS_DIR $RELEASE_BRANCH $BACKPORTS_VERSION
     create_and_switch_branch $LINUX_NEXT_DIR $RELEASE_BRANCH $LINUX_NEXT_VERSION

     mkdir $BUILD_DIR

     (cd $BACKPORTS_DIR; ./gentree.py --clean $DIR/$LINUX_NEXT_DIR $DIR/$BUILD_DIR)

     cp $BACKPORTS_CONFIG $DIR/$BUILD_DIR/.config
     mv $BUILD_DIR $RELEASE_DIR
     tar cjf $RELEASE_DIR.tar.bz2 $RELEASE_DIR
     mv $RELEASE_DIR $BUILD_DIR

     ;;
  "buildrelease")
     $0 release
     ;;
  "dev")
     clone_repo $BACKPORTS_URL $BACKPORTS_DIR
     clone_repo $LINUX_NEXT_URL $LINUX_NEXT_DIR

     $0 master

     create_and_switch_branch $BACKPORTS_DIR $DEVEL_BRANCH $BACKPORTS_VERSION

     switch_to_branch $LINUX_NEXT_DIR $BRN_MASTER
     create_and_switch_branch $LINUX_NEXT_DIR $DEVEL_BRANCH

     (cd $BACKPORTS_DIR; ./gentree.py --clean $DIR/$LINUX_NEXT_DIR $DIR/$BUILD_DIR)

     cp $BACKPORTS_CONFIG $DIR/$BUILD_DIR/.config
     mv $BUILD_DIR $DEVEL_DIR
     tar cjf $DEVEL_DIR.tar.bz2 $DEVEL_DIR
     mv $DEVEL_DIR $BUILD_DIR
     ;;
  "show")
     for d in $BACKPORTS_DIR $LINUX_NEXT_DIR; do
       echo "$d"
       (cd $d; git branch)
     done
     ;;
  "master")
     switch_to_branch $BACKPORTS_DIR master
     switch_to_branch $LINUX_NEXT_DIR master
     ;;
  "brnmaster")
     switch_to_branch $BACKPORTS_DIR master
     switch_to_branch $LINUX_NEXT_DIR brn-master
     ;;

  "pull")
     $0 master
     pull_branch $BACKPORTS_DIR
     pull_branch $LINUX_NEXT_DIR
     ;;
  "clear")
     $0 master
     for r in $BACKPORTS_DIR $LINUX_NEXT_DIR; do
       for b in $DEVEL_BRANCH $RELEASE_BRANCH; do
          delete_branch $r $b
       done
     done
     ;;
  "devrelease")
     mkdir $BUILD_DIR

     (cd $BACKPORTS_DIR; ./gentree.py --clean $DIR/$LINUX_NEXT_DIR $DIR/$BUILD_DIR)

     cp $BACKPORTS_CONFIG $DIR/$BUILD_DIR/.config
     #mv $BUILD_DIR $DEVEL_DIR
     #tar cjf $DEVEL_DIR.tar.bz2 $DEVEL_DIR
     #mv $DEVEL_DIR $BUILD_DIR
    ;;
esac
