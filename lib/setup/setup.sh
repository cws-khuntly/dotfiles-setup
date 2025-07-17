#!/usr/bin/env bash

#==============================================================================
#          FILE:  basefunctions.sh
#         USAGE:  Import file into script and call relevant functions
#   DESCRIPTION:  Base system functions that don't necessarily belong elsewhere
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

# check for and create
[[ ! -d "${WORK_DIR}" ]] && mkdir -pv "${WORK_DIR}";

generateSshKeys;

if [[ -n "${?}" ]] && (( ${?} != 0 )); then
    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SSH key generation failed. Return code -> ${?}. This may prevent processing from completing.";
        writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SSH key generation failed. Return code -> ${?}. This may prevent processing from completing.";
    fi
fi

#======  FUNCTION  ============================================================
#          NAME:  runDeployLocalFiles
#   DESCRIPTION:  Deploys dotfiles but does not install.
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runDeployLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local transfer_file_list;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    transfer_file_list="${WORK_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR},";
    transfer_file_list+="${PACKAGE_CONFIG}|${DEPLOY_TO_DIR}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_LOCAL} ${transfer_file_list}";
	fi

	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	transferFiles "${TRANSFER_LOCATION_LOCAL}" "${transfer_file_list}";
	ret_code="${?}";

	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
	fi

	if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

		if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to perform file transfer to $(hostname -s). Please review logs.";
		fi
	else
		if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Successfully transferred files to host $(hostname -s) as user ${LOGNAME}.";
		fi
	fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && builtin unset -verror_count;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
    [[ -n "${transfer_file_list}" ]] && builtin unset -vtransfer_file_list;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  runDeployRemoteFiles
#   DESCRIPTION:  Deploys dotfiles but does not install.
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runDeployRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local target_host;
	local ssh_port_number;
	local target_user;
    local transfer_file_list;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 3 )) && return 3;

	target_host="${1}";
	ssh_port_number="${2}";
	target_user="${3}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_port_number -> ${ssh_port_number}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
	fi

    transfer_file_list="${WORK_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
	transfer_file_list="${WORK_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
	transfer_file_list+="${WORKING_CONFIG_FILE}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${ssh_port_number} ${target_user} ${DEPLOY_TO_DIR}";
	fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${ssh_port_number}" "${target_user}" "${DEPLOY_TO_DIR}";
	ret_code="${?}";

    cname="setup.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
	fi

	if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

		if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${target_host} as user ${target_user} has completed failed. Please review logs.";
		fi
	else
		if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host $(hostname -s) as user ${target_user} has completed successfully.";
		fi
	fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
	[[ -n "${error_count}" ]] && builtin unset -verror_count;
	[[ -n "${target_host}" ]] && builtin unset -vtarget_host;
	[[ -n "${ssh_port_number}" ]] && builtin unset -vssh_port_number;
	[[ -n "${target_user}" ]] && builtin unset -vtarget_user;
    [[ -n "${transfer_file_list}" ]] && builtin unset -vtransfer_file_list;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  runInstallLocalFiles
#   DESCRIPTION:  Installs dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runInstallLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installFiles ${INSTALL_LOCATION_LOCAL} ${INSTALL_TAR}";
	fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	installFiles "${INSTALL_LOCATION_LOCAL}" "${INSTALL_TAR}";
	ret_code="${?}";

    cname="setup.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installFiles -> ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host $(hostname -s) as user ${LOGNAME}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host $(hostname -s) as user ${LOGNAME} has completed successfully.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${cleanup_file_list}" ]] && builtin unset -vcleanup_file_list;

    cleanup_file_list="${INSTALL_TAR},";
    cleanup_file_list+="${WORK_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
    cleanup_file_list+="${WORK_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}"

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_file_list}";
    fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_file_list}";
    ret_code="${?}";

    cname="setup.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles / ${CLEANUP_LOCATION_LOCAL} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while executing cleanupFiles ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles ${CLEANUP_LOCATION_LOCAL} completed successfully.";
        fi
    fi

    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
    [[ -n "${error_count}" ]] && builtin unset -verror_count;
    [[ -n "${cleanup_file_list}" ]] && builtin unset -vcleanup_file_list;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  runInstallRemoteFiles
#   DESCRIPTION:  Installs dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runInstallRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
	local target_hostname;
	local target_ssh_port;
	local target_ssh_user;
    local cleanup_file_list;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 3 )) && return 3;

	target_hostname="${1}";
	target_ssh_port="${2}";
	target_ssh_user="${3}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_hostname -> ${target_hostname}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_ssh_port -> ${target_ssh_port}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_ssh_user -> ${target_ssh_user}";
    fi

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		 writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: buildPackage";
	fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	buildSetupPackage;
	ret_code="${?}";

    cname="setup.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "buildSetupPackage -> ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute buildSetupPackage. Please review logs.";
        fi
    else
        ## transfer
        [[ -n "${transfer_file_list}" ]] && builtin unset -vtransfer_file_list;

        transfer_file_list="${WORK_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR},";
        transfer_file_list+="${WORK_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR},";
        transfer_file_list+="${PACKAGE_CONFIG}|${DEPLOY_TO_DIR}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending installation script ${installation_script} to host ${target_host} as user ${target_user}...";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user} ${DEPLOY_TO_DIR}";
        fi

        [[ -n "${cname}" ]] && builtin unset -vcname;
        [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
        [[ -n "${ret_code}" ]] && builtin unset -vret_code;

        transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}" "${DEPLOY_TO_DIR}";
        ret_code="${?}";

        cname="installutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
            fi
        else
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${WORK_DIR}";
            fi

            installation_script="$(mktemp --tmpdir="${WORK_DIR}")";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installation_script -> ${installation_script}";
            fi

            if [[ ! -e "${installation_script}" ]] || [[ ! -w "${installation_script}" ]]; then
                return_code=1;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating installation script ${installation_script}...";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                        printf \"%s\n\n\" #!/usr/bin/env bash
                        printf \"%s\n\n\" PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;
                        printf \"%s\n\" umask 022;
                        printf \"%s\n\" mkdir -pv ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}
                        printf \"%s\n\" ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | ( cd \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}\" || return 1; tar -xf - );
                        printf \"%s\n\n\" chmod 755 ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup;
                        printf \"%s\n\n\" ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup -n ${DEPLOY_TO_DIR}/$(basename "${PACKAGE_SETUP_FILE}")
                        printf \"%s\n\n\" printf \"%s\" \${?}";
                fi

                ## build the install script
                {
                    printf "%s\n\n" "#!/usr/bin/env bash";
                    printf "%s\n\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
                    printf "%s\n" "umask 022;";
                    printf "%s\n" "mkdir -pv \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}\";":
                    printf "%s\n" "${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | ( cd \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}\" || return 1; tar -xf - );";
                    printf "%s\n\n" "chmod 755 ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup;";
                    printf "%s\n\n" "${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup -n $(basename "${PACKAGE_SETUP_FILE}");";
                    printf "%s\n\n" "printf "%s" \${?}";
                } >| "${installation_script}";

                if [[ ! -s "${installation_script}" ]]; then
                    return_code=1;

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
                    fi
                else
                    [[ -n "${transfer_file_list}" ]] && builtin unset -vtransfer_file_list;

                    transfer_file_list="${installation_script}|${DEPLOY_TO_DIR}/$(basename "${installation_script}")";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending installation script ${installation_script} to host ${target_host} as user ${target_user}...";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user}" "${DEPLOY_TO_DIR}";
                    fi

                    [[ -n "${cname}" ]] && builtin unset -vcname;
                    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
                    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

                    transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}" "${DEPLOY_TO_DIR}";
                    ret_code="${?}";

                    cname="installutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
                        fi
                    else
                        ## ok, files should be out there. lets go
                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installRemoteFiles ${target_host} ${target_port} ${target_user} ${installation_script}";
                        fi

                        [[ -n "${cname}" ]] && builtin unset -vcname;
                        [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
                        [[ -n "${ret_code}" ]] && builtin unset -vret_code;

                        install_response="$(installRemoteFiles "${target_host}" "${target_port}" "${target_user}" "${installation_script}")";
                        ret_code="${?}";

                        cname="setup.sh";
                        function_name="${cname}#${FUNCNAME[0]}";

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_response -> ${install_response}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installRemoteFiles -> ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) || [[ -z "${install_response}" ]]; then
                            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${target_hostname} as user ${target_ssh_user}. Please review logs.";
                            fi
                        else
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${target_hostname} as user ${target_ssh_user} has completed with response ${install_response}.";
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${cleanup_file_list}" ]] && builtin unset -vcleanup_file_list;

    [[ -n "${cname}" ]] && builtin unset -vcname;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    cleanup_file_list="${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
    cleanup_file_list+="${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
    cleanup_file_list+="${DEPLOY_TO_DIR}/${PACKAGE_CONFIG}";

    cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${cleanup_file_list}" "${target_hostname}" "${target_ssh_port}" "${target_ssh_user}";
    ret_code="${?}";

    cname="setup.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles / ${CLEANUP_LOCATION_REMOTE} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while executing cleanupFiles ${CLEANUP_LOCATION_REMOTE}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles ${CLEANUP_LOCATION_REMOTE} completed successfully.";
        fi
    fi

    [[ -n "${cleanup_file_list}" ]] && builtin unset -vcleanup_file_list;

    cleanup_file_list="${installation_script},";
    cleanup_file_list+="${WORK_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
    cleanup_file_list+="${WORK_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}"

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_file_list}";
    fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_file_list}";
    ret_code="${?}";

    cname="setup.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles / ${CLEANUP_LOCATION_LOCAL} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while executing cleanupFiles ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles ${CLEANUP_LOCATION_LOCAL} completed successfully.";
        fi
    fi

    [[ -n "${target_host}" ]] && builtin unset -vtarget_host;
	[[ -n "${error_count}" ]] && builtin unset -verror_count;
	[[ -n "${target_hostname}" ]] && builtin unset -vtarget_hostname;
	[[ -n "${target_ssh_port}" ]] && builtin unset -vtarget_ssh_port;
	[[ -n "${target_ssh_user}" ]] && builtin unset -vtarget_ssh_user;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
    [[ -n "${installation_script}" ]] && builtin unset -vinstallation_script;
    [[ -n "${cleanup_file_list}" ]] && builtin unset -vcleanup_file_list;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  runRemoveLocalFiles
#   DESCRIPTION:  Removes installed dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runRemoveLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	uninstallFiles "${UNINSTALL_LOCATION_LOCAL}";
	ret_code="${?}";

    cname="setup.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstallFiles -> ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute uninstallFiles with uninstall type of ${UNINSTALL_LOCATION_LOCAL}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File removal complete on host $(hostname -s) for user ${LOGNAME}.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  runRemoveRemoteFiles
#   DESCRIPTION:  Removes installed dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runRemoveRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="setup.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local target_host;
	local ssh_port_number;
	local target_user;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 3 )) && return 3;

	target_host="${1}";
	ssh_port_number="${2}";
	target_user="${3}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_port_number -> ${ssh_port_number}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: uninstallFiles ${UNINSTALL_LOCATION_REMOTE} ${target_host} ${ssh_port_number} ${target_user}";
	fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
	[[ -n "${function_name}" ]] && builtin unset -vfunction_name;
	[[ -n "${ret_code}" ]] && builtin unset -vret_code;

	uninstallFiles "${UNINSTALL_LOCATION_REMOTE}" "${target_host}" "${ssh_port_number}" "${target_user}";
	ret_code="${?}";

    cname="setup.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstallFiles -> ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		[[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute uninstallFiles with uninstall type of ${UNINSTALL_LOCATION_REMOTE} on host ${target_host} as user ${target_user}. Please review logs.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File removal on host ${target_host} as user ${target_user} complete.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${target_host}" ]] && builtin unset -vtarget_host;
	[[ -n "${ssh_port_number}" ]] && builtin unset -vssh_port_number;
	[[ -n "${target_user}" ]] && builtin unset -vtarget_user;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -vstart_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -vend_epoch;
    [[ -n "${runtime}" ]] && builtin unset -vruntime;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${cname}" ]] && builtin unset -vcname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
