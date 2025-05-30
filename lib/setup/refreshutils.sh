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
#          NAME:  refreshFiles
#   DESCRIPTION:  Re-loads existing setup for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function refreshFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="refreshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local refresh_mode;
    local target_host;
    local target_port;
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

    refresh_mode="${1}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "refresh_mode -> ${refresh_mode}";
    fi

    case "${refresh_mode}" in
        "${INSTALL_LOCATION_LOCAL}")
            (( ${#} != 1 )) && return 3;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: refreshLocalFiles";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            refreshLocalFiles;
            ret_code="${?}";

            cname="refreshutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "refreshLocalFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local installation of package failed. Please review logs.";
                fi
            fi
            ;;
        "${INSTALL_LOCATION_REMOTE}")
            (( ${#} != 4 )) && return 3;

            target_host="${2}";
            target_port="${3}";
            target_user="${4}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: refreshRemoteFiles ${target_host} ${target_port} ${target_user}";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            refreshRemoteFiles "${target_host}" "${target_port}" "${target_user}";
            ret_code="${?}";

            cname="refreshutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "refreshRemoteFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote refresh of files failed. Please review logs.";
                fi
            else
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${refresh_mode} on host ${target_host} as user ${target_user} has completed successfully.";
                fi
            fi
            ;;
        *)
            (( error_count += 1 ));

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid installation mode was specified. refresh_mode -> ${refresh_mode}. Cannot continue.";
            fi
            ;;
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${refresh_mode}" ]] && unset -v refresh_mode;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${target_user}" ]] && unset -v target_user;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  installLocalFiles
#   DESCRIPTION:  Re-loads existing setup for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function refreshLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="refreshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local cmd_output;
    local entry;
    local entry_command;
    local entry_source;
    local entry_target;
    local entry_permissions;
    local cleanup_list;
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

    if [[ -f "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | ( cd ${SOURCE_PATH}; tar -xf - )";
        fi

        [[ -n "${cmd_output}" ]] && unset -v cmd_output;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        cmd_output="$("${UNARCHIVE_PROGRAM}" -c "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" | ( cd "${SOURCE_PATH}" || exit 1; tar -xf - ))";
        ret_code="${?}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "decompress -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while unpacking the file archive. Please review logs.";
            fi
        else
            if [[ -s "${INSTALL_CONF}" ]]; then
                ## change the IFS
                IFS="${MODIFIED_IFS}";

                ## clean up home directory first
                for entry in $(< "${INSTALL_CONF}"); do
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
                    fi

                    [[ -z "${entry}" ]] && continue;
                    [[ "${entry}" =~ ^\# ]] && continue;

                    entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                    entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                    entry_target="$(cut -d "|" -f 3 <<< "${entry}")";
                    entry_permissions="$(cut -d "|" -f 4 <<< "${entry}")";
                    recurse_permissions="$(cut -d "|" -f 4 <<< "${entry}")";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_command -> ${entry_command}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_source -> ${entry_source}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_permissions -> ${entry_permissions}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "recurse_permissions -> ${recurse_permissions}";
                    fi

                    if [[ -z "${entry_command}" ]] || [[ -z "${entry_source}" ]] || [[ -z "${entry_target}" ]] && [[ "${entry_command}" != "mkdir" ]]; then
                        (( error_count += 1 ));

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}, entry_source -> ${entry_source}, entry_target -> ${entry_target}";
                        fi

                        continue;
                    fi

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}";
                    fi

                    case "${entry_command}" in
                        "ln")
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing symbolic link ${entry_target} if exists...";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                                    [[ -L \$(eval printf \"%s\" ${entry_target}) ]] && unlink \$(eval printf \"%s\" ${entry_target})
                                    [[ -f \$(eval printf \"%s\" ${entry_target}) ]] && rm -f \$(eval printf \"%s\" ${entry_target})";
                            fi

                            [[ -L "$(eval printf "%s" "${entry_target}")" ]] && unlink "$(eval printf "%s" "${entry_target}")";
                            [[ -f "$(eval printf "%s" "${entry_target}")" ]] && rm -f "$(eval printf "%s" "${entry_target}")";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating symbolic link ${entry_source} -> ${entry_target}";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ln -s eval printf \"%s\" ${entry_source} eval printf \"%s\" ${entry_target}";
                            fi

                            [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                            [[ -n "${ret_code}" ]] && unset -v ret_code;

                            cmd_output="$(ln -s "$(eval printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")")";
                            ret_code="${?}";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ln/${entry_source},${entry_target} -> ret_code -> ${ret_code}";
                            fi

                            if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                            then
                                (( error_count += 1 ));

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create symbolic link ${entry_target} with source ${entry_source}.";
                                fi

                                continue;
                            else
                                if [[ -n "${entry_permissions}" ]]; then
                                    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                                    cmd_output="$(chmod -h "${entry_permissions}" "$(eval printf "%s" "${entry_target}")")";
                                    ret_code="${?}";

                                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "chmod -> ret_code -> ${ret_code}";
                                    fi

                                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                    then
                                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to change permissions of ${entry_target} to ${entry_permissions}.";
                                        fi
                                    fi
                                fi

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Symbolic link ${entry_source} -> ${entry_target} created.";
                                fi
                            fi
                            ;;
                        "cp")
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Copying file ${entry_source} to ${entry_target}";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp -p ${entry_source} ${entry_target}";
                            fi

                            [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                            [[ -n "${ret_code}" ]] && unset -v ret_code;

                            cmd_output="$(cp -p "$(eval printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")")";
                            ret_code="${?}";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cp/${entry_source},${entry_target} -> ret_code -> ${ret_code}";
                            fi

                            if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                            then
                                (( error_count += 1 ));

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to copy file ${entry_source} to ${entry_target}.";
                                fi

                                continue;
                            else
                                if [[ -n "${entry_permissions}" ]]; then
                                    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                                    cmd_output="$(chmod "${entry_permissions}" "$(eval printf "%s" "${entry_target}")")";
                                    ret_code="${?}";

                                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "chmod -> ret_code -> ${ret_code}";
                                    fi

                                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                    then
                                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to change permissions of ${entry_target} to ${entry_permissions}.";
                                        fi
                                    fi
                                fi

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${entry_source} copied to ${entry_target}.";
                                fi
                            fi
                            ;;
                        *)
                            (( error_count += 1 ));

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Skipping entry ${entry_command}.";
                            fi

                            continue;
                            ;;
                    esac

                    [[ -n "${ret_code}" ]] && unset -v ret_code;
                    [[ -n "${entry_command}" ]] && unset -v entry_command;
                    [[ -n "${entry_source}" ]] && unset -v entry_source;
                    [[ -n "${entry_target}" ]] && unset -v entry_target;
                    [[ -n "${entry}" ]] && unset -v entry;
                done

                ## restore the original ifs
                IFS="${CURRENT_IFS}";
            else
                return_code=1;

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
                fi
            fi
        fi
    else
        (( error_count += 1 ));

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Package appears to be missing: SOURCE_PATH -> ${SOURCE_PATH} - directory is either missing or unwriteable. ";
        fi
    fi

    ## cleanup
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${USABLE_TMP_DIR:-${TMPDIR}}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
    [[ -n "${entry}" ]] && unset -v entry;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry_permissions}" ]] && unset -v entry_permissions;
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

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

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  refreshRemoteFiles
#   DESCRIPTION:  Re-loads existing setup for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function refreshRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="refreshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local target_host;
    local target_port;
    local target_user;
    local file_verification_script;
    local transfer_file_list;
    local verify_response;
    local installation_script;
    local refresh_response;
    local cleanup_list;
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

	(( ${#} != 3 )) && return 3;

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";

	if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${USABLE_TMP_DIR:-${TMPDIR}}";
    fi

    file_verification_script="$(mktemp --tmpdir="${USABLE_TMP_DIR:-${TMPDIR}}")";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_verification_script -> ${file_verification_script}";
    fi

    if [[ ! -e "${file_verification_script}" ]] || [[ ! -w "${file_verification_script}" ]]; then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file verification script ${file_verification_script}...";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                printf \"%s\n\n\" #!/usr/bin/env bash
                printf \"%s\n\" PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;
                printf \"%s\n\n\" error_count=0;
                printf \"%s\n\" if [[ ! -e ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]] || [[ ! -r ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\" if [[ ! -e ${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") ]] || [[ ! -r ${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\n\" if [[ ! -e ${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}") ]] || [[ ! -r ${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}") ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\n\" printf \"%s\" \${error_count}";
        fi

        ## set script header
        {
            printf "%s\n\n" "#!/usr/bin/env bash";
            printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
            printf "%s\n\n" "error_count=0;";
            printf "%s\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}")\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}")\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n\n" "printf \"%s\" \${error_count}";
        } >| "${file_verification_script}";

        if [[ ! -s "${file_verification_script}" ]]; then
            return_code=1;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
            fi
        else
            [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;

            transfer_file_list="${file_verification_script}|${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending file verification script ${transfer_file_list} to host ${target_host} as user ${target_user}...";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user}";
            fi

            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}";
            ret_code="${?}";

            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
                fi
            else
                ## verify files have been transferred
                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: fssh ${SCRIPT_ROOT}/config/setup/sshconfig ${target_host} ${target_port} ${target_user} \"bash -s < ${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")\"";
                fi

                [[ -n "${verify_response}" ]] && unset -v verify_response;
				[[ -n "${function_name}" ]] && unset -v function_name;
				[[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                verify_response="$(fssh "${SCRIPT_ROOT}/config/setup/sshconfig" "${target_host}" "${target_port}" "${target_user}" "bash -s" < "${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")")";
                ret_code="${?}";

				cname="installutils.sh";
				function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "verify_response -> ${verify_response}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh / verify_response -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${verify_response}" ]] || (( verify_response != 0 )); then
                    return_code="${error_count}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while verifying files on remote host ${target_host}.";
                    fi
                else
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${USABLE_TMP_DIR:-${TMPDIR}}";
                    fi

                    installation_script="$(mktemp --tmpdir="${USABLE_TMP_DIR:-${TMPDIR}}")";

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
                                printf \"%s\n\" [[ -d ${SOURCE_PATH} ]] && rm -rf ${SOURCE_PATH}; mkdir -pv ${SOURCE_PATH} > /dev/null 2>&1;
                                printf \"%s\n\" cd ${SOURCE_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xf -
                                printf \"%s\n\n\" ${SOURCE_PATH}/bin/setup --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=refreshFiles --servername=${target_host}
                                printf \"%s\n\n\" printf \"%s\" \${?}";
                        fi

                        ## build the install script
                        {
                            printf "%s\n\n" "#!/usr/bin/env bash";
                            printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
                            printf "%s\n\n" "error_counter=0;";
                            printf "%s\n" "umask 022";
                            printf "%s\n" "[[ -d ${SOURCE_PATH} ]] && rm -rf ${SOURCE_PATH}; mkdir -pv ${SOURCE_PATH} > /dev/null 2>&1;";
                            printf "%s\n" "cd ${SOURCE_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xf -;";
                            printf "%s\n\n" "${SOURCE_PATH}/bin/setup --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=refreshFiles --servername=${target_host}";
                            printf "%s\n\n" "printf \"%s\" \${?}";
                        } >| "${installation_script}";

                        if [[ ! -s "${installation_script}" ]]; then
                            return_code=1;

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
                            fi
                        else
                            [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;

                            transfer_file_list="${installation_script}|${DEPLOY_TO_DIR}/$(basename "${installation_script}lib/setup/refreshutils.sh")";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending installation script ${installation_script} to host ${target_host} as user ${target_user}...";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user}";
                            fi

                            [[ -n "${function_name}" ]] && unset -v function_name;
                            [[ -n "${ret_code}" ]] && unset -v ret_code;

                            transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}";
                            ret_code="${?}";

                            function_name="${cname}#${FUNCNAME[0]}";

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transferFiles -> ret_code -> ${ret_code}";
                            fi

                            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
                                fi
                            else
                                ## ok, files should be out there. lets go
                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: fssh ${SCRIPT_ROOT}/config/setup/sshconfig ${target_host} ${target_port} ${target_user} \"bash -s < ${DEPLOY_TO_DIR}/$(basename "${installation_script}")\"";
                                fi

                                [[ -n "${refresh_response}" ]] && unset -v refresh_response;
            					[[ -n "${function_name}" ]] && unset -v function_name;
            					[[ -n "${cname}" ]] && unset -v cname;
                                [[ -n "${ret_code}" ]] && unset -v ret_code;

                                refresh_response="$(fssh "${SCRIPT_ROOT}/config/setup/sshconfig" "${target_host}" "${target_port}" "${target_user}" "bash -s" < "${DEPLOY_TO_DIR}/$(basename "${installation_script}")")";
                                ret_code="${?}";

            					cname="installutils.sh";
            					function_name="${cname}#${FUNCNAME[0]}";

                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "refresh_response -> ${refresh_response}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh / refresh_response -> ret_code -> ${ret_code}";
                                fi

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${refresh_response}" ]]; then
                                    [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while performing installation on remote host ${target_host}. refresh_response -> ${refresh_response}";
                                    fi
                                else
                                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "setup successfully installed to host ${target_host} as user ${target_user}";
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    ## cleanup
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${USABLE_TMP_DIR:-${TMPDIR}}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    cname="refreshutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanupFiles -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -f "${file_verification_script}" ]] && rm -f "${file_verification_script}";
    [[ -f "${installation_script}" ]] && rm -f "${installation_script}";

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${file_verification_script}" ]] && unset -v file_verification_script;
    [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;
    [[ -n "${verify_response}" ]] && unset -v verify_response;
    [[ -n "${installation_script}" ]] && unset -v installation_script;
    [[ -n "${refresh_response}" ]] && unset -v refresh_response;
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

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

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
