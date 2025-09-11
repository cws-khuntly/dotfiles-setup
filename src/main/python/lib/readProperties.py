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

import logging
import ConfigParser

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

def checkIfPropertySectionExists(configFile, sectionName):
    debugLogger.log(logging.DEBUG, "ENTER: includes#checkIfPropertySectionExists(configFile, sectionName)")
    debugLogger.log(logging.DEBUG, configFile)
    debugLogger.log(logging.DEBUG, sectionName)

    configResponse = False

    debugLogger.log(logging.DEBUG, configResponse)

    config = ConfigParser.ConfigParser()
    config.read(configFile)

    debugLogger.log(logging.DEBUG, config)

    if (len(config) != 0):
        if (config.has_section(sectionName)):
            configResponse = True
        #endif
    else:
        errorLogger.log(logging.ERROR, str("Unable to load configuration file {0}.").format(configFile))

        raise Exception(str("Unable to load configuration file {0}.").format(configFile))
    #endif

    debugLogger.log(logging.DEBUG, configResponse)
    debugLogger.log(logging.DEBUG, "EXIT: includes#checkIfPropertySectionExists(configFile, sectionName)")

    return configResponse
#enddef

def returnPropertyConfiguration(configFile, sectionName, valueName):
    debugLogger.log(logging.DEBUG, "ENTER: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")
    debugLogger.log(logging.DEBUG, configFile)
    debugLogger.log(logging.DEBUG, sectionName)
    debugLogger.log(logging.DEBUG, valueName)

    configResponse = ""

    debugLogger.log(logging.DEBUG, configResponse)

    config = ConfigParser.ConfigParser()
    config.read(configFile)

    debugLogger.log(logging.DEBUG, config)

    if (len(config) != 0):
        configResponse = config.get(sectionName, valueName)
    else:
        errorLogger.log(logging.ERROR, str("Unable to load configuration file {0}.").format(configFile))

        raise Exception(str("Unable to load configuration file {0}.").format(configFile))
    #endif

    debugLogger.log(logging.DEBUG, configResponse)
    debugLogger.log(logging.DEBUG, "EXIT: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")

    return configResponse
#enddef
