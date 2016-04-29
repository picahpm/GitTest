#!/bin/csh
set BRANCH_PATH=${1}
set BRANCH=`echo ${1}|cut -d'/' -f1`
cd $HOME/GIT_Servers
if ( -d $BRANCH )then
				echo "ncq-retbuild02(Linux) - Build ${BRANCH}"
				cd $HOME/GIT_Servers/$BRANCH_PATH
				perl ./githelper.pl -t release -B rstl_robot@apac.reuters.com -P Welcome1
else
				echo "No branch to build."
				exit 1
endif
