#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.5 Ensure System Data Files and Security Updates Are Downloaded Automatically Is Enabled (Automated)"
orgScore="OrgScore1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > ConfigDataInstall=true - CriticalUpdateInstall=true "

	appidentifier="com.apple.SoftwareUpdate"
	value="ConfigDataInstall"
	value2="CriticalUpdateInstall"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefValue2=$(getPrefValue "${appidentifier}" "${value2}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="System data files and security update installs: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" && "${prefValue2}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "true" && "${prefValue2}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="System data files and security update installs: Disabled"
		fi
	fi
fi
printReport