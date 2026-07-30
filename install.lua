tArgs = {...}
if not term.isColor or not term.isColor() then
    error('OneOS Requires an Advanced Computer')
end

_jstr = [[
    local base = _G
    local decode_scanArray
    local decode_scanComment
    local decode_scanConstant
    local decode_scanNumber
    local decode_scanObject
    local decode_scanString
    local decode_scanWhitespace
    local encodeString
    local isArray
    local isEncodable
    function encode (v)
      if v==nil then return "null" end
      local vtype = base.type(v)
      if vtype=='string' then return '"'.. encodeString(v).. '"' end
      if vtype=='number' or vtype=='boolean' then return base.tostring(v) end
      if vtype=='table' then
        local rval = {}
        local bArray, maxCount = isArray(v)
        if bArray then for i = 1,maxCount do table.insert(rval, encode(v[i])) end
        else for i,j in base.pairs(v) do if isEncodable(i) and isEncodable(j) then table.insert(rval, '"'.. encodeString(i).. '":'.. encode(j)) end end end
        if bArray then return '['.. table.concat(rval,',')..']' else return '{'.. table.concat(rval,',').. '}' end
      end
      if vtype=='function' and v==null then return 'null' end
      base.assert(false,'encode attempt to encode unsupported type '.. vtype.. ':'.. base.tostring(v))
    end
    function decode(s, startPos)
      startPos = startPos and startPos or 1
      startPos = decode_scanWhitespace(s,startPos)
      base.assert(startPos<=string.len(s), 'Unterminated JSON')
      local curChar = string.sub(s,startPos,startPos)
      if curChar=='{' then return decode_scanObject(s,startPos) end
      if curChar=='[' then return decode_scanArray(s,startPos) end
      if string.find("+-0123456789.e", curChar, 1, true) then return decode_scanNumber(s,startPos) end
      if curChar=='"' or curChar=="'" then return decode_scanString(s,startPos) end
      if string.sub(s,startPos,startPos+1)=='/*' then return decode(s, decode_scanComment(s,startPos)) end
      return decode_scanConstant(s,startPos)
    end
    function null() return null end
    function decode_scanArray(s,startPos)
      local array = {} local stringLen = string.len(s)
      base.assert(string.sub(s,startPos,startPos)=='[','decode_scanArray')
      startPos = startPos + 1
      repeat
        startPos = decode_scanWhitespace(s,startPos)
        base.assert(startPos<=stringLen,'JSON String ended unexpectedly')
        local curChar = string.sub(s,startPos,startPos)
        if (curChar==']') then return array, startPos+1 end
        if (curChar==',') then startPos = decode_scanWhitespace(s,startPos+1) end
        base.assert(startPos<=stringLen, 'JSON ended')
        object, startPos = decode(s,startPos)
        table.insert(array,object)
      until false
    end
    function decode_scanComment(s, startPos)
      base.assert(string.sub(s,startPos,startPos+1)=='/*', "decode_scanComment")
      local endPos = string.find(s,'*/',startPos+2)
      base.assert(endPos~=nil, "Unterminated comment")
      return endPos+2
    end
    function decode_scanConstant(s, startPos)
      local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
      local constNames = {"true","false","null"}
      for i,k in base.pairs(constNames) do if string.sub(s,startPos, startPos + string.len(k) -1 )==k then return consts[k], startPos + string.len(k) end end
      base.assert(nil, 'Failed to scan constant')
    end
    function decode_scanNumber(s,startPos)
      local endPos = startPos+1 local stringLen = string.len(s) local acceptableChars = "+-0123456789.e"
      while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true) and endPos<=stringLen) do endPos = endPos + 1 end
      local stringValue = 'return '.. string.sub(s,startPos, endPos-1)
      local stringEval = base.loadstring(stringValue)
      base.assert(stringEval, 'Failed to scan number')
      return stringEval(), endPos
    end
    function decode_scanObject(s,startPos)
      local object = {} local stringLen = string.len(s) local key, value
      base.assert(string.sub(s,startPos,startPos)=='{','decode_scanObject')
      startPos = startPos + 1
      repeat
        startPos = decode_scanWhitespace(s,startPos)
        base.assert(startPos<=stringLen, 'JSON ended')
        local curChar = string.sub(s,startPos,startPos)
        if (curChar=='}') then return object,startPos+1 end
        if (curChar==',') then startPos = decode_scanWhitespace(s,startPos+1) end
        base.assert(startPos<=stringLen, 'JSON ended')
        key, startPos = decode(s,startPos)
        base.assert(startPos<=stringLen, 'JSON ended')
        startPos = decode_scanWhitespace(s,startPos)
        base.assert(string.sub(s,startPos,startPos)==':','mal-formed')
        startPos = decode_scanWhitespace(s,startPos+1)
        value, startPos = decode(s,startPos)
        object[key]=value
      until false
    end
    function decode_scanString(s,startPos)
      base.assert(startPos, 'no start') local startChar = string.sub(s,startPos,startPos)
      base.assert(startChar=="'" or startChar=='"','non-string')
      local escaped = false local endPos = startPos + 1 local bEnded = false local stringLen = string.len(s)
      repeat
        local curChar = string.sub(s,endPos,endPos)
        if not escaped then if curChar=='\\' then escaped = true else bEnded = curChar==startChar end
        else escaped = false end
        endPos = endPos + 1
        base.assert(endPos <= stringLen+1, "unterminated string")
      until bEnded
      local stringValue = 'return '.. string.sub(s, startPos, endPos-1)
      local stringEval = base.loadstring(stringValue)
      base.assert(stringEval, 'Failed to load string')
      return stringEval(), endPos
    end
    function decode_scanWhitespace(s,startPos)
      local whitespace=" \n\r\t" local stringLen = string.len(s)
      while (string.find(whitespace, string.sub(s,startPos,startPos), 1, true) and startPos <= stringLen) do startPos = startPos + 1 end
      return startPos
    end
    function encodeString(s)
      s = string.gsub(s,'\\','\\\\') s = string.gsub(s,'"','\\"') s = string.gsub(s,"'","\\'") s = string.gsub(s,'\n','\\n') s = string.gsub(s,'\t','\\t') return s
    end
    function isArray(t)
      local maxIndex = 0
      for k,v in base.pairs(t) do
        if (base.type(k)=='number' and math.floor(k)==k and 1<=k) then if (not isEncodable(v)) then return false end maxIndex = math.max(maxIndex,k)
        else if (k=='n') then if v ~= table.getn(t) then return false end else if isEncodable(v) then return false end end end
      end
      return true, maxIndex
    end
    function isEncodable(o) local t = base.type(o) return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or (t=='function' and o==null) end
]]

function loadJSON()
    local sName = 'JSON'
    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )
    local fnAPI, err = loadstring(_jstr)
    if fnAPI then setfenv( fnAPI, tEnv ) fnAPI() else printError( err ) return false end
    local tAPI = {}
    for k,v in pairs( tEnv ) do tAPI[k] = v end
    _G[sName] = tAPI
    return true
end

local mainTitle = 'OneOS Installer - TUO REPO'
local subTitle = 'Please wait...'

function Draw()
    sleep(0) term.setBackgroundColour(colours.white) term.clear()
    local w, h = term.getSize()
    term.setTextColour(colours.lightBlue)
    term.setCursorPos(math.ceil((w-#mainTitle)/2), 8) term.write(mainTitle)
    term.setTextColour(colours.blue)
    term.setCursorPos(math.ceil((w-#subTitle)/2), 10) term.write(subTitle)
end

Settings = {
    InstallPath = '/',
    Hidden = false,
    GitHubUsername = 'smazzara0000-hue', -- TUO
    GitHubRepoName = 'OneOS', -- TUO
    GitHubBranch = 'main',
    DownloadReleases = false,
    TotalBytes = 0, DownloadedBytes = 0, Status = '', SecondaryStatus = '',
}

loadJSON()

function downloadJSON(path)
    local _json = http.get(path)
    if not _json then error('Could not download: '..path) end
    return JSON.decode(_json.readAll())
end

if not http then subTitle = 'HTTP required' Draw() error('') end

subTitle = 'Downloading File Listing from main branch'
Draw()

-- FIX: scarica direttamente dal branch main, non dalle releases
local tree = downloadJSON('https://api.github.com/repos/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/git/trees/'..Settings.GitHubBranch..'?recursive=1').tree

local blacklist = {'/.gitignore','/README.md','/TODO','/Desktop/.Desktop.settings','/.version'}
function isBlacklisted(path) for i, item in ipairs(blacklist) do if item == path then return true end end return false end

Settings.TotalFiles = 0 Settings.TotalBytes = 0
for i, v in ipairs(tree) do
    if not isBlacklisted('/'..v.path) and v.type == 'blob' then
        Settings.TotalFiles = Settings.TotalFiles + 1
        if v.size then Settings.TotalBytes = Settings.TotalBytes + v.size end
    end
end

Settings.DownloadedBytes = 0 Settings.DownloadedFiles = 0
function downloadBlob(v)
    if isBlacklisted('/'..v.path) then return end
    if v.type == 'tree' then
        Draw() fs.makeDir('/'..v.path)
    else
        Draw()
        local tries, f = 0
        repeat
            f = http.get(('https://raw.githubusercontent.com/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/'..Settings.GitHubBranch..'/'..v.path):gsub(' ','%%20'))
            if not f then sleep(1) end tries = tries + 1
        until tries > 5 or f
        if not f then error('Download failed: '..v.path) end
        -- fix OneOS/ doppio
        local savePath = v.path
        if savePath:sub(1,5) == "OneOS/" then savePath = savePath:sub(6) end
        local dir = fs.getDir('/'..savePath)
        if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
        local h = fs.open('/'..savePath, 'w') h.write(f.readAll()) h.close()
        subTitle = 'Downloading: '.. math.floor(100*(Settings.DownloadedFiles/Settings.TotalFiles))..'%'
        Draw()
        Settings.DownloadedFiles = Settings.DownloadedFiles + 1
    end
end

local connectionLimit = 5
local downloads = {}
for i, v in ipairs(tree) do
    local queueNumber = math.ceil(i / connectionLimit)
    if not downloads[queueNumber] then downloads[queueNumber] = {} end
    table.insert(downloads[queueNumber], function() downloadBlob(v) end)
end
for i, queue in ipairs(downloads) do parallel.waitForAll(unpack(queue)) end

local h = fs.open('/System/.version', 'w') h.write('v1.1.1') h.close()

mainTitle = 'Installation Complete!' subTitle = 'Rebooting...' Draw() sleep(1) os.reboot()
