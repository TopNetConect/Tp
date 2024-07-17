





sub runGlobalMigrations()
    appLastRunVersion = m.global.app.lastRunVersion

    if isValid(appLastRunVersion) and not versionChecker(appLastRunVersion, "2.0.0")

        m.wasMigrated = true
        print ("Running " + rokucommunity_bslib_toString("2.0.0") + " global registry migrations")




        rememberMe = registry_read("global.rememberme", "Jellyfin")
        if not isValid(rememberMe)

            set_setting("global.rememberme", "true")
        end if

        savedUserId = get_setting("active_user")
        if isValid(savedUserId)
            savedUsername = get_setting("username")
            if isValid(savedUsername)
                registry_write("username", savedUsername, savedUserId)
            end if
            savedToken = get_setting("token")
            if isValid(savedToken)
                registry_write("token", savedToken, savedUserId)
            end if
        end if

        unset_setting("port")
        unset_setting("token")
        unset_setting("username")
        unset_setting("password")

        saved = get_setting("saved_servers")
        if isValid(saved)
            savedServers = ParseJson(saved)
            if isValid(savedServers.serverList) and savedServers.serverList.Count() > 0
                newServers = {
                    serverList: []
                }
                for each item in savedServers.serverList
                    item.Delete("username")
                    item.Delete("password")
                    newServers.serverList.Push(item)
                end for
                set_setting("saved_servers", FormatJson(newServers))
            end if
        end if
    end if
end sub

sub runRegistryUserMigrations()
    regSections = getRegistrySections()
    for each section in regSections
        if LCase(section) <> "jellyfin"
            reg = CreateObject("roRegistrySection", section)
            if reg.exists("LastRunVersion")
                hasUserVersion = true
                lastRunVersion = reg.read("LastRunVersion")
            else
                hasUserVersion = false


                lastRunVersion = m.global.app.lastRunVersion
                registry_write("LastRunVersion", lastRunVersion, section)
            end if

            if not versionChecker(lastRunVersion, "2.0.0")
                m.wasMigrated = true
                print ("Running Registry Migration for " + rokucommunity_bslib_toString("2.0.0") + " for userid: " + rokucommunity_bslib_toString(section))


                if not hasUserVersion
                    print "useWebSectionArrangement set to false"
                    registry_write("ui.home.useWebSectionArrangement", "false", section)
                end if

                registry_delete("password", section)

                registry_delete("playback.av1", section)
            end if
        end if
    end for
end sub