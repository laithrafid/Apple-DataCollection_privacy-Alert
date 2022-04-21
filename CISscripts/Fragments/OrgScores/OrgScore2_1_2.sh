#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.1.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled (Automated)"
orgScore="OrgScore2_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u firstuser defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18"

	appidentifier="com.apple.controlcenter"
	value="NSStatusItem Visible Bluetooth"
	# function check2_1_2 {
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")

	comment="Show Bluetooth status in menu bar: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "true" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Enable Show Bluetooth status in menu bar"
			# Remediation
			if [[ "${remediateResult}" == "enabled" ]]; then
				su -l ${currentUser} -c "defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18"
				killall ControlCenter
				# re-check
				sleep 1
				prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
				prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
				if [[ "${prefValueAsUser}" == "true" ]]; then
					result="Passed After Remediation"
					comment="Show Bluetooth status in menu bar: Enabled"
				else
					result="Failed After Remediation"
				fi
			fi
		fi
	fi
fi
printReport