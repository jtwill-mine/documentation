#!/bin/bash

CWD=`pwd`

DITA_HOME="$CWD/../DITA-OT1.8.5"

cd "$DITA_HOME"
export DITA_DIR="$DITA_HOME/"
set +x 

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

if [[ -z $OVERLAY_TOOL_DIR ]]; then
  export OVERLAY_TOOL_DIR="${CWD}/../dell_customization/overlay_tools"
fi

export OUTDIR="${WORKSPACE}"/artifacts
export DOC_VERSION=JS3.0

mkdir -p "${OUTDIR}"

echo "WORKSPACE: ${WORKSPACE}"
cd "${WORKSPACE}"

filelist=$(find . -name *.ditamap | grep -FzZ 'maps')
 
if [[ -n $1  && $1 == "build_all" ]]; then
  echo "Building All documents" 
  shopt -s globstar
  for filename in **/*.ditamap; do
        echo "Starting build of ${filename}"
        oname=`basename ${filename}`
        cd "$DITA_HOME"
        "${ANT_HOME}"/bin/ant -Dtranstype=pdf2 -Dargs.input="$WORKSPACE/$filename" -Ddita.temp.dir="$WORKSPACE/temp" -Doutput.dir="$WORKSPACE" -Dcustomization.dir="$WORKSPACE/../dell_customization" -Douter.control=quiet
        if [[ -n $2  && $2 == "release" ]]; then
           echo "*** Build Release Documents ***"
           mv "${WORKSPACE}"/"${filename%.*}.pdf" "${OUTDIR}"
        else 
           java -jar "${OVERLAY_TOOL_DIR}"/pdfbox-app-1.8.8.jar OverlayPDF "$WORKSPACE"/"${filename%.*}.pdf" "${OVERLAY_TOOL_DIR}"/watermark_draft_lightred_filled.pdf "${OUTDIR}"/"${oname%.*}.pdf"
           rm -f "${WORKSPACE}"/"${filename%.*}.pdf" 
        fi
  done
  exit
fi

select filename in ${filelist}; do
    if [ -n "$filename" ]; then
        echo "Starting build of ${filename}"
        oname=`basename ${filename}`
        cd "$DITA_HOME"
        "${ANT_HOME}"/bin/ant -Dtranstype=pdf2 -Dargs.input="$WORKSPACE/$filename" -Ddita.temp.dir="$WORKSPACE/temp" -Doutput.dir="$WORKSPACE" -Dcustomization.dir="$WORKSPACE/../dell_customization" -Douter.control=quiet
        java -jar "${OVERLAY_TOOL_DIR}"/pdfbox-app-1.8.8.jar OverlayPDF "$WORKSPACE"/"${filename%.*}.pdf" "${OVERLAY_TOOL_DIR}"/watermark_draft_lightred_filled.pdf "${OUTDIR}"/"${oname%.*}.pdf"
        rm -f "${WORKSPACE}"/"${filename%.*}.pdf" 
    fi
    break
done
