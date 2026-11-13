-- Exercise the actual Fennel source with the host filesystem and find process.
local fennel = require("fennel")
table.insert(package.searchers or package.loaders, fennel.searcher)
local tab = require("tab")
local root = os.tmpname()
assert(os.remove(root))
local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end
local function run(command) assert(os.execute(command)) end
local function write(path, contents)
  local file = assert(io.open(path, "w"))
  assert(file:write(contents))
  assert(file:close())
end
local function names(actual, expected)
  table.sort(actual)
  table.sort(expected)
  assert(#actual == #expected, "unexpected result count")
  for i, name in ipairs(expected) do assert(actual[i] == name, actual[i]) end
end
local function fails(fn, path)
  local ok, err = pcall(fn)
  assert(not ok, "failed scan must not succeed")
  assert(tostring(err):find("Could not scan directory: " .. path, 1, true), tostring(err))
end
local ok, err = pcall(function()
  run("mkdir -p " .. quote(root .. "/empty") .. " " .. quote(root .. "/nested"))
  write(root .. "/one.fnl", "{:value 1}")
  write(root .. "/nested/two.fnl", "{:value 2}")
  names(tab["scan-directory"](root .. "/empty"), {})
  names(tab["scan-directory"](root, false, "f"), {"one.fnl"})
  names(tab["scan-directory"](root .. "/", false, "f"), {"one.fnl"})
  names(tab["scan-directory"](root .. "//", false, "f"), {"one.fnl"})
  assert(tab["load-folder"](root .. "/").one.value == 1)
  names(tab["scan-directory"](root, false, "d"), {"empty", "nested"})
  names(tab["scan-directory"](root, true, "f"), {"one.fnl", "nested/two.fnl"})
  names(tab["scan-directory"](root, false, "f", true), {"one"})
  -- Shell syntax must remain literal filename data, never execute or expand.
  for _, name in ipairs({"space directory", "quote'and\"double", "$HOME", "$(printf injected)", "`printf injected`", "semi;colon"}) do
    local path = root .. "/" .. name
    run("mkdir " .. quote(path))
    write(path .. "/literal.fnl", "{:value 3}")
    names(tab["scan-directory"](path, false, "f"), {"literal.fnl"})
  end
  local relative = "-scan-test-" .. root:gsub("/", "_")
  run("mkdir " .. quote("./" .. relative))
  local relative_ok, relative_error = pcall(function()
    write(relative .. "/literal.fnl", "{:value 4}")
    names(tab["scan-directory"](relative, false, "f"), {"literal.fnl"})
  end)
  run("rm -r " .. quote("./" .. relative))
  assert(relative_ok, relative_error)
  local link = root .. "/linked"
  run("ln -s " .. quote(root .. "/nested") .. " " .. quote(link))
  names(tab["scan-directory"](link, false, "f"), {})
  names(tab["scan-directory"](link .. "/", false, "f"), {"two.fnl"})
  names(tab["scan-directory"](link .. "//", false, "f"), {"two.fnl"})
  assert(tab["load-folder"](link .. "/").two.value == 2)
  local substitution = "$(printf " .. root .. "/empty)"
  fails(function() tab["scan-directory"](substitution) end, substitution)
  local original_popen = io.popen
  local invoked = false
  io.popen = function() invoked = true; error("invalid input reached shell") end
  for _, value in ipairs({"f; printf injected", "x", "", false, 1}) do
    assert(not pcall(tab["scan-directory"], root, false, value))
  end
  for _, path in ipairs({"", "bad\0path", false, 1}) do
    assert(not pcall(tab["scan-directory"], path))
  end
  io.popen = original_popen
  assert(not invoked, "invalid inputs must be rejected before process startup")
  local loaded = tab["load-folder"](root, true)
  assert(loaded.one.value == 1 and loaded["nested/two"].value == 2)
  local missing = root .. "/missing"
  fails(function() tab["scan-directory"](missing) end, missing)
  fails(function() tab["load-folder"](missing) end, missing)

  -- Root has no extra separator before its children.
  local root_popen = io.popen
  local root_ok, root_error = pcall(function()
    for _, prefix in ipairs({"/", "///"}) do
      io.popen = function()
        return {lines = function()
          local paths, i = {prefix, prefix .. "tmp"}, 0
          return function() i = i + 1; return paths[i] end
        end, close = function() return true, "exit", 0 end}
      end
      names(tab["scan-directory"](prefix), {"tmp"})
    end
  end)
  io.popen = root_popen
  assert(root_ok, root_error)

  -- Starting the child can fail before there is a stream to read.
  local popen = io.popen
  io.popen = function() return nil, "process unavailable" end
  local started, start_error = pcall(tab["scan-directory"], root)
  io.popen = popen
  assert(not started and tostring(start_error):find("Could not start directory scan: " .. root, 1, true))

  -- A process can produce partial output before failing. Never return it as success.
  local original = io.popen
  local closed = false
  io.popen = function()
    return {
      lines = function()
        local sent = false
        return function()
          if not sent then sent = true; return root .. "/one.fnl" end
        end
      end,
      close = function() closed = true; return nil, "exit", 1 end
    }
  end
  local passed, failure = pcall(function()
    fails(function() tab["scan-directory"](root) end, root)
    assert(closed, "scan must close its process")
  end)
  io.popen = original
  assert(passed, failure)

  -- The real MUD user-data consumer must not mark a failed load as ready.
  local users = fennel.dofile("behaviors/users/handler.fnl")
  local handler = {fname = function() return "test users" end}
  -- Use an explicitly missing relative folder beneath attributes, not credentials.
  handler["users-folder"] = "__missing_scan_test__" .. root:gsub("/", "_")
  local path = "attributes/" .. handler["users-folder"]
  fails(function() users.load(handler, {}) end, path)
  assert(handler.users == nil and handler["loaded?"] == nil)
end)
run("rm -r " .. quote(root))
assert(ok, err)
print("filesystem scan and MUD user-data receiving tests passed")
