function LoginFlow()

    start_login:
    serverUrl = get_setting("server")
    if isValid(serverUrl)
        print "Previous server connection saved to registry"
        startOver = not session_server_UpdateURL(serverUrl)
        if startOver
            print "Could not connect to previously saved server."
        end if
    else
        startOver = true
        print "No previous server connection saved to registry"
    end if
    invalidServer = true
    if not startOver
        m.scene.isLoading = true
        invalidServer = ServerInfo().Error
        m.scene.isLoading = false
    end if
    m.serverSelection = "Saved"
    if startOver or invalidServer
        print "Get server details"
        SendPerformanceBeacon("AppDialogInitiate") ' Roku Performance monitoring - Dialog Starting
        m.serverSelection = CreateServerGroup()
        SendPerformanceBeacon("AppDialogComplete") ' Roku Performance monitoring - Dialog Closed
        if m.serverSelection = "backPressed"
            print "backPressed"
            m.global.sceneManager.callFunc("clearScenes")
            return false
        end if
        SaveServerList()
    end if
    activeUser = get_setting("active_user")
    if activeUser = invalid
        print "No active user found in registry"
        user_select:
        SendPerformanceBeacon("AppDialogInitiate") ' Roku Performance monitoring - Dialog Starting
        publicUsers = GetPublicUsers()
        savedUsers = getSavedUsers()
        numPubUsers = publicUsers.count()
        numSavedUsers = savedUsers.count()
        if numPubUsers > 0 or numSavedUsers > 0
            publicUsersNodes = []
            publicUserIds = []

            if numPubUsers > 0
                for each item in publicUsers
                    user = CreateObject("roSGNode", "PublicUserData")
                    user.id = item.Id
                    user.name = item.Name
                    if isValid(item.PrimaryImageTag)
                        user.ImageURL = UserImageURL(user.id, {
                            "tag": item.PrimaryImageTag
                        })
                    end if
                    publicUsersNodes.push(user)
                    publicUserIds.push(user.id)
                end for
            end if

            if numSavedUsers > 0
                for each savedUser in savedUsers
                    if isValid(savedUser.serverId) and savedUser.serverId = m.global.session.server.id

                        if not arrayHasValue(publicUserIds, savedUser.Id)
                            user = CreateObject("roSGNode", "PublicUserData")
                            user.id = savedUser.Id
                            if isValid(savedUser.username)
                                user.name = savedUser.username
                            end if
                            publicUsersNodes.push(user)
                        end if
                    end if
                end for
            end if

            userSelected = CreateUserSelectGroup(publicUsersNodes)
            SendPerformanceBeacon("AppDialogComplete") ' Roku Performance monitoring - Dialog Closed
            if userSelected = "backPressed"
                session_server_Delete()
                unset_setting("server")
                goto start_login
            else if userSelected <> ""
                startLoadingSpinner()
                print "A public user was selected with username=" + userSelected
                session_user_Update("name", userSelected)
                regex = CreateObject("roRegex", "[^a-zA-Z0-9\ \-\_]", "")
                session_user_Update("friendlyName", regex.ReplaceAll(userSelected, ""))

                for each user in publicUsersNodes
                    if user.name = userSelected
                        session_user_Update("id", user.id)
                        exit for
                    end if
                end for

                myToken = get_user_setting("token")
                if myToken <> invalid

                    print "Auth token found in registry for selected user"
                    session_user_Update("authToken", myToken)
                    print "Attempting to use API with auth token"
                    currentUser = AboutMe()
                    if currentUser = invalid
                        print "Auth token is no longer valid - deleting token"
                        unset_user_setting("token")
                        unset_user_setting("username")
                    else
                        print "Success! Auth token is still valid"
                        session_user_Login(currentUser, true)
                        LoadUserAbilities()
                        return true
                    end if
                else
                    print "No auth token found in registry for selected user"
                end if

                print "Attempting to login with no password"
                userData = get_token(userSelected, "")
                if isValid(userData)
                    print "login success!"
                    session_user_Login(userData, true)
                    LoadUserAbilities()
                    return true
                else
                    print "Auth failed. Password required"
                end if
            end if
        else
            userSelected = ""
        end if
        stopLoadingSpinner()
        passwordEntry = CreateSigninGroup(userSelected)
        SendPerformanceBeacon("AppDialogComplete") ' Roku Performance monitoring - Dialog Closed
        if passwordEntry = "backPressed"
            if numPubUsers > 0
                goto user_select
            else
                session_server_Delete()
                unset_setting("server")
                goto start_login
            end if
        end if
    else
        print "Active user found in registry"
        session_user_Update("id", activeUser)
        myUsername = get_user_setting("username")
        myAuthToken = get_user_setting("token")
        if isValid(myAuthToken) and isValid(myUsername)
            print "Auth token found in registry"
            session_user_Update("authToken", myAuthToken)
            session_user_Update("name", myUsername)
            regex = CreateObject("roRegex", "[^a-zA-Z0-9\ \-\_]", "")
            session_user_Update("friendlyName", regex.ReplaceAll(myUsername, ""))
            print "Attempting to use API with auth token"
            currentUser = AboutMe()
            if currentUser = invalid
                print "Auth token is no longer valid"

                print "Attempting to login with no password"
                userData = get_token(myUsername, "")
                if isValid(userData)
                    print "login success!"
                    session_user_Login(userData, true)
                    LoadUserAbilities()
                    return true
                else
                    print "Auth failed. Password required"
                    print "delete token and restart login flow"
                    unset_user_setting("token")
                    unset_user_setting("username")
                    goto start_login
                end if
            else
                print "Success! Auth token is still valid"
                session_user_Login(currentUser, true)
            end if
        else
            print "No auth token found in registry"
        end if
    end if
    if m.global.session.user.id = invalid or m.global.session.user.authToken = invalid
        print "Login failed, restart flow"
        unset_setting("active_user")
        session_user_Logout()
        goto start_login
    end if
    LoadUserAbilities()
    m.global.sceneManager.callFunc("clearScenes")
    return true
end function

sub SaveServerList()

    server = m.global.session.server.url
    saved = get_setting("saved_servers")
    if isValid(server)
        server = LCase(server) 'Saved server data is always lowercase
    end if
    entryCount = 0
    addNewEntry = true
    savedServers = {
        serverList: []
    }
    if isValid(saved)
        savedServers = ParseJson(saved)
        entryCount = savedServers.serverList.Count()
        if isValid(savedServers.serverList) and entryCount > 0
            for each item in savedServers.serverList
                if item.baseUrl = server
                    addNewEntry = false
                    exit for
                end if
            end for
        end if
    end if
    if addNewEntry
        if entryCount = 0
            set_setting("saved_servers", FormatJson({
                serverList: [
                    {
                        name: m.serverSelection
                        baseUrl: server
                        iconUrl: "pkg:/images/logo-icon120.jpg"
                        iconWidth: 120
                        iconHeight: 120
                    }
                ]
            }))
        else
            savedServers.serverList.Push({
                name: m.serverSelection
                baseUrl: server
                iconUrl: "pkg:/images/logo-icon120.jpg"
                iconWidth: 120
                iconHeight: 120
            })
            set_setting("saved_servers", FormatJson(savedServers))
        end if
    end if
end sub

sub DeleteFromServerList(urlToDelete)
    saved = get_setting("saved_servers")
    if isValid(urlToDelete)
        urlToDelete = LCase(urlToDelete)
    end if
    if isValid(saved)
        savedServers = ParseJson(saved)
        newServers = {
            serverList: []
        }
        for each item in savedServers.serverList
            if item.baseUrl <> urlToDelete
                newServers.serverList.Push(item)
            end if
        end for
        set_setting("saved_servers", FormatJson(newServers))
    end if
end sub


sub SendPerformanceBeacon(signalName as string)
    if m.global.app_loaded = false
        m.scene.signalBeacon(signalName)
    end if
end sub

function CreateServerGroup()
    screen = CreateObject("roSGNode", "SetServerScreen")
    screen.optionsAvailable = true
    m.global.sceneManager.callFunc("pushScene", screen)
    port = CreateObject("roMessagePort")
    m.colors = {}
    if isValid(m.global.session.server.url)
        screen.serverUrl = m.global.session.server.url
    end if
    m.viewModel = {}
    button = screen.findNode("submit")
    button.observeField("buttonSelected", port)

    new_options = []
    sidepanel = screen.findNode("options")
    opt = CreateObject("roSGNode", "OptionsButton")
    opt.title = tr("Delete Saved")
    opt.id = "delete_saved"
    opt.observeField("optionSelected", port)
    new_options.push(opt)
    sidepanel.options = new_options
    sidepanel.observeField("closeSidePanel", port)
    screen.observeField("backPressed", port)
    while true
        msg = wait(0, port)
        print type(msg), msg
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            return "false"
        else if isNodeEvent(msg, "backPressed")
            return "backPressed"
        else if isNodeEvent(msg, "closeSidePanel")
            screen.setFocus(true)
            serverPicker = screen.findNode("serverPicker")
            serverPicker.setFocus(true)
        else if type(msg) = "roSGNodeEvent"
            node = msg.getNode()
            if node = "submit"
                m.scene.isLoading = true
                serverUrl = inferServerUrl(screen.serverUrl)
                isConnected = session_server_UpdateURL(serverUrl)
                serverInfoResult = invalid
                if isConnected
                    set_setting("server", serverUrl)
                    serverInfoResult = ServerInfo()

                    if m.global.session.server.url <> serverUrl
                        set_setting("username", "")
                        set_setting("password", "")
                    end if
                    set_setting("server", serverUrl)
                end if
                m.scene.isLoading = false
                if isConnected = false or serverInfoResult = invalid


                    print "Server not found, is it online? New values / Retry"
                    screen.errorMessage = tr("Server not found, is it online?")
                    SignOut(false)
                else
                    if isValid(serverInfoResult.Error) and serverInfoResult.Error

                        if isValid(serverInfoResult.UpdatedUrl)
                            serverUrl = serverInfoResult.UpdatedUrl
                            isConnected = session_server_UpdateURL(serverUrl)
                            if isConnected
                                set_setting("server", serverUrl)
                                screen.visible = false
                                return ""
                            end if
                        end if

                        message = tr("Error: ")
                        if isValid(serverInfoResult.ErrorCode)
                            message = message + "[" + serverInfoResult.ErrorCode.toStr() + "] "
                        end if
                        screen.errorMessage = message + tr(serverInfoResult.ErrorMessage)
                        SignOut(false)
                    else
                        screen.visible = false
                        if isValid(serverInfoResult.serverName)
                            return serverInfoResult.ServerName + " (Saved)"
                        else
                            return "Saved"
                        end if
                    end if
                end if
            else if node = "delete_saved"
                serverPicker = screen.findNode("serverPicker")
                itemToDelete = serverPicker.content.getChild(serverPicker.itemFocused)
                urlToDelete = itemToDelete.baseUrl
                if isValid(urlToDelete)
                    DeleteFromServerList(urlToDelete)
                    serverPicker.content.removeChild(itemToDelete)
                    sidepanel.visible = false
                    serverPicker.setFocus(true)
                end if
            end if
        end if
    end while

    screen.visible = false
    return ""
end function

function CreateUserSelectGroup(users = [])
    if users.count() = 0
        return ""
    end if
    group = CreateObject("roSGNode", "UserSelect")
    m.global.sceneManager.callFunc("pushScene", group)
    port = CreateObject("roMessagePort")
    group.itemContent = users
    group.findNode("userRow").observeField("userSelected", port)
    group.findNode("alternateOptions").observeField("itemSelected", port)
    group.observeField("backPressed", port)
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            group.visible = false
            return -1
        else if isNodeEvent(msg, "backPressed")
            return "backPressed"
        else if type(msg) = "roSGNodeEvent" and msg.getField() = "userSelected"
            return msg.GetData()
        else if type(msg) = "roSGNodeEvent" and msg.getField() = "itemSelected"
            if msg.getData() = 0
                return ""
            end if
        end if
    end while

    group.visible = false
    return ""
end function

function CreateSigninGroup(user = "")

    group = CreateObject("roSGNode", "LoginScene")
    m.global.sceneManager.callFunc("pushScene", group)
    port = CreateObject("roMessagePort")
    group.findNode("prompt").text = tr("Sign In")
    config = group.findNode("configOptions")
    username_field = CreateObject("roSGNode", "ConfigData")
    username_field.label = tr("Username")
    username_field.field = "username"
    username_field.type = "string"
    if user = "" and get_setting("username") <> invalid
        username_field.value = get_setting("username")
    else
        username_field.value = user
    end if
    password_field = CreateObject("roSGNode", "ConfigData")
    password_field.label = tr("Password")
    password_field.field = "password"
    password_field.type = "password"
    registryPassword = get_setting("password")
    if isValid(registryPassword)
        password_field.value = registryPassword
    end if

    checkbox = group.findNode("onOff")
    items = CreateObject("roSGNode", "ContentNode")
    items.role = "content"
    saveCheckBox = CreateObject("roSGNode", "ContentNode")
    saveCheckBox.title = tr("Save Credentials?")
    items.appendChild(saveCheckBox)
    checkbox.content = items
    checkbox.checkedState = [
        true
    ]
    quickConnect = group.findNode("quickConnect")

    if versionChecker(m.global.session.server.version, "10.8.0")

        quickConnect.text = tr("Quick Connect")
        quickConnect.observeField("buttonSelected", port)
    else
        quickConnect.visible = false
    end if
    items = [
        username_field
        password_field
    ]
    config.configItems = items
    button = group.findNode("submit")
    button.observeField("buttonSelected", port)
    config = group.findNode("configOptions")
    username = config.content.getChild(0)
    password = config.content.getChild(1)
    group.observeField("backPressed", port)
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            group.visible = false
            return "false"
        else if isNodeEvent(msg, "backPressed")
            group.unobserveField("backPressed")
            group.backPressed = false
            return "backPressed"
        else if type(msg) = "roSGNodeEvent"
            node = msg.getNode()
            if node = "submit"
                startLoadingSpinner()

                activeUser = get_token(username.value, password.value)
                if isValid(activeUser)
                    print "activeUser=", activeUser
                    if checkbox.checkedState[0] = true

                        session_user_Login(activeUser, true)
                        set_user_setting("token", activeUser.token)
                        set_user_setting("username", username.value)
                    else
                        session_user_Login(activeUser)
                    end if
                    return "true"
                end if
                stopLoadingSpinner()
                print "Login attempt failed..."
                group.findNode("alert").text = tr("Login attempt failed.")
            else if node = "quickConnect"
                json = initQuickConnect()
                if json = invalid
                    group.findNode("alert").text = tr("Quick Connect not available.")
                else

                    m.quickConnectDialog = createObject("roSGNode", "QuickConnectDialog")
                    m.quickConnectDialog.saveCredentials = checkbox.checkedState[0]
                    m.quickConnectDialog.quickConnectJson = json
                    m.quickConnectDialog.title = tr("Quick Connect")
                    m.quickConnectDialog.message = [
                        tr("Here is your Quick Connect code: ") + json.Code
                        tr("(Dialog will close automatically)")
                    ]
                    m.quickConnectDialog.buttons = [
                        tr("Cancel")
                    ]
                    m.quickConnectDialog.observeField("authenticated", port)
                    m.scene.dialog = m.quickConnectDialog
                end if
            else if msg.getField() = "authenticated"
                authenticated = msg.getData()
                if authenticated = true

                    return "true"
                else
                    dialog = createObject("roSGNode", "Dialog")
                    dialog.id = "QuickConnectError"
                    dialog.title = tr("Quick Connect")
                    dialog.buttons = [
                        tr("OK")
                    ]
                    dialog.message = tr("There was an error authenticating via Quick Connect.")
                    m.scene.dialog = dialog
                    m.scene.dialog.observeField("buttonSelected", port)
                end if
            else

                dialog = msg.getRoSGNode()
                if dialog.id = "QuickConnectError"
                    dialog.unobserveField("buttonSelected")
                    dialog.close = true
                end if
            end if
        end if
    end while

    group.visible = false
    return ""
end function

function CreateHomeGroup()

    group = CreateObject("roSGNode", "Home")
    group.overhangTitle = tr("Home")
    group.optionsAvailable = true
    group.observeField("selectedItem", m.port)
    group.observeField("quickPlayNode", m.port)
    sidepanel = group.findNode("options")
    sidepanel.observeField("closeSidePanel", m.port)
    new_options = []
    options_buttons = [
        {
            "title": "Search"
            "id": "goto_search"
        }
        {
            "title": "Change user"
            "id": "change_user"
        }
        {
            "title": "Change server"
            "id": "change_server"
        }
        {
            "title": "Sign out"
            "id": "sign_out"
        }
    ]
    for each opt in options_buttons
        o = CreateObject("roSGNode", "OptionsButton")
        o.title = tr(opt.title)
        o.id = opt.id
        o.observeField("optionSelected", m.port)
        new_options.push(o)
    end for

    o = CreateObject("roSGNode", "OptionsButton")
    o.title = "Settings"
    o.id = "settings"
    o.observeField("optionSelected", m.port)
    new_options.push(o)

    user_node = CreateObject("roSGNode", "OptionsData")
    user_node.id = "active_user"
    user_node.title = tr("Profile")
    user_node.base_title = tr("Profile")
    user_options = []
    for each user in AvailableUsers()
        user_options.push({
            display: user.username + "@" + user.server
            value: user.id
        })
    end for
    user_node.choices = user_options
    user_node.value = m.global.session.user.id
    new_options.push(user_node)
    sidepanel.options = new_options
    return group
end function

function CreateMovieDetailsGroup(movie as object) as dynamic

    if not isValid(movie) or not isValid(movie.id) then
        return invalid
    end if
    startLoadingSpinner()

    movieMetaData = ItemMetaData(movie.id)

    if not isValid(movieMetaData)
        stopLoadingSpinner()
        return invalid
    end if

    group = CreateObject("roSGNode", "MovieDetails")
    group.observeField("quickPlayNode", m.port)
    group.overhangTitle = movie.title
    group.optionsAvailable = false
    group.trailerAvailable = false

    m.global.sceneManager.callFunc("pushScene", group)
    group.itemContent = movieMetaData

    trailerData = api_users_GetLocalTrailers(m.global.session.user.id, movie.id)
    if isValid(trailerData)
        group.trailerAvailable = trailerData.Count() > 0
    end if

    buttons = group.findNode("buttons")
    for each b in buttons.getChildren(-1, 0)
        b.observeField("buttonSelected", m.port)
    end for

    extras = group.findNode("extrasGrid")
    extras.observeField("selectedItem", m.port)
    extras.callFunc("loadParts", movieMetaData.json)

    stopLoadingSpinner()
    return group
end function

function CreateSeriesDetailsGroup(seriesID as string) as dynamic

    if not isValid(seriesID) or seriesID = "" then
        return invalid
    end if
    startLoadingSpinner()

    seriesMetaData = ItemMetaData(seriesID)

    if not isValid(seriesMetaData)
        stopLoadingSpinner()
        return invalid
    end if

    seasonData = TVSeasons(seriesID)

    if m.global.session.user.settings["ui.tvshows.goStraightToEpisodeListing"] = true and seasonData.Items.Count() = 1
        stopLoadingSpinner()
        return CreateSeasonDetailsGroupByID(seriesID, seasonData.Items[0].id)
    end if

    group = CreateObject("roSGNode", "TVShowDetails")
    group.optionsAvailable = false

    m.global.sceneManager.callFunc("pushScene", group)
    group.itemContent = seriesMetaData
    group.seasonData = seasonData

    group.observeField("seasonSelected", m.port)
    group.observeField("quickPlayNode", m.port)

    extras = group.findNode("extrasGrid")
    extras.observeField("selectedItem", m.port)
    extras.callFunc("loadParts", seriesMetaData.json)

    stopLoadingSpinner()
    return group
end function


function CreateArtistView(artist as object) as dynamic

    if not isValid(artist) or not isValid(artist.id) then
        return invalid
    end if
    musicData = MusicAlbumList(artist.id)
    appearsOnData = AppearsOnList(artist.id)
    if (musicData = invalid or musicData.Items.Count() = 0) and (appearsOnData = invalid or appearsOnData.Items.Count() = 0)

        group = CreateObject("roSGNode", "AlbumView")
        group.pageContent = ItemMetaData(artist.id)

        songList = GetSongsByArtist(artist.id)
        if not isValid(songList)

            songList = MusicSongList(artist.id)
        end if
        if not isValid(songList)
            return invalid
        end if
        group.albumData = songList
        group.observeField("playSong", m.port)
        group.observeField("playAllSelected", m.port)
        group.observeField("instantMixSelected", m.port)
    else

        group = CreateObject("roSGNode", "ArtistView")
        group.pageContent = ItemMetaData(artist.id)
        group.musicArtistAlbumData = musicData
        group.musicArtistAppearsOnData = appearsOnData
        group.artistOverview = ArtistOverview(artist.name)
        group.observeField("musicAlbumSelected", m.port)
        group.observeField("playArtistSelected", m.port)
        group.observeField("instantMixSelected", m.port)
        group.observeField("appearsOnSelected", m.port)
    end if
    group.observeField("quickPlayNode", m.port)
    m.global.sceneManager.callFunc("pushScene", group)
    return group
end function


function CreateAlbumView(album as object) as dynamic

    if not isValid(album) or not isValid(album.id) then
        return invalid
    end if
    group = CreateObject("roSGNode", "AlbumView")
    m.global.sceneManager.callFunc("pushScene", group)
    group.pageContent = ItemMetaData(album.id)
    group.albumData = MusicSongList(album.id)

    group.observeField("playSong", m.port)

    group.observeField("playAllSelected", m.port)

    group.observeField("instantMixSelected", m.port)
    return group
end function


function CreatePlaylistView(playlist as object) as dynamic

    if not isValid(playlist) or not isValid(playlist.id) then
        return invalid
    end if
    group = CreateObject("roSGNode", "PlaylistView")
    m.global.sceneManager.callFunc("pushScene", group)
    group.pageContent = ItemMetaData(playlist.id)
    group.albumData = PlaylistItemList(playlist.id)

    group.observeField("playItem", m.port)

    group.observeField("playAllSelected", m.port)
    return group
end function

function CreateSeasonDetailsGroup(series as object, season as object) as dynamic

    if not isValid(series) or not isValid(series.id) then
        return invalid
    end if

    if not isValid(season) or not isValid(season.id) then
        return invalid
    end if
    startLoadingSpinner()

    seasonMetaData = ItemMetaData(season.id)

    if not isValid(seasonMetaData)
        stopLoadingSpinner()
        return invalid
    end if

    group = CreateObject("roSGNode", "TVEpisodes")
    group.optionsAvailable = false

    m.global.sceneManager.callFunc("pushScene", group)
    group.seasonData = seasonMetaData.json
    group.objects = TVEpisodes(series.id, season.id)
    group.episodeObjects = group.objects
    group.extrasObjects = TVSeasonExtras(season.id)

    group.observeField("selectedItem", m.port)
    group.observeField("quickPlayNode", m.port)

    stopLoadingSpinner()
    return group
end function

function CreateSeasonDetailsGroupByID(seriesID as string, seasonID as string) as dynamic

    if seriesID = "" or seasonID = "" then
        return invalid
    end if
    startLoadingSpinner()

    seasonMetaData = ItemMetaData(seasonID)

    if not isValid(seasonMetaData)
        stopLoadingSpinner()
        return invalid
    end if

    group = CreateObject("roSGNode", "TVEpisodes")
    group.optionsAvailable = false

    group.seasonData = seasonMetaData.json
    group.objects = TVEpisodes(seriesID, seasonID)
    group.episodeObjects = group.objects

    group.observeField("episodeSelected", m.port)
    group.observeField("quickPlayNode", m.port)

    stopLoadingSpinner()
    m.global.sceneManager.callFunc("pushScene", group)

    group.extrasObjects = TVSeasonExtras(seasonID)

    return group
end function

function CreateItemGrid(libraryItem as object) as dynamic

    if not isValid(libraryItem) then
        return invalid
    end if
    group = CreateObject("roSGNode", "ItemGrid")
    group.parentItem = libraryItem
    group.optionsAvailable = true
    group.observeField("selectedItem", m.port)
    group.observeField("quickPlayNode", m.port)
    return group
end function

function CreateMovieLibraryView(libraryItem as object) as dynamic

    if not isValid(libraryItem) then
        return invalid
    end if
    group = CreateObject("roSGNode", "MovieLibraryView")
    group.parentItem = libraryItem
    group.optionsAvailable = true
    group.observeField("selectedItem", m.port)
    group.observeField("quickPlayNode", m.port)
    return group
end function

function CreateMusicLibraryView(libraryItem as object) as dynamic

    if not isValid(libraryItem) then
        return invalid
    end if
    group = CreateObject("roSGNode", "MusicLibraryView")
    group.parentItem = libraryItem
    group.optionsAvailable = true
    group.observeField("selectedItem", m.port)
    group.observeField("quickPlayNode", m.port)
    return group
end function

function CreateSearchPage()

    group = CreateObject("roSGNode", "searchResults")
    group.observeField("quickPlayNode", m.port)
    options = group.findNode("searchSelect")
    options.observeField("itemSelected", m.port)
    return group
end function

function CreateVideoPlayerGroup(video_id as string, mediaSourceId = invalid as dynamic, audio_stream_idx = 1 as integer, forceTranscoding = false as boolean, showIntro = true as boolean, allowResumeDialog = true as boolean)

    if not isValid(video_id) or video_id = "" then
        return invalid
    end if
    startLoadingSpinner()

    video = VideoPlayer(video_id, mediaSourceId, audio_stream_idx, defaultSubtitleTrackFromVid(video_id), forceTranscoding, showIntro, allowResumeDialog)
    if video = invalid then
        return invalid
    end if
    video.allowCaptions = true
    if video.errorMsg = "introaborted" then
        return video
    end if
    video.observeField("selectSubtitlePressed", m.port)
    video.observeField("selectPlaybackInfoPressed", m.port)
    video.observeField("state", m.port)
    stopLoadingSpinner()
    return video
end function

function CreatePersonView(personData as object) as dynamic

    if not isValid(personData) or not isValid(personData.id) then
        return invalid
    end if
    startLoadingSpinner()

    personMetaData = ItemMetaData(personData.id)

    if not isValid(personMetaData)
        stopLoadingSpinner()
        return invalid
    end if

    person = CreateObject("roSGNode", "PersonDetails")

    m.global.SceneManager.callFunc("pushScene", person)
    person.itemContent = personMetaData
    person.setFocus(true)

    person.observeField("selectedItem", m.port)
    person.findNode("favorite-button").observeField("buttonSelected", m.port)

    stopLoadingSpinner()
    return person
end function


sub playbackOptionDialog(time as longinteger, meta as object)
    resumeData = [
        tr("Resume playing at ") + ticksToHuman(time) + "."
        tr("Start over from the beginning.")
    ]
    group = m.global.sceneManager.callFunc("getActiveScene")
    if LCase(group.subtype()) = "home"
        if LCase(meta.type) = "episode"
            resumeData.push(tr("Go to series"))
            resumeData.push(tr("Go to season"))
            resumeData.push(tr("Go to episode"))
        end if
    end if
    stopLoadingSpinner()
    m.global.sceneManager.callFunc("optionDialog", tr("Playback Options"), [], resumeData)
end sub