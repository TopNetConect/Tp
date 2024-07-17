




function getDeviceCapabilities() as object
    deviceProfile = {
        "PlayableMediaTypes": [
            "Audio"
            "Video"
            "Photo"
        ]
        "SupportedCommands": []
        "SupportsPersistentIdentifier": true
        "SupportsMediaControl": false
        "SupportsContentUploading": false
        "SupportsSync": false
        "DeviceProfile": getDeviceProfile()
        "AppStoreUrl": "https://channelstore.roku.com/details/cc5e559d08d9ec87c5f30dcebdeebc12/jellyfin"
    }
    printDeviceProfile(deviceProfile)
    return deviceProfile
end function

function getDeviceProfile() as object
    globalDevice = m.global.device
    return {
        "Name": "Official Roku Client"
        "Id": globalDevice.id
        "Identification": {
            "FriendlyName": globalDevice.friendlyName
            "ModelNumber": globalDevice.model
            "SerialNumber": "string"
            "ModelName": globalDevice.name
            "ModelDescription": "Type: " + globalDevice.modelType
            "Manufacturer": globalDevice.modelDetails.VendorName
        }
        "FriendlyName": globalDevice.friendlyName
        "Manufacturer": globalDevice.modelDetails.VendorName
        "ModelName": globalDevice.name
        "ModelDescription": "Type: " + globalDevice.modelType
        "ModelNumber": globalDevice.model
        "SerialNumber": globalDevice.serial
        "MaxStreamingBitrate": 120000000
        "MaxStaticBitrate": 100000000
        "MusicStreamingTranscodingBitrate": 192000
        "DirectPlayProfiles": GetDirectPlayProfiles()
        "TranscodingProfiles": getTranscodingProfiles()
        "ContainerProfiles": getContainerProfiles()
        "CodecProfiles": getCodecProfiles()
        "SubtitleProfiles": getSubtitleProfiles()
    }
end function

function GetDirectPlayProfiles() as object
    globalUserSettings = m.global.session.user.settings
    directPlayProfiles = []
    di = CreateObject("roDeviceInfo")

    supportedCodecs = {
        mp4: {
            audio: []
            video: []
        }
        hls: {
            audio: []
            video: []
        }
        mkv: {
            audio: []
            video: []
        }
        ism: {
            audio: []
            video: []
        }
        dash: {
            audio: []
            video: []
        }
        ts: {
            audio: []
            video: []
        }
    }

    videoCodecs = [
        "h264"
        "mpeg4 avc"
        "vp8"
        "vp9"
        "h263"
        "mpeg1"
    ]
    audioCodecs = [
        "mp3"
        "mp2"
        "pcm"
        "lpcm"
        "wav"
        "ac3"
        "ac4"
        "aiff"
        "wma"
        "flac"
        "alac"
        "aac"
        "opus"
        "dts"
        "wmapro"
        "vorbis"
        "eac3"
        "mpg123"
    ]

    if globalUserSettings["playback.compatibility.disablehevc"] = false
        videoCodecs.push("hevc")
    end if

    for each container in supportedCodecs
        for each videoCodec in videoCodecs
            if di.CanDecodeVideo({
                Codec: videoCodec
                Container: container
            }).Result
                if videoCodec = "hevc"
                    supportedCodecs[container]["video"].push("hevc")
                    supportedCodecs[container]["video"].push("h265")
                else

                    supportedCodecs[container]["video"].push(videoCodec)
                end if
            end if
        end for
    end for

    if globalUserSettings["playback.mpeg4"]
        for each container in supportedCodecs
            supportedCodecs[container]["video"].push("mpeg4")
        end for
    end if
    if globalUserSettings["playback.mpeg2"]
        for each container in supportedCodecs
            supportedCodecs[container]["video"].push("mpeg2video")
        end for
    end if


    if di.CanDecodeVideo({
        Codec: "av1"
    }).Result

        for each container in supportedCodecs
            supportedCodecs[container]["video"].push("av1")
        end for
    end if

    for each container in supportedCodecs
        for each audioCodec in audioCodecs
            if di.CanDecodeAudio({
                Codec: audioCodec
                Container: container
            }).Result
                supportedCodecs[container]["audio"].push(audioCodec)
            end if
        end for
    end for


    audioCodecs = [
        "aac"
        "mp3"
        "mp2"
        "pcm"
        "lpcm"
        "wav"
        "ac3"
        "ac4"
        "aiff"
        "wma"
        "flac"
        "alac"
        "aac"
        "dts"
        "wmapro"
        "vorbis"
        "eac3"
        "mpg123"
    ]

    supportedAudio = []
    for each audioCodec in audioCodecs
        if di.CanDecodeAudio({
            Codec: audioCodec
        }).Result
            supportedAudio.push(audioCodec)
        end if
    end for

    for each container in supportedCodecs
        videoCodecString = supportedCodecs[container]["video"].Join(",")
        if videoCodecString <> ""
            containerString = container
            if container = "mp4"
                containerString = "mp4,mov,m4v"
            else if container = "mkv"
                containerString = "mkv,webm"
            end if
            directPlayProfiles.push({
                "Container": containerString
                "Type": "Video"
                "VideoCodec": videoCodecString
                "AudioCodec": supportedCodecs[container]["audio"].Join(",")
            })
        end if
    end for
    directPlayProfiles.push({
        "Container": supportedAudio.Join(",")
        "Type": "Audio"
    })
    return directPlayProfiles
end function

function getTranscodingProfiles() as object
    globalUserSettings = m.global.session.user.settings
    transcodingProfiles = []
    di = CreateObject("roDeviceInfo")
    transcodingContainers = [
        "mp4"
        "ts"
    ]

    mp4AudioCodecs = "aac"
    mp4VideoCodecs = "h264"
    tsAudioCodecs = "aac"
    tsVideoCodecs = "h264"

    maxAudioChannels = "2" ' jellyfin expects this as a string

    audioCodecs = [
        "mp3"
        "vorbis"
        "opus"
        "flac"
        "alac"
        "ac4"
        "pcm"
        "wma"
        "wmapro"
    ]
    surroundSoundCodecs = [
        "eac3"
        "ac3"
        "dts"
    ]
    if globalUserSettings["playback.forceDTS"] = true
        surroundSoundCodecs = [
            "dts"
            "eac3"
            "ac3"
        ]
    end if
    surroundSoundCodec = invalid
    if di.GetAudioOutputChannel() = "5.1 surround"
        maxAudioChannels = "6"
        for each codec in surroundSoundCodecs
            if di.CanDecodeAudio({
                Codec: codec
                ChCnt: 6
            }).Result
                surroundSoundCodec = codec
                if di.CanDecodeAudio({
                    Codec: codec
                    ChCnt: 8
                }).Result
                    maxAudioChannels = "8"
                end if
                exit for
            end if
        end for
    end if



    for each container in transcodingContainers
        if di.CanDecodeVideo({
            Codec: "h264"
            Container: container
        }).Result
            if container = "mp4"

                if mp4VideoCodecs.Instr(0, ",h264") = -1
                    mp4VideoCodecs = mp4VideoCodecs + ",h264"
                end if
            else if container = "ts"

                if tsVideoCodecs.Instr(0, ",h264") = -1
                    tsVideoCodecs = tsVideoCodecs + ",h264"
                end if
            end if
        end if
        if di.CanDecodeVideo({
            Codec: "mpeg4 avc"
            Container: container
        }).Result
            if container = "mp4"

                if mp4VideoCodecs.Instr(0, ",mpeg4 avc") = -1
                    mp4VideoCodecs = mp4VideoCodecs + ",mpeg4 avc"
                end if
            else if container = "ts"

                if tsVideoCodecs.Instr(0, ",mpeg4 avc") = -1
                    tsVideoCodecs = tsVideoCodecs + ",mpeg4 avc"
                end if
            end if
        end if
    end for

    if globalUserSettings["playback.compatibility.disablehevc"] = false
        for each container in transcodingContainers
            if di.CanDecodeVideo({
                Codec: "hevc"
                Container: container
            }).Result
                if container = "mp4"

                    if mp4VideoCodecs.Instr(0, "h265,") = -1
                        mp4VideoCodecs = "h265," + mp4VideoCodecs
                    end if
                    if mp4VideoCodecs.Instr(0, "hevc,") = -1
                        mp4VideoCodecs = "hevc," + mp4VideoCodecs
                    end if
                else if container = "ts"

                    if tsVideoCodecs.Instr(0, "h265,") = -1
                        tsVideoCodecs = "h265," + tsVideoCodecs
                    end if
                    if tsVideoCodecs.Instr(0, "hevc,") = -1
                        tsVideoCodecs = "hevc," + tsVideoCodecs
                    end if
                end if
            end if
        end for
    end if

    for each container in transcodingContainers
        if di.CanDecodeAudio({
            Codec: "vp9"
            Container: container
        }).Result
            if container = "mp4"

                if mp4VideoCodecs.Instr(0, ",vp9") = -1
                    mp4VideoCodecs = mp4VideoCodecs + ",vp9"
                end if
            else if container = "ts"

                if tsVideoCodecs.Instr(0, ",vp9") = -1
                    tsVideoCodecs = tsVideoCodecs + ",vp9"
                end if
            end if
        end if
    end for

    if globalUserSettings["playback.mpeg2"]
        for each container in transcodingContainers
            if di.CanDecodeVideo({
                Codec: "mpeg2"
                Container: container
            }).Result
                if container = "mp4"

                    if mp4VideoCodecs.Instr(0, ",mpeg2video") = -1
                        mp4VideoCodecs = mp4VideoCodecs + ",mpeg2video"
                    end if
                else if container = "ts"

                    if tsVideoCodecs.Instr(0, ",mpeg2video") = -1
                        tsVideoCodecs = tsVideoCodecs + ",mpeg2video"
                    end if
                end if
            end if
        end for
    end if

    for each container in transcodingContainers
        if di.CanDecodeVideo({
            Codec: "av1"
            Container: container
        }).Result
            if container = "mp4"

                if mp4VideoCodecs.Instr(0, ",av1") = -1
                    mp4VideoCodecs = mp4VideoCodecs + ",av1"
                end if
            else if container = "ts"

                if tsVideoCodecs.Instr(0, ",av1") = -1
                    tsVideoCodecs = tsVideoCodecs + ",av1"
                end if
            end if
        end if
    end for

    for each container in transcodingContainers
        for each codec in audioCodecs
            if di.CanDecodeAudio({
                Codec: codec
                Container: container
            }).result
                if container = "mp4"
                    mp4AudioCodecs = mp4AudioCodecs + "," + codec
                else if container = "ts"
                    tsAudioCodecs = tsAudioCodecs + "," + codec
                end if
            end if
        end for
    end for


    transcodingProfiles.push({
        "Container": "aac"
        "Type": "Audio"
        "AudioCodec": "aac"
        "Context": "Streaming"
        "Protocol": "http"
        "MaxAudioChannels": "2"
    })
    transcodingProfiles.push({
        "Container": "aac"
        "Type": "Audio"
        "AudioCodec": "aac"
        "Context": "Static"
        "Protocol": "http"
        "MaxAudioChannels": "2"
    })

    transcodingProfiles.push({
        "Container": "mp3"
        "Type": "Audio"
        "AudioCodec": "mp3"
        "Context": "Streaming"
        "Protocol": "http"
        "MaxAudioChannels": maxAudioChannels
    })
    transcodingProfiles.push({
        "Container": "mp3"
        "Type": "Audio"
        "AudioCodec": "mp3"
        "Context": "Static"
        "Protocol": "http"
        "MaxAudioChannels": maxAudioChannels
    })
    tsArray = {
        "Container": "ts"
        "Context": "Streaming"
        "Protocol": "hls"
        "Type": "Video"
        "AudioCodec": tsAudioCodecs
        "VideoCodec": tsVideoCodecs
        "MaxAudioChannels": maxAudioChannels
        "MinSegments": 1
        "BreakOnNonKeyFrames": false
    }
    mp4Array = {
        "Container": "mp4"
        "Context": "Streaming"
        "Protocol": "hls"
        "Type": "Video"
        "AudioCodec": mp4AudioCodecs
        "VideoCodec": mp4VideoCodecs
        "MaxAudioChannels": maxAudioChannels
        "MinSegments": 1
        "BreakOnNonKeyFrames": false
    }

    if globalUserSettings["playback.resolution.max"] <> "off"
        tsArray.Conditions = [
            getMaxHeightArray()
            getMaxWidthArray()
        ]
        mp4Array.Conditions = [
            getMaxHeightArray()
            getMaxWidthArray()
        ]
    end if

    if surroundSoundCodec <> invalid

        transcodingProfiles.push({
            "Container": surroundSoundCodec
            "Type": "Audio"
            "AudioCodec": surroundSoundCodec
            "Context": "Streaming"
            "Protocol": "http"
            "MaxAudioChannels": maxAudioChannels
        })
        transcodingProfiles.push({
            "Container": surroundSoundCodec
            "Type": "Audio"
            "AudioCodec": surroundSoundCodec
            "Context": "Static"
            "Protocol": "http"
            "MaxAudioChannels": maxAudioChannels
        })

        if tsArray.AudioCodec = ""
            tsArray.AudioCodec = surroundSoundCodec
        else
            tsArray.AudioCodec = surroundSoundCodec + "," + tsArray.AudioCodec
        end if
        if mp4Array.AudioCodec = ""
            mp4Array.AudioCodec = surroundSoundCodec
        else
            mp4Array.AudioCodec = surroundSoundCodec + "," + mp4Array.AudioCodec
        end if
    end if
    transcodingProfiles.push(tsArray)
    transcodingProfiles.push(mp4Array)
    return transcodingProfiles
end function

function getContainerProfiles() as object
    containerProfiles = []
    return containerProfiles
end function

function getCodecProfiles() as object
    globalUserSettings = m.global.session.user.settings
    codecProfiles = []
    profileSupport = {
        "h264": {}
        "mpeg4 avc": {}
        "h265": {}
        "hevc": {}
        "vp9": {}
        "mpeg2": {}
        "av1": {}
    }
    maxResSetting = globalUserSettings["playback.resolution.max"]
    di = CreateObject("roDeviceInfo")
    maxHeightArray = getMaxHeightArray()
    maxWidthArray = getMaxWidthArray()


    audioCodecs = [
        "aac"
        "mp3"
        "mp2"
        "opus"
        "pcm"
        "lpcm"
        "wav"
        "flac"
        "alac"
        "ac3"
        "ac4"
        "aiff"
        "dts"
        "wmapro"
        "vorbis"
        "eac3"
        "mpg123"
    ]
    audioChannels = [
        8
        6
        2
    ] ' highest first
    for each audioCodec in audioCodecs
        for each audioChannel in audioChannels
            channelSupportFound = false
            if di.CanDecodeAudio({
                Codec: audioCodec
                ChCnt: audioChannel
            }).Result
                channelSupportFound = true
                for each codecType in [
                    "VideoAudio"
                    "Audio"
                ]
                    if audioCodec = "opus" and codecType = "Audio"

                    else
                        codecProfiles.push({
                            "Type": codecType
                            "Codec": audioCodec
                            "Conditions": [
                                {
                                    "Condition": "LessThanEqual"
                                    "Property": "AudioChannels"
                                    "Value": audioChannel
                                    "IsRequired": true
                                }
                            ]
                        })
                    end if
                end for
            end if
            if channelSupportFound


                exit for
            end if
        end for
    end for


    h264Profiles = [
        "main"
        "high"
    ]
    h264Levels = [
        "4.1"
        "4.2"
    ]
    for each profile in h264Profiles
        for each level in h264Levels
            if di.CanDecodeVideo({
                Codec: "h264"
                Profile: profile
                Level: level
            }).Result
                profileSupport = updateProfileArray(profileSupport, "h264", profile, level)
            end if
            if di.CanDecodeVideo({
                Codec: "mpeg4 avc"
                Profile: profile
                Level: level
            }).Result
                profileSupport = updateProfileArray(profileSupport, "mpeg4 avc", profile, level)
            end if
        end for
    end for

    hevcProfiles = [
        "main"
        "main 10"
    ]
    hevcLevels = [
        "4.1"
        "5.0"
        "5.1"
    ]
    for each profile in hevcProfiles
        for each level in hevcLevels
            if di.CanDecodeVideo({
                Codec: "hevc"
                Profile: profile
                Level: level
            }).Result
                profileSupport = updateProfileArray(profileSupport, "h265", profile, level)
                profileSupport = updateProfileArray(profileSupport, "hevc", profile, level)
            end if
        end for
    end for

    vp9Profiles = [
        "profile 0"
        "profile 2"
    ]
    vp9Levels = [
        "4.1"
        "5.0"
        "5.1"
    ]
    for each profile in vp9Profiles
        for each level in vp9Levels
            if di.CanDecodeVideo({
                Codec: "vp9"
                Profile: profile
                Level: level
            }).Result
                profileSupport = updateProfileArray(profileSupport, "vp9", profile, level)
            end if
        end for
    end for



    mpeg2Levels = [
        "main"
        "high"
    ]
    for each level in mpeg2Levels
        if di.CanDecodeVideo({
            Codec: "mpeg2"
            Level: level
        }).Result
            profileSupport = updateProfileArray(profileSupport, "mpeg2", level)
        end if
    end for

    av1Profiles = [
        "main"
        "main 10"
    ]
    av1Levels = [
        "4.1"
        "5.0"
        "5.1"
    ]
    for each profile in av1Profiles
        for each level in av1Levels
            if di.CanDecodeVideo({
                Codec: "av1"
                Profile: profile
                Level: level
            }).Result
                profileSupport = updateProfileArray(profileSupport, "av1", profile, level)
            end if
        end for
    end for

    h264VideoRangeTypes = "SDR"
    hevcVideoRangeTypes = "SDR"
    vp9VideoRangeTypes = "SDR"
    av1VideoRangeTypes = "SDR"
    dp = di.GetDisplayProperties()
    if dp.Hdr10
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HDR10"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HDR10"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HDR10"
    end if
    if dp.Hdr10Plus
        av1VideoRangeTypes = av1VideoRangeTypes + "|HDR10+"
    end if
    if dp.HLG
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|HLG"
        vp9VideoRangeTypes = vp9VideoRangeTypes + "|HLG"
        av1VideoRangeTypes = av1VideoRangeTypes + "|HLG"
    end if
    if dp.DolbyVision
        h264VideoRangeTypes = h264VideoRangeTypes + "|DOVI"
        hevcVideoRangeTypes = hevcVideoRangeTypes + "|DOVI"

        av1VideoRangeTypes = av1VideoRangeTypes + "|DOVI"
    end if

    h264LevelSupported = 0.0
    h264AssProfiles = {}
    for each profile in profileSupport["h264"]
        h264AssProfiles.AddReplace(profile, true)
        for each level in profileSupport["h264"][profile]
            levelFloat = level.ToFloat()
            if levelFloat > h264LevelSupported
                h264LevelSupported = levelFloat
            end if
        end for
    end for

    h264LevelString = h264LevelSupported.ToStr()

    h264LevelString = removeDecimals(h264LevelString)
    h264ProfileArray = {
        "Type": "Video"
        "Codec": "h264"
        "Conditions": [
            {
                "Condition": "NotEquals"
                "Property": "IsAnamorphic"
                "Value": "true"
                "IsRequired": false
            }
            {
                "Condition": "LessThanEqual"
                "Property": "VideoBitDepth"
                "Value": "8"
                "IsRequired": false
            }
            {
                "Condition": "EqualsAny"
                "Property": "VideoProfile"
                "Value": h264AssProfiles.Keys().join("|")
                "IsRequired": false
            }
            {
                "Condition": "EqualsAny"
                "Property": "VideoRangeType"
                "Value": h264VideoRangeTypes
                "IsRequired": false
            }
        ]
    }

    if not globalUserSettings["playback.tryDirect.h264ProfileLevel"]
        h264ProfileArray.Conditions.push({
            "Condition": "LessThanEqual"
            "Property": "VideoLevel"
            "Value": h264LevelString
            "IsRequired": false
        })
    end if

    if globalUserSettings["playback.resolution.mode"] = "everything" and maxResSetting <> "off"
        h264ProfileArray.Conditions.push(maxHeightArray)
        h264ProfileArray.Conditions.push(maxWidthArray)
    end if

    bitRateArray = GetBitRateLimit("h264")
    if bitRateArray.count() > 0
        h264ProfileArray.Conditions.push(bitRateArray)
    end if
    codecProfiles.push(h264ProfileArray)


    if globalUserSettings["playback.mpeg2"]
        mpeg2Levels = []
        for each level in profileSupport["mpeg2"]
            if not arrayHasValue(mpeg2Levels, level)
                mpeg2Levels.push(level)
            end if
        end for
        mpeg2ProfileArray = {
            "Type": "Video"
            "Codec": "mpeg2"
            "Conditions": [
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoLevel"
                    "Value": mpeg2Levels.join("|")
                    "IsRequired": false
                }
            ]
        }

        if globalUserSettings["playback.resolution.mode"] = "everything" and maxResSetting <> "off"
            mpeg2ProfileArray.Conditions.push(maxHeightArray)
            mpeg2ProfileArray.Conditions.push(maxWidthArray)
        end if

        bitRateArray = GetBitRateLimit("mpeg2")
        if bitRateArray.count() > 0
            mpeg2ProfileArray.Conditions.push(bitRateArray)
        end if
        codecProfiles.push(mpeg2ProfileArray)
    end if
    if di.CanDecodeVideo({
        Codec: "av1"
    }).Result
        av1LevelSupported = 0.0
        av1AssProfiles = {}
        for each profile in profileSupport["av1"]
            av1AssProfiles.AddReplace(profile, true)
            for each level in profileSupport["av1"][profile]
                levelFloat = level.ToFloat()
                if levelFloat > av1LevelSupported
                    av1LevelSupported = levelFloat
                end if
            end for
        end for
        av1ProfileArray = {
            "Type": "Video"
            "Codec": "av1"
            "Conditions": [
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoProfile"
                    "Value": av1AssProfiles.Keys().join("|")
                    "IsRequired": false
                }
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoRangeType"
                    "Value": av1VideoRangeTypes
                    "IsRequired": false
                }
                {
                    "Condition": "LessThanEqual"
                    "Property": "VideoLevel"
                    "Value": (120 * av1LevelSupported).ToStr()
                    "IsRequired": false
                }
            ]
        }

        if globalUserSettings["playback.resolution.mode"] = "everything" and maxResSetting <> "off"
            av1ProfileArray.Conditions.push(maxHeightArray)
            av1ProfileArray.Conditions.push(maxWidthArray)
        end if

        bitRateArray = GetBitRateLimit("av1")
        if bitRateArray.count() > 0
            av1ProfileArray.Conditions.push(bitRateArray)
        end if
        codecProfiles.push(av1ProfileArray)
    end if
    if not globalUserSettings["playback.compatibility.disablehevc"] and di.CanDecodeVideo({
        Codec: "hevc"
    }).Result
        hevcLevelSupported = 0.0
        hevcAssProfiles = {}
        for each profile in profileSupport["hevc"]
            hevcAssProfiles.AddReplace(profile, true)
            for each level in profileSupport["hevc"][profile]
                levelFloat = level.ToFloat()
                if levelFloat > hevcLevelSupported
                    hevcLevelSupported = levelFloat
                end if
            end for
        end for
        hevcLevelString = "120"
        if hevcLevelSupported = 5.1
            hevcLevelString = "153"
        end if
        hevcProfileArray = {
            "Type": "Video"
            "Codec": "hevc"
            "Conditions": [
                {
                    "Condition": "NotEquals"
                    "Property": "IsAnamorphic"
                    "Value": "true"
                    "IsRequired": false
                }
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoProfile"
                    "Value": profileSupport["hevc"].Keys().join("|")
                    "IsRequired": false
                }
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoRangeType"
                    "Value": hevcVideoRangeTypes
                    "IsRequired": false
                }
            ]
        }

        if not globalUserSettings["playback.tryDirect.hevcProfileLevel"]
            hevcProfileArray.Conditions.push({
                "Condition": "LessThanEqual"
                "Property": "VideoLevel"
                "Value": hevcLevelString
                "IsRequired": false
            })
        end if

        if globalUserSettings["playback.resolution.mode"] = "everything" and maxResSetting <> "off"
            hevcProfileArray.Conditions.push(maxHeightArray)
            hevcProfileArray.Conditions.push(maxWidthArray)
        end if

        bitRateArray = GetBitRateLimit("h265")
        if bitRateArray.count() > 0
            hevcProfileArray.Conditions.push(bitRateArray)
        end if
        codecProfiles.push(hevcProfileArray)
    end if
    if di.CanDecodeVideo({
        Codec: "vp9"
    }).Result
        vp9Profiles = []
        vp9LevelSupported = 0.0
        for each profile in profileSupport["vp9"]
            vp9Profiles.push(profile)
            for each level in profileSupport["vp9"][profile]
                levelFloat = level.ToFloat()
                if levelFloat > vp9LevelSupported
                    vp9LevelSupported = levelFloat
                end if
            end for
        end for
        vp9LevelString = "120"
        if vp9LevelSupported = 5.1
            vp9LevelString = "153"
        end if
        vp9ProfileArray = {
            "Type": "Video"
            "Codec": "vp9"
            "Conditions": [
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoProfile"
                    "Value": vp9Profiles.join("|")
                    "IsRequired": false
                }
                {
                    "Condition": "EqualsAny"
                    "Property": "VideoRangeType"
                    "Value": vp9VideoRangeTypes
                    "IsRequired": false
                }
                {
                    "Condition": "LessThanEqual"
                    "Property": "VideoLevel"
                    "Value": vp9LevelString
                    "IsRequired": false
                }
            ]
        }

        if globalUserSettings["playback.resolution.mode"] = "everything" and maxResSetting <> "off"
            vp9ProfileArray.Conditions.push(maxHeightArray)
            vp9ProfileArray.Conditions.push(maxWidthArray)
        end if

        bitRateArray = GetBitRateLimit("vp9")
        if bitRateArray.count() > 0
            vp9ProfileArray.Conditions.push(bitRateArray)
        end if
        codecProfiles.push(vp9ProfileArray)
    end if
    return codecProfiles
end function

function getSubtitleProfiles() as object
    subtitleProfiles = []
    subtitleProfiles.push({
        "Format": "vtt"
        "Method": "External"
    })
    subtitleProfiles.push({
        "Format": "srt"
        "Method": "External"
    })
    subtitleProfiles.push({
        "Format": "ttml"
        "Method": "External"
    })
    subtitleProfiles.push({
        "Format": "sub"
        "Method": "External"
    })
    return subtitleProfiles
end function

function GetBitRateLimit(codec as string) as object
    globalUserSettings = m.global.session.user.settings
    if globalUserSettings["playback.bitrate.maxlimited"]
        userSetLimit = globalUserSettings["playback.bitrate.limit"].ToInt()
        if isValid(userSetLimit) and type(userSetLimit) = "Integer" and userSetLimit > 0
            userSetLimit *= 1000000
            return {
                "Condition": "LessThanEqual"
                "Property": "VideoBitrate"
                "Value": userSetLimit.ToStr()
                "IsRequired": true
            }
        else
            codec = Lcase(codec)


            if codec = "h264"

                return {
                    "Condition": "LessThanEqual"
                    "Property": "VideoBitrate"
                    "Value": "10000000"
                    "IsRequired": true
                }
            else if codec = "av1"

                return {
                    "Condition": "LessThanEqual"
                    "Property": "VideoBitrate"
                    "Value": "40000000"
                    "IsRequired": true
                }
            else if codec = "h265"

                return {
                    "Condition": "LessThanEqual"
                    "Property": "VideoBitrate"
                    "Value": "40000000"
                    "IsRequired": true
                }
            else if codec = "vp9"

                return {
                    "Condition": "LessThanEqual"
                    "Property": "VideoBitrate"
                    "Value": "40000000"
                    "IsRequired": true
                }
            end if
        end if
    end if
    return {}
end function

function getMaxHeightArray() as object
    myGlobal = m.global
    maxResSetting = myGlobal.session.user.settings["playback.resolution.max"]
    if maxResSetting = "off" then
        return {}
    end if
    maxVideoHeight = maxResSetting
    if maxResSetting = "auto"
        maxVideoHeight = myGlobal.device.videoHeight
    end if
    return {
        "Condition": "LessThanEqual"
        "Property": "Height"
        "Value": maxVideoHeight
        "IsRequired": true
    }
end function

function getMaxWidthArray() as object
    myGlobal = m.global
    maxResSetting = myGlobal.session.user.settings["playback.resolution.max"]
    if maxResSetting = "off" then
        return {}
    end if
    maxVideoWidth = invalid
    if maxResSetting = "auto"
        maxVideoWidth = myGlobal.device.videoWidth
    else if maxResSetting = "360"
        maxVideoWidth = "480"
    else if maxResSetting = "480"
        maxVideoWidth = "640"
    else if maxResSetting = "720"
        maxVideoWidth = "1280"
    else if maxResSetting = "1080"
        maxVideoWidth = "1920"
    else if maxResSetting = "2160"
        maxVideoWidth = "3840"
    else if maxResSetting = "4320"
        maxVideoWidth = "7680"
    end if
    return {
        "Condition": "LessThanEqual"
        "Property": "Width"
        "Value": maxVideoWidth
        "IsRequired": true
    }
end function


function updateProfileArray(profileArray as object, videoCodec as string, videoProfile as string, profileLevel = "" as string) as object

    if profileArray = invalid then
        return {}
    end if
    if videoCodec = "" or videoProfile = "" then
        return profileArray
    end if
    if profileArray[videoCodec] = invalid
        profileArray[videoCodec] = {}
    end if
    if profileArray[videoCodec][videoProfile] = invalid
        profileArray[videoCodec][videoProfile] = {}
    end if

    if profileLevel <> ""
        if profileArray[videoCodec][videoProfile][profileLevel] = invalid
            profileArray[videoCodec][videoProfile].AddReplace(profileLevel, true)
        end if
    end if
    return profileArray
end function


function removeDecimals(value as string) as string
    r = CreateObject("roRegex", "\.", "")
    value = r.ReplaceAll(value, "")
    return value
end function


sub printDeviceProfile(profile as object)
    print "profile =", profile
    print "profile.DeviceProfile =", profile.DeviceProfile
    print "profile.DeviceProfile.CodecProfiles ="
    for each prof in profile.DeviceProfile.CodecProfiles
        print prof
        for each cond in prof.Conditions
            print cond
        end for
    end for
    print "profile.DeviceProfile.ContainerProfiles =", profile.DeviceProfile.ContainerProfiles
    print "profile.DeviceProfile.DirectPlayProfiles ="
    for each prof in profile.DeviceProfile.DirectPlayProfiles
        print prof
    end for
    print "profile.DeviceProfile.SubtitleProfiles ="
    for each prof in profile.DeviceProfile.SubtitleProfiles
        print prof
    end for
    print "profile.DeviceProfile.TranscodingProfiles ="
    for each prof in profile.DeviceProfile.TranscodingProfiles
        print prof
        if isValid(prof.Conditions)
            for each condition in prof.Conditions
                print condition
            end for
        end if
    end for
    print "profile.PlayableMediaTypes =", profile.PlayableMediaTypes
    print "profile.SupportedCommands =", profile.SupportedCommands
end sub



function setPreferredCodec(codecString as string, preferredCodec as string) as string
    if preferredCodec = "" then
        return ""
    end if
    if codecString = "" then
        return preferredCodec
    end if
    preferredCodecSize = Len(preferredCodec)

    if Left(codecString, preferredCodecSize) = preferredCodec
        return codecString
    else

        codecArray = codecString.Split(",")

        newArray = []
        for each codec in codecArray
            if codec <> preferredCodec
                newArray.push(codec)
            end if
        end for

        newCodecString = newArray.Join(",")

        newCodecString = preferredCodec + "," + newCodecString
        return newCodecString
    end if
end function