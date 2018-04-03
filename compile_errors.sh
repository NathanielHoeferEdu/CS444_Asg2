#!/bin/bash
#
# Compiles a list of errors from VL log files found in test.log stored in directories as errors.log
#
# Synopsis: compile_errors.sh [directory] [-r]
#
# [directory]	If directory provided, it will be the initial location for test.log search, otherwise the present working directory will be used. 
#
# [-r]	Recursively compiles list of errors in each test case and a summary error log file as suite_errors.log in suite directory. Requires directory to be a test suite (indicated by name starting with 'Ts') and contains test case directories starting with 'Tc' which directly hold the test.log files.


#######################################
# Global Constants
#######################################
LOG_FILE_NAME=test.log
ERROR_FILE_NAME=error.log
SUITE_ERR_FILE_NAME=suite_error.log


#######################################
# Parse logs from the test.log file
# and creates error.log file in pwd.
#
# Arguments:
#	Directory containing the
#       test.log file
# Returns:
#	error count	
#######################################
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
    exit 1
  fi

  # Check if error.log file exists
  echo Compiling error report for $test_name
  if [ -s $err_path ]; then
    echo --- Error.log file already exists, skipping
    exit 0
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

  echo Compile completed for $test_name
  exit 0
}

# Determine if recursive call
parseLogs $1



