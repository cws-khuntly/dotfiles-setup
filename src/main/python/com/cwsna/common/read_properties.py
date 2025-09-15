#==============================================================================
#
#          FILE:  configureTargetServer.py
#         USAGE:  wsadmin.sh -lang jython -f configureTargetServer.py
#     ARGUMENTS:  wasVersion serverName clusterName vHostName (vHostAliases) (serverLogRoot)
#   DESCRIPTION:  Executes an scp connection to a pre-defined server
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

import configparser

from logger.enum.logging_configuration import LogConfig
from logger.enum.logging_messages import LogMessages
from logger.custom_logger import CustomLogger

custom_logger = CustomLogger(LogConfig.DEFAULT_LOG_CONFIG)
errorLogger = custom_logger.getLogger("error-logger")
debugLogger = custom_logger.getLogger("debug-logger")

class ReadPropertyFile:
    def __init__(self):
        debugLogger.log(CustomLogger.logging.DEBUG, "ENTER: __init__")
    #enddef

    def check_if_section_exists(config_file, section_name):
        debugLogger.log(CustomLogger.logging.DEBUG, "ENTER: includes#checkIfPropertySectionExists(config_file, section_name)")
        debugLogger.log(CustomLogger.logging.DEBUG, config_file)
        debugLogger.log(CustomLogger.logging.DEBUG, section_name)

        config_response = False

        debugLogger.log(CustomLogger.logging.DEBUG, config_response)

        config = ConfigParser.ConfigParser()
        config.read(config_file)

        debugLogger.log(CustomLogger.logging.DEBUG, config)

        if (len(config) != 0):
            if (len(config.has_section(section_name)) != 0):
                config_response = True
            #endif
        else:
            errorLogger.log(CustomLogger.logging.ERROR, str("Unable to load configuration file {0}.").format(config_file))

            raise Exception(str("Unable to load configuration file {0}.").format(config_file))
        #endif

        debugLogger.log(CustomLogger.logging.DEBUG, config_response)
        debugLogger.log(CustomLogger.logging.DEBUG, "EXIT: includes#checkIfPropertySectionExists(config_file, section_name)")

        return config_response
    #enddef

    def return_property_list(config_file, section_name, value_name):
        debugLogger.log(CustomLogger.logging.DEBUG, "ENTER: includes#returnPropertyConfiguration(config_file, section_name, value_name)")
        debugLogger.log(CustomLogger.logging.DEBUG, config_file)
        debugLogger.log(CustomLogger.logging.DEBUG, section_name)
        debugLogger.log(CustomLogger.logging.DEBUG, value_name)

        config_response = ""

        debugLogger.log(CustomLogger.logging.DEBUG, config_response)

        config = ConfigParser.ConfigParser()
        config.read(config_file)

        debugLogger.log(CustomLogger.logging.DEBUG, config)

        if (len(config) != 0):
            config_response = config.get(section_name, value_name)
        else:
            errorLogger.log(CustomLogger.logging.ERROR, str("Unable to load configuration file {0}.").format(config_file))

            raise Exception(str("Unable to load configuration file {0}.").format(config_file))
        #endif

        debugLogger.log(CustomLogger.logging.DEBUG, config_response)
        debugLogger.log(CustomLogger.logging.DEBUG, "EXIT: includes#returnPropertyConfiguration(config_file, section_name, value_name)")

        return config_response
    #enddef
#endclass
