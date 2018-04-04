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
# Global Constants
################################################################################
LOG_FILE_NAME="test.log"
ERROR_FILE_NAME="error.log"
SUITE_ERR_FILE_NAME="suite_error.log"
REC_FLAG="-r"
INVALID_ARGS="Invalid arguments!"


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
  error_count=0
  dir=$1
  log_name=$LOG_FILE_NAME
  error_name=$ERROR_FILE_NAME
  log_path=$dir/$log_name
  err_path=$dir/$error_name
  test_name=$( basename $dir )  

  # Ensure test.log exists
  if [ ! -e $log_path ]; then
    echo Test.log doesn\'t exist in this directory!
    return
  fi

  # Check if error.log file exists
  echo Compiling error report for $test_name
  if [ -s $err_path ]; then
    echo --- Error.log file already exists, skipping
    return
  fi 

  # Compile error report
  echo -e "-------------------------------------------" > $err_path
  echo -e "Error Report for $test_name" >> $err_path
  echo -e "-------------------------------------------\n" >> $err_path
  local IFS=$'\n'
  for line in $( egrep "ERROR|^!" $log_path ); do
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
# generates the error_summary.log file in the specified directory.
#
# Arguments:
#	Directory containing the test directories labelled with 'Ts'
# Returns:
#	None
################################################################################
parseTests() {
  # TODO
  echo Tests Parsed!
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
