-- OneOS Installer FIX System/API
local owner = "smazzara0000-hue"
local repo = "OneOS"
local branch = "main"
local rawBase = "https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..branch.."/"
local apiBase = "https://api.github.com/repos/"..owner.."/"..repo.."/contents/"

local function get(u)
  local r=http.get(u)
  if not r then return nil end
  local d=r.readAll() r.close() return d
end

local function dl(gp, lp)
  print("Downloading "..gp)
  local r=http.get(rawBase..gp:gsub(" ","%%20"))
  if not r then print("FAIL "..gp) return false end
  local d=r.readAll() r.close()
  local dir=fs.getDir(lp)
  if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(lp,"w") f.write(d) f.close()
  return true
end

local function dlDir(gp)
  local url
  if gp == "" then
    url = "https://api.github.com/repos/"..owner.."/"..repo.."/contents?ref="..branch
  else
    url = apiBase..gp.."?ref="..branch
  end
  local data=get(url)
  if not data then print("API FAIL "..gp) return end
  local files=textutils.unserialiseJSON(data)
  if not files then return end
  for _,file in ipairs(files) do
    if file.type=="file" then
      if file.name~="install.lua" then dl(file.path,file.path) end
    else
      dlDir(file.path)
    end
  end
end

print("Installing OneOS...")
dlDir("")
-- forza i file nascosti che l'API salta
dl(".version",".version")
dl("System/.version","System/.version")
dl("System/.hash","System/.hash")
dl("startup","startup")

print("OneOS installed!")
sleep(1)
os.reboot()
