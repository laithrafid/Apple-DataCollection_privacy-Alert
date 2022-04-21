#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.3 Ensure install.log Is Retained for 365 or More Days and No Maximum Size (Automated)"
orgScore="OrgScore3_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > add 'ttl=365' to /etc/asl/com.apple.install"

	installRetention="$(grep -c ttl=365 /etc/asl/com.apple.install)"
	if [[ "${installRetention}" = "1" ]]; then
		result="Passed"
		comment="Retain install.log: 365 or more days"
	else 
		result="Failed"
		comment="Retain install.log: Less than 365 days"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			mv /etc/asl/com.apple.install{,.old}
			sed '$s/$/ ttl=365/' /etc/asl/com.apple.install.old > /etc/asl/com.apple.install
			chmod 644 /etc/asl/com.apple.install
			chown root:wheel /etc/asl/com.apple.install			
			#re-check
			installRetention="$(grep -c ttl=365 /etc/asl/com.apple.install)"
			if [[ "${installRetention}" = "1" ]]; then
				result="Passed After Remediation"
				comment="Retain install.log: 365 or more days"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport