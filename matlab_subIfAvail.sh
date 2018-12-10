#!/bin/bash

MATLAB_LICENSE='/sw/rhea/matlab/9.1/binary/licenses/network.lic'
LMSTAT='/sw/rhea/matlab/9.1/binary/licenses/check/lmstat'
RETRY_TIME=600

while true; do
	TOTAL_SEATS=$($LMSTAT -A -c $MATLAB_LICENSE | grep "Total of" | awk '{print $6}')
	USED_SEATS=$($LMSTAT -A -c $MATLAB_LICENSE | grep "Total of" | awk '{print $11}')
	
	AVAIL_SEATS=$((TOTAL_SEATS - USED_SEATS))


	printf "\n${USED_SEATS}/${TOTAL_SEATS} MATLAB seats in use. ${AVAIL_SEATS} available.\n"

	if [ ${AVAIL_SEATS} -gt 0 ]; then
		printf "\n Ready to submit a job! \n\n"

		## INSERT JOB SUBMISSION HERE

		break
	else
		printf "\n Not ready to submit a job. Trying again in $RETRY_TIME seconds... \n\n"
	fi

	sleep ${RETRY_TIME}

done
