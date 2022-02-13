--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]
files = require("tde.lib-tde.file")

-- get the script location
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

-- WARNING: Be careful with this function
-- It removes files for the filesystem
local function rm_file(location)
    files.rm(location)

    assert(not files.exists(location), "Failed to remove the file: " .. location)
end

-- simple test functions that were written previously can be integrated
-- in luaunit too
function Test_file_check_parameters_exist()
    assert(files.dir_exists, "The file api should have a dir_exists function")
    assert(files.exists, "The file api should have a exists function")
    assert(files.lines, "The file api should have a lines function")
    assert(files.log, "The file api should have a log function")
    assert(files.string, "The file api should have a string function")
    assert(files.basename, "The file api should have a basename function")
    assert(files.dir_create, "The file api should have a dir_create function")
    assert(files.dirname, "The file api should have a dirname function")
    assert(files.list_dir, "The file api should have a list_dir function")
    assert(files.list_dir_full, "The file api should have a list_dir_full function")
    assert(files.mktemp, "The file api should have a mktemp function")
    assert(files.mktempdir, "The file api should have a mktempdir function")
    assert(files.overwrite, "The file api should have a overwrite function")
    assert(files.rm, "The file api should have a rm function")
    assert(files.copy_file, "The file api should have a copy_file function")
    assert(files.move_file, "The file api should have a move_file function")
    assert(files.write, "The file api should have a write function")
end

-- TODO: verify that dir exists only works for directories
-- HINT: list_dir should contain . and ..
function Test_dir_exists_validation()
    assert(not files.dir_exists(123), "a directory cannot be an integer, must be a string")
    assert(files.dir_exists("/"), "The root directory always exists")
end

function Test_dir_exists_works_with_symlink()
    -- On TOS based systems /bin is symlinked to /usr/bin
    assert(files.dir_exists("/bin"), "/bin is a directory that always exists")
end

function Test_dir_exists_for_known_directories()
    local project_dir = script_path()

    assert(files.dir_exists(project_dir), "The current working directory should exists")
    assert(
        not files.dir_exists(project_dir .. "something_that_should_never_exists_123"),
        "'something_that_should_never_exists_123' shouldn't exist in the current working directory"
    )
end

-- TODO: check that file_exists doesn't mark a directory as a file

function Test_script_file_exists()
    local project_dir = script_path()
    -- this file that contains this code must exist
    assert(files.exists(project_dir .. "files.lua"), "The file " .. project_dir .. "files.lua should exist")
    -- This file shouldn't exist
    assert(
        not files.exists(project_dir .. "files.lua.don.t.exist"),
        "The file " .. project_dir .. "files.lua.don.t.exist shouldn't exist"
    )
end

-- some system files that should exist
function Test_script_lines_in_file()
    assert(files.exists(os.getenv("PWD") .. "/tde/rc.lua"), os.getenv("PWD") .. "/tde/rc.lua is missing")
end

function Test_script_copy_file()
    local data = "this is some test data"
    create_file("test_file_1", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )
    assert(files.copy_file("test_file_1", "test_file_2"))
    assert(
        files.string("test_file_2") == data,
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2', whilsts it was copied"
    )
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function Test_script_copy_file_overwrite()
    local data = "this is some test data"
    create_file("test_file_1", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )

    -- make sure content of test_file_2 doesn't get overridden
    assert(files.copy_file("test_file_1", "test_file_2"))
    assert(not files.copy_file("test_file_1", "test_file_2"))

    assert(
        files.string("test_file_2") == data,
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2', whilsts it was copied"
    )
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function Test_script_move_file()
    local data = "this is some test data"
    create_file("test_file_1", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )
    assert(files.move_file("test_file_1", "test_file_2"))
    assert(
        files.string("test_file_2") == data,
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2', whilsts it was moved"
    )

    assert(files.exists("test_file_2"), "The output of the move_file command didn't work")
    assert(not files.exists("test_file_1"), "It seems the original file still exists, it is not moved")

    rm_file("test_file_1")
    rm_file("test_file_2")
end

-- TODO: Implement a test case for moving directories instead of files for the move_file api

function Test_script_create_string_from_file_single_line()
    local data = "this is some test data"
    create_file("test_file_1", data)
    create_file("test_file_2", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )
    assert(
        files.string("test_file_1") == files.string("test_file_2"),
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2'"
    )
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function Test_script_create_string_from_file_multi_line()
    local data = "this is some more test data\nwith_some_more_information\never a third line is present"
    create_file("test_file_1", data)
    create_file("test_file_2", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )
    assert(
        files.string("test_file_1") == files.string("test_file_2"),
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2'"
    )
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function Test_script_create_string_from_file_empty()
    local data = ""
    create_file("test_file_1", data)
    create_file("test_file_2", data)
    assert(
        files.string("test_file_1") == data,
        "The string representation of the file 'test_file_1' doesn't match: " .. data
    )
    assert(
        files.string("test_file_1") == files.string("test_file_2"),
        "The string representation of the file 'test_file_1' doesn't match the string representation of file 'test_file_2'"
    )
    rm_file("test_file_1")
    rm_file("test_file_2")
end

function Test_script_replace()
    local data = "abc"
    local expected = "bbc"

    create_file("test_file_1", data)

    files.replace("test_file_1", "a", "b")

    assert(
        files.string("test_file_1") == expected,
        "The string representation of the file 'test_file_1' doesn't match: " .. expected
    )
    rm_file("test_file_1")
end

function Test_script_replace_regex()
    local data = "abc123def456"
    local expected = "Z123Z456"

    create_file("test_file_1", data)

    files.replace("test_file_1", "[a-z]+", "Z")

    assert(
        files.string("test_file_1") == expected,
        "The string representation of the file 'test_file_1' doesn't match: " .. expected
    )
    rm_file("test_file_1")
end

function Test_script_lines_from_file()
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
    assert(
        #result == #lines,
        "The amount of lines in result (" .. tostring(#result) .. ") is not equal to lines(" .. tostring(#lines) .. ")"
    )
    for index, line in pairs(result) do
        assert(
            line == lines[index],
            "The line on index: " .. tostring(index) .. " contains: " .. line .. " and is not equal to " .. lines[index]
        )
    end

    rm_file("test_file_1")
end

function Test_script_lines_from_file_empty()
    local lines = {}

    local data = ""

    create_file("test_file_1", data)
    -- we can't do a simple assert on a table since those have unique pointers
    local result = files.lines("test_file_1")
    assert(
        #result == #lines,
        "The amount of lines in result (" .. tostring(#result) .. ") is not equal to lines(" .. tostring(#lines) .. ")"
    )
    for index, line in pairs(result) do
        assert(
            line == lines[index],
            "The line on index: " .. tostring(index) .. " contains: " .. line .. " and is not equal to " .. lines[index]
        )
    end

    rm_file("test_file_1")
end

-- TODO: check for hidden files
-- TODO: check that . and .. are excluded
-- TODO: verify recursion

function Test_directory_list_works()
    assert(files.list_dir("/etc"), "/etc should have some files in it")
    assert(type(files.list_dir("/etc")) == "table", "The files in /etc should be in a table")
end

function Test_directory_list_unexisting_dir_works()
    assert(#files.list_dir("/bdquqddqdsqdqsd") == 0, "/bdquqddqdsqdqsd shouldn't contain any files")
    assert(type(files.list_dir("/bdquqddqdsqdqsd")) == "table", "list_dir should return files")
end

function Test_directory_list_works_reqursive()
    assert(files.list_dir_full("/tmp"), "/bdquqddqdsqdqsd shouldn't contain any files")
    assert(type(files.list_dir_full("/tmp")) == "table", "list_dir_full should return files")
end

function Test_directory_list_unexisting_dir_works_reqursive()
    assert(#files.list_dir_full("/bdquqddqdsqdqsd") == 0, "/bdquqddqdsqdqsd shouldn't contain any files")
    assert(type(files.list_dir_full("/bdquqddqdsqdqsd")) == "table", "list_dir_full should return files")
end

function Test_file_remove_works()
    assert(not files.exists("should_not_exist"), "the file 'should_not_exist' shouldn't exist")
    assert(files.write("should_not_exist", ""), "Writing data to 'should_not_exist' failed")
    assert(files.exists("should_not_exist"), "The file 'should_not_exist' should temporarily exist")
    assert(files.rm("should_not_exist"), "Removing the file 'should_not_exist' failed")

    -- make sure it doesn't exist anymore
    assert(not files.exists("should_not_exist"), "The file 'should_not_exist' shouldn't exist anymore")
end

function Test_file_basename_works()
    assert(files.basename("hello") == "hello", files.basename("Hello") .. " should equal 'Hello'")
    assert(files.basename("/root/hello") == "hello", files.basename("/root/hello") .. " should equal 'hello'")
    assert(
        files.basename("/tmp/sec/test.log") == "test.log",
        files.basename("/tmp/sec/test.log") .. " should equal 'test.log'"
    )
    assert(files.basename("/file") == "file", files.basename("/file") .. " should equal 'file'")
    assert(
        files.basename("/a/deap/data/strucutre/is/present/here") == "here",
        files.basename("/a/deap/data/strucutre/is/present/here") .. " should equal 'here'"
    )
end

function Test_file_basename_works_with_spaces()
    assert(
        files.basename("hello world") == "hello world",
        files.basename("hello world") .. " should equal 'hello world'"
    )
    assert(
        files.basename("/root/hello world") == "hello world",
        files.basename("/root/hello world") .. " should equal 'hello world'"
    )
    assert(
        files.basename("/tmp/sec/test log") == "test log",
        files.basename("/tmp/sec/test log") .. " should equal 'test log'"
    )
    assert(
        files.basename("/file with spaces") == "file with spaces",
        files.basename("/file with spaces") .. " should equal 'file with spaces'"
    )
    assert(
        files.basename("/a/deap/data/strucutre is/present/here with/spaces in the name") == "spaces in the name",
        files.basename("/a/deap/data/strucutre is/present/here with/spaces in the name") ..
            " should equal 'spaces in the name'"
    )
end

function Test_file_basename_validate_input()
    assert(files.basename(nil) == nil, "You cannot ask the basename of nil")
    assert(files.basename(10) == nil, "You cannot ask the basename of a number")
    assert(files.basename(-10) == nil, "You cannot ask the basename of a number")
    assert(files.basename(99991919) == nil, "You cannot ask the basename of a number")
    assert(files.basename({}) == nil, "You cannot ask the basename of a table")
    assert(
        files.basename(
            function()
            end
        ) == nil,
        "You cannot ask the basename of a function"
    )
end

function Test_file_dirname_works()
    assert(files.dirname("hello") == "./", files.dirname("hello") .. " should equal './'")
    assert(files.dirname("/root/hello") == "/root/", files.dirname("/root/hello") .. " should equal '/root/'")
    assert(
        files.dirname("/tmp/sec/test.log") == "/tmp/sec/",
        files.dirname("/tmp/sec/test.log") .. " should equal '/tmp/sec/'"
    )
    assert(files.dirname("/file") == "/", files.dirname("/file") .. " should equal '/'")
    assert(
        files.dirname("/a/deap/data/strucutre/is/present/here") == "/a/deap/data/strucutre/is/present/",
        files.dirname("/a/deap/data/strucutre/is/present/here") .. " should equal '/a/deap/data/strucutre/is/present/'"
    )
end

function Test_file_dirname_works_with_spaces()
    assert(files.dirname("hello world") == "./", files.dirname("hello world") .. " should equal './'")
    assert(
        files.dirname("/root/hello world") == "/root/",
        files.dirname("/root/hello world") .. " should equal '/root/'"
    )
    assert(
        files.dirname("/tmp/sec/test log") == "/tmp/sec/",
        files.dirname("/tmp/sec/test log") .. " should equal '/tmp/sec/'"
    )
    assert(files.dirname("/file with spaces") == "/", files.dirname("/file with spaces") .. " should equal '/'")
    assert(
        files.dirname("/a/deap/data/strucutre is/present/here with/spaces in the name") ==
            "/a/deap/data/strucutre is/present/here with/",
        files.dirname("/a/deap/data/strucutre is/present/here with/spaces in the name") ..
            " should equal '/a/deap/data/strucutre is/present/here with/'"
    )
end

function Test_file_dirname_validate_input()
    assert(files.dirname(nil) == nil, "You cannot ask the basename of nil")
    assert(files.dirname(10) == nil, "You cannot ask the basename of a number")
    assert(files.dirname(-10) == nil, "You cannot ask the basename of a number")
    assert(files.dirname(99991919) == nil, "You cannot ask the basename of a number")
    assert(files.dirname({}) == nil, "You cannot ask the basename of a table")
    assert(
        files.dirname(
            function()
            end
        ) == nil,
        "You cannot ask the basename of a function"
    )
end

function Test_dir_components()
    local dir = "/etc/xdg/tde/lib-tde/"
    local file = dir .. "/logger.lua"
    assert(files.dirname(dir) == dir, "The directory name doesn't match: " .. dir)
    assert(files.dirname(file) == dir, "The directory name doesn't match: " .. file)
end

function Test_dir_recursive_creation()
    local dir = "/tmp/some/random/dir/that/doesn't/exist/"
    files.dir_create(dir)
    local result = files.dir_exists(dir)
    io.popen("rm -rf " .. dir)
    assert(result, "The directroy didn't get created: " .. dir)
end

function Test_dotfile_detection()
    local file = "/home/user/.bashrc"
    assert(files.is_dotfile(file), string.format("%s should be a dotfile", file))

    file = "/home/user/.bashrc.swp"
    assert(files.is_dotfile(file), string.format("%s should be a dotfile", file))

    file = "/home/user/file.txt"
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = "/dir"
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = "~/dir"
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = "~/.config"
    assert(files.is_dotfile(file), string.format("%s should be a dotfile", file))

    file = "~/.config/example/file.txt"
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))


    file = "~/.config/example/.file.txt"
    assert(files.is_dotfile(file), string.format("%s should be a dotfile", file))
end

function Test_dotfile_detection_edge_cases()
    local file = ""
    assert(not files.is_dotfile(file), string.format("'%s' should not be a dotfile", file))

    file = "/"
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = 10
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = "." -- The current directory
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))

    file = ".." -- The parent directory
    assert(not files.is_dotfile(file), string.format("%s should not be a dotfile", file))
end

function Test_filehandle_api_unit_tested()
    local amount = 19
    local result = tablelength(files)
    assert(
        result == amount,
        "You didn't test all filehandle api endpoints, please add them then update the amount to: " .. result
    )
end

rm_file("test_file_1")
rm_file("test_file_2")
