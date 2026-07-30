-- OneOS Installer - Fixed for smazzara0000-hue/OneOS
-- Downloads directly from your GitHub repo (main branch)
-- No Pastebin dependency

if not term.isColor or not term.isColor() then
    error("OneOS requires an Advanced Computer")
end

if not http then
    error("HTTP must be enabled")
end

local owner = "smazzara0000-hue"
local repo = "OneOS"
local branch = "main"

local rawBase = "https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..branch.."/"
local treeUrl = "https://api.github.com/repos/"..owner.."/"..repo.."/git/trees/"..branch.."?recursive=1"

local blacklist = {
    [".gitignore"] = true,
    ["README.md"] = true,
    ["TODO"] = true,
    ["install.lua"] = true,
}

local function downloadJson(url)
    local res = http.get(url)
    if not res then error("Failed to fetch: "..url) end
    local data = res.readAll()
    res.close()
    return textutils.unserialiseJSON(data)
end

local function downloadFile(path)
    -- Fix double OneOS/ folder if present in repo
    local savePath = path
    if savePath:sub(1,5) == "OneOS/" then
        savePath = savePath:sub(6)
    end

    if blacklist[savePath] or blacklist[path] then
        return
    end

    print("Downloading "..savePath)
    local rawUrl = rawBase.. path
    rawUrl = rawUrl:gsub(" ", "%%20") -- fixed: assign first, no second arg to http.get

    local res = http.get(rawUrl)
    if not res then
        print(" FAILED: "..path)
        return
    end
    local content = res.readAll()
    res.close()

    local dir = fs.getDir("/"..savePath)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end

    local file = fs.open("/"..savePath, "w")
    file.write(content)
    file.close()
end

term.setBackgroundColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("OneOS Installer - YOUR REPO")
print("Fetching file list from "..branch.."...")
local treeData = downloadJson(treeUrl)

if not treeData or not treeData.tree then
    error("Could not get file tree, check repo exists and is public")
end

-- First create all folders
for _, v in ipairs(treeData.tree) do
    if v.type == "tree" then
        local p = v.path
        if p:sub(1,5) == "OneOS/" then p = p:sub(6) end
        if not fs.exists("/"..p) then fs.makeDir("/"..p) end
    end
end

-- Then download all files
for _, v in ipairs(treeData.tree) do
    if v.type == "blob" then
        downloadFile(v.path)
    end
end

-- Create version file required by OneOS
local vf = fs.open("/System/.version","w")
vf.write("v1.1.1")
vf.close()

print("Installation Complete! Rebooting...")
sleep(1)
os.reboot()
