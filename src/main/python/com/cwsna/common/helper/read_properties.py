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

from configparser import configparser

from common.logger.enum.logging_messages import LogMessages
from common.logger.impl.custom_logger import CustomLogger

CustomLogger.configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = CustomLogger.logging.getLogger("error-logger")
debugLogger = CustomLogger.logging.getLogger("debug-logger")

class ReadPropertyFile:
    def checkIfPropertySectionExists(configFile, sectionName):
        debugLogger.log(CustomLogger.logging.DEBUG, "ENTER: includes#checkIfPropertySectionExists(configFile, sectionName)")
        debugLogger.log(CustomLogger.logging.DEBUG, configFile)
        debugLogger.log(CustomLogger.logging.DEBUG, sectionName)

        config_response = False

        debugLogger.log(CustomLogger.logging.DEBUG, configResponse)

        config = configparser.ConfigParser()
        config.read(configFile)

        debugLogger.log(CustomLogger.logging.DEBUG, config)

        if (len(config) != 0):
            if (len(config.has_section(sectionName)) != 0):
                config_response = True
            #endif
        else:
            errorLogger.log(CustomLogger.logging.ERROR, str("Unable to load configuration file {0}.").format(configFile))

            raise Exception(str("Unable to load configuration file {0}.").format(configFile))
        #endif

        debugLogger.log(CustomLogger.logging.DEBUG, configResponse)
        debugLogger.log(CustomLogger.logging.DEBUG, "EXIT: includes#checkIfPropertySectionExists(configFile, sectionName)")

        return config_response
    #enddef

    def returnPropertyConfiguration(configFile, sectionName, valueName):
        debugLogger.log(CustomLogger.logging.DEBUG, "ENTER: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")
        debugLogger.log(CustomLogger.logging.DEBUG, configFile)
        debugLogger.log(CustomLogger.logging.DEBUG, sectionName)
        debugLogger.log(CustomLogger.logging.DEBUG, valueName)

        config_response = ""

        debugLogger.log(CustomLogger.logging.DEBUG, configResponse)

        config = configparser.ConfigParser()
        config.read(configFile)

        debugLogger.log(CustomLogger.logging.DEBUG, config)

        if (len(config) != 0):
            config_response = config.get(sectionName, valueName)
        else:
            errorLogger.log(CustomLogger.logging.ERROR, str("Unable to load configuration file {0}.").format(configFile))

            raise Exception(str("Unable to load configuration file {0}.").format(configFile))
        #endif

        debugLogger.log(CustomLogger.logging.DEBUG, configResponse)
        debugLogger.log(CustomLogger.logging.DEBUG, "EXIT: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")

        return config_response
    #enddef
#endclass
