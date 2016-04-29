#!/bin/bash
#####Jenkins Thai#####
JENKINS_PATH=/export/home/jenkins/workspace/jobs/installer_3.5.711.1.1230-ET2.2/workspace


######SOMETHING#######
SOME=ET22
SOMETHING=/tmp/$SOME

######local######
LOCAL_HOST=dev1@172.23.9.152
LOCAL_PATH=/export/home/dev1/system/bin

#####retbuild#####
TARAGET_HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/GIT_Servers/3.5.711.1.1230-ET2.2
TMP_PATH=/tmp/BKK_ET_installer
BIN_PATH=$TARGET_PATH/bins_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*


#############################################
#											#
#		Check version before download		# ##checking version local between retbuild
#											#
#############################################

cd $JENKINS_PATH
####checking version in retbuild
echo "Check version EchoTRM.FX... (at retbuild)"
ssh $TARAGET_HOST "cd ${BIN_PATH}; ./EchoTRM.FX -v > version.txt"
echo "copy version.txt"
scp $TARAGET_HOST:$BIN_PATH/version.txt $JENKINS_PATH/version.txt	
ssh $TARAGET_HOST "rm ${BIN_PATH}/version.txt"

newVersion=`cat version.txt`
echo "NOW $newVersion VERSION"

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
		echo "$newVersion Installed,"
		echo "Program will exit."
		rm versionList1
		exit 1
	elif [[ $((10#$com_newVersion)) -lt $((10#$line)) ]]; #old version
	then
		echo "$newVersion is old version ,"
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

cd $SOMETHING

cp $JENKINS_PATH/version.txt $SOMETHING/version.txt
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
	cd $SOMETHING/$newVersion
	ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
	scp $SOMETHING/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion								#Copy from Jenkins(TH) to dev1
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}/${newVersion}; unzip ${newVersion}.zip; rm $newVersion.zip"	#unzip
	rm ../versionTmp
	echo "installing completely"
	exit 0
fi
done < versionTmp
rm versionTmp
echo ""
echo "Dont have $newVersion version in Jenkins(Thai), Please download from retbuild."
echo ""
echo ""
######### Download from retbuild ############
mkdir -p $SOMETHING
cd $SOMETHING
echo "====	Installing $newVersion version in Jenkins(TH):${SOMETHING}	===="
mkdir $newVersion
rm -r version.txt versionList

#############################################
#			ZipFile	in retbuild				#
#############################################
echo "Make Folder BKK_ET_installer... (retbuild:/tmp/BKK_ET_installer)"
ssh $TARAGET_HOST "mkdir -p $TMP_PATH;cd ${TMP_PATH}; mkdir -p $TMP_PATH/${newVersion}"

zip="DateServer2 EchoTRM.FX EchoMM EventLogger GID.orders GID.admin GID.credit GID.rates GID.logs GID.stats regsvr LOMS.views LOMSServer SFCFeed"
ssh $TARAGET_HOST "cd ${BIN_PATH}; zip ${TMP_PATH}/${newVersion}/${newVersion}.zip $zip"


#############################################
#	Copy ZipFile to Jenkins(TH):/tmp/ET22			#
#############################################
echo "Download form retbuild to Jenkins(TH):/tmp/ET22."
scp $TARAGET_HOST:$TMP_PATH/$newVersion/*.zip $SOMETHING/$newVersion/$newVersion.zip

cd $SOMETHING
mkdir -p $newVersion
scp $TARAGET_HOST:$LIB_PATH/*.so $SOMETHING/$newVersion

###### Copy all file from Jenkins(TH) to dev1 ######
ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
scp $SOMETHING/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion

#############################################
#			Unzip in dev1 					#
#############################################
ssh $LOCAL_HOST "cd ${LOCAL_PATH}/${newVersion}; unzip ${newVersion}.zip; rm $newVersion.zip"

echo "installing completely"
