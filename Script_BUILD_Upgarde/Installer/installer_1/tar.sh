#####Jenkins Thai#####
JENKINS_PATH=/export/home/dev1/system/bin
JENKINS_LIB=/export/home/dev1/system/lib

#####retbuild#####
HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/Servers/branches/3.5.711.1.1230-ET2.2
TAR_PATH=$TARGET_PATH/tar_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*


echo "__________________________________"
echo "Welcome to tar.sh" 
 
	#################################################
	#				CHECK VERSION					#
	#################################################
	
	cd $JENKINS_PATH
	
	ssh $HOST "cd ${TAR_PATH}; ls -l |grep EchoTRM|grep 3.5.711.1.12>version.txt"
	scp $HOST:$TAR_PATH/version.txt $JENKINS_PATH/version.txt
	ssh $HOST "rm ${TAR_PATH}/version.txt"
	
	cd $JENKINS_PATH
	awk '{print $9}' version.txt > version1.txt
	awk -F'-' '{print $3}' version1.txt > version.txt
	
	newVersion=`cat version.txt`
	echo "NOW $newVersion VERSION"
	
	echo "Checking version..."
	ls|grep 3.5.| awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }' >> versionList
	com_newVersion=`cat version.txt | awk -F. '{ printf("%03d%03d%03d%03d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5,$6,$7,$8); }'`

	
	while read line
	do
		if [[ "$com_newVersion" -eq "$line" ]]; #version is installed
		then
			echo "$newVersion Installed,"
			echo "Program will exit."
			rm version.txt version1.txt versionList
			exit 0
		elif [[ "$com_newVersion" -le "$line" ]]; #old version
		then
			echo "$newVersion is old version,"
			echo "Program will exit."
			rm version.txt version1.txt versionList
			exit 0
		fi


		if [[ "$com_newVersion" -gt "$line" ]]; 
		then
			#echo "$newVersion is new version"
			echo ""
		fi
	done < versionList
	echo "$newVersion isn't installing"	
	
	
	mkdir $newVersion
	rm version.txt version1.txt versionList
	cd $newVersion

	#############################################
	#					COPY					#
	#############################################
	
	echo "====Installing $newVersion version===="
	scp $HOST:$TAR_PATH/*$newVersion*.tar.gz .
	
	
	#############################################
	#				UNTAR tar.gz				#
	#############################################
	
	ls *.tar.gz > tarList

	while read line
	do
			echo "Extract tar file $line..."
			/bin/gunzip < $line | /bin/tar xvf -
	done < tarList

	rm -rf *tar.gz
	
	
	##############################################
	#				Update LIB					#
	#############################################
	
	cd $JENKINS_LIB
	mkdir $newVersion
	scp $HOST:$LIB_PATH/*.so $JENKINS_LIB/$newVersion
	cd $JENKINS_PATH

