#!/bin/bash

#Usage - local  : ./run_sims.sh HMG SEQL --data-dir=./data --console
#Usage - niagara: ./run_sims.sh HMG PARA --data-dir=$SCRATCH --console


CASE=$1
PARALLEL=${2:-""}
OTHER="$3 $4 $5 $6 $7 $8"  # for extra arguments

EXEC="python -u src/main.py"

log () { echo "run|$CASE|$1"; }
run () { if ! [ "$PARALLEL" == "PARA" ]; then log ">> $1"; eval $1; else log ">> $1 &"; eval $1 & fi }
exc () { run "$EXEC $1 $OTHER"; }

run_sim_1 () {
    local CHANNEL=$1
    local ARGS_COM="$2"
    local ARGS_ENS=$3  # for ensemble
    local ARGS_PRV=$4  # for provided
    local DEF_MAX_ITER=$5
    local DEF_ARGS="$ARGS_COM --max-iter=$DEF_MAX_ITER"
    declare -a MAX_ITER_ARR=("${!6}")

    LST=()
    for i in `seq 1 10`; do LST+=("$CHANNEL 1200_3_6_rand_ldpc_$i $DEF_ARGS $ARGS_ENS"); done
    LST+=("$CHANNEL 1200_3_6_ldpc $DEF_ARGS $ARGS_PRV")
    for i in ${MAX_ITER_ARR[@]}; do LST+=("$CHANNEL 1200_3_6_ldpc $ARGS_COM --max-iter=$i $ARGS_PRV"); done
    
    for i in `seq 1 ${#LST[@]}`; do exc "${LST[$i-1]}"; done
}

DEF_MIN_WEC="--min-wec=100"
DEF_ARR=(0 1 2 3 6 40 100)

list_DEC () {
    declare -a DECS_=("${!3}")
    for DEC in ${DECS_[@]}; do exc "$1 $DEC $2"; done
}

case ${CASE} in
    "HMG") # all hamming code sims
        CMN="--codeword=1 --min-wec=300"
        PARAMS=".5 .4 .3 .2 .1 .08 .06 .04 .02"
        DECS=("ML" "LP" "SPA" "ADMM")
        list_DEC "bec 7_4_hamming" "$CMN --params $PARAMS" DECS[@]

        PARAMS="$PARAMS .25 .15 .01 .008 .006 .004 .002"
        DECS=("ML" "LP" "SPA" "MSA" "ADMM")
        list_DEC "bsc 7_4_hamming" "$CMN --params $PARAMS" DECS[@]

        PARAMS="2 2.5 3 3.5 4 4.5 5 5.5 6 6.6 7"
        list_DEC "biawgn 7_4_hamming" "$CMN --params $PARAMS" DECS[@]
        ;;
    "MAR") # margulis code sims
        CONFIG="margulis ADMM --codeword=1 --min-wec=100 --params"
        exc "biawgn $CONFIG .5 .75 1. 1.25 1.5 1.75 2. 2.25 2.5 2.75 3.0"
        exc "bsc $CONFIG .1 .09 .08 .07 .06 .05 .04"
        exc "bec $CONFIG .5 .475 .45 .425 .4 .375 .35 .34 .33 .325 .32 .31 .3"
        ;;
    "BEC")
        ARGS="--params .5 .475 .45 .425 .4 .375 .35 .34 .33 .325 .32 .31 .3"
        run_sim_1 bec "SPA --codeword=0" "--min-wec=100 $ARGS" "--min-wec=500 $ARGS .44 .43 .42 .41 .39 .38 .37 .36 .355 .345 .29 .28 .27 .26 .25 .24 .23 .21 .2 .19 .18 .17 .16 .15 .14 .13 .12 .11 .1" 10 DEF_ARR[@]
        ;;
    "BSC_MSA")
        ARGS="$DEF_MIN_WEC --params .081 .0751 .071 .0651 .061 .0551 .051 .0451 .041 .0351 .031 .0251 .021 .0151 .01"
        run_sim_1 bsc "MSA --codeword=1" "$ARGS" "$ARGS" 10 DEF_ARR[@]
        ;;
    "BIAWGN_MSA")
        ARGS="$DEF_MIN_WEC --params .5 .75 1. 1.25 1.5 1.75 2. 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0"
        run_sim_1 biawgn "MSA --codeword=1" "$ARGS" "$ARGS" 10 DEF_ARR[@]
        ;;
    "BSC_SPA")
        ARGS="$DEF_MIN_WEC --params .1 .09 .08 .07 .06 .05 .04"
        run_sim_1 bsc "SPA --codeword=0" "$ARGS" "$ARGS" 10 DEF_ARR[@]
        ;;
    "BIAWGN_SPA")
        ARGS="$DEF_MIN_WEC --params .5 .75 1. 1.25 1.5 1.75 2. 2.25 2.5 2.75 3.0"
        run_sim_1 biawgn "SPA --codeword=0" "$ARGS" "$ARGS" 10 DEF_ARR[@]
        ;;
    *)
        log "Non-existent CASE=$CASE!"
        exit -1
        ;;
esac

log "Waiting..."
wait
log "Done!"