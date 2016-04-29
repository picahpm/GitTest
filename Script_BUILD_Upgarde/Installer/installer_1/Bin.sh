#####Jenkins Thai#####
JENKINS_PATH=/export/home/dev1/system/bin
JENKINS_LIB=/export/home/dev1/system/lib

#####retbuild#####
HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/Servers/branches/3.5.711.1.1230-ET2.2
TMP_PATH=/tmp/BKK_ET_installer
BIN_PATH=$TARGET_PATH/bins_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*


echo "__________________________________"
echo "Welcome to bin.sh"


	#############################################
	#											#
	#				Check Version				#
	#											#
	#############################################
	
	cd $JENKINS_PATH
	
	echo "Check version EchoTRM.FX"
	ssh $HOST "cd ${BIN_PATH}; ./EchoTRM.FX -v > version.txt"
	
	echo "copy version.txt"
	scp $HOST:$BIN_PATH/version.txt $JENKINS_PATH/version.txt	
	ssh $HOST "rm ${BIN_PATH}/version.txt"
	
	newVersion=`cat version.txt`
	echo "NOW $newVersion VERSION"
	
	echo "Checking version..."
	ls -t|grep 3.5.| awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' >> versionList
	com_newVersion=`cat version.txt | awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }'`

	
	while read line
	do
		if [[ "$com_newVersion" -eq "$line" ]]; #version is installed
		then
			echo "$newVersion Installed,"
			echo "Program will exit."
			rm version.txt versionList 
			exit 0
		elif [[ "$com_newVersion" -le "$line" ]]; #old version
		then
			echo "$newVersion is old version,"
			echo "Program will exit."
			rm version.txt versionList
			exit 0
		fi


		if [[ "$com_newVersion" -gt "$line" ]]; 
		then
			#echo "$newVersion is new version"
			echo ""
		fi
	done < versionList
	echo "$newVersion isn't installing"	
	
	
	#########Installing############
	
	
	echo "====Installing $newVersion version===="
	mkdir $newVersion
	rm -rf version.txt versionList
	
	
	#############################################
	#					ZipFile					#
	#############################################
	
	echo "Make Folder BKK_ET_installer"
	ssh $HOST "mkdir -p $TMP_PATH;cd ${TMP_PATH}; mkdir -p $TMP_PATH/${newVersion}"
	
	zip="DateServer2 EchoTRM.FX EchoMM EventLogger GID.orders GID.admin GID.credit GID.rates GID.logs GID.stats regsvr LOMS.views LOMSServer SFCFeed"
	ssh $HOST "cd ${BIN_PATH}; zip ${TMP_PATH}/${newVersion}/${newVersion}.zip $zip"
	
		
	#############################################
	#				Copy ZipFile				#
	#############################################
	
	scp $HOST:$TMP_PATH/$newVersion/*.zip $JENKINS_PATH/$newVersion/
	
	##############################################
	#				Update LIB					#
	#############################################
	
	cd $JENKINS_LIB
	mkdir -p $newVersion
	scp $HOST:$LIB_PATH/*.so $JENKINS_LIB/$newVersion
	cd $JENKINS_PATH
	
	#############################################
	#					UnZip 					#
	#############################################
	cd $JENKINS_PATH/$newVersion
	echo "--UnZip--"
	unzip $newVersion.zip -d .
	rm $newVersion.zip
	
