log_script() {
  SCRIPT_NAME=$(basename $0)
  THIS=$0
  mkdir -p $TURBINE_OUTPUT
  LOG_NAME="${TURBINE_OUTPUT}/${SCRIPT_NAME}.log"
  echo "### VARIABLES ###" > $LOG_NAME
  set +u
  VARS=( "EMEWS_PROJECT_ROOT" "EXPID" "TURBINE_OUTPUT" \
    "PROCS" "QUEUE" "WALLTIME" "PPN" "TURBINE_JOBNAME" \
    "PYTHONPATH" "R_HOME" "LD_LIBRARY_PATH" "DYLD_LIBRARY_PATH" \
    "TURBINE_RESIDENT_WORK_WORKERS" "RESIDENT_WORK_RANKS" "EQPY" \
    "EQR" "CMD_LINE_ARGS" "MACHINE")
  for i in "${VARS[@]}"
  do
      v=\$$i
      echo "$i=`eval echo $v`" >> $LOG_NAME
  done

  for i in "${USER_VARS[@]}"
  do
      v=\$$i
      echo "$i=`eval echo $v`" >> $LOG_NAME
  done
  set -u

  echo "" >> $LOG_NAME
  echo "## SCRIPT ###" >> $LOG_NAME
  cat $THIS >> $LOG_NAME
}

check_directory_exists() {
  if [[ -d $TURBINE_OUTPUT ]]; then
    while true; do
      read -p "Experiment directory exists. Continue? (Y/n) " yn
      yn=${yn:-y}
      case $yn in
          [Yy""]* ) break;;
          [Nn]* ) exit; break;;
          * ) echo "Please answer yes or no.";;
      esac
    done
  fi

}

check_file_exists() {
  echo "checking: $1"
  if [[ ! -r $1 ]]; then
    echo "check_file_exists(): File not found: $1"
    return 1
  fi
}

auto_expid() {
  # Search for free experiment number
  local EXPERIMENTS=$1
  if ! check_file_exists $EXPERIMENTS
  then
    echo "auto_expid(): bad EXPERIMENTS directory!"
    return 1
  fi
  
  local i=1 EXPS E ID

  EXPS=( $( ls $EXPERIMENTS ) )
  if (( ${#EXPS[@]} != 0 ))
  then
    for E in ${EXPS[@]}
    do
      ID=$( printf "X%03i" $i )
      if [[ $E == $ID ]]
      then
        i=$(( i + 1 ))
      fi
    done
  fi
  REPLY=$( printf "X%03i" $i )
}
