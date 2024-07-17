

function api_albums_GetInstantMix(id as string, params = {} as object)
    req = APIRequest(Substitute("/albums/{0}/instantmix", id), params)
    return getJson(req)
end function


function api_albums_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/albums/{0}/similar", id), params)
    return getJson(req)
end function

function api_artists_Get(params = {} as object)
    req = APIRequest("/artists", params)
    return getJson(req)
end function


function api_artists_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/artists/{0}", name), params)
    return getJson(req)
end function


function api_artists_GetAlbumArtists(params = {} as object)
    req = APIRequest("/artists/albumartists", params)
    return getJson(req)
end function


function api_artists_GetImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/artists/{0}/images/{1}/{2}", name, imagetype, imageindex.ToStr()), params)
end function


function api_artists_HeadImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/artists/{0}/images/{1}/{2}", name, imagetype, imageindex.ToStr()), params)
    return headVoid(req)
end function


function api_artists_GetInstantMix(id as string, params = {} as object)
    req = APIRequest(Substitute("/artists/{0}/instantmix", id), params)
    return getJson(req)
end function


function api_artists_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/artists/{0}/similar", id), params)
    return getJson(req)
end function

function api_audio_GetStreamURL(id as string, params = {} as object)
    return buildURL(Substitute("Audio/{0}/stream", id), params)
end function


function api_audio_HeadStreamURL(id as string, params = {} as object)
    req = APIRequest(Substitute("Audio/{0}/stream", id), params)
    return headVoid(req)
end function


function api_audio_GetStreamURLWithContainer(id as string, container as string, params = {} as object)
    return buildURL(Substitute("Audio/{0}/stream.{1}", id, container), params)
end function


function api_audio_HeadStreamURLWithContainer(id as string, container as string, params = {} as object)
    req = APIRequest(Substitute("Audio/{0}/stream.{1}", id, container), params)
    return headVoid(req)
end function


function api_audio_GetUniversalURL(id as string, params = {} as object)
    return buildURL(Substitute("Audio/{0}/universal", id), params)
end function


sub api_audio_HeadUniversalURL()
    throw "System.NotImplementedException: The function is not implemented."
end sub

function api_auth_GetKeys()
    req = APIRequest("/auth/keys")
    return getJson(req)
end function


function api_auth_PostKeys(params = {} as object)
    req = APIRequest("/auth/keys", params)
    return postVoid(req)
end function


function api_auth_DeleteKeys(key as string)
    req = APIRequest(Substitute("/auth/keys/{0}", key))
    return deleteVoid(req)
end function


function api_auth_GetPasswordResetProviders()
    req = APIRequest("/auth/passwordresetproviders")
    return getJson(req)
end function


function api_auth_GetAuthProviders()
    req = APIRequest("/auth/providers")
    return getJson(req)
end function

function api_branding_GetSplashScreen(params = {} as object)
    return buildURL("/branding/splashscreen", params)
end function


sub api_branding_PostSplashScreen()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_branding_DeleteSplashScreen()
    req = APIRequest("/branding/splashscreen")
    return deleteVoid(req)
end function


function api_branding_GetConfiguration()
    req = APIRequest("/branding/configuration")
    return getJson(req)
end function


function api_branding_GetCSS()
    req = APIRequest("/branding/css")
    return getJson(req)
end function


function api_branding_GetCSSWithExtension()
    req = APIRequest("/branding/css.css")
    return getJson(req)
end function

function api_channels_Get(params = {} as object)
    req = APIRequest("/channels", params)
    return getJson(req)
end function

function api_channels_GetFeatures(id as string)
    req = APIRequest(Substitute("/channels/{0}/features", id))
    return getJson(req)
end function

function api_channels_GetItems(id as string, params = {} as object)
    req = APIRequest(Substitute("/channels/{0}/items", id), params)
    return getJson(req)
end function

function api_channels_GetAllFeatures()
    req = APIRequest("/channels/features")
    return getJson(req)
end function

function api_channels_GetLatestItems(params = {} as object)
    req = APIRequest("/channels/items/latest", params)
    return getJson(req)
end function
sub api_clientLog_Document()
    throw "System.NotImplementedException: The function is not implemented."
end sub

function api_collections_Create(params = {} as object)
    req = APIRequest("/collections", params)
    return postJson(req)
end function


function api_collections_AddItems(id as string, params = {} as object)
    req = APIRequest(Substitute("/collections/{0}/items", id), params)
    return postVoid(req)
end function


function api_collections_DeleteItems(id as string, params = {} as object)
    req = APIRequest(Substitute("/collections/{0}/items", id), params)
    return deleteVoid(req)
end function

function api_devices_Get(params = {} as object)
    req = APIRequest("/devices", params)
    return getJson(req)
end function

function api_devices_GetInfo(params = {} as object)
    req = APIRequest("/devices/info", params)
    return getJson(req)
end function

function api_devices_GetOptions(params = {} as object)
    req = APIRequest("/devices/options", params)
    return getJson(req)
end function

function api_devices_UpdateOptions(params = {} as object, body = {} as object)
    req = APIRequest("/devices/options", params)
    return postVoid(req, FormatJson(body))
end function

function api_devices_Delete(params = {} as object)
    req = APIRequest("/devices", params)
    return deleteVoid(req)
end function





function api_displayPreferences_Get(id as string, params = {} as object)
    req = APIRequest(Substitute("/displaypreferences/{0}", id), params)
    return getJson(req)
end function

function api_displayPreferences_Update(id, params = {} as object, body = {} as object)
    req = APIRequest(Substitute("/displaypreferences/{0}", id), params)
    return postVoid(req, FormatJson(body))
end function

function api_dlna_GetProfileInfos()
    req = APIRequest("/dlna/profileinfos")
    return getJson(req)
end function


function api_dlna_CreateProfile(body = {} as object)
    req = APIRequest("/dlna/profiles")
    return postVoid(req, FormatJson(body))
end function


sub api_dlna_UpdateProfile()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_dlna_GetProfileByID(id as string)
    req = APIRequest(Substitute("/dlna/profiles/{0}", id))
    return getJson(req)
end function


function api_dlna_DeleteProfile(id as string)
    req = APIRequest(Substitute("/dlna/profiles/{0}", id))
    return deleteVoid(req)
end function


function api_dlna_GetDefaultProfile()
    req = APIRequest("/dlna/profiles/default")
    return getJson(req)
end function

function api_environment_GetDefaultDirectoryBrowser()
    req = APIRequest("/environment/defaultdirectorybrowser")
    return getJson(req)
end function


function api_environment_GetDirectoryContents(params = {} as object)
    req = APIRequest("/environment/directorycontents", params)
    return getJson(req)
end function


function api_environment_GetParentPath(params = {} as object)
    req = APIRequest("/environment/parentpath", params)
    return getJson(req)
end function


function api_environment_GetDrives()
    req = APIRequest("/environment/drives")
    return getJson(req)
end function


function api_environment_ValidatePath(body = {} as object)
    req = APIRequest("/environment/validatepath")
    return postVoid(req, FormatJson(body))
end function

function api_fallbackFont_GetFonts()
    req = APIRequest("/fallbackfont/fonts")
    return getJson(req)
end function


function api_fallbackFont_GetFontURL(name as string)
    return buildURL(Substitute("/fallbackfont/fonts/{0}", name))
end function

function api_getUTCTime_Get()
    req = APIRequest("/getutctime")
    return getJson(req)
end function

function api_genres_Get(params = {} as object)
    req = APIRequest("/genres", params)
    return getJson(req)
end function


function api_genres_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/genres/{0}", name), params)
    return getJson(req)
end function


function api_genres_GetImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/genres/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
end function


function api_genres_HeadImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/genres/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function

function api_images_GetGeneral()
    req = APIRequest("/images/general")
    return getJson(req)
end function


function api_images_GetGeneralURLByName(name as string, imagetype = "primary" as string)
    return buildURL(Substitute("/images/general/{0}/{1}", name, imagetype))
end function


function api_images_GetMediaInfo()
    req = APIRequest("/images/mediainfo")
    return getJson(req)
end function


function api_images_GetMediaInfoURL(theme as string, name as string)
    return buildURL(Substitute("/images/mediainfo/{0}/{1}", theme, name))
end function


function api_images_GetRatings()
    req = APIRequest("/images/ratings")
    return getJson(req)
end function


function api_images_GetRatingsURL(theme as string, name as string)
    return buildURL(Substitute("/images/ratings/{0}/{1}", theme, name))
end function

function api_items_GetFilters(params = {} as object)
    req = APIRequest("/items/filters", params)
    return getJson(req)
end function


function api_items_GetFilters2(params = {} as object)
    req = APIRequest("/items/filters2", params)
    return getJson(req)
end function


function api_items_GetImages(id as string)
    req = APIRequest(Substitute("/items/{0}/images", id))
    return getJson(req)
end function


sub api_items_DeleteImage()
    throw "System.NotImplementedException: The function is not implemented."
end sub


sub api_items_PostImage()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_items_GetImageURL(id as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/items/{0}/images/{1}/{2}", id, imagetype, imageindex.toStr()), params)
end function


function api_items_HeadImageURLByName(id as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/images/{1}/{2}", id, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function


sub api_items_DeleteImageByIndex()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_items_UpdateImageIndex(id as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/images/{1}/{2}/index", id, imagetype, imageindex.toStr()), params)
    return postVoid(req)
end function


function api_items_GetInstantMix(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/instantmix", id), params)
    return getJson(req)
end function


function api_items_GetExternalIDInfos(id as string)
    req = APIRequest(Substitute("/items/{0}/externalidinfos", id))
    return getJson(req)
end function


sub api_items_ApplySearchResult()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_items_GetBookRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/book")
    return postJson(req, FormatJson(body))
end function


function api_items_GetBoxsetRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/boxset")
    return postJson(req, FormatJson(body))
end function


function api_items_GetMovieRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/movie")
    return postJson(req, FormatJson(body))
end function


function api_items_GetMusicAlbumRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/musicalbum")
    return postJson(req, FormatJson(body))
end function


function api_items_GetMusicArtistRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/musicartist")
    return postJson(req, FormatJson(body))
end function


function api_items_GetMusicVideoRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/musicvideo")
    return postJson(req, FormatJson(body))
end function


function api_items_GetPersonRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/person")
    return postJson(req, FormatJson(body))
end function


function api_items_GetSeriesRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/series")
    return postJson(req, FormatJson(body))
end function


function api_items_GetTrailerRemoteSearch(body = {} as object)
    req = APIRequest("/items/remotesearch/trailer")
    return postJson(req, FormatJson(body))
end function


function api_items_RefreshMetaData(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/refresh", id), params)
    return postVoid(req)
end function



function api_items_GetByQuery(params = {} as object)
    req = APIRequest("/items/", params)
    return getJson(req)
end function


function api_items_Delete(params = {} as object)
    req = APIRequest("/items/", params)
    return deleteVoid(req)
end function


function api_items_DeleteByID(id as string)
    req = APIRequest(Substitute("/items/{0}", id))
    return deleteVoid(req)
end function


function api_items_GetAncestors(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/ancestors", id), params)
    return getJson(req)
end function


sub api_items_GetDownload()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_items_GetOriginalFile(id as string)
    return buildURL(Substitute("/items/{0}/file", id))
end function


function api_items_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/similar", id), params)
    return getJson(req)
end function


function api_items_GetThemeMedia(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/thememedia", id), params)
    return getJson(req)
end function


function api_items_GetThemeSongs(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/themesongs", id), params)
    return getJson(req)
end function


function api_items_GetThemeVideos(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/themevideos", id), params)
    return getJson(req)
end function


function api_items_GetCounts(params = {} as object)
    req = APIRequest("/items/counts", params)
    return getJson(req)
end function


function api_items_Update(id as string, body = {} as object)
    req = APIRequest(Substitute("/items/{0}", id))
    return postVoid(req, FormatJson(body))
end function


function api_items_UpdateContentType(id as string, body = {} as object)
    req = APIRequest(Substitute("/items/{0}/contenttype", id))
    return postVoid(req, FormatJson(body))
end function


function api_items_GetMedaDataEditor(id as string)
    req = APIRequest(Substitute("/items/{0}/metadataeditor", id))
    return getJson(req)
end function


function api_items_GetPlaybackInfo(id as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/playbackinfo", id), params)
    return getJson(req)
end function


function api_items_PostPlayBackInfo(id as string, body = {} as object)
    req = APIRequest(Substitute("/items/{0}/playbackinfo", id))
    return postJson(req, FormatJson(body))
end function


function api_items_GetRemoteImages(id as string)
    req = APIRequest(Substitute("/items/{0}/remoteimages", id))
    return getJson(req)
end function


function api_items_GetRemoteImageProviders(id as string)
    req = APIRequest(Substitute("/items/{0}/remoteimages/providers", id))
    return getJson(req)
end function


sub api_items_DownloadRemoteImages()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_items_SearchRemoteSubtitles(id as string, language as string, params = {} as object)
    req = APIRequest(Substitute("/items/{0}/remotesearch/subtitles/{1}", id, language), params)
    return getJson(req)
end function


sub api_items_DownloadRemoteSubtitles()
    throw "System.NotImplementedException: The function is not implemented."
end sub

function api_libraries_GetAvailableOptions(params = {} as object)
    req = APIRequest("/libraries/availableoptions", params)
    return getJson(req)
end function

sub api_library_ReportMediaUpdated()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_library_GetMediaFolders(params = {} as object)
    req = APIRequest("/library/mediafolders", params)
    return getJson(req)
end function


sub api_library_ReportMoviesAdded()
    throw "System.NotImplementedException: The function is not implemented."
end sub


sub api_library_ReportMoviesUpdated()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_library_GetPhysicalPaths()
    req = APIRequest("/library/physicalpaths")
    return getJson(req)
end function


function api_library_Refresh()
    req = APIRequest("/library/refresh")
    return postVoid(req)
end function


sub api_library_ReportTVSeriesAdded()
    throw "System.NotImplementedException: The function is not implemented."
end sub


sub api_library_ReportTVSeriesUpdated()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_library_GetVirtualFolders()
    req = APIRequest("/library/virtualfolders")
    return getJson(req)
end function


function api_library_AddVirtualFolder(params as object, body = {} as object)
    req = APIRequest("/library/virtualfolders", params)
    return postVoid(req, FormatJson(body))
end function


function api_library_DeleteVirtualFolder(params as object)
    req = APIRequest("/library/virtualfolders", params)
    return deleteVoid(req)
end function


function api_library_UpdateOptions(body = {} as object)
    req = APIRequest("/library/virtualfolders/libraryoptions")
    return postVoid(req, FormatJson(body))
end function


function api_library_RenameVirtualFolder(params as object)
    req = APIRequest("/library/virtualfolders/name", params)
    return postVoid(req)
end function


function api_library_AddPath(params as object, body = {} as object)
    req = APIRequest("/library/virtualfolders/paths", params)
    return postVoid(req, FormatJson(body))
end function


function api_library_DeletePath(params as object)
    req = APIRequest("/library/virtualfolders/paths", params)
    return deleteVoid(req)
end function


function api_library_UpdatePath(body = {} as object)
    req = APIRequest("/library/virtualfolders/paths/update")
    return postVoid(req, FormatJson(body))
end function

function api_livestreams_Open(params = {} as object, body = {} as object)
    req = APIRequest("/livestreams/open", params)
    return postJson(req, FormatJson(body))
end function


function api_livestreams_Close(params = {} as object)
    req = APIRequest("/livestreams/close", params)
    return postVoid(req)
end function

function api_liveTV_GetChannelMappingOptions(params = {} as object)
    req = APIRequest("/livetv/channelmappingoptions", params)
    return getJson(req)
end function


function api_liveTV_SetChannelMappings(body = {} as object)
    req = APIRequest("livetv/channelmappings")
    return postJson(req, FormatJson(body))
end function


function api_liveTV_GetChannels(params = {} as object)
    req = APIRequest("/livetv/channels", params)
    return getJson(req)
end function


function api_liveTV_GetChannelByID(id as string, params = {} as object)
    req = APIRequest(Substitute("/livetv/channels/{0}", id), params)
    return getJson(req)
end function


function api_liveTV_GetGuideInfo()
    req = APIRequest("/livetv/guideinfo")
    return getJson(req)
end function


function api_liveTV_GetInfo()
    req = APIRequest("/livetv/info")
    return getJson(req)
end function


function api_liveTV_AddListingProvider(params = {} as object, body = {} as object)
    req = APIRequest("/livetv/listingproviders", params)
    return postJson(req, FormatJson(body))
end function


function api_liveTV_DeleteListingProvider(id as string)
    req = APIRequest(Substitute("livetv/listingproviders", id))
    return deleteVoid(req)
end function


function api_liveTV_GetDefaultListingProvider()
    req = APIRequest("/livetv/listingproviders/default")
    return getJson(req)
end function


function api_liveTV_GetLineups(params = {} as object)
    req = APIRequest("/livetv/listingproviders/lineups", params)
    return getJson(req)
end function


function api_liveTV_GetCountries()
    req = APIRequest("/livetv/listingproviders/schedulesdirect/countries")
    return getJson(req)
end function


function api_liveTV_GetRecordingStream(id as string)
    return buildURL(Substitute("/livetv/listingproviders/{0}/stream", id))
end function


function api_liveTV_GetChannelStream(id as string, container as string)
    return buildURL(Substitute("/livetv/livestreamfiles/{0}/stream.{1}", id, container))
end function


function api_liveTV_GetPrograms(params = {} as object)
    req = APIRequest("/livetv/programs", params)
    return getJson(req)
end function


function api_liveTV_PostPrograms(body = {} as object)
    req = APIRequest("/livetv/programs")
    return postJson(req, FormatJson(body))
end function


function api_liveTV_PostProgramByID(id as string, params = {} as object)
    req = APIRequest(Substitute("/livetv/programs/{0}", id), params)
    return getJson(req)
end function


function api_liveTV_GetRecommendedPrograms(params = {} as object)
    req = APIRequest("/livetv/programs/recommended", params)
    return getJson(req)
end function


function api_liveTV_GetRecordings(params = {} as object)
    req = APIRequest("/livetv/recordings", params)
    return getJson(req)
end function


function api_liveTV_GetRecordingByID(id as string, params = {} as object)
    req = APIRequest(Substitute("/livetv/recordings/{0}", id), params)
    return getJson(req)
end function


function api_liveTV_DeleteRecordingByID(id as string)
    req = APIRequest(Substitute("/livetv/recordings/{0}", id))
    return deleteVoid(req)
end function


function api_liveTV_GetRecordingsFolders(params = {} as object)
    req = APIRequest("/livetv/recordings/folders", params)
    return getJson(req)
end function


function api_liveTV_GetSeriesTimers(params = {} as object)
    req = APIRequest("/livetv/seriestimers", params)
    return getJson(req)
end function


function api_liveTV_CreateSeriesTimer(body = {} as object)
    req = APIRequest("/livetv/seriestimers")
    return postVoid(req, FormatJson(body))
end function


function api_liveTV_GetSeriesTimerByID(id as string)
    req = APIRequest(Substitute("/livetv/seriestimers/{0}", id))
    return getJson(req)
end function


function api_liveTV_DeleteSeriesTimer(id as string)
    req = APIRequest(Substitute("/livetv/seriestimers/{0}", id))
    return deleteVoid(req)
end function


function api_liveTV_UpdateSeriesTimer(id as string, body = {} as object)
    req = APIRequest(Substitute("/livetv/seriestimers/{0}", id))
    return postVoid(req, FormatJson(body))
end function


function api_liveTV_GetTimers(params = {} as object)
    req = APIRequest("/livetv/timers", params)
    return getJson(req)
end function


function api_liveTV_CreateTimer(body = {} as object)
    req = APIRequest("/livetv/timers")
    return postVoid(req, FormatJson(body))
end function


function api_liveTV_GetTimerByID(id as string)
    req = APIRequest(Substitute("/livetv/timers/{0}", id))
    return getJson(req)
end function


function api_liveTV_DeleteTimer(id as string)
    req = APIRequest(Substitute("/livetv/timers/{0}", id))
    return deleteVoid(req)
end function


function api_liveTV_UpdateTimer(id as string, body = {} as object)
    req = APIRequest(Substitute("/livetv/timers/{0}", id))
    return postVoid(req, FormatJson(body))
end function


function api_liveTV_GetTimerDefaults()
    req = APIRequest("/livetv/timers/defaults")
    return getJson(req)
end function


function api_liveTV_AddTunerHost(body = {} as object)
    req = APIRequest("/livetv/tunerhosts")
    return postJson(req, FormatJson(body))
end function


function api_liveTV_DeleteTunerHost(params = {} as object)
    req = APIRequest("/livetv/tunerhosts", params)
    return deleteVoid(req)
end function


function api_liveTV_GetTunerHostTypes()
    req = APIRequest("/livetv/tunerhosts/types")
    return getJson(req)
end function


function api_liveTV_ResetTunerHost(id as string)
    req = APIRequest(Substitute("/livetv/tuners/{0}/reset", id))
    return postVoid(req)
end function


function api_liveTV_GetTunersDiscover(params = {} as object)
    req = APIRequest("/livetv/tuners/discover", params)
    return getJson(req)
end function


function api_liveTV_GetTunersDiscvover(params = {} as object)
    req = APIRequest("/livetv/tuners/discvover", params)
    return getJson(req)
end function

function api_localization_GetCountries()
    req = APIRequest("/localization/countries")
    return getJson(req)
end function


function api_localization_GetCultures()
    req = APIRequest("/localization/cultures")
    return getJson(req)
end function


function api_localization_GetOptions()
    req = APIRequest("/localization/options")
    return getJson(req)
end function


function api_localization_GetParentalRatings()
    req = APIRequest("/localization/parentalratings")
    return getJson(req)
end function

function api_movies_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/movies/{0}/similar", id), params)
    return getJson(req)
end function



function api_movies_GetRecommendations(params = {} as object)
    req = APIRequest("/movies/recommendations", params)
    return getJson(req)
end function

function api_musicGenres_GetImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/musicgenres/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
end function


function api_musicGenres_HeadImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/musicgenres/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function


function api_musicGenres_GetInstantMix(params = {} as object)
    req = APIRequest("/musicgenres/instantmix", params)
    return getJson(req)
end function


function api_musicGenres_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/musicgenres/{0}", name), params)
    return getJson(req)
end function

function api_notifications_Get(id as string)
    req = APIRequest(Substitute("/notifications/{0}", id))
    return getJson(req)
end function


function api_notifications_MarkRead(id as string)
    req = APIRequest(Substitute("/notifications/{0}/read", id))
    return postVoid(req)
end function


function api_notifications_GetSummary(id as string)
    req = APIRequest(Substitute("/notifications/{0}/summary", id))
    return getJson(req)
end function


function api_notifications_MarkUnread(id as string)
    req = APIRequest(Substitute("/notifications/{0}/unread", id))
    return postVoid(req)
end function


function api_notifications_NotifyAdmins(body = {} as object)
    req = APIRequest("/notifications/admin")
    return postVoid(req, FormatJson(body))
end function


function api_notifications_GetServices()
    req = APIRequest("/notifications/services")
    return getJson(req)
end function


function api_notifications_GetTypes()
    req = APIRequest("/notifications/types")
    return getJson(req)
end function

function api_packages_Get()
    req = APIRequest("/packages")
    return getJson(req)
end function


function api_packages_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/packages/{0}", name), params)
    return getJson(req)
end function


function api_packages_Install(name as string, params = {} as object)
    req = APIRequest(Substitute("/packages/installed/{0}", name), params)
    return postVoid(req)
end function


function api_packages_CancelInstall(id as string)
    req = APIRequest(Substitute("/packages/installing/{0}", id))
    return deleteVoid(req)
end function

function api_persons_GetImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/persons/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
end function


function api_persons_HeadImageURLByName(name as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/persons/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function


function api_persons_Get(params = {} as object)
    req = APIRequest("/persons", params)
    return getJson(req)
end function


function api_persons_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/persons/{0}", name), params)
    return getJson(req)
end function

function api_playback_BitrateTest(params = {} as object)
    req = APIRequest("/playback/bitratetest", params)
    return getVoid(req)
end function

function api_playlists_GetInstantMix(id as string, params = {} as object)
    req = APIRequest(Substitute("/playlists/{0}/instantmix", id), params)
    return getJson(req)
end function


function api_playlists_Create(body = {} as object)
    req = APIRequest("/playlists")
    return postJson(req, FormatJson(body))
end function


function api_playlists_Add(id as string, params = {} as object)
    req = APIRequest(Substitute("/playlists/{0}/items", id), params)
    return postVoid(req)
end function


function api_playlists_Remove(id as string, params = {} as object)
    req = APIRequest(Substitute("/playlists/{0}/items", id), params)
    return deleteVoid(req)
end function


function api_playlists_GetItems(playlistID as string, params = {} as object)
    req = APIRequest(Substitute("/playlists/{0}/items", playlistID), params)
    return getJson(req)
end function


function api_playlists_Move(playlistid as string, itemid as string, newindex as integer)
    req = APIRequest(Substitute("/playlists/{0}/items/{1}/move/{2}", playlistid, itemid, newindex))
    return postVoid(req)
end function

function api_plugins_Get()
    req = APIRequest("/plugins")
    return getJson(req)
end function


sub api_plugins_Uninstall()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_plugins_Disable(id as string, version as string)
    req = APIRequest(Substitute("/plugins/{0}/{1}/disable", id, version))
    return postVoid(req)
end function


function api_plugins_Enable(id as string, version as string)
    req = APIRequest(Substitute("/plugins/{0}/{1}/enable", id, version))
    return postVoid(req)
end function


function api_plugins_GetImage(id as string, version as string)
    return buildURL(Substitute("/plugins/{0}/{1}/image", id, version))
end function


function api_plugins_GetConfiguration(id as string)
    req = APIRequest(Substitute("/plugins/{0}/configuration", id))
    return getJson(req)
end function


function api_plugins_UpdateConfiguration(id as string, body = {} as object)
    req = APIRequest(Substitute("/plugins/{0}/configuration", id))
    return postVoid(req, FormatJson(body))
end function


function api_plugins_GetManifest(id as string)
    req = APIRequest(Substitute("/plugins/{0}/manifest", id))
    return postJson(req)
end function

function api_providers_GetRemoteSubtitles(id as string)
    req = APIRequest(Substitute("/providers/subtitles/subtitles/{0}", id))
    return getJson(req)
end function

function api_quickConnect_Authorize(params = {} as object)
    req = APIRequest("/quickconnect/authorize", params)
    return postString(req)
end function


function api_quickConnect_Connect()
    req = APIRequest("/quickconnect/connect")
    return getJson(req)
end function


function api_quickConnect_IsEnabled()
    req = APIRequest("/quickconnect/enabled")
    return getString(req)
end function


function api_quickConnect_Initiate()
    req = APIRequest("/quickconnect/initiate")
    return getJson(req)
end function

function api_repositories_Get()
    req = APIRequest("/repositories")
    return getJson(req)
end function


function api_repositories_Set(body = {} as object)
    req = APIRequest("/repositories")
    return postVoid(req, FormatJson(body))
end function

function api_scheduledTasks_Get(params = {} as object)
    req = APIRequest("/scheduledtasks", params)
    return getJson(req)
end function


function api_scheduledTasks_GetByID(id as string)
    req = APIRequest(Substitute("/scheduledtasks/{0}", id))
    return getJson(req)
end function


function api_scheduledTasks_UpdateTriggers(id as string, body = {} as object)
    req = APIRequest(Substitute("/scheduledtasks/{0}/triggers", id))
    return postVoid(req, FormatJson(body))
end function


function api_scheduledTasks_Start(id as string)
    req = APIRequest(Substitute("/scheduledtasks/running/{0}", id))
    return postVoid(req)
end function


function api_scheduledTasks_stop(id as string)
    req = APIRequest(Substitute("/scheduledtasks/running/{0}", id))
    return deleteVoid(req)
end function

function api_search_GetHints(params = {} as object)
    req = APIRequest("/search/hints", params)
    return getJson(req)
end function

function api_sessions_Playing(body = {} as object)
    req = APIRequest("/sessions/playing")
    return postVoid(req, FormatJson(body))
end function


function api_sessions_Ping(params = {} as object)
    req = APIRequest("/sessions/playing/ping", params)
    return postVoid(req)
end function


function api_sessions_PostProgress(body = {} as object)
    req = APIRequest("/sessions/playing/progress")
    return postVoid(req, FormatJson(body))
end function


function api_sessions_PostStopped(body = {} as object)
    req = APIRequest("/sessions/playing/stopped")
    return postVoid(req, FormatJson(body))
end function


function api_sessions_Get(params = {
    "deviceId": m.global.device.serverDeviceName
} as object)
    req = APIRequest("/sessions", params)
    return getJson(req)
end function


function api_sessions_PostFullCommand(id as string, body = {} as object)
    req = APIRequest(Substitute("/sessions/{0}/command", id))
    return postVoid(req, FormatJson(body))
end function


function api_sessions_PostCommand(id as string, command as string)
    req = APIRequest(Substitute("/sessions/{0}/command/{1}", id, command))
    return postVoid(req)
end function


function api_sessions_PostMessage(id as string, body = {} as object)
    req = APIRequest(Substitute("/sessions/{0}/message", id))
    return postVoid(req, FormatJson(body))
end function


function api_sessions_Play(id as string, params = {} as object)
    req = APIRequest(Substitute("/sessions/{0}/playing", id), params)
    return postVoid(req)
end function


function api_sessions_PlayCommand(id as string, command as string)
    req = APIRequest(Substitute("/sessions/{0}/playing/{1}", id, command))
    return postVoid(req)
end function


function api_sessions_SystemCommand(id as string, command as string)
    req = APIRequest(Substitute("/sessions/{0}/system/{1}", id, command))
    return postVoid(req)
end function


function api_sessions_AddUser(id as string, userid as string)
    req = APIRequest(Substitute("/sessions/{0}/user/{1}", id, userid))
    return postVoid(req)
end function


function api_sessions_RemoveUser(id as string, userid as string)
    req = APIRequest(Substitute("/sessions/{0}/user/{1}", id, userid))
    return deleteVoid(req)
end function


function api_sessions_BrowseTo(id as string, params = {} as object)
    req = APIRequest(Substitute("/sessions/{0}/viewing", id), params)
    return postVoid(req)
end function


function api_sessions_PostCapabilities(params = {} as object)
    req = APIRequest("/sessions/capabilities", params)
    return postVoid(req)
end function


function api_sessions_PostFullCapabilities(params = {} as object, body = {} as object)
    req = APIRequest("/sessions/capabilities/full", params)
    return postVoid(req, FormatJson(body))
end function


function api_sessions_Logout()
    req = APIRequest("/sessions/logout")
    return postVoid(req)
end function


function api_sessions_PostViewing(params = {} as object)
    req = APIRequest("/sessions/viewing", params)
    return postVoid(req)
end function

function api_shows_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/shows/{0}/similar", id), params)
    return getJson(req)
end function


function api_shows_GetEpisodes(id as string, params = {} as object)
    req = APIRequest(Substitute("/shows/{0}/episodes", id), params)
    return getJson(req)
end function


function api_shows_GetSeasons(id as string, params = {} as object)
    req = APIRequest(Substitute("/shows/{0}/seasons", id), params)
    return getJson(req)
end function


function api_shows_GetNextUp(params = {} as object)
    req = APIRequest("/shows/nextup", params)
    return getJson(req)
end function


function api_shows_GetUpcoming(params = {} as object)
    req = APIRequest("/shows/upcoming", params)
    return getJson(req)
end function

function api_songs_GetInstantMix(id as string, params = {} as object)
    req = APIRequest(Substitute("/songs/{0}/instantmix", id), params)
    return getJson(req)
end function

function api_startup_Complete()
    req = APIRequest("/startup/complete")
    return postVoid(req)
end function


function api_startup_GetConfiguration()
    req = APIRequest("/startup/configuration")
    return getJson(req)
end function


function api_startup_PostConfiguration(body = {} as object)
    req = APIRequest("/startup/configuration")
    return postVoid(req, FormatJson(body))
end function


function api_startup_GetFirstUser()
    req = APIRequest("/startup/firstuser")
    return getJson(req)
end function


function api_startup_PostRemoteAccess(body = {} as object)
    req = APIRequest("/startup/remoteaccess")
    return postVoid(req, FormatJson(body))
end function


function api_startup_GetUser()
    req = APIRequest("/startup/user")
    return getJson(req)
end function


function api_startup_PostUser(body = {} as object)
    req = APIRequest("/startup/user")
    return postVoid(req, FormatJson(body))
end function

function api_studios_Get(params = {} as object)
    req = APIRequest("/studios", params)
    return getJson(req)
end function


function api_studios_GetByName(name as string, params = {} as object)
    req = APIRequest(Substitute("/studios/{0}", name), params)
    return getJson(req)
end function


function api_studios_GetImageURLByName(name as string, imagetype = "thumb" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/studios/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
end function


function api_studios_HeadImageURLByName(name as string, imagetype = "thumb" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/studios/{0}/images/{1}/{2}", name, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function

function api_syncPlay_Buffering(body = {} as object)
    req = APIRequest("/syncplay/buffering")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Join(body = {} as object)
    req = APIRequest("/syncplay/join")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Leave(body = {} as object)
    req = APIRequest("/syncplay/leave")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_GetList()
    req = APIRequest("/syncplay/list")
    return getJson(req)
end function


function api_syncPlay_MovePlaylistItem(body = {} as object)
    req = APIRequest("/syncplay/moveplaylistitem")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_New(body = {} as object)
    req = APIRequest("/syncplay/new")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_NextItem(body = {} as object)
    req = APIRequest("/syncplay/nextitem")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Pause()
    req = APIRequest("/syncplay/pause")
    return postVoid(req)
end function


function api_syncPlay_Ping(body = {} as object)
    req = APIRequest("/syncplay/ping")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Previous(body = {} as object)
    req = APIRequest("/syncplay/previousitem")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Queue(body = {} as object)
    req = APIRequest("/syncplay/queue")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Ready(body = {} as object)
    req = APIRequest("/syncplay/ready")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_RemoveFromPlaylist(body = {} as object)
    req = APIRequest("/syncplay/removefromplaylist")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_Seek(body = {} as object)
    req = APIRequest("/syncplay/seek")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_SetIgnoreWait(body = {} as object)
    req = APIRequest("/syncplay/setignorewait")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_SetNewQueue(body = {} as object)
    req = APIRequest("/syncplay/setnewqueue")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_SetPlaylistItem(body = {} as object)
    req = APIRequest("/syncplay/setplaylistitem")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_SetRepeatMode(body = {} as object)
    req = APIRequest("/syncplay/setrepeatmode")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_SetShuffleMode(body = {} as object)
    req = APIRequest("/syncplay/setshufflemode")
    return postVoid(req, FormatJson(body))
end function


function api_syncPlay_stop()
    req = APIRequest("/syncplay/stop")
    return postVoid(req)
end function


function api_syncPlay_Unpause()
    req = APIRequest("/syncplay/unpause")
    return postVoid(req)
end function

function api_system_GetActivityLogEntries(params = {} as object)
    req = APIRequest("/system/activitylog/entries", params)
    return getJson(req)
end function


function api_system_GetConfiguration()
    req = APIRequest("/system/configuration")
    return getJson(req)
end function


function api_system_UpdateConfiguration(body = {} as object)
    req = APIRequest("/system/configuration")
    return postVoid(req, FormatJson(body))
end function


function api_system_GetConfigurationByName(name as string)
    req = APIRequest(Substitute("/system/configuration/{0}", name))
    return getJson(req)
end function


sub api_system_UpdateConfigurationByName()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_system_GetDefaultMetaDataOptions()
    req = APIRequest("/system/configuration/metadataoptions/default")
    return getJson(req)
end function


sub api_system_UpdateMediaEncoderPath()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_system_GetEndpoint()
    req = APIRequest("/system/endpoint")
    return getJson(req)
end function


function api_system_GetInfo()
    req = APIRequest("/system/info")
    return getJson(req)
end function


function api_system_GetPublicInfo()
    req = APIRequest("/system/info/public")
    return getJson(req)
end function


function api_system_GetLogs()
    req = APIRequest("/system/logs")
    return getJson(req)
end function


function api_system_GetLog(params = {} as object)
    req = APIRequest("/system/logs/log", params)
    return getString(req)
end function


function api_system_GetPing()
    req = APIRequest("/system/ping")
    return getString(req)
end function


function api_system_PostPing()
    req = APIRequest("/system/ping")
    return postString(req)
end function


function api_system_Restart()
    req = APIRequest("/system/restart")
    return postVoid(req)
end function


function api_system_Shutdown()
    req = APIRequest("/system/shutdown")
    return postVoid(req)
end function

function api_tmdb_GetClientConfiguration()
    req = APIRequest("/tmdb/clientconfiguration")
    return getJson(req)
end function

function api_trailers_GetSimilar(id as string, params = {} as object)
    req = APIRequest(Substitute("/trailers/{0}/similar", id), params)
    return getJson(req)
end function


function api_trailers_Get(params = {} as object)
    req = APIRequest("/trailers/", params)
    return getJson(req)
end function


function api_users_Get(id = "")
    url = "/users"
    if id <> ""
        url = url + "/" + id
    end if
    req = APIRequest(url)
    return getJson(req)
end function


function api_users_GetMe()
    req = APIRequest("/users/me")
    return getJson(req)
end function


function api_users_GetPublic()
    resp = APIRequest("/users/public")
    return getJson(resp)
end function


function api_users_Create(body = {} as object)
    req = APIRequest("/users/new")
    return postJson(req, FormatJson(body))
end function


function api_users_Delete(id)
    req = APIRequest(Substitute("/users/{0}", id))
    return deleteVoid(req)
end function


function api_users_Update(id, body = {} as object)
    req = APIRequest(Substitute("/users/{0}", id))
    return postVoid(req, FormatJson(body))
end function


function api_users_UpdateConfiguration(id, body = {} as object)
    req = APIRequest(Substitute("/users/{0}/configuration", id))
    return postVoid(req, FormatJson(body))
end function


function api_users_UpdateEasyPassword(id, body = {} as object)
    req = APIRequest(Substitute("/users/{0}/easypassword", id))
    return postVoid(req, FormatJson(body))
end function


function api_users_UpdatePassword(id, body = {} as object)
    req = APIRequest(Substitute("/users/{0}/password", id))
    return postVoid(req, FormatJson(body))
end function


function api_users_UpdatePolicy(id, body = {} as object)
    req = APIRequest(Substitute("/users/{0}/policy", id))
    return postVoid(req, FormatJson(body))
end function


function api_users_AuthenticateByName(body = {} as object)
    req = APIRequest("users/authenticatebyname")
    json = postJson(req, FormatJson(body))
    return json
end function


sub api_users_AuthenticateWithQuickConnect()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_users_ForgotPassword(body = {} as object)
    req = APIRequest("users/forgotpassword")
    json = postJson(req, FormatJson(body))
    return json
end function


function api_users_ForgotPasswordPin(body = {} as object)
    req = APIRequest("users/forgotpassword/pin")
    json = postJson(req, FormatJson(body))
    return json
end function


sub api_users_UpdateImage()
    throw "System.NotImplementedException: The function is not implemented."
end sub


sub api_users_DeleteImage()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_users_GetImageURL(id as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    return buildURL(Substitute("/users/{0}/images/{1}/{2}", id, imagetype, imageindex.toStr()), params)
end function


function api_users_HeadImageURL(id as string, imagetype = "primary" as string, imageindex = 0 as integer, params = {} as object)
    req = APIRequest(Substitute("/users/{0}/images/{1}/{2}", id, imagetype, imageindex.toStr()), params)
    return headVoid(req)
end function


function api_users_GetItemsByQuery(id as string, params = {} as object)
    req = APIRequest(Substitute("/users/{0}/items", id), params)
    return getJson(req)
end function


function api_users_GetResumeItemsByQuery(id as string, params = {} as object)
    req = APIRequest(Substitute("/users/{0}/items/resume", id), params)
    return getJson(req)
end function


function api_users_GetSuggestions(id as string, params = {} as object)
    resp = APIRequest(Substitute("/users/{0}/suggestions", id), params)
    return getJson(resp)
end function


function api_users_GetGroupingOptions(id as string)
    resp = APIRequest(Substitute("/users/{0}/groupingoptions", id))
    return getJson(resp)
end function


function api_users_GetViews(id as string, params = {} as object)
    resp = APIRequest(Substitute("/users/{0}/views", id), params)
    return getJson(resp)
end function


function api_users_MarkFavorite(userid as string, itemid as string)
    req = APIRequest(Substitute("users/{0}/favoriteitems/{1}", userid, itemid))
    json = postJson(req)
    return json
end function


function api_users_UnmarkFavorite(userid as string, itemid as string)
    req = APIRequest(Substitute("users/{0}/favoriteitems/{1}", userid, itemid))
    json = deleteVoid(req)
    return json
end function


function api_users_GetItem(userid as string, itemid as string)
    resp = APIRequest(Substitute("/users/{0}/items/{1}", userid, itemid))
    return getJson(resp)
end function


function api_users_GetIntros(userid as string, itemid as string)
    resp = APIRequest(Substitute("/users/{0}/items/{1}/intros", userid, itemid))
    return getJson(resp)
end function


function api_users_GetLocalTrailers(userid as string, itemid as string)
    resp = APIRequest(Substitute("/users/{0}/items/{1}/localtrailers", userid, itemid))
    return getJson(resp)
end function


function api_users_DeleteRating(userid as string, itemid as string)
    req = APIRequest(Substitute("users/{0}/items/{1}/rating", userid, itemid))
    json = deleteVoid(req)
    return json
end function


function api_users_UpdateRating(userid as string, itemid as string, params = {} as object)
    req = APIRequest(Substitute("users/{0}/items/{1}/rating", userid, itemid), params)
    json = postJson(req)
    return json
end function


function api_users_GetSpecialFeatures(userid as string, itemid as string)
    resp = APIRequest(Substitute("/users/{0}/items/{1}/specialfeatures", userid, itemid))
    return getJson(resp)
end function


function api_users_GetLatestMedia(userid as string, params = {} as object)
    resp = APIRequest(Substitute("/users/{0}/items/latest", userid), params)
    return getJson(resp)
end function


function api_users_GetRoot(userid as string)
    resp = APIRequest(Substitute("/users/{0}/items/root", userid))
    return getJson(resp)
end function


function api_users_MarkPlayed(userid as string, itemid as string, params = {} as object)
    req = APIRequest(Substitute("users/{0}/playeditems/{1}", userid, itemid), params)
    return postJson(req)
end function


function api_users_UnmarkPlayed(userid as string, itemid as string)
    req = APIRequest(Substitute("users/{0}/playeditems/{1}", userid, itemid))
    return deleteVoid(req)
end function


function api_users_MarkPlaying(userid as string, itemid as string, params = {} as object)
    req = APIRequest(Substitute("users/{0}/playingitems/{1}", userid, itemid), params)
    return postJson(req)
end function


function api_users_MarkStoppedPlaying(userid as string, itemid as string, params = {} as object)
    req = APIRequest(Substitute("users/{0}/playingitems/{1}", userid, itemid), params)
    return deleteVoid(req)
end function


function api_users_ReportPlayProgress(userid as string, itemid as string, params = {} as object)
    req = APIRequest(Substitute("users/{0}/playingitems/{1}/progress", userid, itemid), params)
    return postJson(req)
end function

function api_videos_GetAdditionalParts(id as string, params = {} as object)
    req = APIRequest(Substitute("/videos/{0}/additionalparts", id), params)
    return getJson(req)
end function


sub api_videos_DeleteAdditionalParts()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_videos_GetStreamURL(id as string, params = {} as object)
    return buildURL(Substitute("/videos/{0}/stream", id), params)
end function


function api_videos_HeadStreamURL(id as string, params = {} as object)
    req = APIRequest(Substitute("videos/{0}/stream", id), params)
    return headVoid(req)
end function


function api_videos_GetStreamURLWithContainer(id as string, container as string, params = {} as object)
    return buildURL(Substitute("videos/{0}/stream.{1}", id, container), params)
end function


function api_videos_HeadStreamURLWithContainer(id as string, container as string, params = {} as object)
    req = APIRequest(Substitute("videos/{0}/stream.{1}", id, container), params)
    return headVoid(req)
end function


function api_videos_MergeVersions(params = {} as object)
    req = APIRequest("videos/mergeversions", params)
    return postVoid(req)
end function


sub api_videos_GetAttachments()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_videos_GetHLSSubtitlePlaylistURL(id as string, streamindex as integer, mediasourceid as string, params = {} as object)
    return buildURL(Substitute("/videos/{0}/{1}/subtitles/{2}/subtitles.m3u8", id, streamindex, mediasourceid), params)
end function


sub api_videos_UploadSubtitle()
    throw "System.NotImplementedException: The function is not implemented."
end sub


sub api_videos_DeleteSubtitle()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_videos_GetSubtitlesWithStartPosition(routeitemid as string, routemediasourceid as string, routeindex as integer, routestartpositionticks as integer, routeformat as string, params = {} as object)

    return buildURL(Substitute("/videos/{0}/{1}/subtitles/{2}/{3}/stream." + routeformat, routeitemid, routemediasourceid, routeindex, routestartpositionticks), params)
end function


function api_videos_GetSubtitles(routeitemid as string, routemediasourceid as string, routeindex as integer, routestartpositionticks as integer, routeformat as string, params = {} as object)

    return buildURL(Substitute("/videos/{0}/{1}/subtitles/{2}/{3}/stream." + routeformat, routeitemid, routemediasourceid, routeindex, routestartpositionticks), params)
end function

sub api_web_GetConfigurationPage()
    throw "System.NotImplementedException: The function is not implemented."
end sub


function api_web_GetConfigurationPages()
    req = APIRequest("/web/configurationpages")
    return getJson(req)
end function

function api_years_Get(params = {} as object)
    req = APIRequest("/years", params)
    return getJson(req)
end function


function api_years_GetYear(year as string, params = {} as object)
    req = APIRequest(Substitute("/years/{0}", year), params)
    return getJson(req)
end function