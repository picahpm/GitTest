#!/bin/bash
#####Jenkins Thai#####
JENKINS_PATH=/export/home/jenkins/workspace/jobs/installer_3.5.711-RET3.5-trunk/workspace

#####retbuild#####
HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/GIT_Servers/installer_3.5.711-RET3.5
UPLOAD_BIN_PATH=$TARGET_PATH/Upload/Bin
TAR_PATH=$TARGET_PATH/tar_Sun-CC-5.10-STLport-newalloc_OCI-10*
BIN_PATH=$TARGET_PATH/bins_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*

fileSet="EchoTRM.FX\nDateServer2\nEchoMM\nEventLogger\nGID.orders\nGID.admin\nGID.credit\nGID.rates\nGID.logs\nGID.stats\nregsvr\nLOMSServer\nSFCFeed"
fileTar="EchoTRM.FX*.tar.gz\nDateServer2*.tar.gz\nEchoMM*.tar.gz\nEventLogger*.tar.gz\nGID.orders*.tar.gz\nGID.admin*.tar.gz\nGID.credit*.tar.gz\nGID.rates*.tar.gz\nGID.logs*.tar.gz\nGID.stats*.tar.gz\nregsvr*.tar.gz\nLOMSServer*.tar.gz\nSFCFeed*.tar.gz" #LOMS.views


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
	ssh -q $HOST "test -e $UPLOAD_BIN_PATH/$line"
	if [ $? -eq 0 ]; then
		echo "UPLOAD/Bin | $line exists"
	else
		echo "--------------------"
		echo "UPLOAD/Bin | not exist : $line"
		flag="false"
		break
	fi
	done < fileListTar

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
	ssh -q $HOST "test -e $TAR_PATH/$line"
	if [ $? -eq 0 ]; then
		
		echo "TAR* | $line exists"
	else
		echo "--------------------"
		echo "TAR* | not exist : $line"
		flag="true"
		break
	fi
	done < fileListTar
	fi

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
	ssh -q $HOST "test -e $BIN_PATH/$line"
	if [ $? -eq 0 ]; then
		
		echo "BIN | $line exists"
	else
		echo "--------------------"
		echo "BIN | not exist : $line"
		flag="false"
		break
	fi
	done < fileList
	fi

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
	if [ $? -eq 0 ]; then
		exit 0
	else
		exit 1
	
}

run_tar()
{
	cd $JENKINS_PATH
	./newTar.sh
	if [ $? -eq 0 ]; then
		exit 0
	else
		exit 1
	
}

run_Bin(){

	cd $JENKINS_PATH
	#./long.sh
	./newBin.sh
	if [ $? -eq 0 ]; then
		exit 0
	else
		exit 1
	
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