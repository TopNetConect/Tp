sub Main(args as dynamic) as void
    printRegistry()

    m.screen = CreateObject("roSGScreen")

    setConstants()

    WriteAsciiFile("tmp:/scene.temp", "")
    MoveFile("tmp:/scene.temp", "tmp:/scene")
    m.port = CreateObject("roMessagePort")
    m.screen.setMessagePort(m.port)

    m.global = m.screen.getGlobalNode()
    SaveAppToGlobal()
    SaveDeviceToGlobal()
    session_Init()

    m.wasMigrated = false
    runGlobalMigrations()
    runRegistryUserMigrations()

    if m.global.app.version <> m.global.app.lastRunVersion
        set_setting("LastRunVersion", m.global.app.version)
    end if
    if m.wasMigrated then
        printRegistry()
    end if
    m.scene = m.screen.CreateScene("JFScene")
    m.screen.show() ' vscode_rale_tracker_entry
    playstateTask = CreateObject("roSGNode", "PlaystateTask")
    playstateTask.id = "playstateTask"
    sceneManager = CreateObject("roSGNode", "SceneManager")
    sceneManager.observeField("dataReturned", m.port)
    m.global.addFields({
        app_loaded: false
        playstateTask: playstateTask
        sceneManager: sceneManager
    })
    m.global.addFields({
        queueManager: CreateObject("roSGNode", "QueueManager")
    })
    m.global.addFields({
        audioPlayer: CreateObject("roSGNode", "AudioPlayer")
    })
    app_start:

    if not LoginFlow() then
        return
    end if

    sceneManager.callFunc("clearScenes")

    sceneManager.currentUser = m.global.session.user.name
    group = CreateHomeGroup()
    group.callFunc("loadLibraries")
    stopLoadingSpinner()
    sceneManager.callFunc("pushScene", group)
    m.scene.observeField("exit", m.port)

    configEncoding = api_system_GetConfigurationByName("encoding")
    if isValid(configEncoding) and isValid(configEncoding.EnableFallbackFont)
        if configEncoding.EnableFallbackFont
            re = CreateObject("roRegex", "Name.:.(.*?).,.Size", "s")
            filename = APIRequest("FallbackFont/Fonts").GetToString()
            if isValid(filename)
                filename = re.match(filename)
                if isValid(filename) and filename.count() > 0
                    filename = filename[1]
                    APIRequest("FallbackFont/Fonts/" + filename).gettofile("tmp:/font")
                end if
            end if
        end if
    end if

    usersLastRunVersion = m.global.session.user.settings.lastRunVersion
    if not isValid(usersLastRunVersion) or not versionChecker(m.global.session.user.settings.lastRunVersion, m.global.app.version)
        set_user_setting("LastRunVersion", m.global.app.version)

        if m.global.session.user.settings["load.allowwhatsnew"]
            dialog = createObject("roSGNode", "WhatsNewDialog")
            m.scene.dialog = dialog
            m.scene.dialog.observeField("buttonSelected", m.port)
        end if
    end if

    input = CreateObject("roInput")
    input.SetMessagePort(m.port)
    device = CreateObject("roDeviceInfo")
    device.setMessagePort(m.port)
    device.EnableScreensaverExitedEvent(true)
    device.EnableAppFocusEvent(true)
    device.EnableLowGeneralMemoryEvent(true)
    device.EnableLinkStatusEvent(true)
    device.EnableCodecCapChangedEvent(true)
    device.EnableAudioGuideChangedEvent(true)

    if isValidAndNotEmpty(args.mediaType) and isValidAndNotEmpty(args.contentId)
        deepLinkVideo = {
            id: args.contentId
            type: "video"
        }
        m.global.queueManager.callFunc("push", deepLinkVideo)
        m.global.queueManager.callFunc("playQueue")
    end if




    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            print "CLOSING SCREEN"
            return
        else if isNodeEvent(msg, "exit")
            return
        else if isNodeEvent(msg, "closeSidePanel")
            group = sceneManager.callFunc("getActiveScene")
            if group.lastFocus <> invalid
                group.lastFocus.setFocus(true)
            else
                group.setFocus(true)
            end if
        else if isNodeEvent(msg, "quickPlayNode")

            timeSpan = CreateObject("roTimespan")
            group = sceneManager.callFunc("getActiveScene")
            reportingNode = msg.getRoSGNode()
            itemNode = invalid
            if isValid(reportingNode)
                itemNode = reportingNode.quickPlayNode
                reportingNodeType = reportingNode.subtype()
                print "Quick Play reporting node type=", reportingNodeType

                if isValid(reportingNodeType) and (reportingNodeType = "Home" or reportingNodeType = "TVEpisodes")
                    reportingNode.quickPlayNode = invalid
                end if
            end if
            print "Quick Play started. itemNode=", itemNode



            if isValid(itemNode) and isValid(itemNode.id) and itemNode.id <> ""

                itemType = invalid
                if isValid(itemNode.type) and itemNode.type <> ""
                    itemType = Lcase(itemNode.type)
                else

                    if isValid(itemNode.json) and isValid(itemNode.json.type)
                        itemType = Lcase(itemNode.json.type)
                    end if
                end if
                print "Quick Play itemNode type=", itemType

                if isValid(itemType)
                    startLoadingSpinner()
                    m.global.queueManager.callFunc("clear") ' empty queue/playlist
                    m.global.queueManager.callFunc("resetShuffle") ' turn shuffle off
                    if itemType = "episode" or itemType = "movie" or itemType = "video"
                        quickplay_video(itemNode)

                        if LCase(group.subtype()) = "tvepisodes"
                            if isValid(group.lastFocus)
                                group.lastFocus.setFocus(true)
                            end if
                        end if
                    else if itemType = "audio"
                        quickplay_audio(itemNode)
                    else if itemType = "musicalbum"
                        quickplay_album(itemNode)
                    else if itemType = "musicartist"
                        quickplay_artist(itemNode)
                    else if itemType = "series"
                        quickplay_series(itemNode)
                    else if itemType = "season"
                        quickplay_season(itemNode)
                    else if itemType = "boxset"
                        quickplay_boxset(itemNode)
                    else if itemType = "collectionfolder"
                        quickplay_collectionFolder(itemNode)
                    else if itemType = "playlist"
                        quickplay_playlist(itemNode)
                    else if itemType = "userview"
                        quickplay_userView(itemNode)
                    else if itemType = "folder"
                        quickplay_folder(itemNode)
                    else if itemType = "musicvideo"
                        quickplay_musicVideo(itemNode)
                    else if itemType = "person"
                        quickplay_person(itemNode)
                    else if itemType = "tvchannel"
                        quickplay_tvChannel(itemNode)
                    else if itemType = "program"
                        quickplay_program(itemNode)
                    else if itemType = "photo"
                        quickplay_photo(itemNode)
                    else if itemType = "photoalbum"
                        quickplay_photoAlbum(itemNode)
                    end if
                    m.global.queueManager.callFunc("playQueue")
                end if
            end if
            elapsed = timeSpan.TotalMilliseconds() / 1000
            print "Quick Play finished loading in " + elapsed.toStr() + " seconds."
        else if isNodeEvent(msg, "selectedItem")

            selectedItem = msg.getData()
            if isValid(selectedItem)
                startLoadingSpinner()
                selectedItemType = selectedItem.type
                if selectedItemType = "CollectionFolder"
                    if selectedItem.collectionType = "movies"
                        group = CreateMovieLibraryView(selectedItem)
                    else if selectedItem.collectionType = "music"
                        group = CreateMusicLibraryView(selectedItem)
                    else
                        group = CreateItemGrid(selectedItem)
                    end if
                    sceneManager.callFunc("pushScene", group)
                else if selectedItemType = "Folder" and selectedItem.json.type = "Genre"

                    if selectedItem.json.MovieCount > 0
                        group = CreateMovieLibraryView(selectedItem)
                    else
                        group = CreateItemGrid(selectedItem)
                    end if
                    sceneManager.callFunc("pushScene", group)
                else if selectedItemType = "Folder" and selectedItem.json.type = "MusicGenre"
                    group = CreateMusicLibraryView(selectedItem)
                    sceneManager.callFunc("pushScene", group)
                else if selectedItemType = "UserView" or selectedItemType = "Folder" or selectedItemType = "Channel" or selectedItemType = "Boxset"
                    group = CreateItemGrid(selectedItem)
                    sceneManager.callFunc("pushScene", group)
                else if selectedItemType = "Episode"

                    audio_stream_idx = 0
                    if isValid(selectedItem.selectedAudioStreamIndex) and selectedItem.selectedAudioStreamIndex > 0
                        audio_stream_idx = selectedItem.selectedAudioStreamIndex
                    end if
                    selectedItem.selectedAudioStreamIndex = audio_stream_idx

                    if selectedItem.json.userdata.PlaybackPositionTicks > 0
                        m.global.queueManager.callFunc("hold", selectedItem)
                        playbackOptionDialog(selectedItem.json.userdata.PlaybackPositionTicks, selectedItem.json)
                    else
                        m.global.queueManager.callFunc("clear")
                        m.global.queueManager.callFunc("push", selectedItem)
                        m.global.queueManager.callFunc("playQueue")
                    end if
                else if selectedItemType = "Series"
                    group = CreateSeriesDetailsGroup(selectedItem.json.id)
                else if selectedItemType = "Season"
                    group = CreateSeasonDetailsGroupByID(selectedItem.json.SeriesId, selectedItem.id)
                else if selectedItemType = "Movie"

                    group = CreateMovieDetailsGroup(selectedItem)
                else if selectedItemType = "Person"
                    CreatePersonView(selectedItem)
                else if selectedItemType = "TvChannel" or selectedItemType = "Video" or selectedItemType = "Program"


                    dialog = createObject("roSGNode", "ProgressDialog")
                    dialog.title = tr("Loading Channel Data")
                    m.scene.dialog = dialog

                    if LCase(selectedItemType) = "program"
                        selectedItem.id = selectedItem.json.ChannelId
                    end if

                    if selectedItem.json.userdata.PlaybackPositionTicks > 0
                        dialog.close = true
                        m.global.queueManager.callFunc("hold", selectedItem)
                        playbackOptionDialog(selectedItem.json.userdata.PlaybackPositionTicks, selectedItem.json)
                    else
                        m.global.queueManager.callFunc("clear")
                        m.global.queueManager.callFunc("push", selectedItem)
                        m.global.queueManager.callFunc("playQueue")
                        dialog.close = true
                    end if
                else if selectedItemType = "Photo"

                    if selectedItem.isSubType("HomeData")
                        print "a photo was selected from the home screen"
                        print "selectedItem=", selectedItem
                        quickplay_photo(selectedItem)
                    end if
                else if selectedItemType = "PhotoAlbum"
                    print "a photo album was selected"
                    print "selectedItem=", selectedItem

                    photoAlbumData = api_users_GetItemsByQuery(m.global.session.user.id, {
                        "parentId": selectedItem.id
                        "includeItemTypes": "Photo"
                        "Recursive": true
                    })
                    print "photoAlbumData=", photoAlbumData
                    if isValid(photoAlbumData) and isValidAndNotEmpty(photoAlbumData.items)
                        photoPlayer = CreateObject("roSgNode", "PhotoDetails")
                        photoPlayer.itemsArray = photoAlbumData.items
                        photoPlayer.itemIndex = 0
                        m.global.sceneManager.callfunc("pushScene", photoPlayer)
                    end if
                else if selectedItemType = "MusicArtist"
                    group = CreateArtistView(selectedItem.json)
                    if not isValid(group)
                        stopLoadingSpinner()
                        message_dialog(tr("Unable to find any albums or songs belonging to this artist"))
                    end if
                else if selectedItemType = "MusicAlbum"
                    group = CreateAlbumView(selectedItem.json)
                else if selectedItemType = "MusicVideo"
                    group = CreateMovieDetailsGroup(selectedItem)
                else if selectedItemType = "Playlist"
                    group = CreatePlaylistView(selectedItem.json)
                else if selectedItemType = "Audio"
                    m.global.queueManager.callFunc("clear")
                    m.global.queueManager.callFunc("resetShuffle")
                    m.global.queueManager.callFunc("push", selectedItem.json)
                    m.global.queueManager.callFunc("playQueue")
                else

                    stopLoadingSpinner()
                    message_dialog("This type is not yet supported: " + selectedItemType + ".")
                end if
            end if
        else if isNodeEvent(msg, "movieSelected")

            startLoadingSpinner()
            node = getMsgPicker(msg, "picker")
            group = CreateMovieDetailsGroup(node)
        else if isNodeEvent(msg, "seriesSelected")

            startLoadingSpinner()
            node = getMsgPicker(msg, "picker")
            group = CreateSeriesDetailsGroup(node.id)
        else if isNodeEvent(msg, "seasonSelected")

            startLoadingSpinner()
            ptr = msg.getData()

            series = msg.getRoSGNode()
            if isValid(ptr) and ptr.count() >= 2 and isValid(ptr[1]) and isValid(series) and isValid(series.seasonData) and isValid(series.seasonData.items)
                node = series.seasonData.items[ptr[1]]
                group = CreateSeasonDetailsGroup(series.itemContent, node)
            end if
        else if isNodeEvent(msg, "musicAlbumSelected")

            startLoadingSpinner()
            ptr = msg.getData()
            albums = msg.getRoSGNode()
            node = albums.musicArtistAlbumData.items[ptr]
            group = CreateAlbumView(node)
            if not isValid(group)
                stopLoadingSpinner()
            end if
        else if isNodeEvent(msg, "appearsOnSelected")

            startLoadingSpinner()
            ptr = msg.getData()
            albums = msg.getRoSGNode()
            node = albums.musicArtistAppearsOnData.items[ptr]
            group = CreateAlbumView(node)
            if not isValid(group)
                stopLoadingSpinner()
            end if
        else if isNodeEvent(msg, "playSong")

            startLoadingSpinner()
            selectedIndex = msg.getData()
            screenContent = msg.getRoSGNode()
            m.global.queueManager.callFunc("clear")
            m.global.queueManager.callFunc("resetShuffle")
            m.global.queueManager.callFunc("push", screenContent.albumData.items[selectedIndex])
            m.global.queueManager.callFunc("playQueue")
        else if isNodeEvent(msg, "playItem")

            startLoadingSpinner()
            selectedIndex = msg.getData()
            screenContent = msg.getRoSGNode()
            m.global.queueManager.callFunc("clear")
            m.global.queueManager.callFunc("resetShuffle")
            m.global.queueManager.callFunc("push", screenContent.albumData.items[selectedIndex])
            m.global.queueManager.callFunc("playQueue")
        else if isNodeEvent(msg, "playAllSelected")

            screenContent = msg.getRoSGNode()
            startLoadingSpinner()
            m.global.queueManager.callFunc("clear")
            m.global.queueManager.callFunc("resetShuffle")
            m.global.queueManager.callFunc("set", screenContent.albumData.items)
            m.global.queueManager.callFunc("playQueue")
        else if isNodeEvent(msg, "playArtistSelected")

            startLoadingSpinner()
            screenContent = msg.getRoSGNode()
            m.global.queueManager.callFunc("clear")
            m.global.queueManager.callFunc("resetShuffle")
            m.global.queueManager.callFunc("set", CreateArtistMix(screenContent.pageContent.id).Items)
            m.global.queueManager.callFunc("playQueue")
        else if isNodeEvent(msg, "instantMixSelected")


            screenContent = msg.getRoSGNode()
            startLoadingSpinner()
            viewHandled = false

            if isValid(screenContent.albumData)
                if isValid(screenContent.albumData.items)
                    if screenContent.albumData.items.count() > 0
                        m.global.queueManager.callFunc("clear")
                        m.global.queueManager.callFunc("resetShuffle")
                        m.global.queueManager.callFunc("set", CreateInstantMix(screenContent.albumData.items[0].id).Items)
                        m.global.queueManager.callFunc("playQueue")
                        viewHandled = true
                    end if
                end if
            end if
            if not viewHandled

                m.global.queueManager.callFunc("clear")
                m.global.queueManager.callFunc("resetShuffle")
                m.global.queueManager.callFunc("set", CreateInstantMix(screenContent.pageContent.id).Items)
                m.global.queueManager.callFunc("playQueue")
            end if
        else if isNodeEvent(msg, "search_value")
            query = msg.getRoSGNode().search_value
            group.findNode("SearchBox").visible = false
            options = group.findNode("SearchSelect")
            options.visible = true
            options.setFocus(true)
            dialog = createObject("roSGNode", "ProgressDialog")
            dialog.title = tr("Loading Search Data")
            m.scene.dialog = dialog
            results = SearchMedia(query)
            dialog.close = true
            options.itemData = results
            options.query = query
        else if isNodeEvent(msg, "itemSelected")

            startLoadingSpinner()
            node = getMsgPicker(msg)


            if node.type = "Series"
                group = CreateSeriesDetailsGroup(node.id)
            else if node.type = "Movie"
                group = CreateMovieDetailsGroup(node)
            else if node.type = "MusicArtist"
                group = CreateArtistView(node.json)
            else if node.type = "MusicAlbum"
                group = CreateAlbumView(node.json)
            else if node.type = "MusicVideo"
                group = CreateMovieDetailsGroup(node)
            else if node.type = "Audio"
                m.global.queueManager.callFunc("clear")
                m.global.queueManager.callFunc("resetShuffle")
                m.global.queueManager.callFunc("push", node.json)
                m.global.queueManager.callFunc("playQueue")
            else if node.type = "Person"
                group = CreatePersonView(node)
            else if node.type = "TvChannel"
                group = CreateVideoPlayerGroup(node.id)
                sceneManager.callFunc("pushScene", group)
            else if node.type = "Episode"
                group = CreateVideoPlayerGroup(node.id)
                sceneManager.callFunc("pushScene", group)
            else if node.type = "Audio"
                selectedIndex = msg.getData()
                screenContent = msg.getRoSGNode()
                m.global.queueManager.callFunc("clear")
                m.global.queueManager.callFunc("resetShuffle")
                m.global.queueManager.callFunc("push", screenContent.albumData.items[node.id])
                m.global.queueManager.callFunc("playQueue")
            else

                stopLoadingSpinner()
                message_dialog("This type is not yet supported: " + node.type + ".")
            end if
        else if isNodeEvent(msg, "buttonSelected")

            btn = getButton(msg)
            group = sceneManager.callFunc("getActiveScene")
            if isValid(btn) and btn.id = "play-button"

                startLoadingSpinner()

                audio_stream_idx = 0
                if isValid(group) and isValid(group.selectedAudioStreamIndex)
                    audio_stream_idx = group.selectedAudioStreamIndex
                end if
                group.itemContent.selectedAudioStreamIndex = audio_stream_idx
                group.itemContent.id = group.selectedVideoStreamId

                if group.itemContent.json.userdata.PlaybackPositionTicks > 0
                    m.global.queueManager.callFunc("hold", group.itemContent)
                    playbackOptionDialog(group.itemContent.json.userdata.PlaybackPositionTicks, group.itemContent.json)
                else
                    m.global.queueManager.callFunc("clear")
                    m.global.queueManager.callFunc("push", group.itemContent)
                    m.global.queueManager.callFunc("playQueue")
                end if
                if isValid(group) and isValid(group.lastFocus) and isValid(group.lastFocus.id) and group.lastFocus.id = "main_group"
                    buttons = group.findNode("buttons")
                    if isValid(buttons)
                        group.lastFocus = group.findNode("buttons")
                    end if
                end if
                if isValid(group) and isValid(group.lastFocus)
                    group.lastFocus.setFocus(true)
                end if
            else if btn <> invalid and btn.id = "trailer-button"

                startLoadingSpinner()
                dialog = createObject("roSGNode", "ProgressDialog")
                dialog.title = tr("Loading trailer")
                m.scene.dialog = dialog
                trailerData = api_users_GetLocalTrailers(m.global.session.user.id, group.id)
                if isValid(trailerData) and isValid(trailerData[0]) and isValid(trailerData[0].id)
                    m.global.queueManager.callFunc("clear")
                    m.global.queueManager.callFunc("set", trailerData)
                    m.global.queueManager.callFunc("playQueue")
                    dialog.close = true
                else
                    stopLoadingSpinner()
                end if
                if isValid(group) and isValid(group.lastFocus)
                    group.lastFocus.setFocus(true)
                end if
            else if btn <> invalid and btn.id = "watched-button"
                movie = group.itemContent
                if isValid(movie) and isValid(movie.watched) and isValid(movie.id)
                    if movie.watched
                        UnmarkItemWatched(movie.id)
                    else
                        MarkItemWatched(movie.id)
                    end if
                    movie.watched = not movie.watched
                end if
            else if btn <> invalid and btn.id = "favorite-button"
                movie = group.itemContent
                if movie.favorite
                    UnmarkItemFavorite(movie.id)
                else
                    MarkItemFavorite(movie.id)
                end if
                movie.favorite = not movie.favorite
            else

                dialog = msg.getRoSGNode()
                if dialog.id = "OKDialog"
                    dialog.unobserveField("buttonSelected")
                    dialog.close = true
                end if
            end if
        else if isNodeEvent(msg, "optionSelected")
            button = msg.getRoSGNode()
            group = sceneManager.callFunc("getActiveScene")
            if button.id = "goto_search" and isValid(group)

                panel = group.findNode("options")
                panel.visible = false
                if isValid(group.lastFocus)
                    group.lastFocus.setFocus(true)
                else
                    group.setFocus(true)
                end if
                group = CreateSearchPage()
                sceneManager.callFunc("pushScene", group)
                group.findNode("SearchBox").findNode("search_Key").setFocus(true)
                group.findNode("SearchBox").findNode("search_Key").active = true
            else if button.id = "change_server"
                unset_setting("server")
                session_server_Delete()
                SignOut(false)
                sceneManager.callFunc("clearScenes")
                goto app_start
            else if button.id = "change_user"
                SignOut(false)
                sceneManager.callFunc("clearScenes")
                goto app_start
            else if button.id = "sign_out"
                SignOut()
                sceneManager.callFunc("clearScenes")
                goto app_start
            else if button.id = "settings"

                panel = group.findNode("options")
                panel.visible = false
                if isValid(group) and isValid(group.lastFocus)
                    group.lastFocus.setFocus(true)
                else
                    group.setFocus(true)
                end if
                sceneManager.callFunc("settings")
            end if
        else if isNodeEvent(msg, "selectSubtitlePressed")
            node = m.scene.focusedChild
            if node.focusedChild <> invalid and node.focusedChild.isSubType("JFVideo")
                trackSelected = selectSubtitleTrack(node.Subtitles, node.SelectedSubtitle)
                if trackSelected <> invalid and trackSelected <> -2
                    changeSubtitleDuringPlayback(trackSelected)
                end if
            end if
        else if isNodeEvent(msg, "selectPlaybackInfoPressed")
            node = m.scene.focusedChild
            if node.focusedChild <> invalid and node.focusedChild.isSubType("JFVideo")
                info = GetPlaybackInfo()
                show_dialog(tr("Playback Information"), info)
            end if
        else if isNodeEvent(msg, "state")
            node = msg.getRoSGNode()
            if isValid(node) and isValid(node.state)
                if node.selectedItemType = "TvChannel" and node.state = "finished"
                    video = CreateVideoPlayerGroup(node.id)
                    m.global.sceneManager.callFunc("pushScene", video)
                    m.global.sceneManager.callFunc("deleteSceneAtIndex", 2)
                else if node.state = "finished"
                    node.control = "stop"

                    if isValid(node.retryWithTranscoding) and node.retryWithTranscoding
                        retryVideo = CreateVideoPlayerGroup(node.Id, invalid, node.audioIndex, true, false)
                        m.global.sceneManager.callFunc("popScene")
                        if isValid(retryVideo)
                            m.global.sceneManager.callFunc("pushScene", retryVideo)
                        end if
                    else if not isValid(node.showID)
                        sceneManager.callFunc("popScene")
                    else
                        autoPlayNextEpisode(node.id, node.showID)
                    end if
                end if
            end if
        else if type(msg) = "roDeviceInfoEvent"
            event = msg.GetInfo()
            if event.exitedScreensaver = true
                sceneManager.callFunc("resetTime")
                group = sceneManager.callFunc("getActiveScene")
                if isValid(group)

                    if group.isSubType("JFScreen")
                        group.callFunc("OnScreenShown")
                    end if
                end if
            else if isValid(event.audioGuideEnabled)
                tmpGlobalDevice = m.global.device
                tmpGlobalDevice.AddReplace("isaudioguideenabled", event.audioGuideEnabled)

                m.global.setFields({
                    device: tmpGlobalDevice
                })
            else if isValid(event.Mode)





                print "event.Mode = ", event.Mode
                if isValid(event.Mute)
                    print "event.Mute = ", event.Mute
                end if
            else if isValid(event.linkStatus)

                print "event.linkStatus = ", event.linkStatus
            else if isValid(event.generalMemoryLevel)




                print "event.generalMemoryLevel = ", event.generalMemoryLevel
                session_Update("memoreyLevel", event.generalMemoryLevel)
            else if isValid(event.audioCodecCapabilityChanged)

                print "event.audioCodecCapabilityChanged = ", event.audioCodecCapabilityChanged
                postTask = createObject("roSGNode", "PostTask")
                postTask.arrayData = getDeviceCapabilities()
                postTask.apiUrl = "/Sessions/Capabilities/Full"
                postTask.control = "RUN"
            else if isValid(event.videoCodecCapabilityChanged)

                print "event.videoCodecCapabilityChanged = ", event.videoCodecCapabilityChanged
                postTask = createObject("roSGNode", "PostTask")
                postTask.arrayData = getDeviceCapabilities()
                postTask.apiUrl = "/Sessions/Capabilities/Full"
                postTask.control = "RUN"
            else if isValid(event.appFocus)

                print "event.appFocus = ", event.appFocus
            else
                print "Unhandled roDeviceInfoEvent:"
                print msg.GetInfo()
            end if
        else if type(msg) = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                if info.DoesExist("mediatype") and info.DoesExist("contentid")
                    inputEventVideo = {
                        id: info.contentId
                        type: "video"
                    }
                    m.global.queueManager.callFunc("clear")
                    m.global.queueManager.callFunc("push", inputEventVideo)
                    m.global.queueManager.callFunc("playQueue")
                end if
            end if
        else if isNodeEvent(msg, "dataReturned")
            popupNode = msg.getRoSGNode()
            stopLoadingSpinner()
            if isValid(popupNode) and isValid(popupNode.returnData)
                selectedItem = m.global.queueManager.callFunc("getHold")
                m.global.queueManager.callFunc("clearHold")
                if isValid(selectedItem) and selectedItem.count() > 0 and isValid(selectedItem[0])
                    if popupNode.returnData.indexselected = 0

                        startLoadingSpinner()
                        startingPoint = 0
                        if isValid(selectedItem[0].json) and isValid(selectedItem[0].json.UserData) and isValid(selectedItem[0].json.UserData.PlaybackPositionTicks)
                            if selectedItem[0].json.UserData.PlaybackPositionTicks > 0
                                startingPoint = selectedItem[0].json.UserData.PlaybackPositionTicks
                            end if
                        end if
                        selectedItem[0].startingPoint = startingPoint
                        m.global.queueManager.callFunc("clear")
                        m.global.queueManager.callFunc("push", selectedItem[0])
                        m.global.queueManager.callFunc("playQueue")
                    else if popupNode.returnData.indexselected = 1

                        startLoadingSpinner()
                        selectedItem[0].startingPoint = 0
                        m.global.queueManager.callFunc("clear")
                        m.global.queueManager.callFunc("push", selectedItem[0])
                        m.global.queueManager.callFunc("playQueue")
                    else if popupNode.returnData.indexselected = 2

                        CreateSeriesDetailsGroup(selectedItem[0].json.SeriesId)
                    else if popupNode.returnData.indexselected = 3

                        CreateSeasonDetailsGroupByID(selectedItem[0].json.SeriesId, selectedItem[0].json.seasonID)
                    else if popupNode.returnData.indexselected = 4

                        CreateMovieDetailsGroup(selectedItem[0])
                    end if
                end if
            end if
        else
            print "Unhandled " type(msg)
            print msg
        end if
    end while
end sub