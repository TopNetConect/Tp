

function isNodeEvent(msg, field as string) as boolean
    return type(msg) = "roSGNodeEvent" and msg.getField() = field
end function

function getMsgPicker(msg, subnode = "" as string) as object
    node = msg.getRoSGNode()

    if subnode <> ""
        node = node.findNode(subnode)
    end if
    coords = node.rowItemSelected
    target = node.content.getChild(coords[0]).getChild(coords[1])
    return target
end function

function getButton(msg, subnode = "buttons" as string) as object
    buttons = msg.getRoSGNode().findNode(subnode)
    if buttons = invalid then
        return invalid
    end if
    active_button = buttons.focusedChild
    return active_button
end function

function leftPad(base as string, fill as string, length as integer) as string
    while len(base) < length
        base = fill + base
    end while
    return base
end function

function ticksToHuman(ticks as longinteger) as string
    totalSeconds = int(ticks / 10000000)
    hours = stri(int(totalSeconds / 3600)).trim()
    minutes = stri(int((totalSeconds - (val(hours) * 3600)) / 60)).trim()
    seconds = stri(totalSeconds - (val(hours) * 3600) - (val(minutes) * 60)).trim()
    if val(hours) > 0 and val(minutes) < 10 then
        minutes = "0" + minutes
    end if
    if val(seconds) < 10 then
        seconds = "0" + seconds
    end if
    r = ""
    if val(hours) > 0 then
        r = hours + ":"
    end if
    r = r + minutes + ":" + seconds
    return r
end function

function secondsToHuman(totalSeconds as integer, addLeadingMinuteZero as boolean) as string
    humanTime = ""
    hours = stri(int(totalSeconds / 3600)).trim()
    minutes = stri(int((totalSeconds - (val(hours) * 3600)) / 60)).trim()
    seconds = stri(totalSeconds - (val(hours) * 3600) - (val(minutes) * 60)).trim()
    if val(hours) > 0 or addLeadingMinuteZero
        if val(minutes) < 10
            minutes = "0" + minutes
        end if
    end if
    if val(seconds) < 10
        seconds = "0" + seconds
    end if
    if val(hours) > 0
        hours = hours + ":"
    else
        hours = ""
    end if
    humanTime = hours + minutes + ":" + seconds
    return humanTime
end function


function formatTime(time) as string
    hours = time.getHours()
    minHourDigits = 1
    if m.global.device.clockFormat = "12h"
        meridian = "AM"
        if hours = 0
            hours = 12
            meridian = "AM"
        else if hours = 12
            hours = 12
            meridian = "PM"
        else if hours > 12
            hours = hours - 12
            meridian = "PM"
        end if
    else

        minHourDigits = 2
        meridian = ""
    end if
    return Substitute("{0}:{1} {2}", leftPad(stri(hours).trim(), "0", minHourDigits), leftPad(stri(time.getMinutes()).trim(), "0", 2), meridian)
end function

function div_ceiling(a as integer, b as integer) as integer
    if a < b then
        return 1
    end if
    if int(a / b) = a / b
        return a / b
    end if
    return a / b + 1
end function


function get_dialog_result(dialog, port)
    while dialog <> invalid
        msg = wait(0, port)
        if isNodeEvent(msg, "backPressed")
            return -1
        else if isNodeEvent(msg, "itemSelected")
            return dialog.findNode("optionList").itemSelected
        end if
    end while

    return -1
end function

function lastFocusedChild(obj as object) as object
    if isValid(obj)
        if isValid(obj.focusedChild) and isValid(obj.focusedChild.focusedChild) and LCase(obj.focusedChild.focusedChild.subType()) = "tvepisodes"
            if isValid(obj.focusedChild.focusedChild.lastFocus)
                return obj.focusedChild.focusedChild.lastFocus
            end if
        end if
        child = obj
        for i = 0 to obj.getChildCount()
            if isValid(obj.focusedChild)
                child = child.focusedChild
            end if
        end for
        return child
    else
        return invalid
    end if
end function

function show_dialog(message as string, options = [], defaultSelection = 0) as integer
    lastFocus = lastFocusedChild(m.scene)
    dialog = createObject("roSGNode", "JFMessageDialog")
    if options.count() then
        dialog.options = options
    end if
    if message.len() > 0
        reg = CreateObject("roFontRegistry")
        font = reg.GetDefaultFont()
        dialog.fontHeight = font.GetOneLineHeight()
        dialog.fontWidth = font.GetOneLineWidth(message, 999999999)
        dialog.message = message
    end if
    if defaultSelection > 0
        dialog.findNode("optionList").jumpToItem = defaultSelection
    end if
    dialog.visible = true
    m.scene.appendChild(dialog)
    dialog.setFocus(true)
    port = CreateObject("roMessagePort")
    dialog.observeField("backPressed", port)
    dialog.findNode("optionList").observeField("itemSelected", port)
    result = get_dialog_result(dialog, port)
    m.scene.removeChildIndex(m.scene.getChildCount() - 1)
    lastFocus.setFocus(true)
    return result
end function

function message_dialog(message = "" as string)
    return show_dialog(message, [
        "OK"
    ])
end function

function option_dialog(options, message = "", defaultSelection = 0) as integer
    return show_dialog(message, options, defaultSelection)
end function




function inferServerUrl(url as string) as string


    saved = get_setting("saved_servers")
    if isValid(saved)
        savedServers = ParseJson(saved)
        if isValid(savedServers.lookup(url)) then
            return url
        end if
    end if
    port = CreateObject("roMessagePort")
    hosts = CreateObject("roAssociativeArray")
    reqs = []
    candidates = urlCandidates(url)
    for each endpoint in candidates
        req = CreateObject("roUrlTransfer")
        reqs.push(req) ' keep in scope outside of loop, else -10001
        req.seturl(endpoint + "/system/info/public")
        req.setMessagePort(port)
        hosts.addreplace(req.getidentity().ToStr(), endpoint)
        if endpoint.Left(8) = "https://"
            req.setCertificatesFile("common:/certs/ca-bundle.crt")
        end if
        req.AsyncGetToString()
    end for
    handled = 0
    timeout = CreateObject("roTimespan")
    if hosts.count() > 0
        while timeout.totalseconds() < 15
            resp = wait(0, port)
            if type(resp) = "roUrlEvent"



                if resp.GetResponseCode() = 200 and isJellyfinServer(resp.GetString())
                    selectedUrl = hosts.lookup(resp.GetSourceIdentity().ToStr())
                    print "Successfully inferred server URL: " selectedUrl
                    return selectedUrl
                end if
            end if
            handled += 1
            if handled = reqs.count()
                print "inferServerUrl in utils/misc.brs failed to find a server from the string " url " but did not timeout."
                return ""
            end if
        end while
        print "inferServerUrl in utils/misc.brs failed to find a server from the string " url " because it timed out."
    end if
    return ""
end function




function urlCandidates(input as string)
    if input.endswith("/") then
        input = input.Left(len(input) - 1)
    end if
    url = parseUrl(input)
    if url[1] = invalid

        url = parseUrl("none://" + input)
    end if

    if url[1] = invalid then
        return []
    end if
    proto = url[1]
    host = url[2]
    port = url[3]
    path = url[4]
    protoCandidates = []
    supportedProtos = [
        "http:"
        "https:"
    ] ' appending colons because the regex does
    if proto = "none:" ' the user did not declare a protocol

        for each supportedProto in supportedProtos
            protoCandidates.push(supportedProto + "//" + host)
        end for
    else
        protoCandidates.push(proto + "//" + host) ' but still allow arbitrary protocols if they are declared
    end if
    finalCandidates = []
    if isValid(port) and port <> "" ' if the port is defined just use that
        for each candidate in protoCandidates
            finalCandidates.push(candidate + port + path)
        end for
    else ' the port wasnt declared so use default jellyfin and proto ports
        for each candidate in protoCandidates

            finalCandidates.push(candidate + path)

            if candidate.startswith("https")
                finalCandidates.push(candidate + ":8920" + path)
            else if candidate.startswith("http")
                finalCandidates.push(candidate + ":8096" + path)
            end if
        end for
    end if
    return finalCandidates
end function

sub setFieldTextValue(field, value)
    node = m.top.findNode(field)
    if node = invalid or value = invalid then
        return
    end if

    if type(value) = "roInt" or type(value) = "Integer"
        value = str(value).trim()
    else if type(value) = "roFloat" or type(value) = "Float"
        value = str(value).trim()
    else if type(value) <> "roString" and type(value) <> "String"
        value = ""
    end if
    node.text = value
end sub


function isValid(input as dynamic) as boolean
    return input <> invalid
end function



function isValidAndNotEmpty(input as dynamic) as boolean
    if not isValid(input) then
        return false
    end if

    countableTypes = {
        "array": 1
        "list": 1
        "roarray": 1
        "roassociativearray": 1
        "rolist": 1
    }
    inputType = LCase(type(input))
    if inputType = "string" or inputType = "rostring"
        trimmedInput = input.trim()
        return trimmedInput <> ""
    else if inputType = "rosgnode"
        inputId = input.id
        return inputId <> invalid
    else if countableTypes.doesExist(inputType)
        return input.count() > 0
    else
        print "Called isValidAndNotEmpty() with invalid type: ", inputType
        return false
    end if
end function




function parseUrl(url as string) as object
    rgx = CreateObject("roRegex", "^(.*:)//([A-Za-z0-9\-\.]+)(:[0-9]+)?(.*)$", "")
    return rgx.Match(url)
end function


function isLocalhost(url as string) as boolean

    rgx = CreateObject("roRegex", "^localhost$|^127(?:\.[0-9]+){0,2}\.[0-9]+$|^(?:0*\:)*?:?0*1$", "i")
    return rgx.isMatch(url)
end function


function roundNumber(f as float) as integer


    m = int(f)
    n = m + 1
    x = abs(f - m)
    y = abs(f - n)
    if y > x
        return m
    else
        return n
    end if
end function


function getMinutes(ticks) as integer


    return roundNumber(ticks / 600000000.0)
end function




function versionChecker(versionToCheck as string, minVersionAccepted as string)
    leftHand = CreateObject("roLongInteger")
    rightHand = CreateObject("roLongInteger")
    regEx = CreateObject("roRegex", "\.", "")
    version = regEx.Split(versionToCheck)
    if version.Count() < 3
        for i = version.Count() to 3 step 1
            version.AddTail("0")
        end for
    end if
    minVersion = regEx.Split(minVersionAccepted)
    if minVersion.Count() < 3
        for i = minVersion.Count() to 3 step 1
            minVersion.AddTail("0")
        end for
    end if
    leftHand = (version[0].ToInt() * 10000) + (version[1].ToInt() * 100) + (version[2].ToInt() * 10)
    rightHand = (minVersion[0].ToInt() * 10000) + (minVersion[1].ToInt() * 100) + (minVersion[2].ToInt() * 10)
    return leftHand >= rightHand
end function

function findNodeBySubtype(node, subtype)
    foundNodes = []
    for each child in node.getChildren(-1, 0)
        if lcase(child.subtype()) = "group"
            return findNodeBySubtype(child, subtype)
        end if
        if lcase(child.subtype()) = lcase(subtype)
            foundNodes.push({
                node: child
                parent: node
            })
        end if
    end for
    return foundNodes
end function

function AssocArrayEqual(Array1 as object, Array2 as object) as boolean
    if not isValid(Array1) or not isValid(Array2)
        return false
    end if
    if not Array1.Count() = Array2.Count()
        return false
    end if
    for each key in Array1
        if not Array2.DoesExist(key)
            return false
        end if
        if Array1[key] <> Array2[key]
            return false
        end if
    end for
    return true
end function


function inArray(haystack, needle) as boolean
    valueToFind = needle
    if LCase(type(valueToFind)) <> "rostring" and LCase(type(valueToFind)) <> "string"
        valueToFind = str(needle)
    end if
    valueToFind = lcase(valueToFind)
    for each item in haystack
        if lcase(item) = valueToFind then
            return true
        end if
    end for
    return false
end function

function toString(input) as string
    if LCase(type(input)) = "rostring" or LCase(type(input)) = "string"
        return input
    end if
    return str(input)
end function






sub startLoadingSpinner(disableRemote = true as boolean)
    if not isValid(m.scene)
        m.scene = m.top.getScene()
    end if
    if not m.scene.isLoading
        m.scene.disableRemote = disableRemote
        m.scene.isLoading = true
    end if
end sub

sub stopLoadingSpinner()
    if not isValid(m.scene)
        m.scene = m.top.getScene()
    end if
    if m.scene.isLoading
        m.scene.disableRemote = false
        m.scene.isLoading = false
    end if
end sub



function isJellyfinServer(systemInfo as object) as boolean
    data = ParseJson(systemInfo)
    if isValid(data) and isValid(data.ProductName)
        return LCase(data.ProductName) = m.global.constants.jellyfin_server
    end if
    return false
end function


function arrayHasValue(arr as object, value as dynamic) as boolean
    for each entry in arr
        if entry = value
            return true
        end if
    end for
    return false
end function



function shuffleArray(array as object) as object
    for i = array.count() - 1 to 1 step -1
        j = Rnd(i + 1) - 1
        t = array[i]
        array[i] = array[j]
        array[j] = t
    end for
    return array
end function