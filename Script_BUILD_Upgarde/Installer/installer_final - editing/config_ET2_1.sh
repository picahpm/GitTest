#########retbuild##############################################################################

BRANCH=ET2.1
TARGET_HOST=retbuild@10.6.185.206
TARGET_PATH=/reuters/export/home/retbuild/GIT_Servers/3.5.711.1.1108-ET2.1

TMP_PATH=/tmp/BKK_ET_installer/$BRANCH

UPLOAD_BIN_PATH=$TARGET_PATH/Upload/Bin
BIN_PATH=$TARGET_PATH/bins_Sun-CC-5.10-STLport-newalloc_OCI-10*
TAR_PATH=$TARGET_PATH/tar_Sun-CC-5.10-STLport-newalloc_OCI-10*
LIB_PATH=$TARGET_PATH/libs_Sun-CC-5.10-STLport-newalloc_OCI-10*


######local#####################################################################################

LOCAL_HOST=dev1@172.23.9.152
LOCAL_PATH=/local/reference/bin/$BRANCH

#################################################################################################

JENKINS_PATH=/export/home/jenkins/workspace/jobs/installer_3.5.711.1.1108-ET2.1/workspace

########in Jenkins###############################################################################

JENKINS_TEMP_PACKAGE=~/TEMP_FOR_INSTALLER/$BRANCH

#############################################################################################

fileSet="EchoTRM.FX\nDateServer2\nEchoMM\nEventLogger\nGID.orders\nGID.admin\nGID.credit\nGID.rates\nGID.logs\nGID.stats\nregsvr\nLOMSServer\nSFCFeed\nFeedSim\nLOMS.om\nValServer"
fileTar="EchoTRM.FX*.tar.gz\nDateServer2*.tar.gz\nEchoMM*.tar.gz\nEventLogger*.tar.gz\nGID.orders*.tar.gz\nGID.admin*.tar.gz\nGID.credit*.tar.gz\nGID.rates*.tar.gz\nGID.logs*.tar.gz\nGID.stats*.tar.gz\nregsvr*.tar.gz\nLOMSServer*.tar.gz\nSFCFeed*.tar.gz\nFeedSim*.tar.gz\nLOMS.om*.tar.gz\nValServer*.tar.gz" #LOMS.views

##############################################################################################

