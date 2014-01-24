math.randomseed(os.time())

local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
"w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6"}

local utils = {}

-- Generate a 10-digit random ID
function utils.distinctId()
  if not love.filesystem.exists('gameid.txt') then
    love.filesystem.write('gameid.txt', utils.randomId())
  end

  local contents, _ = love.filesystem.read('gameid.txt')
  return contents
end

-- Generate a 10-digit random ID
function utils.randomId()
  local size = 10
  local pass = {}

  for z = 1,size do
    local case = math.random(1,2)
    local a = math.random(1,#char)
    if case == 1 then
      x=string.upper(char[a])
    elseif case == 2 then
      x=string.lower(char[a])
    end
    table.insert(pass, x)
  end
  return(table.concat(pass))
end

function utils.endswith(s, suffix)
  return s:sub(-suffix:len()) == suffix
end

function utils.startswith(s, prefix)
  return s:sub(1, prefix:len()) == prefix
end

function utils.getLow(a)
	local m = math.huge
	for k,v in pairs(a) do
		if k < m then
			m = k
		end
	end
	return a[m]
end

function utils.naturalKeys(a)
  local keys = {}
  local natural = {}

	for k,v in pairs(a) do
    table.insert(keys, k)
	end

  table.sort(keys)

	for _,k in ipairs(keys) do
    table.insert(natural, a[k])
	end

	return natural
end

return utils
