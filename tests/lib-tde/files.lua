files = require("tde.lib-tde.file")

-- get the script lcation
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

-- create a file with some data
local function create_file(location, value)
    file = io.open(location, "w")
    file:write(value)
    file:close()
end

-- WARNING: Be carefull with this function
-- It removes files for the filesystem
local function rm_file(location)
    os.remove(location)
end

-- simple test functions that were written previously can be integrated
-- in luaunit too
function test_file_check_parameters_exist()
    assert(files.dir_exists)
    assert(files.exists)
    assert(files.lines)
    assert(files.log)
    assert(files.string)
end

-- TODO: verify that dir exists only works for directories
-- HINT: list_dir should contain . and ..
function test_dir_exists_validation()
    assert(not files.dir_exists(123))
    assert(files.dir_exists("/"))
end

function test_dir_exists_works_with_symlink()
    -- On TOS based systems /bin is symlinked to /usr/bin
    assert(files.dir_exists("/bin"))
end

function test_dir_exists_for_known_directories()
    local project_dir = script_path()

    assert(files.dir_exists(project_dir))
    assert(not files.dir_exists(project_dir .. "something_that_should_never_exists_123"))
end

-- TODO: check that file_exists doesn't mark a directory as a file

function test_script_file_exists()
    local project_dir = script_path()
    -- this file that contains this code must exist
    assert(files.exists(project_dir .. "files.lua"))
    -- This file shouldn't exist
    assert(not files.exists(project_dir .. "files.lua.don.t.exist"))
end

-- some system files that should exist
function test_script_lines_in_file()
    assert(files.exists(os.getenv("PWD") .. "/tde/rc.lua"))
end

function test_script_create_string_from_file_single_line()
    local data = "this is some test data\n"
    create_file("test_file_1", data)
    create_file("test_file_2", data)
    assert(files.string("test_file_1") == data)
    assert(files.string("test_file_1") == files.string("test_file_2"))
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function test_script_create_string_from_file_multi_line()
    local data = "this is some more test data\nwith_some_more_information\never a third line is present\n"
    create_file("test_file_1", data)
    create_file("test_file_2", data)
    assert(files.string("test_file_1") == data)
    assert(files.string("test_file_1") == files.string("test_file_2"))
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function test_script_lines_from_file()
    local lines = {}
    lines[1] = "this is some test data"
    lines[2] = "this is the second line"
    lines[3] = "And a third"
    lines[4] = ""

    local data = ""

    for _, line in pairs(lines) do
        data = data .. line .. "\n"
    end

    create_file("test_file_1", data)
    -- we can't do a simple assert on a table since those have unique pointers
    local result = files.lines("test_file_1")
    assert(#result == #lines)
    for index, line in pairs(result) do
        assert(line == lines[index])
    end

    rm_file("test_file_1")
end

-- TODO: check for hidden files
-- TODO: check that . and .. are excluded
-- TODO: verify reqursion

function test_directory_list_works()
    assert(files.list_dir("/etc"))
    assert(type(files.list_dir("/etc")) == "table")
end

function test_directory_list_unexisting_dir_works()
    assert(#files.list_dir("/bdquqddqdsqdqsd") == 0)
    assert(type(files.list_dir("/bdquqddqdsqdqsd")) == "table")
end

function test_directory_list_works_reqursive()
    assert(files.list_dir_full("/tmp"))
    assert(type(files.list_dir_full("/tmp")) == "table")
end

function test_directory_list_unexisting_dir_works_reqursive()
    assert(#files.list_dir_full("/bdquqddqdsqdqsd") == 0)
    assert(type(files.list_dir_full("/bdquqddqdsqdqsd")) == "table")
end

rm_file("test_file_1")
rm_file("test_file_2")
