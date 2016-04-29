#!/bin/bash
BRANCH_TO_BUILD=${1}
FOLDER=${2}
source config_${BRANCH_TO_BUILD}.sh

if [[ "${FOLDER}" == "${UPLOAD_BIN_PATH}" ]];
	then
		echo "Going to $UPLOAD_BIN_PATH"
		FOLDER_PATH=$UPLOAD_BIN_PATH
	else
		echo "Goning to $TAR_PATH"
		FOLDER_PATH=$TAR_PATH
fi


folder()
{
	#############################################
	#											#
	#		Check version before download		# ##checking version local between retbuild
	#											#
	#############################################

	cd $JENKINS_PATH
	####checking version in retbuild

	echo "Checking Version from retbuild:Upload/Bin"
	ssh $TARGET_HOST "cd ${FOLDER_PATH}; ls -trl |grep EchoTRM| grep 3.5 | tail -1  >version.txt"
	scp $TARGET_HOST:$FOLDER_PATH/version.txt $JENKINS_PATH/version.txt
	ssh $TARGET_HOST "rm ${FOLDER_PATH}/version.txt"

	cd $JENKINS_PATH
	awk '{print $9}' version.txt > version1.txt
	awk -F'-' '{print $3}' version1.txt > version.txt


	newVersion=`cat version.txt`
	echo "NOW!! : new version is $newVersion"

	####checking version in dev1
	echo "Checking version in local..."
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}; ls -tr|grep 3.5. >> versionList"
	scp $LOCAL_HOST:$LOCAL_PATH/versionList $JENKINS_PATH/versionList
	ssh $LOCAL_HOST "rm ${LOCAL_PATH}/versionList"
	awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' versionList>>versionList1
	echo "" >> versionList1

	com_newVersion=`cat version.txt | awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }'`


	while read line
	do
		if [[ $((10#$com_newVersion)) -eq $((10#$line)) ]]; #version is installed
		then
			echo "WARNING!! : $newVersion Installed,"
			echo "Program will exit."
			rm versionList versionList1 version.txt version1.txt
			exit 1
		elif [[ $((10#$com_newVersion)) -lt $((10#$line)) ]]; #old version
		then
			echo "WARNING!! : $newVersion is old version ,"
			echo "Program will exit."
			rm versionList versionList1 version.txt version1.txt
			exit 1
		fi


		if [[ $((10#$com_newVersion)) -gt $((10#$line)) ]]; 
		then
			#echo "$newVersion is new version"
			echo ""
		fi
	done < versionList1
	rm versionList versionList1 version.txt version1.txt
	echo "$newVersion isn't installing"	

	######################################################################################################################

	##### Checking in Jenkins  ######
	##### Checking version TEMP_INSTALLER between retbuild #####

	cd $JENKINS_TEMP_PACKAGE

	echo "Checking version in ${JENKINS_TEMP_PACKAGE} (Thai Jenkins)..."
	echo ""
	ls -t|grep 3.5.| awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' >> versionTmp
	echo "" >> versionTmp

	while read line
	do
	if [[ $((10#$com_newVersion)) -eq $((10#$line)) ]]; 
	then
		echo "$newVersion Installed in Jenkins(TH),"
		echo "Download this version..."
		cd $JENKINS_TEMP_PACKAGE/$newVersion
		ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
		scp $JENKINS_TEMP_PACKAGE/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion								
		cd $JENKINS_TEMP_PACKAGE/$newVersion
		ls *.tar.gz > tarList	
		for line in $(<tarList)
		do
			ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; /bin/gunzip < $line | /bin/tar xvf -"
		done
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; rm -r *.tar.gz"	
		echo "installation completed"	
		rm ../versionTmp
		exit 0
	fi
	done < versionTmp
	rm versionTmp
        echo ""
	echo "Dont have $newVersion version, Please download from retbuild."
	echo ""
	echo ""
	######### Download from retbuild ############
	mkdir -p $JENKINS_TEMP_PACKAGE
	cd $JENKINS_TEMP_PACKAGE
	echo "====	Installing $newVersion version in Jenkins(TH):${JENKINS_TEMP_PACKAGE}	===="
	mkdir $newVersion
	#rm -r version.txt versionList


	#############################################
	#	Copy tar.gz to Jenkins(TH):/tmp/ET22			#
	#############################################
        cd $JENKINS_TEMP_PACKAGE
	mkdir -p $JENKINS_TEMP_PACKAGE
	echo "Download form retbuild to Jenkins(TH):${JENKINS_TEMP_PACKAGE}..."
	scp $TARGET_HOST:$FOLDER_PATH/*$newVersion*.tar.gz $JENKINS_TEMP_PACKAGE/$newVersion

	mkdir -p $newVersion
	scp $TARGET_HOST:$LIB_PATH/*.so $JENKINS_TEMP_PACKAGE/$newVersion

	###### Copy all file from Jenkins(TH) to dev1 ######
	echo "Updating local version..."
	ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
	scp $JENKINS_TEMP_PACKAGE/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion

	#untar.gz
	cd $JENKINS_TEMP_PACKAGE/$newVersion
	ls *.tar.gz > tarList	
	for line in $(<tarList)
	do
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; /bin/gunzip < $line | /bin/tar xvf -"
	done
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; rm -rf *.tar.gz"
	#######################################################################################
	
	cd $JENKINS_TEMP_PACKAGE

	main=`ls |grep 3.5 |wc -l`
	result=`expr $main - 1`
	if [ "$result" -gt "0" ]
	then
			folder=`ls -trl|grep 3.5 |head -$result|awk '{print $9}'`
			echo "$folder is(are) going to delete..."
			rm -rf $folder

	else
			echo "No need to remove "
	fi
	echo "installation completed"
}

main()
{	
	BRANCH_TO_BUILD=${1}
	if [[ "${BRANCH_TO_BUILD}" == "" ]]
	then
		echo "ERROR : No Branch specified"
		return 1
	fi
	echo "installer Branch ${1}"
	
	for scenario in $@
	do
		
		folder
	done


}
main "$@"