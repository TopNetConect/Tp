function ItemImages(id = "" as string, params = {} as object)


    resp = APIRequest(Substitute("Items/{0}/Images", id))
    data = getJson(resp)
    if data = invalid then
        return invalid
    end if
    results = []
    for each item in data
        tmp = CreateObject("roSGNode", "ImageData")
        tmp.json = item
        tmp.url = ImageURL(id, tmp.imagetype, params)
        results.push(tmp)
    end for
    return results
end function

function PosterImage(id as string, params = {} as object)
    images = ItemImages(id, params)
    if images = invalid then
        return invalid
    end if
    primary_image = invalid
    for each image in images
        if image.imagetype = "Primary"
            primary_image = image
        else if image.imagetype = "Logo" and primary_image = invalid
            primary_image = image
        else if image.imagetype = "Thumb" and primary_image = invalid
            primary_image = image

        end if
    end for
    return primary_image
end function

function ImageURL(id, version = "Primary", params = {})

    if params.maxHeight = invalid
        param = {
            "maxHeight": "384"
        }
        params.append(param)
    end if
    if params.maxWidth = invalid
        param = {
            "maxWidth": "196"
        }
        params.append(param)
    end if
    if params.quality = invalid
        param = {
            "quality": "90"
        }
        params.append(param)
    end if
    url = Substitute("Items/{0}/Images/{1}", id, version)

    return buildURL(url, params)
end function

function UserImageURL(id, params = {})

    if params.maxHeight = invalid
        params.append({
            "maxHeight": "300"
        })
    end if
    if params.maxWidth = invalid
        params.append({
            "maxWidth": "300"
        })
    end if
    if params.quality = invalid
        params.append({
            "quality": "90"
        })
    end if
    url = Substitute("Users/{0}/Images/Primary", id)
    return buildURL(url, params)
end function