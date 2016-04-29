#!/bin/bash

BRANCH_TO_BUILD=${1}
source config_${BRANCH_TO_BUILD}.sh 
checkFolder()
{
	cd $JENKINS_PATH
	
	#rm fileList fileListTar
	for file in $fileSet
	do
		echo -e $fileSet > fileList
	done

	for file in $fileTar
	do
		echo -e $fileTar > fileListTar
	done

	##CHECK UPLOAD#
	flag="true"
	while read line
	do
	ssh -q $TARGET_HOST "test -e $UPLOAD_BIN_PATH/$line"
	if [ $? -eq 0 ]; then
		echo "UPLOAD/Bin | $line exists"
	else
		echo "UPLOAD/Bin | not exist : $line"
		flag="false"
		break
	fi
	done < fileListTar
	echo "--------------------"

	##RUN UPLOAD##
	if [ $flag = true ];
	then
		run_Upload
	fi
#######################################################################################
	##CHECK TAR##
	if [ $flag = false ];
	then
	while read line
	do
	ssh -q $TARGET_HOST "test -e $TAR_PATH/$line"
	if [ $? -eq 0 ]; then
		
		echo "TAR* | $line exists"
	else
		
		echo "TAR* | not exist : $line"
		flag="true"
		break
	fi
	done < fileListTar
	fi

	echo "--------------------"
	##RUN TAR##
	if [ $flag = false ];
	then
		run_tar
	fi
#######################################################################################
	##CHECK BIN##
	if [ $flag = true ];
	then
	while read line
	do
	ssh -q $TARGET_HOST "test -e $BIN_PATH/$line"
	if [ $? -eq 0 ]; then
		
		echo "BIN | $line exists"
	else
		
		echo "BIN | not exist : $line"
		flag="false"
		#break
		exit 1
	fi
	done < fileList
	fi
	echo "--------------------"
	##RUN_BIN##
	if [ $flag = true ];
	then
		run_Bin
	fi

}

remove()
{	
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}; ./remove.sh"
}

run_Upload()
{ 	
	cd ~/installer_scripts
	./tarAndUpload.sh ${BRANCH_TO_BUILD} ${UPLOAD_BIN_PATH}
	
	if [ $? -eq 1 ];
	then
		exit 1

	elif [ $? -eq 0 ];
	then
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}; ./remove.sh"
	fi
	
	exit $?
	
}

run_tar()
{
	cd ~/installer_scripts
	./tarAndUpload.sh ${BRANCH_TO_BUILD} ${TAR_PATH}
	
	if [ $? -eq 1 ];
	then
		exit 1

	elif [ $? -eq 0 ];
	then
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}; ./remove.sh"
	fi
	
	exit $?
}

run_Bin(){

	cd ~/installer_scripts
	./newBin.sh ${BRANCH_TO_BUILD}
	
	if [ $? -eq 1 ];
	then
		exit 1

	elif [ $? -eq 0 ];
	then
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}; ./remove.sh"
	fi
	
	exit $?
}

main()
{
	BRANCH_TO_BUILD=${1}
	if [[ "${BRANCH_TO_BUILD}" == "" ]]
	then
		echo "ERROR : No Branch specified"
		return 1
	fi
	echo "installer Branh ${1}"
	
	for scenario in $@
	do
		checkFolder
		
	done
}
main "$@"
