



function GetConfigTree()
    return ParseJSON(ReadAsciiFile("pkg:/settings/settings.json"))
end function


function registry_read(key, section = invalid)
    if section = invalid then
        return invalid
    end if
    reg = CreateObject("roRegistrySection", section)
    if reg.exists(key) then
        return reg.read(key)
    end if
    return invalid
end function

sub registry_write(key, value, section = invalid)
    if section = invalid then
        return
    end if
    reg = CreateObject("roRegistrySection", section)
    reg.write(key, value)
    reg.flush()
end sub

sub registry_delete(key, section = invalid)
    if section = invalid then
        return
    end if
    reg = CreateObject("roRegistrySection", section)
    reg.delete(key)
    reg.flush()
end sub


function RegistryReadAll(section as string) as dynamic
    if section = "" then
        return invalid
    end if
    registry = CreateObject("roRegistrySection", section)
    regKeyList = registry.GetKeyList()
    registryData = {}
    for each item in regKeyList
        if registry.Exists(item)
            registryData.AddReplace(item, registry.Read(item))
        end if
    end for
    return registryData
end function


function getRegistrySections() as object
    registry = CreateObject("roRegistry")
    return registry.GetSectionList()
end function


function get_setting(key, defaultValue = invalid)
    value = registry_read(key, "Jellyfin")
    if value = invalid then
        return defaultValue
    end if
    return value
end function

sub set_setting(key, value)
    registry_write(key, value, "Jellyfin")
end sub

sub unset_setting(key)
    registry_delete(key, "Jellyfin")
end sub


function get_user_setting(key as string) as dynamic
    if key = "" or m.global.session.user.id = invalid then
        return invalid
    end if
    value = registry_read(key, m.global.session.user.id)
    return value
end function

sub set_user_setting(key as string, value as dynamic)
    if m.global.session.user.id = invalid then
        return
    end if
    session_user_settings_Save(key, value)
    registry_write(key, value, m.global.session.user.id)
end sub

sub unset_user_setting(key as string)
    if m.global.session.user.id = invalid then
        return
    end if
    session_user_settings_Delete(key)
    registry_delete(key, m.global.session.user.id)
end sub


function findConfigTreeKey(key as string, tree)
    for each item in tree
        if item.settingName <> invalid and item.settingName = key then
            return item
        end if
        if item.children <> invalid and item.children.Count() > 0
            result = findConfigTreeKey(key, item.children)
            if result <> invalid then
                return result
            end if
        end if
    end for
    return invalid
end function



function getSavedUsers() as object
    registrySections = getRegistrySections()
    savedUsers = []
    for each section in registrySections
        if LCase(section) <> "jellyfin"
            savedUsers.push(section)
        end if
    end for
    savedServerUsers = []
    for each userId in savedUsers
        userArray = {
            id: userId
        }
        token = registry_read("token", userId)
        username = registry_read("username", userId)
        if username <> invalid
            userArray["username"] = username
        end if
        serverId = registry_read("serverId", userId)
        if serverId <> invalid
            userArray["serverId"] = serverId
        end if
        if username <> invalid and token <> invalid and serverId <> invalid and serverId = m.global.session.server.id
            savedServerUsers.push(userArray)
        end if
    end for
    return savedServerUsers
end function