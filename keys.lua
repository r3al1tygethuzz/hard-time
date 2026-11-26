local keys = {
    -- Account-specific key (only works for this UserId)
    ["12058832059"] = {
        key = "67",
        expires = 0
    },
}

local globalKeys = {
    -- Universal key (works on ANY account)
    ["westly"] = {
        expires = 0
    },
    ["sonned"] = {
        expires = 2
    },
}

return {
    users = keys,
    global = globalKeys
}
