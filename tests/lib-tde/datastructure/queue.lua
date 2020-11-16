local queue = require("tde.lib-tde.datastructure.queue")

function test_data_structure_queue_basic_usage()
    local list = queue()
    assert(list.next() == nil)
    list.push("first")
    list.push("second")
    assert(list.size() == 2)
    assert(list.next() == "first")
    assert(list.next() == "first")
    assert(list.pop() == "first")
    assert(list.next() == "second")
    assert(list.next() == "second")
    assert(list.pop() == "second")
    assert(list.next() == nil)
    assert(list.size() == 0)
end

function test_data_structure_queue_types_number()
    local list = queue()
    assert(list.next() == nil)
    list.push(1)
    list.push(2)
    assert(list.size() == 2)
    assert(list.next() == 1)
    assert(list.next() == 1)
    assert(list.pop() == 1)
    assert(list.next() == 2)
    assert(list.next() == 2)
    assert(list.pop() == 2)
    assert(list.next() == nil)
    assert(list.size() == 0)
end

function test_data_structure_queue_functions_exist()
    local list = queue()
    assert(type(list.next) == "function")
    assert(type(list.size) == "function")
    assert(type(list.push) == "function")
    assert(type(list.pop) == "function")
end

function test_data_structure_queue_large_dataset()
    local list = queue()
    for i = 1, 1000 do
        list.push(i)
    end
    assert(list.size() == 1000)
    for i = 1, 999 do
        list.pop()
    end
    assert(list.size() == 1)
end

function test_data_structure_queue_very_large_dataset()
    local list = queue()
    for i = 1, 10000 do
        list.push(i)
    end
    assert(list.size() == 10000)
    for _ = 1, 9999 do
        list.pop()
    end
    assert(list.size() == 1)
end
