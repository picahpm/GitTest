#!/bin/bash
source config_ET2_3.sh 

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


run_Upload()
{ 	
	cd $JENKINS_PATH
	./newUpload.sh
	exit $?
	
}

run_tar()
{
	cd $JENKINS_PATH
	./newTar.sh
	exit $?
}

run_Bin(){

	cd $JENKINS_PATH
	./newBin.sh
	exit $?
}

main()
{
	BUILD_NUMBER=${1}
	if [[ "${BUILD_NUMBER}" == "" ]]
	then
		echo "ERROR : No build number specified"
		return 1
	fi
	echo "build number is ${1}"
	
	for scenario in $@
	do
		checkFolder
		
	done
}
main "$@"
