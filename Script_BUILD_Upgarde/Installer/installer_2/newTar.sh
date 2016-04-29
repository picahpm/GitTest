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
TARGET_HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/GIT_Servers/3.5.711.1.1230-ET2.2
TAR_PATH=$TARGET_PATH/tar_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*

#############################################
#											#
#		Check version before download		# ##checking version dev1 between retbuild
#											#
#############################################

cd $JENKINS_PATH
####checking version in retbuild

echo "Checking Version from retbuild:Upload/Bin"
ssh $TARGET_HOST "cd ${TAR_PATH}; ls -l |grep EchoTRM| grep 3.5>version.txt"
scp $TARGET_HOST:$TAR_PATH/version.txt $JENKINS_PATH/version.txt
ssh $TARGET_HOST "rm ${TAR_PATH}/version.txt"

cd $JENKINS_PATH
awk '{print $9}' version.txt > version1.txt
awk -F'-' '{print $3}' version1.txt > version.txt


newVersion=`cat version.txt`
echo "NOW $newVersion VERSION"

####checking version in dev1
echo "Checking version in CURRENT (dev1)"
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
		rm versionList versionList1 version.txt version1.txt
		exit 1
	elif [[ $((10#$com_newVersion)) -lt $((10#$line)) ]]; #old version
	then
		echo "$newVersion is old version ,"
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

##### Checking in Jenkins /tmp/ET22 ######
##### Checking version /tmp/ET22 between retbuild #####

cd $SOMETHING

echo "Checking version in /tmp/ET22 (Jenkins Thai)"
ls -t|grep 3.5.| awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' >> versionTmp
echo "" >> versionTmp

while read line
do
if [[ $((10#$com_newVersion)) -eq $((10#$line)) ]]; #version is installed
then
	echo "$newVersion Installed in Jenkins(TH),"
	echo "Download this version..."
	cd $SOMETHING/$newVersion
	ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
	scp $SOMETHING/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion								#Copy from Jenkins(TH) to dev1
	cd $SOMETHING/$newVersion
	ls *.tar.gz > tarList	
	for line in $(<tarList)
	do
		ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; /bin/gunzip < $line | /bin/tar xvf -"
	done
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; rm -r *.tar.gz"		
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
mkdir -p $SOMETHING
cd $SOMETHING
echo "====	Installing $newVersion version in Jenkins(TH):${SOMETHING}	===="
mkdir $newVersion
#rm -r version.txt versionList


#############################################
#	Copy tar.gz to Jenkins(TH):/tmp/ET22			#
#############################################
cd $SOMETHING
echo "Download form retbuild to Jenkins(TH):${SOMETHING}"
scp $TARGET_HOST:$TAR_PATH/*$newVersion*.tar.gz $SOMETHING/$newVersion

mkdir -p $newVersion
scp $TARGET_HOST:$LIB_PATH/*.so $SOMETHING/$newVersion

###### Copy all file from Jenkins(TH) to dev1 ######
ssh $LOCAL_HOST "mkdir -p $LOCAL_PATH/$newVersion"
scp $SOMETHING/$newVersion/* $LOCAL_HOST:$LOCAL_PATH/$newVersion

#untar.gz
cd $SOMETHING/$newVersion
ls *.tar.gz > tarList	
for line in $(<tarList)
do
	ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; /bin/gunzip < $line | /bin/tar xvf -"
done
ssh $LOCAL_HOST "cd ${LOCAL_PATH}/$newVersion; rm -rf *.tar.gz"
