#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.3 Ensure Download New Updates When Available is Enabled (Automated)"
orgScore="OrgScore1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticDownload=true"

	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticDownload"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Download new updates when available: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Download new updates when available: Disabled"
		fi
	fi
fi
printReport