-- OneOS Installer - smazzara0000-hue/OneOS
local owner = "smazzara0000-hue"
local repo = "OneOS"
local branch = "main"
local rawBase = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(owner, repo, branch)
local apiBase = ("https://api.github.com/repos/%s/%s/contents/"):format(owner, repo)

local function get(url)
    local res = http.get(url)
    if not res then return nil end
    local data = res.readAll()
    res.close()
    return data
end

local function safeDownload(gitPath, localPath)
    local url = rawBase .. gitPath:gsub(" ", "%%20")
    print("Downloading " .. gitPath)
    local res = http.get(url)
    if not res then print("Skip: " .. gitPath) return false end
    local content = res.readAll()
    res.close()
    local dir = fs.getDir(localPath)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
    local f = fs.open(localPath, "w")
    f.write(content)
    f.close()
    return true
end

local function downloadDir(gitPath)
    local data = get(apiBase .. gitPath .. "?ref=" .. branch)
    if not data then return end
    local files = textutils.unserialiseJSON(data)
    if not files then return end
    for _, file in ipairs(files) do
        if file.type == "file" then
            if file.name ~= "install.lua" then safeDownload(file.path, file.path) end
        elseif file.type == "dir" then
            downloadDir(file.path)
        end
    end
end

print("Installing OneOS...")
downloadDir("")
print("OneOS installed! Reboot with 'reboot'")
