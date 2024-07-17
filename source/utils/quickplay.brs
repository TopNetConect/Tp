


sub quickplay_pushToQueue(queueArray as object, shufflePlay = false as boolean)
    if isValidAndNotEmpty(queueArray)

        for each item in queueArray
            m.global.queueManager.callFunc("push", item)
        end for

        if shufflePlay and m.global.queueManager.callFunc("getCount") > 1
            m.global.queueManager.callFunc("toggleShuffle")
        end if
    end if
end sub


sub quickplay_video(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) or not isValid(itemNode.json) then
        return
    end if

    if isValid(itemNode.selectedVideoStreamId)
        itemNode.id = itemNode.selectedVideoStreamId
    end if
    audio_stream_idx = 0
    if isValid(itemNode.selectedAudioStreamIndex) and itemNode.selectedAudioStreamIndex > 0
        audio_stream_idx = itemNode.selectedAudioStreamIndex
    end if
    itemNode.selectedAudioStreamIndex = audio_stream_idx
    playbackPosition = 0
    if isValid(itemNode.json.userdata) and isValid(itemNode.json.userdata.PlaybackPositionTicks)
        playbackPosition = itemNode.json.userdata.PlaybackPositionTicks
    end if
    itemNode.startingPoint = playbackPosition
    m.global.queueManager.callFunc("push", itemNode)
end sub


sub quickplay_audio(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    m.global.queueManager.callFunc("push", itemNode)
end sub


sub quickplay_musicVideo(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) or not isValid(itemNode.json) then
        return
    end if
    m.global.queueManager.callFunc("push", itemNode)
end sub


sub quickplay_photo(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    photoPlayer = CreateObject("roSgNode", "PhotoDetails")
    photoPlayer.itemsNode = itemNode
    photoPlayer.itemIndex = 0
    m.global.sceneManager.callfunc("pushScene", photoPlayer)
end sub


sub quickplay_photoAlbum(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    photoAlbumData = api_users_GetItemsByQuery(m.global.session.user.id, {
        "parentId": itemNode.id
        "includeItemTypes": "Photo"
        "sortBy": "Random"
        "Recursive": true
    })
    print "photoAlbumData=", photoAlbumData
    if isValid(photoAlbumData) and isValidAndNotEmpty(photoAlbumData.items)
        photoPlayer = CreateObject("roSgNode", "PhotoDetails")
        photoPlayer.isSlideshow = true
        photoPlayer.isRandom = false
        photoPlayer.itemsArray = photoAlbumData.items
        photoPlayer.itemIndex = 0
        m.global.sceneManager.callfunc("pushScene", photoPlayer)
    else
        stopLoadingSpinner()
    end if
end sub



sub quickplay_album(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    albumSongs = api_users_GetItemsByQuery(m.global.session.user.id, {
        "parentId": itemNode.id
        "imageTypeLimit": 1
        "sortBy": "SortName"
        "limit": 2000
        "enableUserData": false
        "EnableTotalRecordCount": false
    })
    if isValid(albumSongs) and isValidAndNotEmpty(albumSongs.items)
        quickplay_pushToQueue(albumSongs.items)
    else
        stopLoadingSpinner()
    end if
end sub



sub quickplay_artist(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    artistSongs = api_users_GetItemsByQuery(m.global.session.user.id, {
        "artistIds": itemNode.id
        "includeItemTypes": "Audio"
        "sortBy": "Album"
        "limit": 2000
        "imageTypeLimit": 1
        "Recursive": true
        "enableUserData": false
        "EnableTotalRecordCount": false
    })
    print "artistSongs=", artistSongs
    if isValid(artistSongs) and isValidAndNotEmpty(artistSongs.items)
        quickplay_pushToQueue(artistSongs.items, true)
    else
        stopLoadingSpinner()
    end if
end sub



sub quickplay_boxset(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    data = api_items_GetByQuery({
        "userid": m.global.session.user.id
        "parentid": itemNode.id
        "limit": 2000
        "EnableTotalRecordCount": false
    })
    if isValid(data) and isValidAndNotEmpty(data.Items)
        quickplay_pushToQueue(data.items)
    else
        stopLoadingSpinner()
    end if
end sub




sub quickplay_series(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    data = api_shows_GetNextUp({
        "seriesId": itemNode.id
        "recursive": true
        "SortBy": "DatePlayed"
        "SortOrder": "Descending"
        "ImageTypeLimit": 1
        "UserId": m.global.session.user.id
        "EnableRewatching": false
        "DisableFirstEpisode": false
        "EnableTotalRecordCount": false
    })
    if isValid(data) and isValidAndNotEmpty(data.Items)

        m.global.queueManager.callFunc("push", data.Items[0])
    else


        data = api_users_GetResumeItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "userid": m.global.session.user.id
            "SortBy": "DatePlayed"
            "recursive": true
            "SortOrder": "Descending"
            "Filters": "IsResumable"
            "EnableTotalRecordCount": false
        })
        print "resumeitems data=", data
        if isValid(data) and isValidAndNotEmpty(data.Items)

            if isValid(data.Items[0].UserData) and isValid(data.Items[0].UserData.PlaybackPositionTicks)
                data.Items[0].startingPoint = data.Items[0].userdata.PlaybackPositionTicks
            end if
            m.global.queueManager.callFunc("push", data.Items[0])
        else

            data = api_shows_GetEpisodes(itemNode.id, {
                "userid": m.global.session.user.id
                "SortBy": "Random"
                "limit": 2000
                "EnableTotalRecordCount": false
            })
            if isValid(data) and isValidAndNotEmpty(data.Items)

                quickplay_pushToQueue(data.Items)
            else
                stopLoadingSpinner()
            end if
        end if
    end if
end sub



sub quickplay_multipleSeries(itemNodes as object)
    if isValidAndNotEmpty(itemNodes)
        numTotal = 0
        numLimit = 2000
        for each tvshow in itemNodes

            showData = api_shows_GetEpisodes(tvshow.id, {
                "userId": m.global.session.user.id
                "SortBy": "Random"
                "imageTypeLimit": 0
                "EnableTotalRecordCount": false
                "enableImages": false
            })
            if isValid(showData) and isValidAndNotEmpty(showData.items)
                playedEpisodes = []

                for each episode in showData.items
                    if isValid(episode.userdata) and isValid(episode.userdata.Played)
                        if episode.userdata.Played
                            playedEpisodes.push(episode)
                        end if
                    end if
                end for
                quickplay_pushToQueue(playedEpisodes)

                numTotal = numTotal + showData.items.count()
                if numTotal >= numLimit

                    exit for
                end if
            end if
        end for
        if m.global.queueManager.callFunc("getCount") > 1
            m.global.queueManager.callFunc("toggleShuffle")
        else
            stopLoadingSpinner()
        end if
    end if
end sub


sub quickplay_videoContainer(itemNode as object)
    print "itemNode=", itemNode
    collectionType = Lcase(itemNode.collectionType)
    if collectionType = "movies"

        data = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "sortBy": "Random"
            "recursive": true
            "includeItemTypes": "Movie,Video"
            "limit": 2000
        })
        print "data=", data
        if isValid(data) and isValidAndNotEmpty(data.items)
            videoList = []

            for each item in data.Items
                print "data.Item=", item

                if isValid(item.userdata) and isValid(item.userdata.PlaybackPositionTicks)
                    if item.userdata.PlaybackPositionTicks = 0
                        videoList.push(item)
                    end if
                end if
            end for
            quickplay_pushToQueue(videoList)
        else
            stopLoadingSpinner()
        end if
        return
    else if collectionType = "tvshows" or collectionType = "collectionfolder"

        tvshowsData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "sortBy": "Random"
            "recursive": true
            "excludeItemTypes": "Season"
            "imageTypeLimit": 0
            "enableUserData": false
            "EnableTotalRecordCount": false
            "enableImages": false
        })
        print "tvshowsData=", tvshowsData
        if isValid(tvshowsData) and isValidAndNotEmpty(tvshowsData.items)

            if tvshowsData.items[0].Type = "Series"
                quickplay_multipleSeries(tvshowsData.items)
            else

                quickplay_pushToQueue(tvshowsData.items)
            end if
        else
            stopLoadingSpinner()
        end if
    else
        stopLoadingSpinner()
        print "Quick Play videoContainer WARNING: Unknown collection type"
    end if
end sub




sub quickplay_season(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    unwatchedData = api_shows_GetEpisodes(itemNode.json.SeriesId, {
        "seasonId": itemNode.id
        "userid": m.global.session.user.id
        "limit": 2000
        "EnableTotalRecordCount": false
    })
    if isValid(unwatchedData) and isValidAndNotEmpty(unwatchedData.Items)

        firstUnwatchedEpisodeIndex = invalid
        for each item in unwatchedData.Items
            if isValid(item.UserData)
                if isValid(item.UserData.Played) and item.UserData.Played = false
                    firstUnwatchedEpisodeIndex = (function(__bsCondition, item)
                            if __bsCondition then
                                return item.IndexNumber - 1
                            else
                                return 0
                            end if
                        end function)(isValid(item.IndexNumber), item)
                    if isValid(item.UserData.PlaybackPositionTicks)
                        item.startingPoint = item.UserData.PlaybackPositionTicks
                    end if
                    exit for
                end if
            end if
        end for
        if isValid(firstUnwatchedEpisodeIndex)

            for i = firstUnwatchedEpisodeIndex to unwatchedData.Items.count() - 1
                m.global.queueManager.callFunc("push", unwatchedData.Items[i])
            end for
        else

            continueData = api_users_GetResumeItemsByQuery(m.global.session.user.id, {
                "parentId": itemNode.id
                "userid": m.global.session.user.id
                "SortBy": "DatePlayed"
                "recursive": true
                "SortOrder": "Descending"
                "Filters": "IsResumable"
                "EnableTotalRecordCount": false
            })
            if isValid(continueData) and isValidAndNotEmpty(continueData.Items)

                for each item in continueData.Items
                    if isValid(item.UserData) and isValid(item.UserData.PlaybackPositionTicks)
                        item.startingPoint = item.userdata.PlaybackPositionTicks
                    end if
                    m.global.queueManager.callFunc("push", item)
                end for
            else

                if isValid(unwatchedData) and isValidAndNotEmpty(unwatchedData.Items)

                    quickplay_pushToQueue(unwatchedData.Items)
                end if
            end if
        end if
    else
        stopLoadingSpinner()
    end if
end sub



sub quickplay_person(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    personMovies = api_users_GetItemsByQuery(m.global.session.user.id, {
        "personIds": itemNode.id
        "includeItemTypes": "Movie,Video"
        "excludeItemTypes": "Season,Series"
        "recursive": true
        "limit": 2000
    })
    print "personMovies=", personMovies
    if isValid(personMovies) and isValidAndNotEmpty(personMovies.Items)

        quickplay_pushToQueue(personMovies.Items)
    end if

    personEpisodes = api_users_GetItemsByQuery(m.global.session.user.id, {
        "personIds": itemNode.id
        "includeItemTypes": "Episode"
        "isPlayed": true
        "excludeItemTypes": "Season,Series"
        "recursive": true
        "limit": 2000
    })
    print "personEpisodes=", personEpisodes
    if isValid(personEpisodes) and isValidAndNotEmpty(personEpisodes.Items)

        quickplay_pushToQueue(personEpisodes.Items)
    end if
    if m.global.queueManager.callFunc("getCount") > 1
        m.global.queueManager.callFunc("toggleShuffle")
    else
        stopLoadingSpinner()
    end if
end sub


sub quickplay_tvChannel(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    group = CreateVideoPlayerGroup(itemNode.id)
    stopLoadingSpinner()
    m.global.sceneManager.callFunc("pushScene", group)
end sub


sub quickplay_program(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.json) or not isValid(itemNode.json.ChannelId) then
        return
    end if
    group = CreateVideoPlayerGroup(itemNode.json.ChannelId)
    stopLoadingSpinner()
    m.global.sceneManager.callFunc("pushScene", group)
end sub




sub quickplay_playlist(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    myPlaylist = api_playlists_GetItems(itemNode.id, {
        "userId": m.global.session.user.id
        "limit": 2000
    })
    if isValid(myPlaylist) and isValidAndNotEmpty(myPlaylist.Items)

        quickplay_pushToQueue(myPlaylist.Items)
        if m.global.queueManager.callFunc("getCount") > 1
            m.global.queueManager.callFunc("toggleShuffle")
        end if
    else
        stopLoadingSpinner()
    end if
end sub



sub quickplay_folder(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if
    paramArray = {
        "includeItemTypes": [
            "Episode"
            "Movie"
            "Video"
        ]
        "videoTypes": "VideoFile"
        "sortBy": "Random"
        "limit": 2000
        "imageTypeLimit": 1
        "Recursive": true
        "enableUserData": false
        "EnableTotalRecordCount": false
    }

    folderType = Lcase(itemNode.json.type)
    print "folderType=", folderType
    if folderType = "studio"
        paramArray["studioIds"] = itemNode.id
    else if folderType = "genre"
        paramArray["genreIds"] = itemNode.id
        if isValid(itemNode.json.MovieCount) and itemNode.json.MovieCount > 0
            paramArray["includeItemTypes"] = "Movie"
        end if
    else if folderType = "musicgenre"
        paramArray["genreIds"] = itemNode.id
        paramArray.delete("videoTypes")
        paramArray["includeItemTypes"] = "Audio"
    else if folderType = "photoalbum"
        paramArray["parentId"] = itemNode.id
        paramArray["includeItemTypes"] = "Photo"
        paramArray.delete("videoTypes")
        paramArray.delete("Recursive")
    else
        paramArray["parentId"] = itemNode.id
    end if

    if isValid(itemNode.json.SeriesCount) and itemNode.json.SeriesCount > 0
        paramArray["includeItemTypes"] = "Series"
        paramArray.Delete("videoTypes")
    end if

    folderData = api_users_GetItemsByQuery(m.global.session.user.id, paramArray)
    print "folderData=", folderData
    if isValid(folderData) and isValidAndNotEmpty(folderData.items)
        if isValid(itemNode.json.SeriesCount) and itemNode.json.SeriesCount > 0
            if itemNode.json.SeriesCount = 1
                quickplay_series(folderData.items[0])
            else
                quickplay_multipleSeries(folderData.items)
            end if
        else
            if folderType = "photoalbum"
                photoPlayer = CreateObject("roSgNode", "PhotoDetails")
                photoPlayer.isSlideshow = true
                photoPlayer.isRandom = false
                photoPlayer.itemsArray = folderData.items
                photoPlayer.itemIndex = 0
                m.global.sceneManager.callfunc("pushScene", photoPlayer)
            else
                quickplay_pushToQueue(folderData.items, true)
            end if
        end if
    else
        stopLoadingSpinner()
    end if
end sub




sub quickplay_collectionFolder(itemNode as object)
    if not isValid(itemNode) or not isValid(itemNode.id) then
        return
    end if

    print "attempting to quickplay a collection folder"
    collectionType = LCase(itemNode.collectionType)
    print "collectionType=", collectionType
    if collectionType = "movies"
        quickplay_videoContainer(itemNode)
    else if collectionType = "music"


        songsData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "includeItemTypes": "Audio"
            "sortBy": "Album"
            "Recursive": true
            "limit": 2000
            "imageTypeLimit": 1
            "enableUserData": false
            "EnableTotalRecordCount": false
        })
        print "songsData=", songsData
        if isValid(songsData) and isValidAndNotEmpty(songsData.items)
            quickplay_pushToQueue(songsData.Items, true)
        else
            stopLoadingSpinner()
        end if
    else if collectionType = "boxsets"

        boxsetData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "limit": 2000
            "imageTypeLimit": 0
            "enableUserData": false
            "EnableTotalRecordCount": false
            "enableImages": false
        })
        print "boxsetData=", boxsetData
        if isValid(boxsetData) and isValidAndNotEmpty(boxsetData.items)

            arrayIndex = Rnd(boxsetData.items.count()) - 1
            myBoxset = boxsetData.items[arrayIndex]

            print "myBoxset=", myBoxset
            boxsetData = api_users_GetItemsByQuery(m.global.session.user.id, {
                "parentId": myBoxset.id
                "EnableTotalRecordCount": false
            })
            if isValid(boxsetData) and isValidAndNotEmpty(boxsetData.items)

                quickplay_pushToQueue(boxsetData.Items)
            else
                stopLoadingSpinner()
            end if
        end if
    else if collectionType = "tvshows" or collectionType = "collectionfolder"
        quickplay_videoContainer(itemNode)
    else if collectionType = "musicvideos"

        data = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "includeItemTypes": "MusicVideo"
            "sortBy": "Random"
            "Recursive": true
            "limit": 2000
            "imageTypeLimit": 1
            "enableUserData": false
            "EnableTotalRecordCount": false
        })
        print "data=", data
        if isValid(data) and isValidAndNotEmpty(data.items)
            quickplay_pushToQueue(data.Items)
        else
            stopLoadingSpinner()
        end if
    else if collectionType = "homevideos"


        folderData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "includeItemTypes": "Photo"
            "sortBy": "Random"
            "Recursive": true
        })
        print "folderData=", folderData
        if isValid(folderData) and isValidAndNotEmpty(folderData.items)
            photoPlayer = CreateObject("roSgNode", "PhotoDetails")
            photoPlayer.isSlideshow = true
            photoPlayer.isRandom = false
            photoPlayer.itemsArray = folderData.items
            photoPlayer.itemIndex = 0
            m.global.sceneManager.callfunc("pushScene", photoPlayer)
        else
            stopLoadingSpinner()
        end if
    else
        stopLoadingSpinner()
        print "Quick Play WARNING: Unknown collection type"
    end if
end sub



sub quickplay_userView(itemNode as object)

    collectionType = LCase(itemNode.collectionType)
    print "collectionType=", collectionType
    if collectionType = "playlists"

        playlistData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "parentId": itemNode.id
            "imageTypeLimit": 0
            "enableUserData": false
            "EnableTotalRecordCount": false
            "enableImages": false
        })
        print "playlistData=", playlistData
        if isValid(playlistData) and isValidAndNotEmpty(playlistData.items)

            arrayIndex = Rnd(playlistData.items.count()) - 1
            myPlaylist = playlistData.items[arrayIndex]

            print "myPlaylist=", myPlaylist
            playlistItems = api_playlists_GetItems(myPlaylist.id, {
                "userId": m.global.session.user.id
                "EnableTotalRecordCount": false
                "limit": 2000
            })

            if isValid(playlistItems) and isValidAndNotEmpty(playlistItems.items)
                quickplay_pushToQueue(playlistItems.items, true)
            else
                stopLoadingSpinner()
            end if
        end if
    else if collectionType = "livetv"

        channelData = api_users_GetItemsByQuery(m.global.session.user.id, {
            "includeItemTypes": "TVChannel"
            "sortBy": "Random"
            "Recursive": true
            "imageTypeLimit": 0
            "enableUserData": false
            "EnableTotalRecordCount": false
            "enableImages": false
        })
        print "channelData=", channelData
        if isValid(channelData) and isValidAndNotEmpty(channelData.items)

            arrayIndex = Rnd(channelData.items.count()) - 1
            myChannel = channelData.items[arrayIndex]
            print "myChannel=", myChannel

            quickplay_tvChannel(myChannel)
        else
            stopLoadingSpinner()
        end if
    else if collectionType = "movies"
        quickplay_videoContainer(itemNode)
    else if collectionType = "tvshows"
        quickplay_videoContainer(itemNode)
    else
        stopLoadingSpinner()
        print "Quick Play CollectionFolder WARNING: Unknown collection type"
    end if
end sub