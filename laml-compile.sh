INPUT=${1:?"input file is not designated."}
OUTPUT=${2:-`basename ${INPUT%.*}`}

echo "${INPUT} -> ${OUTPUT}.tex"
laml < ${INPUT} > ${OUTPUT}.tex
uplatex -interaction=nonstopmode ${OUTPUT}.tex
dvipdfmx ${OUTPUT}.dvi
