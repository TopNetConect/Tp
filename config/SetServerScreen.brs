


sub init()
    m.log = log_Logger("SetServerScreen")
    m.top.setFocus(true)
    m.serverPicker = m.top.findNode("serverPicker")
    m.serverUrlTextbox = m.top.findNode("serverUrlTextbox")
    m.serverUrlContainer = m.top.findNode("serverUrlContainer")
    m.serverUrlOutline = m.top.findNode("serverUrlOutline")
    m.submit = m.top.findNode("submit")
    m.top.observeField("serverUrl", "clearErrorMessage")
    ScanForServers()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    
    if not press then
        return true
    end if
    handled = true
    if key = "OK" and m.serverPicker.hasFocus()
        m.top.serverUrl = m.serverPicker.content.getChild(m.serverPicker.itemFocused).baseUrl
        m.submit.setFocus(true)

    else if key = "down" and m.serverPicker.hasFocus() and m.serverPicker.content.getChildCount() > 0 and m.serverPicker.itemFocused = m.serverPicker.content.getChildCount() - 1
        m.serverUrlContainer.setFocus(true)

    else if key = "up" and m.serverUrlContainer.hasFocus() and m.servers.Count() > 0
        m.serverPicker.setFocus(true)
    else if key = "up" and m.serverUrlContainer.hasFocus() and m.servers.Count() = 0
        ScanForServers()
    else if key = "back" and m.serverUrlContainer.hasFocus() and m.servers.Count() > 0
        m.serverPicker.setFocus(true)
    else if key = "OK" and m.serverUrlContainer.hasFocus()
        ShowKeyboard()
    else if key = "back" and m.submit.hasFocus() and m.servers.Count() > 0
        m.serverPicker.setFocus(true)
    else if key = "back" and m.submit.hasFocus() and m.servers.Count() = 0
        m.serverUrlContainer.setFocus(true)
    else if key = "back" and m.serverUrlContainer.hasFocus() and m.servers.Count() = 0
        ScanForServers()
    else if key = "back" and m.serverPicker.hasFocus() and m.servers.Count() > 0
        ScanForServers()

    else if key = "up" and m.submit.hasFocus()
        m.serverUrlContainer.setFocus(true)

    else if key = "down" and m.serverUrlContainer.hasFocus()
        m.submit.setFocus(true)
    else if key = "options"
        if m.serverPicker.itemFocused >= 0 and m.serverPicker.itemFocused < m.serverPicker.content.getChildCount()
            serverName = m.serverPicker.content.getChild(m.serverPicker.itemFocused).name
            if m.servers.Count() > 0 and Instr(1, serverName, "Saved") > 0


                handled = false
            end if
        end if
    else
        handled = false
    end if

    m.serverUrlOutline.visible = m.serverUrlContainer.isInFocusChain()
    return handled
end function

sub ScanForServers()
    m.ssdpScanner = CreateObject("roSGNode", "ServerDiscoveryTask")

    m.ssdpScanner.observeField("content", "ScanForServersComplete")
    m.ssdpScanner.control = "RUN"
    startLoadingSpinner(false)
end sub

sub ScanForServersComplete(event)
    m.servers = event.getData()
    items = CreateObject("roSGNode", "ContentNode")
    for each server in m.servers
        server.subtype = "ContentNode"

        items.update([
            server
        ], true)
    end for

    saved = get_setting("saved_servers")
    if saved <> invalid
        savedServers = ParseJson(saved)
        for each server in savedServers.serverList
            alreadyListed = false
            for each listed in m.servers
                if LCase(listed.baseUrl) = server.baseUrl 'saved server data is always lowercase
                    alreadyListed = true
                    exit for
                end if
            end for
            if alreadyListed = false
                items.update([
                    server
                ], true)
                m.servers.push(server)
            end if
        end for
    end if
    m.serverPicker.content = items
    stopLoadingSpinner()

    if m.servers.Count() > 0
        m.serverPicker.setFocus(true)

    else
        m.serverUrlContainer.setFocus(true)

        m.serverUrlOutline.visible = true
    end if
end sub

sub ShowKeyboard()
    dialog = createObject("roSGNode", "StandardKeyboardDialog")
    dialog.title = tr("Enter the server name or ip address")
    dialog.buttons = [
        tr("OK")
        tr("Cancel")
    ]
    dialog.text = m.serverUrlTextbox.text
    greenPalette = createObject("roSGNode", "RSGPalette")
    greenPalette.colors = {
        DialogBackgroundColor: "#2A2B2A"
    }
    dialog.palette = greenPalette
    m.top.getscene().dialog = dialog
    m.dialog = dialog
    dialog.observeField("buttonSelected", "onDialogButton")
end sub

function onDialogButton()
    d = m.dialog
    button_text = d.buttons[d.buttonSelected]
    if button_text = tr("OK")
        m.serverUrlTextbox.text = d.text
        m.dialog.close = true
        return true
    else if button_text = tr("Cancel")
        m.dialog.close = true
        return true
    else
        return false
    end if
end function

sub clearErrorMessage()
    m.top.errorMessage = ""
end sub