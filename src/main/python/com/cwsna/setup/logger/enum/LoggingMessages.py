#==============================================================================
#
#          FILE:  logging.py
#         USAGE:  Simple class to configure a logger
#     ARGUMENTS:  logConfigFile: The file to use for configuration options
#   DESCRIPTION:  Configures a logging subsystem based on a provided configuration file
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

from enum import Enum

class LogMessages(Enum):
    ENTER = "Method Entry"
    EXIT = "Method Exit"
