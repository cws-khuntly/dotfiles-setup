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
#          NAME:  transferFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="transferutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local operating_mode;
    local files_to_process;
    local target_host;
    local -i target_port;
    local target_user;
    local target_dir;
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

    (( ${#} < 2 )) && return 3;

    operating_mode="${1}";
    files_to_process="${2}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "operating_mode -> ${operating_mode}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process}";
    fi

    case "${operating_mode}" in
        "${TRANSFER_LOCATION_LOCAL}")
            (( ${#} != 2 )) && return 3;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferLocalFiles ${files_to_process}";
            fi

            [[ -n "${cname}" ]] && unset cname;
            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${ret_code}" ]] && unset ret_code;

            transferLocalFiles "${files_to_process}";
            ret_code="${?}";

            cname="transferutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferLocalFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File transfer to host $(hostname -s) has failed. Please review logs.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File transfer to host $(hostname -s) has completed successfully.";
                fi
            fi
            ;;
        "${TRANSFER_LOCATION_REMOTE}")
            (( ${#} != 6 )) && return 3;

            target_host="${3}";
            target_port="${4}";
            target_user="${5}";
            target_dir="${6}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_dir -> ${target_dir}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferRemoteFiles ${files_to_process} ${target_host} ${target_port} ${target_user} ${target_dir}";
            fi

            [[ -n "${cname}" ]] && unset cname;
            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${ret_code}" ]] && unset ret_code;

            transferRemoteFiles "${files_to_process}" "${target_host}" "${target_port}" "${target_user}" "${target_dir}";
            ret_code="${?}";

            cname="transferutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferRemoteFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File transfer to host ${target_host} has failed. Please review logs.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File transfer to host ${target_host} has completed successfully.";
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

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${operating_mode}" ]] && unset operating_mode;
    [[ -n "${files_to_process}" ]] && unset files_to_process;
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
#          NAME:  transferLocalFiles
#
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="transferutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local file_listing;
    local files_to_process;
    local eligibleFile;
    local target_file;
    local target_dir;
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

    file_listing="${1}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_listing -> ${file_listing}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mapfile -t files_to_process < <(printf %s ${file_listing});";
    fi

    mapfile -d "," -t files_to_process < <(printf "%s" "${file_listing}");

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process[*]}";
    fi

    if [[ -z "${files_to_process[*]}" ]] || (( ${#files_to_process[@]} == 0 )); then
		return_code="${ret_code}"

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File listing was null or empty. Please review logs.";
        fi
    else
        for eligible_file in "${files_to_process[@]}"; do
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligible_file -> ${eligible_file}";
            fi

            [[ -z "${eligible_file}" ]] && continue;

            source_file="$(awk -F "|" '{print $1}' <<< "${eligible_file}")";
            target_file="$(basename "$(awk -F "|" '{print $1}' <<< "${eligible_file}")")";
            target_dir="$(awk -F "|" '{print $2}' <<< "${eligible_file}")";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_file -> ${source_file}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_file -> ${target_file}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_dir -> ${target_dir}";
            fi

            if [[ -n "${source_file}" ]] && [[ -n "${target_file}" ]] && [[ -n "${target_dir}" ]]; then
                if [[ -n "${source_file}" ]] && [[ -f "${source_file}" ]] && [[ -r "${source_file}" ]]; then
                    [[ ! -d "${target_dir}" ]] && mkdir "${target_dir}";
                    [[ -f "${target_dir}/${target_file}" ]] && rm -f "${target_dir}/${target_file}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp ${source_file} ${target_dir}/${target_file}";
                    fi

                    [[ -n "${ret_code}" ]] && unset ret_code;

                    cmd_output="$(cp "${source_file}" "${target_dir}/${target_file}")";
                    ret_code="${?}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cp / ${source_file} ${target_dir}/${target_file} -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to copy source file ${source_file} to ${target_dir}/${target_file}. Please review logs.";
                        fi
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Source file ${source_file} does not exist. Skipping entry.";
                    fi

                    continue;
                fi

                (( file_counter += 1 ));

                [[ -n "${target_dir}" ]] && unset target_dir;
                [[ -n "${target_file}" ]] && unset target_file;
                [[ -n "${source_file}" ]] && unset source_file;
                [[ -n "${eligible_file}" ]] && unset eligible_file;
            fi
        done
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${file_listing}" ]] && unset file_listing;
    [[ -n "${files_to_process[*]}" ]] && unset files_to_process;
    [[ -n "${eligibleFile}" ]] && unset eligibleFile;
    [[ -n "${target_file}" ]] && unset target_file;
    [[ -n "${target_dir}" ]] && unset target_dir;
    [[ -n "${cmd_output}" ]] && unset cmd_output;

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
#          NAME:  transferRemoteFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="transferutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local file_list;
    local target_host;
    local -i target_port;
    local target_user;
    local target_dir;
    local sftp_send_file;
    local files_to_process;
    local eligibleFile;
    local file_counter;
    local cleanup_file_list;
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

    (( ${#} != 5 )) && return_code=3;

    file_list="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    target_dir="${5}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_dir -> ${target_dir}";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp";
    fi

    sftp_send_file="$(mktemp)";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sftp_send_file -> ${sftp_send_file}";
    fi

    if [[ ! -e "${sftp_send_file}" ]] || [[ ! -w "${sftp_send_file}" ]]; then
        return_code=1;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mapfile -t files_to_process < <(printf %s ${file_list})";
        fi

        mapfile -d "," -t files_to_process < <(printf "%s" "${file_list}");

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating batch file ${sftp_send_file}...";
        fi

        if [[ -z "${files_to_process[*]}" ]] || (( ${#files_to_process[*]} == 0 )); then
            return_code=1;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
            fi
        else
            for eligible_file in "${files_to_process[@]}"; do
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligible_file -> ${eligible_file}";
                fi

                [[ -z "${eligible_file}" ]] && continue;

                if [[ -n "${source_file}" ]] && [[ -f "${source_file}" ]] && [[ -r "${source_file}" ]]; then
                    if (( file_counter == 0 )); then
                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s\\n\" ${eligible_file} >| ${sftp_send_file}";
                        fi

                        { printf "%s\n" "${eligible_file}"; } >| "${sftp_send_file}";
                    else
                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s\\n\" ${eligible_file} >> ${sftp_send_file}";
                        fi

                        { printf "%s\n" "${eligible_file}"; } >> "${sftp_send_file}";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Source file ${eligible_file} does not exist. Skipping entry.";
                    fi

                    continue;
                fi

                (( file_counter += 1 ));

                [[ -n "${eligible_file}" ]] && unset eligible_file;
            done

            if [[ ! -s "${sftp_send_file}" ]] || (( file_counter != ${#files_to_process[*]} )); then
                return_code=1;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending requested files to host ${target_host} as user ${target_user}...";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: send-file --files-from=${sftp_send_file} ${target_user}@${target_host}:${target_dir}";
                fi

                [[ -n "${function_name}" ]] && unset function_name;
                [[ -n "${cname}" ]] && unset cname;
                [[ -n "${ret_code}" ]] && unset ret_code;

                cmd_output="$(send-file "--files-from=${sftp_send_file}" "${target_user}@${target_host}:${target_dir}")";
                ret_code="${?}";

                cname="transferutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "send-file / sftp_send_file -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while transferring the package. Please review logs.";
                    fi
                fi
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${cleanup_file_list}" ]] && unset cleanup_file_list;

    cleanup_file_list="${sftp_send_file}"

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_file_list}";
    fi

    [[ -n "${cname}" ]] && unset cname;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${ret_code}" ]] && unset ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_file_list}";
    ret_code="${?}";

    cname="transferutils.sh";
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

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${file_list}" ]] && unset file_list;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${sftp_send_file}" ]] && unset sftp_send_file;
    [[ -n "${files_to_process[*]}" ]] && unset files_to_process;
    [[ -n "${eligibleFile}" ]] && unset eligibleFile;
    [[ -n "${target_file}" ]] && unset target_file;
    [[ -n "${target_dir}" ]] && unset target_dir;
    [[ -n "${file_counter}" ]] && unset file_counter;
    [[ -n "${cleanup_file_list}" ]] && unset cleanup_file_list;
    [[ -n "${cmd_output}" ]] && unset cmd_output;

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

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
