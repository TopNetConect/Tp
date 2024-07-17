

function ItemGetPlaybackInfo(id as string, startTimeTicks = 0 as longinteger)
    params = {
        "UserId": m.global.session.user.id
        "StartTimeTicks": startTimeTicks
        "IsPlayback": true
        "AutoOpenLiveStream": true
        "MaxStreamingBitrate": "140000000"
    }
    resp = APIRequest(Substitute("Items/{0}/PlaybackInfo", id), params)
    return getJson(resp)
end function

function ItemPostPlaybackInfo(id as string, mediaSourceId = "" as string, audioTrackIndex = -1 as integer, subtitleTrackIndex = -1 as integer, startTimeTicks = 0 as longinteger)
    body = {
        "DeviceProfile": getDeviceProfile()
    }
    params = {
        "UserId": m.global.session.user.id
        "StartTimeTicks": startTimeTicks
        "IsPlayback": true
        "AutoOpenLiveStream": true
        "MaxStreamingBitrate": "140000000"
        "MaxStaticBitrate": "140000000"
        "SubtitleStreamIndex": subtitleTrackIndex
    }
    if mediaSourceId <> "" then
        params.MediaSourceId = mediaSourceId
    end if
    if audioTrackIndex > -1 then
        params.AudioStreamIndex = audioTrackIndex
    end if
    req = APIRequest(Substitute("Items/{0}/PlaybackInfo", id), params)
    req.SetRequest("POST")
    return postJson(req, FormatJson(body))
end function


function searchMedia(query as string)
    if query <> ""
        data = api_users_GetItemsByQuery(m.global.session.user.id, {
            "searchTerm": query
            "IncludePeople": true
            "IncludeMedia": true
            "IncludeShows": true
            "IncludeGenres": true
            "IncludeStudios": true
            "IncludeArtists": true
            "IncludeItemTypes": "LiveTvChannel,Movie,BoxSet,Series,Episode,Video,Person,Audio,MusicAlbum,MusicArtist,Playlist"
            "EnableTotalRecordCount": false
            "ImageTypeLimit": 1
            "Recursive": true
            "limit": 100
        })
        results = []
        for each item in data.Items
            tmp = CreateObject("roSGNode", "SearchData")
            tmp.image = PosterImage(item.id)
            tmp.json = item
            results.push(tmp)
        end for
        data.Items = results
        return data
    end if
    return []
end function


function ItemMetaData(id as string)
    url = Substitute("Users/{0}/Items/{1}", m.global.session.user.id, id)
    resp = APIRequest(url, {
        "fields": "Chapters"
    })
    data = getJson(resp)
    if data = invalid then
        return invalid
    end if
    imgParams = {}
    if data.type <> "Audio"
        if data.UserData <> invalid and data.UserData.PlayedPercentage <> invalid
            param = {
                "PercentPlayed": data.UserData.PlayedPercentage
            }
            imgParams.Append(param)
        end if
    end if
    if data.type = "Movie" or data.type = "MusicVideo"
        tmp = CreateObject("roSGNode", "MovieData")
        tmp.image = PosterImage(data.id, imgParams)
        tmp.json = data
        return tmp
    else if data.type = "Series"
        tmp = CreateObject("roSGNode", "SeriesData")
        tmp.image = PosterImage(data.id)
        tmp.json = data
        return tmp
    else if data.type = "Episode"


        tmp = CreateObject("roSGNode", "TVEpisodeData")
        tmp.image = PosterImage(data.id, imgParams)
        tmp.json = data
        return tmp
    else if data.type = "BoxSet" or data.type = "Playlist"
        tmp = CreateObject("roSGNode", "CollectionData")
        tmp.image = PosterImage(data.id, imgParams)
        tmp.json = data
        return tmp
    else if data.type = "Season"
        tmp = CreateObject("roSGNode", "TVSeasonData")
        tmp.image = PosterImage(data.id)
        tmp.json = data
        return tmp
    else if data.type = "Video"
        tmp = CreateObject("roSGNode", "VideoData")
        tmp.image = PosterImage(data.id)
        tmp.json = data
        return tmp
    else if data.type = "Trailer"
        tmp = CreateObject("roSGNode", "VideoData")
        tmp.json = data
        return tmp
    else if data.type = "TvChannel" or data.type = "Program"
        tmp = CreateObject("roSGNode", "ChannelData")
        tmp.image = PosterImage(data.id)
        tmp.isFavorite = data.UserData.isFavorite
        tmp.json = data
        return tmp
    else if data.type = "Person"
        tmp = CreateObject("roSGNode", "PersonData")
        tmp.image = PosterImage(data.id, {
            "MaxWidth": 300
            "MaxHeight": 450
        })
        tmp.json = data
        return tmp
    else if data.type = "MusicArtist"

        tmp = CreateObject("roSGNode", "MusicArtistData")
        tmp.image = PosterImage(data.id)
        tmp.json = data
        return tmp
    else if data.type = "MusicAlbum"

        tmp = CreateObject("roSGNode", "MusicAlbumSongListData")
        tmp.image = PosterImage(data.id)
        tmp.json = data
        return tmp
    else if data.type = "Audio"

        tmp = CreateObject("roSGNode", "MusicSongData")

        tmp.image = PosterImage(data.ParentId, {
            "MaxWidth": 500
            "MaxHeight": 500
        })

        if tmp.image = invalid
            tmp.image = PosterImage(data.id, {
                "MaxWidth": 500
                "MaxHeight": 500
            })
        end if
        tmp.json = data
        return tmp
    else if data.type = "Recording"


        return data
    else
        print "Items.brs::ItemMetaData processed unhandled type: " data.type

        return data
    end if
end function


function ArtistOverview(name as string)
    req = createObject("roUrlTransfer")
    url = Substitute("Artists/{0}", req.escape(name))
    resp = APIRequest(url)
    data = getJson(resp)
    if data = invalid then
        return invalid
    end if
    return data.overview
end function


function MusicAlbumList(id as string)
    url = Substitute("Users/{0}/Items", m.global.session.user.id)
    resp = APIRequest(url, {
        "AlbumArtistIds": id
        "includeitemtypes": "MusicAlbum"
        "sortBy": "SortName"
        "Recursive": true
    })
    data = getJson(resp)
    results = []
    for each item in data.Items
        tmp = CreateObject("roSGNode", "MusicAlbumData")
        tmp.image = PosterImage(item.id)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function


function AppearsOnList(id as string)
    url = Substitute("Users/{0}/Items", m.global.session.user.id)
    resp = APIRequest(url, {
        "ContributingArtistIds": id
        "ExcludeItemIds": id
        "includeitemtypes": "MusicAlbum"
        "sortBy": "PremiereDate,ProductionYear,SortName"
        "SortOrder": "Descending"
        "Recursive": true
    })
    data = getJson(resp)
    results = []
    for each item in data.Items
        tmp = CreateObject("roSGNode", "MusicAlbumData")
        tmp.image = PosterImage(item.id)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function


function GetSongsByArtist(id as string, params = {} as object)
    url = Substitute("Users/{0}/Items", m.global.session.user.id)
    paramArray = {
        "AlbumArtistIds": id
        "includeitemtypes": "Audio"
        "sortBy": "SortName"
        "Recursive": true
    }

    for each param in params
        paramArray.AddReplace(param, params[param])
    end for
    resp = APIRequest(url, paramArray)
    data = getJson(resp)
    results = []
    if data = invalid then
        return invalid
    end if
    if data.Items = invalid then
        return invalid
    end if
    if data.Items.Count() = 0 then
        return invalid
    end if
    for each item in data.Items
        tmp = CreateObject("roSGNode", "MusicAlbumData")
        tmp.image = PosterImage(item.id)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function


function PlaylistItemList(id as string)
    url = Substitute("Playlists/{0}/Items", id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
    })
    results = []
    data = getJson(resp)
    if data = invalid then
        return invalid
    end if
    if data.Items = invalid then
        return invalid
    end if
    if data.Items.Count() = 0 then
        return invalid
    end if
    for each item in data.Items
        tmp = CreateObject("roSGNode", "PlaylistData")
        tmp.image = PosterImage(item.id)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function


function MusicSongList(id as string)
    url = Substitute("Users/{0}/Items", m.global.session.user.id, id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
        "parentId": id
        "includeitemtypes": "Audio"
        "sortBy": "SortName"
    })
    results = []
    data = getJson(resp)
    if data = invalid then
        return invalid
    end if
    if data.Items = invalid then
        return invalid
    end if
    if data.Items.Count() = 0 then
        return invalid
    end if
    for each item in data.Items
        tmp = CreateObject("roSGNode", "MusicSongData")
        tmp.image = PosterImage(item.id)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function


function AudioItem(id as string)
    url = Substitute("Users/{0}/Items/{1}", m.global.session.user.id, id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
        "includeitemtypes": "Audio"
        "sortBy": "SortName"
    })
    return getJson(resp)
end function


function CreateInstantMix(id as string)
    url = Substitute("/Items/{0}/InstantMix", id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
        "Limit": 201
    })
    return getJson(resp)
end function


function CreateArtistMix(id as string)
    url = Substitute("Users/{0}/Items", m.global.session.user.id)
    resp = APIRequest(url, {
        "ArtistIds": id
        "Recursive": "true"
        "MediaTypes": "Audio"
        "Filters": "IsNotFolder"
        "SortBy": "SortName"
        "Limit": 300
        "Fields": "Chapters"
        "ExcludeLocationTypes": "Virtual"
        "EnableTotalRecordCount": false
        "CollapseBoxSetItems": false
    })
    return getJson(resp)
end function


function GetIntroVideos(id as string)
    url = Substitute("Users/{0}/Items/{1}/Intros", m.global.session.user.id, id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
    })
    return getJson(resp)
end function

function AudioStream(id as string)
    songData = AudioItem(id)
    if songData <> invalid
        content = createObject("RoSGNode", "ContentNode")
        if songData.title <> invalid
            content.title = songData.title
        end if
        playbackInfo = ItemPostPlaybackInfo(songData.id, songData.mediaSources[0].id)
        if playbackInfo <> invalid
            content.id = playbackInfo.PlaySessionId
            if useTranscodeAudioStream(playbackInfo)

                content.url = buildURL(playbackInfo.mediaSources[0].TranscodingURL)
            else

                params = {
                    "Static": "true"
                    "Container": songData.mediaSources[0].container
                    "MediaSourceId": songData.mediaSources[0].id
                }
                content.streamformat = songData.mediaSources[0].container
                content.url = buildURL(Substitute("Audio/{0}/stream", songData.id), params)
            end if
        else
            return invalid
        end if
        return content
    else
        return invalid
    end if
end function

function useTranscodeAudioStream(playbackInfo)
    return playbackInfo.mediaSources[0] <> invalid and playbackInfo.mediaSources[0].TranscodingURL <> invalid
end function

function BackdropImage(id as string)
    imgParams = {
        "maxHeight": "720"
        "maxWidth": "1280"
    }
    return ImageURL(id, "Backdrop", imgParams)
end function


function TVSeasons(id as string) as dynamic
    url = Substitute("Shows/{0}/Seasons", id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
    })
    data = getJson(resp)

    if data = invalid or data.Items = invalid then
        return invalid
    end if
    results = []
    for each item in data.Items
        imgParams = {
            "AddPlayedIndicator": item.UserData.Played
        }
        tmp = CreateObject("roSGNode", "TVSeasonData")
        tmp.image = PosterImage(item.id, imgParams)
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function



function TVEpisodes(showId as string, seasonId as string) as dynamic

    data = api_shows_GetEpisodes(showId, {
        "seasonId": seasonId
        "UserId": m.global.session.user.id
        "fields": "MediaStreams,MediaSources"
    })
    if data = invalid or data.Items = invalid then
        return invalid
    end if
    results = []
    for each item in data.Items
        tmp = CreateObject("roSGNode", "TVEpisodeData")
        tmp.image = PosterImage(item.id, {
            "maxWidth": 400
            "maxheight": 250
        })
        if isValid(tmp.image)
            tmp.image.posterDisplayMode = "scaleToZoom"
        end if
        tmp.json = item
        tmpMetaData = ItemMetaData(item.id)

        if isValid(tmpMetaData) and isValid(tmpMetaData.overview)
            tmp.overview = tmpMetaData.overview
        end if
        results.push(tmp)
    end for
    data.Items = results
    return data
end function



function TVSeasonExtras(seasonId as string) as dynamic

    data = api_users_GetSpecialFeatures(m.global.session.user.id, seasonId)
    if not isValid(data) then
        return invalid
    end if
    results = []
    for each item in data
        tmp = CreateObject("roSGNode", "TVEpisodeData")
        tmp.image = PosterImage(item.id, {
            "maxWidth": 400
            "maxheight": 250
        })
        if isValid(tmp.image)
            tmp.image.posterDisplayMode = "scaleToZoom"
        end if
        tmp.json = item

        tmp.type = "Video"
        tmpMetaData = ItemMetaData(item.id)

        if isValid(tmpMetaData) and isValid(tmpMetaData.overview)
            tmp.overview = tmpMetaData.overview
        end if
        results.push(tmp)
    end for

    return {
        Items: results
    }
end function

function TVEpisodeShuffleList(show_id as string)
    url = Substitute("Shows/{0}/Episodes", show_id)
    resp = APIRequest(url, {
        "UserId": m.global.session.user.id
        "Limit": 200
        "sortBy": "Random"
    })
    data = getJson(resp)
    results = []
    for each item in data.Items
        tmp = CreateObject("roSGNode", "TVEpisodeData")
        tmp.json = item
        results.push(tmp)
    end for
    data.Items = results
    return data
end function