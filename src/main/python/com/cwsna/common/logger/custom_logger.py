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

import os
import logging

from enum.logging_configuration import LogConfig
from enum.logging_messages import LogMessages

class CustomLogger:
    def __init__(self, log_config_file):
        if (len(logConfigFile) != 0):
            if (os.path.exists(log_config_file)) and (os.access(log_config_file, os.R_OK)):
                try:
                    logging.config.fileConfig(log_config_file)
                except Exception as e:
                    print(str("Failed to configure logging: {0}. No logging enabled!").format(str(e)))
                #endtry
            else:
                print(str("The provided configuration file either cannot be read or does not exist."))
            #endif
        elif (os.path.exists(LogConfiguration.DEFAULT_LOG_CONFIG)) and (os.access(LogConfiguration.DEFAULT_LOG_CONFIG, os.R_OK)):
            try:
                logging.config.fileConfig(LogConfiguration.DEFAULT_LOG_CONFIG)
            except Exception as e:
                print(str("Failed to configure logging: {0}. No logging enabled!").format(str(e)))
            #endtry
        else:
            print("Unable to load logging configuration file. No logging enabled!")
        #endif
    #enddef
#endclass
