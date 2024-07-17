

























function log_initializeLogManager(transportTypes = invalid, logLevel = invalid, includeDate = false, enabled = false) as object
    rLog = CreateObject("roSGNode", "log_Log")
    m.global.addFields({
        "rLog": rLog
    })
    m.top.getScene().addFields({
        "rLog": rLog
    })
    m.global.addFields({
        "logIndentText": ""
    })
    m.global.addFields({
        "logIndent": 0
    })
    if transportTypes = invalid
        transportTypes = [
            "log_PrintTransport"
        ]
    end if
    if logLevel = invalid
        logLevel = 2
    end if
    rlog.includeFilters = {}
    rlog.excludeFilters = {}
    rlog.transportTypes = transportTypes
    rlog.logLevel = logLevel
    rlog.includeDate = includeDate = true
    rlog.enabled = enabled = true
    return rLog
end function

function log_global()
    return m.global
end function

function log_getLogInstance()
    if m.global <> invalid and m.global.rLog <> invalid
        return m.global.rLog
    end if
    if m.top.getScene() <> invalid

        return m.top.getScene().rLog
    end if
    return invalid
end function

function __log_Logger_builder()
    instance = {}
    instance.new = function(name = "general") as void
        m.enabled = true
        m.name = invalid
        m.rLog = invalid
        m.isFiltering = false
        m.logLevel = 2
        m.includeFilters = []
        m.excludeFilters = []
        m.includeDate = false
        m.logMode = 1
        m.transports = []
        m.name = name
        m.rLog = log_getLogInstance()
        if m.rLog <> invalid
            m.enabled = m.rLog.enabled
            m.isFiltering = m.rLog.isFiltering
            m.logLevel = m.rLog.logLevel
            m.includeFilters = m.rLog.includeFilters
            m.excludeFilters = m.rLog.excludeFilters
            m.includeDate = m.rLog.includeDate
            m.logMode = m.rLog.logMode
            m.transports = m.rLog.transports
        else
            m.log = function(levelNum, level, message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#", isMethod = false) as void
                ? " ERROR  NO LOGGER FOUND IN " m.top
            end function
        end if
    end function
    instance.log = function(levelNum, level, message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#", isMethod = false) as void
        if m.isFiltering
            if m.logLevel < levelNum or (m.includeFilters.count() > 0 and m.includeFilters[m.name] = invalid) or (m.excludeFilters.count() > 0 and m.excludeFilters[m.name] <> invalid)
                return
            end if
        end if
        if m.includeDate
            level = m.rLog.dateText + " " + level
        end if
        g = log_global()
        if m.logMode = 1
            print g.logIndentText + level " " m.toString(message) " " m.toString(value) " " m.toString(value2) " " m.toString(value3) " " m.toString(value4) " " m.toString(value5) " " m.toString(value6) " " m.toString(value7) " " m.toString(value8) " " + m.toString(value9)
        else
            text = g.logIndentText + level + " " + m.toString(message) + " " + m.toString(value) + " " + m.toString(value2) + " " + m.toString(value3) + " " + m.toString(value4) + " " + m.toString(value5) + " " + m.toString(value6) + " " + m.toString(value7) + " " + m.toString(value8) + " " + m.toString(value9)
            if m.logMode = 3
                print text
            end if
            for each transport in m.transports
                transport.callFunc("logItem", m.name, levelNum, text)
            end for
        end if
    end function
    instance.increaseIndent = function(title = invalid) as void
        if title <> invalid
            m.log(0, "", "", title, "  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end if
        m._changeIndent(1)
    end function
    instance.decreaseIndent = function() as void
        m._changeIndent(- 1)
    end function
    instance._changeIndent = function(delta as integer) as void
        g = log_global()
        newIndent = g.logIndent + delta
        logIndentText = ""
        g.logIndent = newIndent
        for i = 0 to newIndent - 2
            logIndentText += "  "
        end for
        if newIndent > 0
            logIndentText += " | "
        end if
        g.logIndentText = logIndentText
    end function
    instance.resetIndent = function() as void
        g = log_global()
        g.logIndent = 0
        g.logIndentText = ""
    end function
    instance.debug = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(4, "DEBUG", message, value, value2, value3, value4, value5, value6, value7, value8, value9)
    end function
    instance.verbose = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(3, "VERBOSE", message, value, value2, value3, value4, value5, value6, value7, value8, value9)
    end function
    instance.info = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(2, "INFO", message, value, value2, value3, value4, value5, value6, value7, value8, value9)
    end function
    instance.method = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(2, "METHOD", message, value, value2, value3, value4, value5, value6, value7, value8, value9, true)
    end function
    instance.warn = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(1, "WARN", message, value, value2, value3, value4, value5, value6, value7, value8, value9)
    end function
    instance.error = function(message, value = "~#", value2 = "~#", value3 = "~#", value4 = "~#", value5 = "~#", value6 = "~#", value7 = "~#", value8 = "~#", value9 = "~#") as void
        if m.rLog = invalid then
            return
        end if
        m.log(0, "ERROR", message, value, value2, value3, value4, value5, value6, value7, value8, value9)
    end function
    instance.toString = function(value as dynamic) as string
        valueType = type(value)
        if valueType = "<uninitialized>"
            return "UNINIT"
        else if value = invalid
            return "INVALID"
        else if getInterface(value, "ifString") <> invalid
            if value = "~#"
                return ""
            else
                return value
            end if
        else if valueType = "roInt" or valueType = "roInteger" or valueType = "Integer"
            return value.toStr()
        else if getInterface(value, "ifFloat") <> invalid
            return str(value).trim()
        else if valueType = "roSGNode"
            return "Node(" + value.subType() + ")"
        else if valueType = "roAssociativeArray"
            return "AA(" + formatJson(value) + ")"
        else if valueType = "roBoolean" or valueType = "Boolean"
            return value.toStr()
        else
            return ""
        end if
    end function
    return instance
end function

function log_Logger(name = "general")
    instance = __log_Logger_builder()
    instance.new(name)
    return instance
end function '//# sourceMappingURL=./LogMixin.bs.map