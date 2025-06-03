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
#          NAME:  cleanupFiles
#   DESCRIPTION:  Cleans up after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="cleanuputils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local operating_mode;
    local cleanup_file_list;
    local target_host;
    local -i target_port;
    local target_user;
    local -i start_epoch;
    local -i start_epoch;
    local -i runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    if [[ -z "${IS_CLEANUP_ENABLED}" ]] || [[ "${IS_CLEANUP_ENABLED}" == "${_FALSE}" ]]; then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Cleanup functionality has been disabled, exiting";
        fi

        return_code=0;
    else
        (( ${#} < 2 )) && return 3;

        operating_mode="${1}";
        cleanup_file_list="${2}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "operating_mode -> ${operating_mode}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        fi

        if [[ -n "${cleanup_file_list}" ]]; then
            case "${operating_mode}" in
                "${CLEANUP_LOCATION_LOCAL}")
                    (( ${#} != 2 )) && return 3;

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupLocalFiles ${cleanup_file_list}";
                    fi

                    [[ -n "${cname}" ]] && unset cname;
                    [[ -n "${function_name}" ]] && unset function_name;
                    [[ -n "${ret_code}" ]] && unset ret_code;

                    cleanupLocalFiles "${cleanup_file_list}";
                    ret_code="${?}";

                    cname="cleanuputils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupLocalFiles -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during local cleanup. Please review logs.";
                        fi
                    else
                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local file cleanup completed successfully.";
                        fi
                    fi
                    ;;
                "${CLEANUP_LOCATION_REMOTE}")
                    (( ${#} != 2 )) && return 3;

                    target_host="${3}";
                    target_port="${4}";
                    target_user="${5}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupRemoteFiles ${cleanup_file_list} ${target_host} ${target_port} ${target_user}";
                    fi

                    [[ -n "${cname}" ]] && unset cname;
                    [[ -n "${function_name}" ]] && unset function_name;
                    [[ -n "${ret_code}" ]] && unset ret_code;

                    cleanupRemoteFiles "${cleanup_file_list}" "${target_host}" "${target_port}" "${target_user}"
                    ret_code="${?}";

                    cname="cleanuputils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupRemoteFiles -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote cleanup of package files failed. Please review logs.";
                        fi
                    fi
                    ;;
                *)
                    return_code=1;

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
                    fi
                    ;;
            esac
        else
            return_code=1;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The list of files to operate against appears to be empty. Cannot continue.";
            fi
        fi

        if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi
    fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${operating_mode}" ]] && unset operating_mode;
    [[ -n "${cleanup_file_list}" ]] && unset forcleanup_file_listce_exec;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  cleanupLocalFiles
#   DESCRIPTION:  Cleans up locally after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="cleanuputils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local requested_files;
    local eligibleFile;
    local targetFile;
    local targetDir;
    local cmd_output;
    local files_to_process;
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

    (( ${#} != 1 )) && return 3;

    requested_files="${1}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "requested_files -> ${requested_files[*]}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mapfile -d \",\" -t files_to_process < <(printf \"%s\" \"${requested_files}\")";
    fi

    mapfile -d "," -t files_to_process < <(printf "%s" "${requested_files}");

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process[*]}";
    fi

    for eligible_file in "${files_to_process[@]}"; do
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligible_file -> ${eligible_file}";
        fi

        [[ -z "${eligible_file}" ]] && continue;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Check if file ${eligible_file} exists and removing if necessary";
        fi

        if [[ -d "${eligible_file}" ]] && [[ -w "${eligible_file}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -rf ${eligible_file:?}";
            fi

            [[ -n "${cmd_output}" ]] && unset cmd_output;
            [[ -n "${ret_code}" ]] && unset ret_code;

            cmd_output="$(rm -rf "${eligible_file:?}")";
            ret_code="${?}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "rm / ${eligible_file:?} ->ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove directory ${eligible_file}. Please remove the directory manually.";
                fi
            else
                if [[ -d "${eligible_file:?}" ]]; then
                    (( error_count += 1 ))

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove directory ${eligible_file}. Please remove the directory manually.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory ${eligible_file} successfully removed.";
                    fi
                fi
            fi
        elif [[ -e "${eligible_file}" ]] && [[ -f "${eligible_file}" ]] && [[ -w "${eligible_file}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -f ${eligible_file:?}";
            fi

            [[ -n "${cmd_output}" ]] && unset cmd_output;
            [[ -n "${ret_code}" ]] && unset ret_code;

            cmd_output="$(rm -f "${eligible_file:?}")";
            ret_code="${?}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "rm / ${eligible_file:?} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove file ${eligible_file}. Please remove the file manually.";
                fi
            else
                if [[ -e "${eligible_file}" ]] || [[ -f "${eligible_file}" ]]; then
                    (( error_count += 1 ))

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove file ${eligible_file}. Please remove the file manually.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${eligible_file} successfully removed.";
                    fi
                fi
            fi
        elif [[ -e "${eligible_file}" ]] && [[ -L "${eligible_file}" ]] && [[ -w "${eligible_file}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: unlink ${eligible_file:?}";
            fi

            [[ -n "${cmd_output}" ]] && unset cmd_output;
            [[ -n "${ret_code}" ]] && unset ret_code;

            cmd_output="$(unlink "${eligible_file:?}")";
            ret_code="${?}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "unlink / ${eligible_file:?} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove link ${eligible_file}. Please remove the file manually.";
                fi
            else
                if [[ -e "${eligible_file}" ]] || [[ -L "${eligible_file}" ]]; then
                    (( error_count += 1 ))

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove link ${eligible_file}. Please remove the file manually.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Link ${eligible_file} successfully removed.";
                    fi
                fi
            fi
        fi

        [[ -n "${eligibleFile}" ]] && unset eligibleFile;
        [[ -n "${targetFile}" ]] && unset targetFile;
        [[ -n "${ret_code}" ]] && unset ret_code;
    done

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${requested_files}" ]] && unset requested_files;
    [[ -n "${eligibleFile}" ]] && unset eligibleFile;
    [[ -n "${targetFile}" ]] && unset targetFile;
    [[ -n "${targetDir}" ]] && unset targetDir;
    [[ -n "${cmd_output}" ]] && unset cmd_output;
    [[ -n "${files_to_process[*]}" ]] && unset files_to_process;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  cleanupRemoteFiles
#   DESCRIPTION:  Cleans up a remote system after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="cleanuputils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i file_counter=0;
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local requested_files;
    local target_host;
    local -i target_port;
    local target_user;
    local file_cleanup_file;
    local eligible_file;
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

    (( ${#} != 4 )) && return 3;

    requested_files="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "requested_files -> ${requested_files}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp";
    fi

    file_cleanup_file="$(mktemp)";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_cleanup_file -> ${file_cleanup_file}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file cleanup script ${file_cleanup_file}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Clearing any existing content in ${file_cleanup_file}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cat /dev/null >| ${file_cleanup_file}";
        fi

        [[ -n "${ret_code}" ]] && unset ret_code;

        cat /dev/null >| "${file_cleanup_file}";
        ret_code="${?}";

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to clear any existing content in ${file_cleanup_file}. Please review logs.";
            fi
        else
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file cleanup file ${file_cleanup_file}...";
            fi

            for eligible_file in "${requested_files[@]}"; do
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_counter -> ${file_counter}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligible_file -> ${eligible_file}";
                fi

                [[ -z "${eligible_file}" ]] && continue;

                if (( file_counter == 0 )); then
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm -i --preserve-root -rf\" \"${eligible_file:?}\" >| ${file_cleanup_file}";
                    fi

                    { printf "%s %s %s\n" "-" "rm -i --preserve-root" "${eligible_file:?}"; } >| "${file_cleanup_file}";
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm -i --preserve-root -rf\" \"${eligible_file:?}\" >> ${file_cleanup_file}";
                    fi

                    { printf "%s %s %s\n" "-" "rm -i --preserve-root -rf" "${eligible_file:?}"; } >> "${file_cleanup_file}";
                fi

                (( file_counter += 1 ));

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_counter -> ${file_counter}";
                fi

                [[ -n "${eligible_file}" ]] && unset eligible_file;
            done

            if [[ ! -s "${file_cleanup_file}" ]]; then
                return_code="${ret_code}"

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file cleanup file ${file_cleanup_file}. Please ensure the file exists and can be written to.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file -> ${transfer_file}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${file_cleanup_file} ${target_host} ${target_port} ${target_user} ${DEPLOY_TO_DIR}";
                fi

                [[ -n "${cname}" ]] && unset cname;
                [[ -n "${function_name}" ]] && unset function_name;
                [[ -n "${ret_code}" ]] && unset ret_code;

                transferFiles "${TRANSFER_LOCATION_REMOTE}" "${file_cleanup_file}" "${target_host}" "${target_port}" "${target_user}" "${DEPLOY_TO_DIR}";
                ret_code="${?}";

                cname="cleanuputils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during the file cleanup process on host ${target_host} as user ${target_user}. Please review logs.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${file_cleanup_file} successfully generated and transferred to ${target_host} as user ${target_user}.";
                    fi
                fi
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -f "${file_cleanup_file}" ]] && rm -i --preserve-root -f "${file_cleanup_file}";

    [[ -n "${file_counter}" ]] && unset file_counter;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${requested_files[*]}" ]] && unset requested_files;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${file_cleanup_file}" ]] && unset file_cleanup_file;
    [[ -n "${eligible_file}" ]] && unset eligible_file;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
