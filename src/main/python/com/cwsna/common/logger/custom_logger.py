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

from logger.enum.logging_configuration import LogConfig
from logger.enum.logging_messages import LogMessages

class CustomLogger:
    def __init__(self, logConfigFile):
        if (len(logConfigFile) != 0):
            if (os.path.exists(logConfigFile)) and (os.access(logConfigFile, os.R_OK)):
                try:
                    logging.config.fileConfig(logConfigFile)
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
