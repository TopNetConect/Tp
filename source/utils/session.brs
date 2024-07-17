




sub session_Init()
    m.global.addFields({
        session: {
            "memoryLevel": "normal"
            server: {}
            user: {
                Configuration: {}
                Policy: {}
                settings: {}
                lastRunVersion: invalid
            }
        }
    })
    session_user_settings_SaveDefaults()
end sub


sub session_Delete()
    session_server_Delete()
    session_user_Logout()
end sub


sub session_Update(key as string, value = {} as object)

    if key = "" or (key <> "user" and key <> "server") or value = invalid
        print "Error in session.Update(): Invalid parameters provided"
        return
    end if

    tmpSession = m.global.session

    tmpSession.AddReplace(key, value)

    m.global.setFields({
        session: tmpSession
    })

end sub

sub session_server_Delete()
    session_Update("server")
end sub


sub session_server_Update(key as string, value as dynamic)

    if key = "" or value = invalid then
        return
    end if

    tmpSessionServer = m.global.session.server

    tmpSessionServer[key] = value
    session_Update("server", tmpSessionServer)
end sub



function session_server_UpdateURL(value as string) as boolean

    if value = "" then
        return false
    end if
    session_server_Update("url", value)
    success = session_server_Populate()
    if not success
        session_server_Delete()
    end if
    return success
end function



function session_server_Populate() as boolean

    if m.global.session.server.url = invalid or m.global.session.server.url = "" then
        return false
    end if

    myServerInfo = ServerInfo()

    if myServerInfo.id = invalid then
        return false
    end if

    tmpSessionServer = m.global.session.server

    tmpSessionServer.AddReplace("id", myServerInfo.Id)
    tmpSessionServer.AddReplace("name", myServerInfo.ServerName)
    tmpSessionServer.AddReplace("localURL", myServerInfo.LocalAddress)
    tmpSessionServer.AddReplace("os", myServerInfo.OperatingSystem)
    tmpSessionServer.AddReplace("startupWizardCompleted", myServerInfo.StartupWizardCompleted)
    tmpSessionServer.AddReplace("version", myServerInfo.Version)
    tmpSessionServer.AddReplace("hasError", myServerInfo.error)

    isServerHTTPS = false
    if tmpSessionServer.url.left(8) = "https://" then
        isServerHTTPS = true
    end if
    tmpSessionServer.AddReplace("isHTTPS", isServerHTTPS)
    isLocalServerHTTPS = false
    if myServerInfo.LocalAddress <> invalid and myServerInfo.LocalAddress.left(8) = "https://" then
        isLocalServerHTTPS = true
    end if
    tmpSessionServer.AddReplace("isLocalHTTPS", isLocalServerHTTPS)

    session_Update("server", tmpSessionServer)
    if m.global.app.isDev
        print "m.global.session.server = ", m.global.session.server
    end if
    return true
end function

sub session_user_Update(key as string, value as dynamic)

    if key = "" or value = invalid then
        return
    end if

    tmpSessionUser = m.global.session.user

    tmpSessionUser[key] = value

    session_Update("user", tmpSessionUser)
end sub



sub session_user_Login(userData as object, saveCredentials = false as boolean)

    if userData = invalid or userData.id = invalid then
        return
    end if

    tmpSession = m.global.session
    oldUserSettings = tmpSession.user.settings
    if userData.json = invalid

        myAuthToken = tmpSession.user.authToken
        tmpSession.AddReplace("user", userData)
        tmpSession.user.AddReplace("authToken", myAuthToken)
    else

        tmpSession.AddReplace("user", userData.json.User)
        tmpSession.user.AddReplace("authToken", userData.json.AccessToken)
    end if

    regex = CreateObject("roRegex", "[^a-zA-Z0-9\ \-\_]", "")
    friendlyName = regex.ReplaceAll(tmpSession.user.name, "")
    tmpSession.user.AddReplace("friendlyName", friendlyName)
    tmpSession.user.AddReplace("settings", oldUserSettings)

    session_Update("user", tmpSession.user)

    lastRunVersion = get_user_setting("LastRunVersion")
    if isValid(lastRunVersion)
        session_user_Update("LastRunVersion", lastRunVersion)
    end if

    userSettings = RegistryReadAll(tmpSession.user.id)
    for each setting in userSettings

        if setting <> "token"
            session_user_settings_Save(setting, userSettings[setting])
        end if
    end for
    if m.global.app.isDev
        print "m.global.session.user = ", m.global.session.user
        print "m.global.session.user.Configuration = ", m.global.session.user.Configuration
        print "m.global.session.user.Policy = ", m.global.session.user.Policy
        print "m.global.session.user.settings = ", m.global.session.user.settings
    end if
    set_user_setting("serverId", m.global.session.server.id)
    if saveCredentials
        set_user_setting("token", tmpSession.user.authToken)
        set_user_setting("username", tmpSession.user.name)
    end if
    if m.global.session.user.settings["global.rememberme"]
        set_setting("active_user", tmpSession.user.id)
    end if
    session_user_LoadUserPreferences()
end sub


sub session_user_SetServerDeviceName()
    if isValid(m.global.session.user) and isValid(m.global.session.user.friendlyName)
        m.global.device.serverDeviceName = m.global.device.id + m.global.session.user.friendlyName
    else
        m.global.device.serverDeviceName = m.global.device.id
    end if
end sub


sub session_user_LoadUserPreferences()

    session_user_SetServerDeviceName()
    id = m.global.session.user.id


    url = Substitute("DisplayPreferences/usersettings?userId={0}&client=emby", id)
    resp = APIRequest(url)
    jsonResponse = getJson(resp)
    if isValid(jsonResponse) and isValid(jsonResponse.CustomPrefs)
        session_user_SaveUserHomeSections(jsonResponse.CustomPrefs)
        if isValid(jsonResponse.CustomPrefs["landing-livetv"])
            set_user_setting("display.livetv.landing", jsonResponse.CustomPrefs["landing-livetv"])
        else
            unset_user_setting("display.livetv.landing")
        end if
    else

        session_user_SaveUserHomeSections({
            homesection0: "smalllibrarytiles"
            homesection1: "resume"
            homesection2: "nextup"
            homesection3: "latestmedia"
            homesection4: "livetv"
            homesection5: "none"
            homesection6: "none"
        })
        unset_user_setting("display.livetv.landing")
    end if
end sub



sub session_user_SaveUserHomeSections(customPrefs as object)
    userPreferences = customPrefs
    rowTypes = []
    useWebSectionArrangement = m.global.session.user.settings["ui.home.useWebSectionArrangement"]
    if isValid(useWebSectionArrangement)
        if not useWebSectionArrangement
            userPreferences.delete("homesection0")
        end if
    end if

    if not userPreferences.doesExist("homesection0")
        userPreferences = {
            homesection0: "smalllibrarytiles"
            homesection1: "resume"
            homesection2: "nextup"
            homesection3: "latestmedia"
            homesection4: "livetv"
            homesection5: "none"
            homesection6: "none"
        }
    end if
    for i = 0 to 6
        homeSectionKey = "homesection" + i.toStr()

        if not userPreferences.DoesExist(homeSectionKey)
            userPreferences.AddReplace(homeSectionKey, "none")
        end if
        rowType = LCase(userPreferences[homeSectionKey])

        if not isValid(rowType) then
            rowType = "none"
        end if

        if rowType = "librarybuttons"
            rowType = "smalllibrarytiles"
        end if


        if inArray(rowTypes, rowType)
            set_user_setting(homeSectionKey, "none")
        else
            set_user_setting(homeSectionKey, rowType)
            if rowType <> "none"
                rowTypes.push(rowType)
            end if
        end if
    end for
end sub


sub session_user_Logout()
    session_Update("user", {
        Configuration: {}
        Policy: {}
        settings: {}
    })

    session_user_settings_SaveDefaults()
end sub

sub session_user_settings_Delete(name as string)

    if name = "" then
        return
    end if
    tmpSettingArray = m.global.session.user.settings

    tmpSettingArray.Delete(name)

    session_user_Update("settings", tmpSettingArray)
end sub


function session_user_settings_Read(name as string) as dynamic

    if name = "" then
        return invalid
    end if
    if m.global.session.user.settings[name] <> invalid
        return m.global.session.user.settings[name]
    else
        return invalid
    end if
end function


sub session_user_settings_SaveDefaults()
    configTree = GetConfigTree()
    if configTree = invalid then
        return
    end if
    for each item in configTree
        if item.default <> invalid and item.settingName <> invalid
            session_user_settings_Save(item.settingName, item.default)
        else if item.children <> invalid and item.children.Count() > 0
            for each child in item.children
                if child.default <> invalid and child.settingName <> invalid
                    session_user_settings_Save(child.settingName, child.default)
                else if child.children <> invalid and child.children.Count() > 0
                    for each child in child.children
                        if child.default <> invalid and child.settingName <> invalid
                            session_user_settings_Save(child.settingName, child.default)
                        else if child.children <> invalid and child.children.Count() > 0
                            for each child in child.children
                                if child.default <> invalid and child.settingName <> invalid
                                    session_user_settings_Save(child.settingName, child.default)
                                else if child.children <> invalid and child.children.Count() > 0
                                    for each child in child.children
                                        if child.default <> invalid and child.settingName <> invalid
                                            session_user_settings_Save(child.settingName, child.default)
                                        else if child.children <> invalid and child.children.Count() > 0
                                            for each child in child.children
                                                if child.default <> invalid and child.settingName <> invalid
                                                    session_user_settings_Save(child.settingName, child.default)
                                                end if
                                            end for
                                        end if
                                    end for
                                end if
                            end for
                        end if
                    end for
                end if
            end for
        end if
    end for

    session_user_settings_LoadGlobals()
end sub


sub session_user_settings_LoadGlobals()

    jfRegistry = RegistryReadAll("Jellyfin")
    for each item in jfRegistry
        if Left(item, 7) = "global."
            session_user_settings_Save(item, get_setting(item))
        end if
    end for

    session_user_SetServerDeviceName()
end sub



sub session_user_settings_Save(name as string, value as string)
    if name = invalid or value = invalid then
        return
    end if
    tmpSettingArray = m.global.session.user.settings
    convertedValue = value

    if value = "true"
        convertedValue = true
    else if value = "false"
        convertedValue = false
    end if
    tmpSettingArray[name] = convertedValue
    session_user_Update("settings", tmpSettingArray)
end sub