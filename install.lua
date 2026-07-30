-- OneOS Installer - Animated Progress Bar - smazzara0000-hue/OneOS

local mainTitle = 'OneOS Installer - YOUR REPO'
local subTitle = 'Fetching file list...'
local barText = ''

function Draw()
    term.setBackgroundColour(colours.white)
    term.clear()
    local w, h = term.getSize()
    term.setTextColour(colours.lightBlue)
    term.setCursorPos(math.ceil((w-#mainTitle)/2), 7)
    term.write(mainTitle)
    term.setTextColour(colours.blue)
    term.setCursorPos(math.ceil((w-#subTitle)/2), 9)
    term.write(subTitle)
    term.setTextColour(colours.black)
    term.setCursorPos(math.ceil((w-#barText)/2), 12)
    term.write(barText)
end

local owner = "smazzara0000-hue"
local repo = "OneOS"
local branch = "main"
local treeUrl = "https://api.github.com/repos/"..owner.."/"..repo.."/git/trees/"..branch.."?recursive=1"
local rawBase = "https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..branch.."/"

function downloadJson(url)
    local r = http.get(url)
    if not r then error("Failed: "..url) end
    local d = r.readAll() r.close()
    return textutils.unserialiseJSON(d)
end

Draw()
local treeData = downloadJson(treeUrl)
local total = 0
for _, v in ipairs(treeData.tree) do if v.type == "blob" then total = total + 1 end end

local done = 0
for _, v in ipairs(treeData.tree) do
    if v.type == "tree" then
        local p = v.path if p:sub(1,5)=="OneOS/" then p=p:sub(6) end
        if not fs.exists("/"..p) then fs.makeDir("/"..p) end
    else
        local savePath = v.path if savePath:sub(1,5)=="OneOS/" then savePath=savePath:sub(6) end
        if savePath ~= "install.lua" then
            done = done + 1
            local percent = math.floor(done/total*100)
            local width = 20
            local filled = math.floor(width * percent / 100)
            barText = "["..string.rep("#", filled)..string.rep(" ", width-filled).."] "..percent.."%"
            subTitle = savePath
            Draw()

            local rawUrl = rawBase .. v.path
            rawUrl = (rawUrl:gsub(" ", "%%20"))
            local f = http.get(rawUrl)
            if f then
                local data = f.readAll() f.close()
                local dir = fs.getDir("/"..savePath)
                if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
                local file = fs.open("/"..savePath, "w")
                file.write(data) file.close()
            end
        end
    end
end

local h = fs.open('/System/.version', 'w') h.write('v9.9.9') h.close()
mainTitle = 'Installation Complete!'
subTitle = 'Rebooting...'
barText = '[####################] 100%'
Draw()
sleep(1)
os.reboot()
