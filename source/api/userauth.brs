



function get_token(user as string, password as string)
    url = "Users/AuthenticateByName?format=json"
    req = APIRequest(url)
    json = postJson(req, FormatJson({
        "Username": user
        "Pw": password
    }))
    if json = invalid then
        return invalid
    end if
    userdata = CreateObject("roSGNode", "UserData")
    userdata.json = json
    userdata.callFunc("saveToRegistry")
    return userdata
end function

function AboutMe(id = "" as string)
    if id = ""
        if m.global.session.user.id <> invalid
            id = m.global.session.user.id
        else
            return invalid
        end if
    end if
    url = Substitute("Users/{0}", id)
    resp = APIRequest(url)
    return getJson(resp)
end function

sub SignOut(deleteSavedEntry = true as boolean)
    if deleteSavedEntry
        unset_user_setting("token")
        unset_user_setting("username")
    end if
    unset_setting("active_user")
    session_user_Logout()
    m.global.sceneManager.currentUser = ""
    group = m.global.sceneManager.callFunc("getActiveScene")
    group.optionsAvailable = false
end sub

function AvailableUsers()
    users = parseJson(get_setting("available_users", "[]"))
    return users
end function

function ServerInfo()
    url = "System/Info/Public"
    req = APIRequest(url)
    req.setMessagePort(CreateObject("roMessagePort"))
    req.AsyncGetToString()

    resp = wait(35000, req.GetMessagePort())

    if type(resp) <> "roUrlEvent"
        return {
            "Error": true
            "ErrorMessage": "Unknown"
        }
    end if

    headers = resp.GetResponseHeaders()
    if headers <> invalid and headers.location <> invalid


        if right(headers.location, 19) = "/System/Info/Public"
            set_setting("server", left(headers.location, len(headers.location) - 19))
            isConnected = session_server_UpdateURL(left(headers.location, len(headers.location) - 19))
            if isConnected
                info = ServerInfo()
                if info.Error
                    info.UpdatedUrl = left(headers.location, len(headers.location) - 19)
                    info.ErrorMessage = info.ErrorMessage + " (Note: Server redirected us to " + info.UpdatedUrl + ")"
                end if
                return info
            end if
        end if
    end if

    if resp.GetResponseCode() <> 200
        return {
            "Error": true
            "ErrorCode": resp.GetResponseCode()
            "ErrorMessage": resp.GetFailureReason()
        }
    end if

    responseString = resp.GetString()
    if responseString <> invalid and responseString <> ""
        result = ParseJson(responseString)
        if result <> invalid
            result.Error = false
            return result
        end if
    end if

    return {
        "Error": true
        "ErrorMessage": "Does not appear to be a Jellyfin Server"
    }
end function

function GetPublicUsers()
    url = "Users/Public"
    resp = APIRequest(url)
    return getJson(resp)
end function

sub LoadUserAbilities()
    if m.global.session.user.Policy.EnableLiveTvManagement = true
        set_user_setting("livetv.canrecord", "true")
    else
        set_user_setting("livetv.canrecord", "false")
    end if
    if m.global.session.user.Policy.EnableContentDeletion = true
        set_user_setting("content.candelete", "true")
    else
        set_user_setting("content.candelete", "false")
    end if
end sub

function initQuickConnect()
    resp = APIRequest("QuickConnect/Initiate")
    jsonResponse = getJson(resp)
    if jsonResponse = invalid
        return invalid
    end if
    if jsonResponse.Secret = invalid
        return invalid
    end if
    return jsonResponse
end function

function checkQuickConnect(secret)
    url = Substitute("QuickConnect/Connect?secret={0}", secret)
    resp = APIRequest(url)
    jsonResponse = getJson(resp)
    if jsonResponse = invalid
        return false
    end if
    if jsonResponse.Authenticated <> invalid and jsonResponse.Authenticated = true
        return true
    end if
    return false
end function

function AuthenticateViaQuickConnect(secret)
    params = {
        secret: secret
    }
    req = APIRequest("Users/AuthenticateWithQuickConnect")
    jsonResponse = postJson(req, FormatJson(params))
    if jsonResponse <> invalid and jsonResponse.AccessToken <> invalid and jsonResponse.User <> invalid
        userdata = CreateObject("roSGNode", "UserData")
        userdata.json = jsonResponse
        session_user_Update("id", jsonResponse.User.Id)
        session_user_Update("authToken", jsonResponse.AccessToken)
        userdata.callFunc("saveToRegistry")
        return true
    end if
    return false
end function