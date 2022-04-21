#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.10 Ensure Secure Keyboard Entry terminal.app is Enabled (Automated)"
orgScore="OrgScore2_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.Terminal > SecureKeyboardEntry=true"

	appidentifier="com.apple.Terminal"
	value="SecureKeyboardEntry"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Secure Keyboard Entry in terminal.app: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Secure Keyboard Entry in terminal.app: Disabled"
		fi
	fi
fi
printReport