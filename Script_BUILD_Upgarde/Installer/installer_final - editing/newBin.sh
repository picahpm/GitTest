#!/bin/bash
BRANCH_TO_BUILD=${1}
source config_${BRANCH_TO_BUILD}.sh
binFolder()
{
	#############################################
	#											#
	#		Check version before download		# ##checking version local between retbuild
	#											#
	#############################################

	cd $JENKINS_PATH
	####checking version in retbuild
	echo "Check version EchoTRM.FX... (at retbuild)"
	ssh $TARGET_HOST "cd ${BIN_PATH}; ./EchoTRM.FX -v > version.txt"
	echo "copy version.txt"
	scp $TARGET_HOST:$BIN_PATH/version.txt $JENKINS_PATH/version.txt	
	ssh $TARGET_HOST "rm ${BIN_PATH}/version.txt"

	newVersion=`cat version.txt`
	echo "NOW!! :  new version is $newVersion"

	####checking version in local
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
			rm versionList1
			exit 1
		elif [[ $((10#$com_newVersion)) -lt $((10#$line)) ]]; #old version
		then
			echo "WARNING!! : $newVersion is old version ,"
			echo "Program will exit."
			rm versionList1
			exit 1
		fi


		if [[ $((10#$com_newVersion)) -gt $((10#$line)) ]]; 
		then
			#echo "$newVersion is new version"
			echo ""
		fi
	done < versionList1
	rm versionList1
	echo "$newVersion doesn't installing"	

	######################################################################################################################

	##### Checking in Jenkins /tmp/ET22 ######
	##### Checking version /tmp/ET22 between retbuild #####
	
	cd $JENKINS_TEMP_PACKAGE
	
	cp $JENKINS_PATH/version.txt $JENKINS_TEMP_PACKAGE/version.txt
	echo "Checking version in Jenkins (Thai)..."
	ls -t|grep 3.5.| awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' >> versionTmp
	echo "" >> versionTmp
	com_newVersion=`cat version.txt | awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }'`


	while read line
	do
	if [[ $((10#$com_newVersion)) -eq $((10#$line)) ]]; #version is installed
	then
		echo "$newVersion Installed in Jenkins(TH),"
		echo "Download this version..."
		cd $JENKINS_TEMP_PACKAGE/$newVersion
		ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
		scp $JENKINS_TEMP_PACKAGE/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion								#Copy from Jenkins(TH) to dev1
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}/${newVersion}; unzip ${newVersion}.zip; rm $newVersion.zip"	#unzip
		rm ../versionTmp
		echo "installation completed"		
		exit 0
	fi
	done < versionTmp
	rm versionTmp
	echo ""
	echo "Dont have $newVersion version in Jenkins(Thai), Please download from retbuild."
	echo ""
	echo ""
	######### Download from retbuild ############
	mkdir -p $JENKINS_TEMP_PACKAGE
	cd $JENKINS_TEMP_PACKAGE
	echo "====	Installing $newVersion version in Jenkins(TH):${JENKINS_TEMP_PACKAGE}	===="
	mkdir $newVersion
	
	#############################################
	#			ZipFile	in retbuild				#
	#############################################
	echo "Make Folder BKK_ET_installer... (retbuild:/tmp/BKK_ET_installer)"
	ssh $TARGET_HOST "mkdir -p $TMP_PATH;cd ${TMP_PATH}; mkdir -p $TMP_PATH/${newVersion}"

	zip="DateServer2 EchoTRM.FX EchoMM EventLogger GID.orders GID.admin GID.credit GID.rates GID.logs GID.stats regsvr LOMS.views LOMSServer SFCFeed FeedSim LOMS.om ValServer"
	ssh $TARGET_HOST "cd ${BIN_PATH}; zip ${TMP_PATH}/${newVersion}/${newVersion}.zip $zip"


	#############################################
	#	Copy ZipFile to Jenkins(TH):/tmp/ET22			#
	#############################################
	echo "Download form retbuild to Jenkins(TH):/tmp/ET22."
	scp $TARGET_HOST:$TMP_PATH/$newVersion/*.zip $JENKINS_TEMP_PACKAGE/$newVersion/$newVersion.zip

	cd $JENKINS_TEMP_PACKAGE
	mkdir -p $newVersion
	scp $TARGET_HOST:$LIB_PATH/*.so $JENKINS_TEMP_PACKAGE/$newVersion
	
	###### Copy all file from Jenkins(TH) to local ######
	echo "Updating local version"
	ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
	scp $JENKINS_TEMP_PACKAGE/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion
	
	#############################################
	#			Unzip in dev1 					#
	#############################################
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}/${newVersion}; unzip ${newVersion}.zip; rm $newVersion.zip"
	
	#####################################################
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
	echo "Build Branch ${1}"
	
	for scenario in $@
	do
		binFolder
	done


}
main "$@"