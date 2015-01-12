#!/bin/bash

CWD=`pwd`

DITA_HOME=/opt/DITA-OT1.8.5
cd $DITA_HOME
set +x 

realpath() {
  case $1 in
    /*) echo "$1" ;;
    *) echo "$PWD/${1#./}" ;;
  esac
}


if [ "${DITA_HOME:+1}" = "1" ] && [ -e "$DITA_HOME" ]; then
  export DITA_DIR="$(realpath "$DITA_HOME")"
else #elif [ "${DITA_HOME:+1}" != "1" ]; then
  export DITA_DIR="$(dirname "$(realpath "$0")")"
fi


if [ -f "$DITA_DIR"/tools/ant/bin/ant ] && [ ! -x "$DITA_DIR"/tools/ant/bin/ant ]; then
  chmod +x "$DITA_DIR"/tools/ant/bin/ant
fi

export ANT_OPTS="-Xmx512m $ANT_OPTS"
export ANT_OPTS="$ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
export ANT_HOME="$DITA_DIR"/tools/ant
export PATH="$DITA_DIR"/tools/ant/bin:"$PATH"

NEW_CLASSPATH="$DITA_DIR/lib/dost.jar"
NEW_CLASSPATH="$DITA_DIR/lib:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/commons-codec-1.4.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/resolver.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/icu4j.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/xercesImpl.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/xml-apis.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9-dom.jar:$NEW_CLASSPATH"


if test -n "$CLASSPATH"; then
  export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
  export CLASSPATH="$NEW_CLASSPATH"
fi


if [[ -z $WORKSPACE ]]; then
  export WORKSPACE="${CWD}"
fi
  
export DOC_VERSION=JS3.0

echo "WORKSPACE: ${WORKSPACE}"
cd "${WORKSPACE}"

filelist=$(find . -name *.ditamap | grep -FzZ 'maps')

select filename in ${filelist}; do
    if [ -n "$filename" ]; then
        echo "Starting build of ${filename}"
        cd $DITA_HOME
        /opt/DITA-OT1.8.5/tools/ant/bin/ant -Dtranstype=pdf2 -Dargs.input="$WORKSPACE/$filename" -Ddita.temp.dir="$WORKSPACE/temp" -Doutput.dir="$WORKSPACE" -Dcustomization.dir="$WORKSPACE/../dell_customization" -Douter.control=quiet
    fi
    break
done

