-- OneOS Installer FINAL FIX - no loop
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
  local r=http.get(rawBase..gp:gsub(" ","%%20"))
  if not r then return false end
  local d=r.readAll() r.close()
  local dir=fs.getDir(lp)
  if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(lp,"w") f.write(d) f.close()
  return true
end

local function dlDir(gp)
  local data=get(apiBase..gp.."?ref="..branch)
  if not data then return end
  local files=textutils.unserialiseJSON(data)
  if not files then return end
  for _,file in ipairs(files) do
    if file.type=="file" then
      if file.name~="install.lua" then dl(file.path,file.path) end
    elseif file.type=="dir" then
      dlDir(file.path)
    end
  end
end

print("Installing OneOS...")
dlDir("")
-- FORZA file critici che l'API salta
dl(".version",".version")
dl("System/.version","System/.version")
dl("System/.hash","System/.hash")
dl("startup","startup")

-- FIX LOOP: forza isDebug true nello startup scaricato
if fs.exists("startup") then
  local f=fs.open("startup","r")
  local s=f.readAll() f.close()
  s=s:gsub("isDebug%s*=%s*false","isDebug = true")
  local out=fs.open("startup","w") out.write(s) out.close()
end

print("OneOS installed!")
sleep(1)
os.reboot()
