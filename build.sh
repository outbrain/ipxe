[ -d log ] || mkdir log
[ -d tmp ] || mkdir tmp
EMBED_TPL="$(dirname $0)/../contrib/outbrain/onering.ipxe"
BUILDBIN="undionly.kkpxe"

case $1 in
all)
  cd src
  [ -f "$EMBED_TPL" ] || (echo "Cannot find file $EMBED_TPL" && exit 1)

  for i in $(onering devices list site | grep -P '[0-9]+$'); do
    ONERING_SERVER=$(host onering.$i.outbrain.com | tail -n1 | cut -d' ' -f4)
    echo "Building image for $i (onering-server: $ONERING_SERVER)..." 1>&2
    cat "$EMBED_TPL" | sed -e "s/{{ONERING_SERVER}}/$ONERING_SERVER/g" > $EMBED_TPL.$i
    [ -f "bin/$BUILDBIN" ] && rm -f "bin/$BUILDBIN"
    [ -f "../$BUILDBIN.$i" ] && rm -f "../$BUILDBIN.$i"
    make "bin/$BUILDBIN" EMBED=$EMBED_TPL.$i > ../log/$BUILDBIN.$i.log 2>&1
    mv "bin/$BUILDBIN" "../$BUILDBIN.$i"
  done
  ;;

push)
  for i in $BUILDBIN.*; do
    SITE=${i##*.}
    echo "Pushing $i to pxe.$SITE..." 1>&2
    scp $i pxe.$SITE:/tftpboot/$BUILDBIN
  done
  ;;
*)
  echo "Unknown build command $1" 1>&2
  exit 255;;
esac
