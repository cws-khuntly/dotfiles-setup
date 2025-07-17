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

#=====  FUNCTION  =============================================================
#          NAME:  uninstallFiles
#   DESCRIPTION:  Removes dotfiles as configured in the install.conf
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function uninstallFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="uninstallutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local uninstall_mode;
    local target_host;
    local -i target_port;
    local target_user;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} == 0 )) && return 3;

    uninstall_mode="${1}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstall_mode -> ${uninstall_mode}";
    fi

    case "${uninstall_mode}" in
        "${UNINSTALL_LOCATION_LOCAL}")
            (( ${#} != 1 )) && return 3;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: uninstallLocalFiles";
            fi

            [[ -n "${cname}" ]] && builtin unset -vcname;
            [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
            [[ -n "${ret_code}" ]] && builtin unset -vret_code;

            uninstallLocalFiles;
            ret_code="${?}";

            cname="uninstallutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstallLocalFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred performing file uninstall on host $(hostname -s). Please review logs.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File uninstall on host $(hostname -s) completed successfully.";
                fi
            fi
            ;;
        "${UNINSTALL_LOCATION_REMOTE}")
            (( ${#} != 4 )) && return 3;

            target_host="${2}";
            target_port="${3}";
            target_user="${4}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: uninstallRemoteFiles ${target_host} ${target_port} ${target_user}";
            fi

            [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
            [[ -n "${ret_code}" ]] && builtin unset -vret_code;

            uninstallRemoteFiles "${target_host}" "${target_port}" "${target_user}";
            ret_code="${?}";

            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstallRemoteFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred performing file uninstall on host ${target_host}. Please review logs.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File uninstall on host ${target_host} as user ${target_user} completed successfully.";
                fi
            fi
            ;;
        *)
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid installation mode was specified. uninstall_mode -> ${uninstall_mode}. Cannot continue.";
            fi
            ;;
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && builtin unset -verror_count;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
    [[ -n "${uninstall_mode}" ]] && builtin unset -vuninstall_mode;
    [[ -n "${target_host}" ]] && builtin unset -vtarget_host;
    [[ -n "${target_port}" ]] && builtin unset -vtarget_port;
    [[ -n "${target_user}" ]] && builtin unset -vtarget_user;

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

#=====  FUNCTION  =============================================================
#          NAME:  uninstallLocalFiles
#   DESCRIPTION:  Removes dotfiles as configured in the install.conf
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function uninstallLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="uninstallutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local entry;
    local removable_entry;
    local cmd_output;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    if [[ -f "${INSTALL_CONF}" ]] && [[ -r "${INSTALL_CONF}" ]] && [[ -s "${INSTALL_CONF}" ]]; then
        ## change the IFS
        IFS="${MODIFIED_IFS}";

        ## clean up home directory first
        for entry in $(< "${INSTALL_CONF}"); do
            [[ -z "${entry}" ]] && continue;
            [[ "${entry}" =~ ^\# ]] && continue;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
            fi

            entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
            fi

            if [[ -z "${removable_entry}" ]]; then
                return_code=1;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removable entry was null or empty.";
                fi

                continue;
            else
                if [[ -d "$(eval printf "%s" "${entry_target}")" ]] || [[ -L "$(eval printf "%s" "${entry_target}")" ]] || [[ -f "$(eval printf "%s" "${entry_target}")" ]]; then
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} $(eval printf "%s" "${entry_target}")";
                    fi

                    [[ -n "${cname}" ]] && builtin unset -vcname;
                    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;

                    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "$(eval printf "%s" "${entry_target}")";
                    ret_code="${?}";

                    cname="uninstallutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${entry_target} -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                    then
                        (( error_count += 1 ));

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove target ${entry_target}. Please remove manually.";
                        fi

                        continue;
                    else
                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Target ${entry_target} has been removed ";
                        fi
                    fi
                fi
            fi

            [[ -n "${ret_code}" ]] && builtin unset -vret_code;
            [[ -n "${entry_target}" ]] && builtin unset -ventry_target;
            [[ -n "${entry}" ]] && builtin unset -ventry;
        done

        ## restore the original ifs
        IFS="${CURRENT_IFS}";

        ## remove the installation directory
        if [[ -d "${INSTALL_ROOT}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${INSTALL_ROOT}";
            fi

            [[ -n "${cname}" ]] && builtin unset -vcname;
            [[ -n "${function_name}" ]] && builtin unset -vfunction_name;

            cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${INSTALL_ROOT}";
            ret_code="${?}";

            cname="uninstallutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${INSTALL_ROOT} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
            then
                (( error_count += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove target ${INSTALL_ROOT}. Please remove manually.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Target ${INSTALL_ROOT} has been removed ";
                fi
            fi
        fi
    else
        return_code=1;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -vret_code;
    [[ -n "${error_count}" ]] && builtin unset -verror_count;
    [[ -n "${entry}" ]] && builtin unset -ventry;
    [[ -n "${entry_target}" ]] && builtin unset -ventry_target;
    [[ -n "${cmd_output}" ]] && builtin unset -vcmd_output;

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

#=====  FUNCTION  =============================================================
#          NAME:  uninstallRemoteFiles
#   DESCRIPTION:  Removes dotfiles as configured in the install.conf
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function uninstallRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="uninstallutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local target_host;
    local -i target_port;
    local target_user;
    local sftp_send_file;
    local entry_target;
    local uninstall_response;
    local -i file_counter;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 3 )) && return_code=3;

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${WORK_DIR}";
    fi

    sftp_send_file="$(mktemp --tmpdir="${WORK_DIR}")";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_removal_script -> ${file_removal_script}";
    fi

    if [[ ! -e "${file_removal_script}" ]] || [[ ! -w "${file_removal_script}" ]]; then
        (( error_count += 1 ));

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file verification script ${file_removal_script}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Processing entries from ${INSTALL_CONF}";
        fi

        if [[ -s "${INSTALL_CONF}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file verification script ${file_removal_script}...";
            fi

            ## change the IFS
            IFS="${MODIFIED_IFS}";

            ## clean up home directory first
            for entry in $(< "${INSTALL_CONF}"); do
                [[ -z "${entry}" ]] && continue;
                [[ "${entry}" =~ ^\# ]] && continue;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
                fi

                entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                fi

                if (( file_counter == 0 )); then
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"rm -irf --preserve-root\" \"${entry_target:?}\" >| ${sftp_send_file}";
                    fi

                    { printf "%s %s %s\n" "rm -irf --preserve-root" "${entry_target:?}"; } >| "${sftp_send_file}";
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"rm -irf --preserve-root\" \"${entry_target:?}\" >> ${sftp_send_file}";
                    fi

                    { printf "%s %s %s\n" "rm -irf --preserve-root" "${entry_target:?}"; } >> "${sftp_send_file}";
                fi

                [[ -n "${ret_code}" ]] && builtin unset -vret_code;
                [[ -n "${entry_command}" ]] && builtin unset -ventry_command;
                [[ -n "${removable_entry}" ]] && builtin unset -vremovable_entry;
                [[ -n "${entry}" ]] && builtin unset -ventry;
            done

            ## restore the original ifs
            IFS="${CURRENT_IFS}";

            if [[ ! -s "${sftp_send_file}" ]]; then
                return_code=1;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file cleanup file ${sftp_send_file}. Please ensure the file exists and can be written to.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${sftp_send_file} ${target_host} ${ssh_port_number} ${target_user}" "${DEPLOY_TO_DIR}";
                fi

                [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
                [[ -n "${cname}" ]] && builtin unset -vcname;
                [[ -n "${ret_code}" ]] && builtin unset -vret_code;

                transferFiles "${TRANSFER_LOCATION_REMOTE}" "${sftp_send_file}" "${target_host}" "${ssh_port_number}" "${target_user}" "${DEPLOY_TO_DIR}";
                ret_code="${?}";

                cname="uninstallutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sftp / file_removal_script -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during the file removal process on host ${target_host} as user ${target_user}. Please review logs.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installRemoteFiles ${target_host} ${target_port} ${target_user} ${installation_script}";
                    fi

                    [[ -n "${cname}" ]] && builtin unset -vcname;
                    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
                    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

                    uninstall_response="$(fssh "${SSH_CONFIG_FILE}" "${target_host}" "${target_port}" "${target_user}" "${USABLE_TMP_DIR:-${TMPDIR}}/$(basename "${sftp_send_file}")")";
                    ret_code="${?}";

                    cname="uninstallutils.sh";
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
        else
            return_code=1;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_REMOTE} ${USABLE_TMP_DIR:-${TMPDIR}}/${sftp_send_file} ${target_hostname} ${target_ssh_port} ${target_ssh_user}";
    fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${USABLE_TMP_DIR:-${TMPDIR}}/${sftp_send_file}" "${target_hostname}" "${target_ssh_port}" "${target_ssh_user}";
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

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_file_list}";
    fi

    [[ -n "${cname}" ]] && builtin unset -vcname;
    [[ -n "${function_name}" ]] && builtin unset -vfunction_name;
    [[ -n "${ret_code}" ]] && builtin unset -vret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${sftp_send_file}";
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
    [[ -n "${target_host}" ]] && builtin unset -vtarget_host;
    [[ -n "${target_port}" ]] && builtin unset -vtarget_port;
    [[ -n "${target_user}" ]] && builtin unset -vtarget_user;
    [[ -n "${sftp_send_file}" ]] && builtin unset -vsftp_send_file;
    [[ -n "${entry_target}" ]] && builtin unset -ventry_target;
    [[ -n "${uninstall_response}" ]] && builtin unset -vuninstall_response;
    [[ -n "${file_counter}" ]] && builtin unset -vfile_counter;

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
