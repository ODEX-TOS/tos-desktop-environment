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

local wibox = require("wibox")
local beautiful = require("beautiful")

-- information about the game area
local screen_width = mouse.screen.workarea.width
local screen_height = mouse.screen.workarea.height

-- make the board size x percent of the screen
local screen_size = 0.8

local PICTURE_DIR = os.getenv("HOME") .. "/.config/tde/chess/"

local wibox_rows = {}

local bIsWhitesTurn = true

local function has_oposite_piece_in_position(bIsWhite, i, j)
    -- first we validat the input
    if i < 1 or j < 1 then
        return false
    end

    if i > 8 or j > 8 then
        return false
    end

    local piece = wibox_rows[i][j].widget.piece

    if bIsWhite and piece.color == "black" then
        return true
    end

    if not bIsWhite and piece.color == "white" then
        return true
    end

    return false
end


local function has_piece_in_position(i, j)
    -- first we validat the input
    if i < 1 or j < 1 then
        return false
    end

    if i > 8 or j > 8 then
        return false
    end

    local piece = wibox_rows[i][j].widget.piece

    return not piece.isEmpty
end

local function has_no_piece_in_position(i ,j)
    if i < 1 or j < 1 then
        return false
    end

    if i > 8 or j > 8 then
        return false
    end

    local has_piece = has_piece_in_position(i, j)

    return not has_piece
end



local function move_pawn(_moves, piece, i, j)
    if piece.color == "black" then
        -- make sure we can move up one
        if not has_oposite_piece_in_position(false, i + 1, j) then
            table.insert(_moves, {i = i + 1, j = j})
        end
        if i == 2 and not has_oposite_piece_in_position(false, i + 2, j) then
            table.insert(_moves, {i = i + 2, j = j})
        end

        -- lets check if there is a piece we can capture
        if has_oposite_piece_in_position(false, i + 1, j + 1) then
            table.insert(_moves, {i = i + 1, j = j + 1})
        end
        if has_oposite_piece_in_position(false, i + 1, j - 1) then
            table.insert(_moves, {i = i + 1, j = j - 1})
        end

    else
        -- make sure we can move up one
        if not has_oposite_piece_in_position(true, i - 1, j) then
            table.insert(_moves, {i = i - 1, j = j})
        end
        if i == 7 and not has_oposite_piece_in_position(true, i - 2, j) then
            table.insert(_moves, {i = i - 2, j = j})
        end

        -- lets check if there is a piece we can capture
        if has_oposite_piece_in_position(true, i - 1, j +1) then
            table.insert(_moves, {i = i - 1, j = j + 1})
        end
        if has_oposite_piece_in_position(true, i - 1, j - 1) then
            table.insert(_moves, {i = i - 1, j = j - 1})
        end
    end

    return _moves
end

local function move_rook(_moves, piece, i, j)
    local bIsWhite = piece.color == "white"

    local di = i + 1

    while(not has_piece_in_position(di, j) and di <=8) do
        table.insert(_moves, {i = di, j = j})
        di = di + 1
    end

    if has_oposite_piece_in_position(bIsWhite, di, j) then
        table.insert(_moves, {i = di, j = j})
    end

    di = i - 1

    while(not has_piece_in_position(di, j) and di > 0) do
        table.insert(_moves, {i = di, j = j})
        di = di - 1
    end

    if has_oposite_piece_in_position(bIsWhite, di, j) then
        table.insert(_moves, {i = di, j = j})
    end

    local dj = j + 1

    while(not has_piece_in_position(i, dj) and dj <=8) do
        table.insert(_moves, {i = i, j = dj})
        dj = dj + 1
    end

    if has_oposite_piece_in_position(bIsWhite, i, dj) then
        table.insert(_moves, {i = i, j = dj})
    end

    dj = i - 1

    while(not has_piece_in_position(i, dj) and dj > 0) do
        table.insert(_moves, {i = i, j = dj})
        dj = dj - 1
    end

    if has_oposite_piece_in_position(bIsWhite, i, dj) then
        table.insert(_moves, {i = i, j = dj})
    end

    return _moves
end

local function move_bishop(_moves, piece, i, j)
    local di = i + 1
    local dj = j + 1

    local bIsWhite = piece.color == "white"

    while(not has_piece_in_position(di, dj) and di <=8 and dj <=8) do
        table.insert(_moves, {i = di, j = dj})
        di = di + 1
        dj = dj + 1
    end
    if has_oposite_piece_in_position(bIsWhite, di, dj) then
        table.insert(_moves, {i = di, j = dj})
    end

    di = i + 1
    dj = j - 1

    while(not has_piece_in_position(di, dj) and di <= 8 and dj > 0) do
        table.insert(_moves, {i = di, j = dj})
        di = di + 1
        dj = dj - 1
    end
    if has_oposite_piece_in_position(bIsWhite, di, dj) then
        table.insert(_moves, {i = di, j = dj})
    end

    di = i - 1
    dj = j + 1

    while(not has_piece_in_position(di, dj) and di > 0 and  dj <=8) do
        table.insert(_moves, {i = di, j = dj})
        di = di - 1
        dj = dj + 1
    end
    if has_oposite_piece_in_position(bIsWhite, di, dj) then
        table.insert(_moves, {i = di, j = dj})
    end

    di = i - 1
    dj = j - 1

    while(not has_piece_in_position(di, dj) and di > 0 and dj > 0) do
        table.insert(_moves, {i = di, j = dj})
        di = di - 1
        dj = dj - 1
    end
    if has_oposite_piece_in_position(bIsWhite, di, dj) then
        table.insert(_moves, {i = di, j = dj})
    end

    return _moves
end

local function move_horse(_moves, piece, i, j)
    local bIsWhite = piece.color == "white"

    if has_oposite_piece_in_position(bIsWhite, i + 2 , j + 1) or has_no_piece_in_position(i + 2 , j + 1) then
        table.insert(_moves, {i = i + 2, j = j + 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 2 , j - 1) or has_no_piece_in_position(i + 2 , j - 1) then
        table.insert(_moves, {i = i + 2, j = j - 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i - 2 , j - 1) or has_no_piece_in_position(i - 2 , j -1) then
        table.insert(_moves, {i = i - 2, j = j -1})
    end

    if has_oposite_piece_in_position(bIsWhite, i - 2 , j + 1) or has_no_piece_in_position(i - 2 , j + 1) then
        table.insert(_moves, {i = i - 2, j = j + 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i - 1 , j + 2) or has_no_piece_in_position(i - 1 , j + 2) then
        table.insert(_moves, {i = i - 1, j = j + 2})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 1 , j + 2) or has_no_piece_in_position(i + 1 , j + 2) then
        table.insert(_moves, {i = i + 1, j = j + 2})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 1 , j - 2) or has_no_piece_in_position(i + 1 , j - 2) then
        table.insert(_moves, {i = i + 1, j = j - 2})
    end

    if has_oposite_piece_in_position(bIsWhite, i - 1 , j - 2) or has_no_piece_in_position(i - 1 , j - 2) then
        table.insert(_moves, {i = i - 1, j = j - 2})
    end

    return _moves
end

local function move_king(_moves, piece, i, j)
    local bIsWhite = piece.color == "white"

    if has_oposite_piece_in_position(bIsWhite, i - 1 , j - 1) or has_no_piece_in_position(i -1 , j -1) then
        table.insert(_moves, {i = i - 1, j = j -1})
    end

    if has_oposite_piece_in_position(bIsWhite, i , j - 1) or has_no_piece_in_position(i, j- 1) then
        table.insert(_moves, {i = i, j = j- 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 1 , j - 1) or has_no_piece_in_position(i + 1, j - 1) then
        table.insert(_moves, {i = i + 1, j = j - 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i -1 , j ) or has_no_piece_in_position(i -1, j) then
        table.insert(_moves, {i = i - 1, j = j})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 1 , j) or has_no_piece_in_position(i + 1, j) then
        table.insert(_moves, {i = i + 1, j = j})
    end

    if has_oposite_piece_in_position(bIsWhite, i - 1, j + 1) or has_no_piece_in_position(i  - 1, j + 1) then
        table.insert(_moves, {i = i  - 1, j = j + 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i , j) or has_no_piece_in_position(i, j) then
        table.insert(_moves, {i = i, j = j + 1})
    end

    if has_oposite_piece_in_position(bIsWhite, i + 1, j + 1) or has_no_piece_in_position(i + 1, j + 1) then
        table.insert(_moves, {i = i + 1, j = j + 1})
    end

    return _moves
end

local function move_queen(_moves, piece, i, j)

    _moves = move_rook(_moves, piece, i, j)
    _moves = move_bishop(_moves, piece, i, j)
    _moves = move_king(_moves, piece, i, j)

    return _moves
end

-- return a table of valid locations this piece can move to
local function moves(piece, i, j)
    local _moves = {}

    -- if it is the turn of the other player we abort
    if bIsWhitesTurn and piece.color == "black" then return _moves end
    if not bIsWhitesTurn and piece.color == "white" then return _moves end

    if piece.piece == "pawn" then
        _moves = move_pawn(_moves, piece, i, j)
    elseif piece.piece == "rook" then
        _moves = move_rook(_moves, piece, i, j)
    elseif piece.piece == "bishop" then
        _moves = move_bishop(_moves, piece, i, j)
    elseif piece.piece == "horse" then
        _moves = move_horse(_moves, piece, i, j)
    elseif piece.piece == "queen" then
        _moves = move_queen(_moves, piece, i, j)
    elseif piece.piece == "king" then
        _moves = move_king(_moves, piece, i, j)
    end

    return _moves
end

local function reset_highlight(locations)
    locations = locations or {}

    -- reset the previous selection
    for _, location in ipairs(locations) do
        wibox_rows[location.i][location.j].reset_color()
    end


    if #locations == 0 then
        for i, row in ipairs(wibox_rows) do
            for j, _ in ipairs(row) do
                wibox_rows[i][j].reset_color()
            end
        end
    end
end

local function highlight_valid_moves(piece, i, j)
    local valid_moves = moves(piece, i, j)

    for _, location in ipairs(valid_moves) do
        wibox_rows[location.i][location.j].highlight_movable()
    end

    return valid_moves
end

local function generate_row(color, a, b, c, d, e, f, g, h)
    return {
        {color = color, piece = a, isEmpty = a == ""},
        {color = color, piece = b, isEmpty = b == ""},
        {color = color, piece = c, isEmpty = c == ""},
        {color = color, piece = d, isEmpty = d == ""},
        {color = color, piece = e, isEmpty = e == ""},
        {color = color, piece = f, isEmpty = f == ""},
        {color = color, piece = g, isEmpty = g == ""},
        {color = color, piece = h, isEmpty = h == ""}
    }
end

local function generate_row_1()
    return generate_row("white", "rook", "horse", "bishop", "king", "queen",
                        "bishop", "horse", "rook")
end
local function generate_row_2()
    return generate_row("white", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn",
                        "pawn", "pawn")
end
local function generate_row_3()
    return generate_row("", "", "", "", "", "", "", "", "")
end
local function generate_row_4()
    return generate_row("", "", "", "", "", "", "", "", "")
end
local function generate_row_5()
    return generate_row("", "", "", "", "", "", "", "", "")
end
local function generate_row_6()
    return generate_row("", "", "", "", "", "", "", "", "")
end
local function generate_row_7()
    return generate_row("black", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn",
                        "pawn", "pawn")
end
local function generate_row_8()
    return generate_row("black", "rook", "horse", "bishop", "queen", "king",
                        "bishop", "horse", "rook")
end

local play_win_animation = function () end

local field = {
    generate_row_8(), generate_row_7(), generate_row_6(), generate_row_5(),
    generate_row_4(), generate_row_3(), generate_row_2(), generate_row_1()
}

local function get_piece_on_position(i, j)
    return wibox_rows[i][j].widget.piece
end


local function move_piece(si, sj, ei, ej)
    local bWasKing = wibox_rows[ei][ej].widget.piece.piece == "king"

    local original_piece = wibox_rows[si][sj].widget.piece
    wibox_rows[ei][ej].widget.piece = original_piece

    -- the old square is now empty
    wibox_rows[si][sj].widget.piece = {color = "", piece = "", isEmpty = true}

    wibox_rows[si][sj].widget.draw_piece()
    wibox_rows[ei][ej].widget.draw_piece()

    -- we advance to the next player
    bIsWhitesTurn = not bIsWhitesTurn

    print(string.format("Moving piece to %d %d", ei, ej))

    return bWasKing
end

local function isActivePlayerPiece(piece)
    if piece == nil then
        return false
    end
    return (piece.color == "white" and bIsWhitesTurn) or (piece.color == "black" and not bIsWhitesTurn)
end

local last_selected_box = {
    bIsInMoveState = false,
    x = 0, y = 0,
}

local function create_chess_widget(image)
    local image_widget = wibox.widget.imagebox(image, true)
    local empty_widget = wibox.widget.base.empty_widget()

    local widget = wibox.container.place(image_widget)

    widget.update_image = function(_image)
        image_widget.image = _image
        widget.widget = image_widget
    end

    widget.empty = function()
        widget.widget = empty_widget
    end

    return widget
end

local function build_square(i, j, piece)

    -- the size of the chess board in pixels
    local size = math.min(screen_height, screen_width) * screen_size

    -- the start and end screen coordinates of the board
    local relative_start_x = mouse.screen.workarea.x + (screen_width - size) / 2
    local relative_start_y = mouse.screen.workarea.y + (screen_height - size) / 2

    -- our chess board consists of 8 pieces in each direction
    -- this variable holds the size of such a piece
    local increment = size / 8

    if wibox_rows[i] == nil then table.insert(wibox_rows, {}) end

    assert(wibox_rows[i][j] == nil)

    local color = beautiful.accent.hue_400

    -- make the checker pattern
    if i % 2 == 0 then
        if j % 2 == 0 then color = "#FFFFFF" end
    else
        if j % 2 == 1 then color = "#FFFFFF" end
    end

    local widget = create_chess_widget(PICTURE_DIR ..
        piece.color ..
        "_" ..
        piece.piece ..
        ".svg")

    widget.piece = piece

    wibox_rows[i][j] = wibox({
        ontop = true,
        visible = true,
        x = relative_start_x + (j - 1) * increment,
        y = relative_start_y + (i - 1) * increment,
        type = "dock",
        bg = color .. "99",
        border_width = 2,
        border_color = "#FFF",
        width = increment,
        height = increment,
        screen = mouse.screen,
        widget = widget
    })

    wibox_rows[i][j].reset_color = function()
        wibox_rows[i][j].bg = color .. "99"
        wibox_rows[i][j].highlighted = false
    end

    wibox_rows[i][j].highlight_movable = function()
        wibox_rows[i][j].bg = "#5BC236"
        wibox_rows[i][j].highlighted = true
    end

    wibox_rows[i][j].highlight = function()
        wibox_rows[i][j].bg = color
    end

    local previous_moves = {}

    -- next step is to show all possible moves for the selected piece
    widget:connect_signal("mouse::enter", function()
        local _piece = get_piece_on_position(i,j)

        if isActivePlayerPiece(_piece) then
            wibox_rows[i][j].highlight()

            previous_moves = highlight_valid_moves(_piece, i, j)
        end
    end)

    widget:connect_signal("mouse::leave", function()
        if last_selected_box.x == i and last_selected_box.y == j and last_selected_box.bIsInMoveState then
            return
        end

        if wibox_rows[i][j].highlighted then
            return
        end

        wibox_rows[i][j].reset_color()

        local _piece = get_piece_on_position(i,j)

        if isActivePlayerPiece(_piece) then
            reset_highlight(previous_moves)
            previous_moves = {}
        end
    end)

    widget.draw_piece = function()
        local _piece = get_piece_on_position(i,j)

        if _piece.isEmpty then
            widget.empty()
        else
            widget.update_image(PICTURE_DIR ..
            _piece.color ..
                "_" ..
                _piece.piece ..
                ".svg")
        end
    end

    local function select_piece(_piece)
        last_selected_box.x = i
        last_selected_box.y = j

        last_selected_box.bIsInMoveState = true

        reset_highlight()

        wibox_rows[i][j].highlight()

        previous_moves = highlight_valid_moves(_piece, i, j)
    end

    local function place_piece()
        print(i, j)
        if not wibox_rows[i][j].highlighted then return end

        local bWasKing = move_piece(last_selected_box.x, last_selected_box.y, i,j)

        reset_highlight()

        last_selected_box.bIsInMoveState = false

        if bWasKing then
            play_win_animation()
        end
    end

    widget:connect_signal("button::press", function ()
        local _piece = get_piece_on_position(i,j)

        local isOurPiece = isActivePlayerPiece(_piece)

        if last_selected_box.bIsInMoveState and not isOurPiece then
            place_piece()
        elseif isOurPiece then
            select_piece(_piece)
        end

    end)

end

local function generate_field()
    for i, row in ipairs(field) do
        for j, piece in ipairs(row) do build_square(i, j, piece) end
    end
end

local function cleanup()
    print("Cleaning game up")
    field = nil

    for _, row in ipairs(wibox_rows) do
        for _, _wibox in ipairs(row) do _wibox.visible = false end
    end

    wibox_rows = nil

    collectgarbage("collect")
end

local background

local function generate_background()
    local widget = wibox.container.background(wibox.widget.textbox())

    background = wibox({
        ontop = true,
        visible = true,
        x = mouse.screen.workarea.x,
        y = mouse.screen.workarea.y,
        type = "dnd", -- to skip bluring
        bg = "#00000000",
        width = screen_width,
        height = screen_height,
        screen = mouse.screen,
        widget = widget
    })

    widget:connect_signal("button::press", function()
        background.visible = false

        -- luacheck: ignore 331
        background = nil
        cleanup()
    end)
end

play_win_animation = function ()
    cleanup()
    background.visible = false

    local animate = require("lib-tde.animations").createAnimObject

    -- the size of the chess board in pixels
    local size = math.min(screen_height, screen_width) * screen_size

    -- the start and end screen coordinates of the board
    local relative_start_x = mouse.screen.workarea.x + (screen_width - size) / 2
    local relative_start_y = mouse.screen.workarea.y + (screen_height - size) / 2

    local win = wibox({
        ontop = true,
        visible = true,
        x = relative_start_x,
        y = relative_start_y,
        type = "drop",
        bg = beautiful.accent.hue_400 .. "44",
        width = size,
        height = size,
        screen = mouse.screen,
        widget = wibox.widget.base.empty_widget()
    })

    local new_size = math.min(screen_height, screen_width)

    local new_x = mouse.screen.workarea.x + (screen_width - new_size) / 2
    local new_y = mouse.screen.workarea.y + (screen_height - new_size) / 2

    -- the last move flipped the board, so we change it to the winner
    if not bIsWhitesTurn then
        win.widget = wibox.container.place(wibox.widget.imagebox(PICTURE_DIR .."white_king.svg"))
    else
        win.widget = wibox.container.place(wibox.widget.imagebox(PICTURE_DIR .."black_king.svg"))
    end

    animate(2.5, win, {width = new_size, height = new_size, x = new_x, y = new_y}, "inBounce", function ()
        animate(2.5, win, {x = relative_start_x, y = relative_start_y, width = size, height = size}, "inBounce", function ()
            win.visible = false
        end)
    end)
end

local function start()
    print("Starting game")

    generate_background()

    generate_field()
end

start()
