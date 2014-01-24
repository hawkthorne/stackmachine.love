local stackmachine = require "stackmachine"
local osx = require "stackmachine/osx"
local glove = require "stackmachine/glove"
local windows = require "stackmachine/windows"
local utils = require "stackmachine/utils"

local targs = { [-1] = "game.exe"}
local u = stackmachine.newUpdater(targs, "0.0.0", "http://example.com")

function test_updater_create()
  local u = stackmachine.newUpdater(targs, "0.0.0", "")
  assert_true(u:done())
end

function test_natural_keys()
  local args = {
    [-1] = 'foo',
    [-2] = 'bar',
    [1]  = 'bat',
  }

  local natural = utils.naturalKeys(args)
  assert_equal('bar', natural[1])
  assert_equal('foo', natural[2])
  assert_equal('bat', natural[3])
end

function test_working_directory()
  assert_not_equal("", love.filesystem.getWorkingDirectory())
end

function test_osx_get_application_path()
  local path = osx.getApplicationPath({"/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app/Contents/Resources"})
  assert_equal("/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app", path)
end

function test_osx_short_path()
  local path = osx.getApplicationPath({"//"})
  assert_equal(path, "")
end

function test_osx_no_root_path()
  local path = osx.getApplicationPath({"//Contents/Resources"})
  assert_equal(path, "")
end

function test_updater_no_thread_started()
  local u = stackmachine.newUpdater(targs, "0.0.0", "")
  u:start()
  assert_nil(u.thread)
end

function test_updater_progress_not_started()
  local u = stackmachine.newUpdater(targs, "0.0.0", "http://example.com")
  local msg, percent = u:progress()
  assert_equal("Waiting to start", msg)
  assert_equal(0, percent)
end

function test_stackmachine_osx_unzip_unknown_file()
  assert_error(function() 
    osx.replace("/foo/bar.zip", "bar")
  end)
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function test_stackmachine_same_versions()
  assert_false(stackmachine.isNewer("0.0.1", "0.0.1"))
end

function test_stackmachine_lower_versions()
  assert_false(stackmachine.isNewer("0.0.1", "0.0.0"))
end

function test_stackmachine_higher_bug_versions()
  assert_true(stackmachine.isNewer("0.0.1", "0.0.2"))
end

function test_stackmachine_lower_minor_version()
  assert_false(stackmachine.isNewer("0.1.0", "0.0.2"))
end

function test_stackmachine_unsupported_versions()
  assert_false(stackmachine.isNewer("0.0.-1", "0.0.2.0"))
end

function test_stackmachine_higher_minor_version()
  assert_true(stackmachine.isNewer("0.1.0", "0.2.0"))
end

function test_stackmachine_lower_major_version()
  assert_false(stackmachine.isNewer("1.0.0", "0.2.0"))
end

function test_stackmachine_higher_major_version()
  assert_true(stackmachine.isNewer("1.9.9", "2.0.0"))
end

function test_stackmachine_remove_path_no_exist()
  assert_false(windows.removeRecursive("nonexistant"))
end

function test_stackmachine_remove_directory()
  glove.filesystem.mkdir("test_folder")
  love.filesystem.write("test_folder/foo.txt", "Hello")
  assert_true(windows.removeRecursive("test_folder"))
  assert_false(love.filesystem.exists("test_folder/foo.txt"))
end

function test_stackmachine_windows_basename()
  local url = "http://files.projecthawkthorne.com/releases/v0.0.84/i386/OpenAL32.dll"
  local basename = windows.basename(url)
  assert_equal("OpenAL32.dll", basename)
end

function test_windows_split()
  local dir, base = windows.split("C:\\foo\\bar\\foo.exe")
  assert_equal("foo.exe", base)
  assert_equal("C:\\foo\\bar", dir)
end
