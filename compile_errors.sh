#!/bin/bash
#
# Compiles a list of errors from VL log files found in test.log stored in 
# directories as errors.log
#
# Synopsis: compile_errors.sh [directory] [-r]
#
# [directory]	If directory provided, it will be the initial location for 
# 		test.log search, otherwise the present working directory will 
# 		be used. 
#
# [-r]	Recursively compiles list of errors in each test subdirectory and a 
# 	generates summary error log file as error_summary.log in directory 
# 	provided.


################################################################################
# Constants
################################################################################
LOG_FILE_NAME="test.log"
ERROR_FILE_NAME="error.log"
ERR_SUM_FILE_NAME="error_summary.log"
REC_FLAG="-r"
INVALID_ARGS="Invalid arguments!"
ERROR_PATTERN="^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{6}\sERROR|^!"
  # Pattern example: "2018-04-04 17:26:58.797072 ERROR ..." OR "!..."


################################################################################
# Parse logs from the test.log file and creates error.log file in specifed
# directory.
#
# Arguments:
#	Directory containing the test.log file
# Returns:
#	None
################################################################################
parseLogs () {
  local error_count=0
  local dir=$1
  local log_path=$dir/$LOG_FILE_NAME
  local err_path=$dir/$ERROR_FILE_NAME
  local test_name=$( basename $dir )

  # Ensure test.log exists
  if [ ! -e $log_path ]; then
    echo $log_path doesn\'t exist!
    return
  fi

  # Check if error.log file exists
  echo Compiling error report for $test_name
  if [ -s $err_path ]; then
    echo --- $ERROR_FILE_NAME file already exists, skipping
    return
  fi

  # Compile error report
  echo -e "-------------------------------------------" > $err_path
  echo -e "Error Report: $test_name" >> $err_path
  echo -e "-------------------------------------------\n" >> $err_path
  local IFS=$'\n'
  for line in $( grep -P $ERROR_PATTERN $log_path ); do
    echo $line >> $err_path
  done
  unset IFS

  # Calculate total number of errors in the file
  error_count=$( grep ERROR $err_path | wc -l )
  echo -e "-------------------------------------------" >> $err_path
  echo -e "Error Count: $error_count" >> $err_path
  echo -e "-------------------------------------------" >> $err_path
  echo Compile completed for $test_name, Errors Found: $error_count
}


################################################################################
# Recursively call parseLogs for each subdirectory starting with 'Ts' and
# generates the error summary file in the specified directory.
#
# Arguments:
#	Directory containing the test directories labelled with 'Ts'
# Returns:
#	None
################################################################################
parseTests() {
  local dir=$1
  local dir_name=$( basename $dir )
  local sum_path=$dir/$ERR_SUM_FILE_NAME

  # Check if dir contains dir's starting with 'Ts'
  if [ $( ls $dir | egrep "^Ts" | wc -l ) -lt 1 ]; then
    echo No test directories found.
    return
  fi

  # Check if error summary log exists
  if [ -s $sum_path ]; then
    echo $ERR_SUM_FILE_NAME already exists
    return
  fi

  echo Compiling error summary report for $dir_name
  echo "==========================================="

  # Create Summary file
  echo -e "-------------------------------------------" > $sum_path
  echo -e "Error Summary Report: $dir_name" >> $sum_path
  echo -e "-------------------------------------------" >> $sum_path

  # Compile reports for all tests in directory
  local IFS=$'\n'
  for tests in $( ls $dir | grep "^Ts" ); do
    echo -e "===========================================\n" >> $sum_path
    parseLogs $dir/$tests
    cat $dir/$tests/$ERROR_FILE_NAME >> $sum_path
  done
  unset IFS
  echo "==========================================="
  echo Compile completed for $dir_name
}


# Validate based on number of arguments and execute accordingly
case $# in

  # Default to use pwd to parse logs
  0)
    parseLogs $PWD ;;

  # Check for flag or dir and execute
  1)
    if [ $1 = $REC_FLAG ]; then
      parseTests $PWD
    elif [ -d $1 ]; then
      parseLogs $1
    else
      echo $INVALID_ARGS
      exit 1
    fi ;;

  # Verify that one arg is flag and another is a dir
  2)
    if [ $1 = $REC_FLAG ] || [ $2 = $REC_FLAG ]; then
      if [ -d $1 ]; then
        parseTests $1
      elif [ -d $2 ]; then
        parseTests $2
      else
        echo $INVALID_ARGS
        exit 1
      fi
    else
      echo $INVALID_ARGS
      exit 1
    fi ;;

  # All other number of args are invalid
  *)
    echo $INVALID_ARGS
    exit 1
esac
exit 0