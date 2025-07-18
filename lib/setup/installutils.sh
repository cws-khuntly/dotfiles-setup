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
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="installutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local install_mode;
    local target_host;
    local -i target_port;
    local target_user;
    local entry;
    local entry_target;
    local entry_permissions;
    local recurse_permissions;
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

    (( ${#} < 2 )) && return 3;

    install_mode="${1}";
    install_archive="${2}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_mode -> ${install_mode}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_archive -> ${install_archive}";
    fi

    case "${install_mode}" in
        "${INSTALL_LOCATION_LOCAL}")
            (( ${#} != 2 )) && return 3;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation mode is ${install_mode}. Performing local install.";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installLocalFiles ${install_archive}";
            fi

            [[ -n "${cname}" ]] && builtin unset -v cname;
            [[ -n "${function_name}" ]] && builtin unset -v function_name;
            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            installLocalFiles "${install_archive}";
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installLocalFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local installation of package failed. Please review logs.";
                fi
            fi
            ;;
        "${INSTALL_LOCATION_REMOTE}")
            (( ${#} != 5 )) && return 3;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation mode is ${install_mode}. Performing remote install.";
            fi

            target_host="${3}";
            target_port="${4}";
            target_user="${5}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
            fi

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installRemoteFiles ${target_host} ${target_port} ${target_user} ${install_archive}";
            fi

            [[ -n "${cname}" ]] && builtin unset -v cname;
            [[ -n "${function_name}" ]] && builtin unset -v function_name;
            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            installRemoteFiles "${target_host}" "${target_port}" "${target_user}" "${install_archive}";
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installRemoteFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote installation of package failed. Please review logs.";
                fi
            fi
            ;;
        *)
            (( error_count += 1 ));

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid installation mode was specified. install_mode -> ${install_mode}. Cannot continue.";
            fi
            ;;
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
    [[ -n "${error_count}" ]] && builtin unset -v error_count;
    [[ -n "${install_mode}" ]] && builtin unset -v install_mode;
    [[ -n "${install_archive}" ]] && builtin unset -v install_archive;
    [[ -n "${target_host}" ]] && builtin unset -v target_host;
    [[ -n "${target_port}" ]] && builtin unset -v target_port;
    [[ -n "${target_user}" ]] && builtin unset -v target_user;
    [[ -n "${entry}" ]] && builtin unset -v entry;
    [[ -n "${entry_target}" ]] && builtin unset -v entry_target;
    [[ -n "${entry_permissions}" ]] && builtin unset -v entry_permissions;
    [[ -n "${recurse_permissions}" ]] && builtin unset -v recurse_permissions;
    [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -v end_epoch;
    [[ -n "${runtime}" ]] && builtin unset -v runtime;
    [[ -n "${function_name}" ]] && builtin unset -v function_name;
    [[ -n "${cname}" ]] && builtin unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  installLocalFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="installutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local install_archive;
    local entry;
    local is_root_dir;
    local entry_command;
    local entry_source;
    local entry_target;
    local entry_permissions;
    local recurse_permissions;
    local cmd_output;
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

    (( ${#} != 1 )) && return 3;

    install_archive="${1}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_archive -> ${install_archive}";
    fi

    if [[ ! -f "${install_archive}" ]] || [[ ! -r "${install_archive}" ]] || [[ ! -s "${install_archive}" ]]; then
        return_code=1;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No installation archive file was provided. Cannot continue.";
        fi
    else
        if [[ ! -d "${INSTALL_PATH}" ]]; then
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating directory ${INSTALL_PATH}...";
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mkdir -pv ${INSTALL_PATH}";
            fi

            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            cmd_output="$(mkdir -pv "${INSTALL_PATH}")";
            ret_code="${?}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "mkdir / ${INSTALL_PATH} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred creating directory ${INSTALL_PATH}. Please review logs.";
                fi
            fi
        fi

        if [[ ! -d "${INSTALL_PATH}" ]]; then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation path ${INSTALL_PATH} does not exist. Please review logs.";
            fi
        else
            if [[ -d "${INSTALL_PATH}" ]]; then
                if [[ -n "${IS_BACKUP_ENABLED}" ]] && [[ "${IS_BACKUP_ENABLED}" == "${_TRUE}" ]]; then
                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation path ${INSTALL_PATH} exists, taking backup.";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "NOTE:";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "A backup *attempt* is taken but it is not verified. A removal *attempt* is made but is not verified.";
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ( cd ${INSTALL_PATH} || return 1; tar -cf - ./*) | ${ARCHIVE_PROGRAM} > $(dirname "${INSTALL_PATH}")/${PACKAGE_NAME}.${BACKUP_DATE_STAMP}.${ARCHIVE_FILE_EXTENSION}";
                    fi

                    ( cd "${INSTALL_PATH}" || return 1; tar -cf - ./*) | ${ARCHIVE_PROGRAM} > "$(dirname "${INSTALL_PATH}")/${PACKAGE_NAME}.${BACKUP_DATE_STAMP}.${ARCHIVE_FILE_EXTENSION}";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -rf ${INSTALL_PATH:?}/*";
                    fi
                fi

                rm -rf --preserve-root "${INSTALL_PATH:?}"/*;
            fi

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${UNARCHIVE_PROGRAM} -c ${INSTALL_TAR} | ( cd ${INSTALL_PATH} || return 1; tar -xf - )";
            fi

            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            "${UNARCHIVE_PROGRAM}" -dc "${INSTALL_TAR}" | tar xf - -C "${INSTALL_PATH}";
            ret_code="${?}";

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "tar -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred decompressing the archive. Please review logs.";
                fi
            else
                grep "mkdir" < "${INSTALL_CONF}" | while read -r entry; do
                    [[ -z "${entry}" ]] && continue;
                    [[ "${entry}" =~ ^\# ]] && continue;

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
                    fi

                    entry_target="$(cut -d "|" -f 3 <<< "${entry}")";
                    entry_permissions="$(cut -d "|" -f 4 <<< "${entry}")";
                    recurse_permissions="$(cut -d "|" -f 5 <<< "${entry}")";
                    exempt_from_purge="$(cut -d "|" -f 6 <<< "${entry}")";
                    is_root_entry="$(cut -d "|" -f 7 <<< "${entry}")";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_permissions -> ${entry_permissions}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "recurse_permissions -> ${recurse_permissions}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "exempt_from_purge -> ${exempt_from_purge}";
                        writeLogEntry "FILE" "DEBUG" "${?}" "${cname}" "${LINENO}" "${function_name}" "is_root_entry -> ${is_root_entry}";
                    fi

                    if [[ -z "${entry_target}" ]]; then
                        (( error_count += 1 ));

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";
                        fi

                        continue;
                    else
                        if [[ -n "${exempt_from_purge}" ]] && [[ "${exempt_from_purge}" == "${_FALSE}" ]] && \
                            [[ -n "${is_root_dir}" ]] && [[ "${is_root_dir}" == "${_TRUE}" ]] && [[ -d "${entry_target}" ]]; then
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} $(eval printf "%s" "${entry_target}")";
                            fi

                            [[ -n "${cname}" ]] && builtin unset -v cname;
                            [[ -n "${function_name}" ]] && builtin unset -v function_name;

                            cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "$(eval printf "%s" "${entry_target}")";

                            cname="setup.sh";
                            function_name="${cname}#${FUNCNAME[0]}";
                        fi

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating directory ${entry_target}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mkdir -pv ${entry_target}";
                        fi

                        [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                        [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

                        cmd_output="$(mkdir -pv "$(eval printf "%s" "${entry_target}")")";
                        ret_code="${?}";

                        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "mkdir/${entry_target} -> ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                        then
                            (( error_count += 1 ));

                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create directory ${entry_target}.";
                            fi

                            continue;
                        else
                            if [[ -n "${entry_permissions}" ]]; then
                                [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                                [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

                                if [[ -n "${recurse_permissions}" ]] && [[ "${recurse_permissions}" == "${_TRUE}" ]]; then
                                    cmd_output="$(chmod -R "${entry_permissions}" "$(eval printf "%s" "${entry_target}")")";
                                else
                                    cmd_output="$(chmod "${entry_permissions}" "$(eval printf "%s" "${entry_target}")")";
                                fi

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
                                writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory ${entry_target} created";
                            fi
                        fi
                    fi

                    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
                    [[ -n "${entry_source}" ]] && builtin unset -v entry_source;
                    [[ -n "${entry_target}" ]] && builtin unset -v entry_target;
                    [[ -n "${entry_permissions}" ]] && builtin unset -v entry_permissions;
                    [[ -n "${recurse_permissions}" ]] && builtin unset -v recurse_permissions;
                    [[ -n "${exempt_from_purge}" ]] && builtin unset -v exempt_from_purge;
                    [[ -n "${is_root_dir}" ]] && builtin unset -v is_root_dir;
                    [[ -n "${entry}" ]] && builtin unset -v entry;
                done

                ## change the IFS
                IFS="${MODIFIED_IFS}";

                ## clean up home directory first
                for entry in $(< "${INSTALL_CONF}"); do
                    [[ -z "${entry}" ]] && continue;
                    [[ "${entry}" =~ ^\# ]] && continue;

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
                    fi

                    entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                    entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                    entry_target="$(cut -d "|" -f 3 <<< "${entry}")";
                    entry_permissions="$(cut -d "|" -f 4 <<< "${entry}")";
                    recurse_permissions="$(cut -d "|" -f 5 <<< "${entry}")";
                    exempt_from_purge="$(cut -d "|" -f 6 <<< "${entry}")";

                    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_command -> ${entry_command}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_source -> ${entry_source}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_permissions -> ${entry_permissions}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "recurse_permissions -> ${recurse_permissions}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "exempt_from_purge -> ${exempt_from_purge}";
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
                        "mkdir")
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Skipping entry ${entry_command}.";
                            fi

                            continue;
                            ;;
                        "ln")
                            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating symbolic link ${entry_source} -> ${entry_target}";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ln -is eval printf \"%s\" ${entry_source} eval printf \"%s\" ${entry_target}";
                            fi

                            if [[ -L "$(eval printf "%s" "${entry_target}")" ]] || [[ -f "$(eval printf "%s" "${entry_target}")" ]] && [[ -n "${exempt_from_purge}" ]] && [[ "${exempt_from_purge}" == "${_FALSE}" ]]; then cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "$(eval printf "%s" "${entry_target}")"; fi

                            if [[ -n "$(stat "$(eval printf "%s" "${entry_source}")" 2>/dev/null)" ]]; then
                                [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                                [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

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
                                        [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                                        [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

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
                            else
                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
                                fi

                                writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
                            fi
                            ;;
                        "cp")
                            if [[ -n "${exempt_from_purge}" ]] && [[ "${exempt_from_purge}" == "${_FALSE}" ]] && [[ -f "$(eval printf "%s" "${entry_target}")" ]]; then
                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${entry_target}";
                                fi

                                [[ -n "${cname}" ]] && builtin unset -v cname;
                                [[ -n "${function_name}" ]] && builtin unset -v function_name;

                                cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "$(eval printf "%s" "${entry_target}")";

                                cname="setup.sh";
                                function_name="${cname}#${FUNCNAME[0]}";
                            fi

                            if [[ -f "$(eval printf "%s" "${entry_target}")" ]] && [[ -n "${exempt_from_purge}" ]] && [[ "${exempt_from_purge}" == "${_FALSE}" ]]; then cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "$(eval printf "%s" "${entry_target}")"; fi

                            if [[ -n "$(stat "$(eval printf "%s" "${entry_source}")" 2>/dev/null)" ]]; then
                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Copying file ${entry_source} to ${entry_target}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp -ipv ${entry_source} ${entry_target}";
                                fi

                                [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                                [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

                                cmd_output="$(cp -pv "$(val printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")")";
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
                                        [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
                                        [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

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
                            else
                                if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
                                fi

                                writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Configured entry source ${entry_source} for ${entry_command} does not exist.";
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

                    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
                    [[ -n "${entry_command}" ]] && builtin unset -v entry_command;
                    [[ -n "${entry_source}" ]] && builtin unset -v entry_source;
                    [[ -n "${entry_target}" ]] && builtin unset -v entry_target;
                    [[ -n "${entry}" ]] && builtin unset -v entry;
                done

                ## restore the original ifs
                IFS="${CURRENT_IFS}";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
    [[ -n "${error_count}" ]] && builtin unset -v error_count;
    [[ -n "${entry_command}" ]] && builtin unset -v entry_command;
    [[ -n "${entry_source}" ]] && builtin unset -v entry_source;
    [[ -n "${entry_target}" ]] && builtin unset -v entry_target;
    [[ -n "${entry_permissions}" ]] && builtin unset -v entry_permissions;
    [[ -n "${recurse_permissions}" ]] && builtin unset -v recurse_permissions;
    [[ -n "${cmd_output}" ]] && builtin unset -v cmd_output;
    [[ -n "${entry}" ]] && builtin unset -v entry;
    [[ -n "${cleanup_list}" ]] && builtin unset -v cleanup_list;

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

    [[ -n "${start_epoch}" ]] && builtin unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -v end_epoch;
    [[ -n "${runtime}" ]] && builtin unset -v runtime;
    [[ -n "${function_name}" ]] && builtin unset -v function_name;
    [[ -n "${cname}" ]] && builtin unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  installRemoteFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="installutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code;
    local -i return_code=0;
    local -i error_count=0;
    local target_host;
    local -i target_port;
    local target_user;
    local installation_script;
    local install_response;
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

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
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
                printf \"%s\n\" mkdir -pv ${DEPLOY_TO_DIR}/{${SETUP_PACKAGE_NAME},${PACKAGE_NAME}}
                printf \"%s\n\" ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | ( cd \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}\" || return 1; tar -xf - );
                printf \"%s\n\" ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | ( cd \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}\" || return 1; tar -xf - );
                printf \"%s\n\n\" chmod 755 ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup;
                printf \"%s\n\n\" ${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup -n ${DEPLOY_TO_DIR}/$(basename "${PACKAGE_SETUP_FILE}")
                printf \"%s\n\n\" printf \"%s\" \${?}";
        fi

        ## build the install script
        {
            printf "%s\n\n" "#!/usr/bin/env bash";
            printf "%s\n\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
            printf "%s\n" "umask 022;";
            printf "%s\n" "mkdir -pv \"${DEPLOY_TO_DIR}/{${SETUP_PACKAGE_NAME},${PACKAGE_NAME}\";":
            printf "%s\n" "${UNARCHIVE_PROGRAM} -c \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" | ( cd \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}\" || return 1; tar -xf - );";
            printf "%s\n" "${UNARCHIVE_PROGRAM} -c \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" | ( cd \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}\" || return 1; tar -xf - );";
            printf "%s\n\n" "chmod 755 \"${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup\";";
            printf "%s\n\n" "${DEPLOY_TO_DIR}/${SETUP_PACKAGE_NAME}/bin/setup -n \"${DEPLOY_TO_DIR}/$(basename "${PACKAGE_CONFIG}")\"";
            printf "%s\n\n" "printf "%s" \${?}";
        } >| "${installation_script}";

        if [[ ! -s "${installation_script}" ]]; then
            return_code=1;

            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
            fi
        else
            if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${installation_script} ${target_host} ${target_port} ${target_user} ${DEPLOY_TO_DIR}";
            fi

            [[ -n "${cname}" ]] && builtin unset -v cname;
            [[ -n "${function_name}" ]] && builtin unset -v function_name;
            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            transferFiles "${TRANSFER_LOCATION_REMOTE}" "${installation_script}" "${target_host}" "${target_port}" "${target_user}" "${DEPLOY_TO_DIR}";
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
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: fssh ${SSH_CONFIG_FILE} ${target_host} ${target_port} ${target_user} ${DEPLOY_TO_DIR}/$(basename "${installation_script}")";
                fi

                [[ -n "${cname}" ]] && builtin unset -v cname;
                [[ -n "${function_name}" ]] && builtin unset -v function_name;
                [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

                install_response="$(fssh "${SSH_CONFIG_FILE}" "${target_host}" "${target_port}" "${target_user}" "${DEPLOY_TO_DIR}/$(basename "${installation_script}")"))";
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

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${installation_script}";
    fi

    [[ -n "${cname}" ]] && builtin unset -v cname;
    [[ -n "${function_name}" ]] && builtin unset -v function_name;
    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${installation_script}";
    ret_code="${?}";

    cname="installutils.sh";
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

    [[ -n "${initial_transfer_list}" ]] && builtin unset -v initial_transfer_list;
    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
    [[ -n "${error_count}" ]] && builtin unset -v error_count;
    [[ -n "${target_host}" ]] && builtin unset -v target_host;
    [[ -n "${target_port}" ]] && builtin unset -v target_port;
    [[ -n "${target_user}" ]] && builtin unset -v target_user;
    [[ -n "${installation_script}" ]] && builtin unset -v installation_script;
    [[ -n "${install_response}" ]] && builtin unset -v install_response;

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

    [[ -n "${start_epoch}" ]] && builtin unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -v end_epoch;
    [[ -n "${runtime}" ]] && builtin unset -v runtime;
    [[ -n "${function_name}" ]] && builtin unset -v function_name;
    [[ -n "${cname}" ]] && builtin unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
