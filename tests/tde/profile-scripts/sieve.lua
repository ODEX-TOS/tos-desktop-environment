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
local time = require("socket").gettime

local function PrimeSieve(n)
    local prime_counts = {}
    prime_counts[10] = 5
    prime_counts[100] = 25
    prime_counts[1000] = 168
    prime_counts[10000] = 1229
    prime_counts[100000] = 9592
    prime_counts[1000000] = 78498
    prime_counts[100000000] = 5761455

    local sieve_size = n
    local rawbits
    local int_count = 64 -- 64 bits in an int

    local function constructor()
        rawbits = {}
        for _ = 1, ((sieve_size // int_count) + 1), 1 do
            table.insert(rawbits, 0xffffffffffffffff)
        end
    end

    constructor()

    local function get_bit(index)
        if index % 2 == 0 then
            return false
        end
        index = index >> 1
        return ((rawbits[(index // int_count) + 1]) & (1 << (index % int_count))) ~= 0
    end

    local function clear_bit(index)
        if index % 2 == 0 then
            return false
        end
        index = index >> 1
        rawbits[(index // int_count) + 1] = rawbits[(index // int_count) + 1] & ~(1 << (index % int_count));
    end

    local function count_primes()
        local count = 0
        for i = 1, sieve_size, 2 do
            if get_bit(i) then
                count = count + 1
            end
        end
        return count
    end

    local function validate_results()
        local primes = count_primes()
        return prime_counts[sieve_size] == primes, primes
    end

    local function run_sieve()
        local factor = 3
        local q = math.sqrt(sieve_size)
        while(factor < q) do
            for num = factor, sieve_size, 1 do
                if get_bit(num) then
                    factor = num
                    break
                end
            end

            for num = factor * 3, sieve_size, factor * 2 do
                clear_bit(num)
            end

            factor = factor + 2
        end
    end

    local function print_results(show_results, duration, passes)
        if show_results then
            io.write("2, ")
        end
        local valid, primes = validate_results()

        io.write("\n")
        io.write(string.format("Passes: %d, Time: %f, Avg: %f, Limit: %d, Count: %d, Valid: %s",passes, duration, duration/passes, sieve_size, primes, valid))
    end

    return {
        run_sieve = run_sieve,
        print_results = print_results
    }
end


local start_time = time()
local passes = 0
local sieve

while time()-start_time < 5 do
    sieve = PrimeSieve(1000000)
    sieve.run_sieve()
    passes = passes + 1
end

local elapsed_time = time() - start_time
print('Done')

sieve.print_results(False, elapsed_time, passes)