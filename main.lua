
-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end
  
  -- get all lines from a file, returns an empty 
  -- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end
    return lines
end

local Word = require "Word"

function scoreEntry(entry) 
    local found = 0
    for i, word in ipairs(objects.words) do
        if word.word == entry then
            word:setState("exploding")
            found = found + 1
        end
    end
    if found > 0 then
        print("success")
    else
        print("fail")
    end
end

function love.keypressed(key)
    if #key == 1 and string.byte(key) > 31 and string.byte(key) < 127 then
        currentEntry = currentEntry .. key
    elseif key == "return" then
        scoreEntry(currentEntry)
        currentEntry = ""
    end
end

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 7, true)

    font = love.graphics.newFont("ka1.ttf", 24)
    word_collection = lines_from("words.txt")

    currentEntry = ""

    objects = {}

    objects.words = {}
    objects.words[#objects.words + 1] = Word:new()
    newWordCountdown = 3.0
    newWordCurrent = newWordCountdown

    objects.floor = {}
    objects.floor.body = love.physics.newBody(world, 650/2, 600)
    objects.floor.shape = love.physics.newRectangleShape(650, 10)
    objects.floor.fixture = love.physics.newFixture(objects.floor.body, objects.floor.shape)


    love.window.setMode(650, 650)
end

function love.update(dt)
    newWordCurrent = newWordCurrent - dt
    if newWordCurrent <= 0 then
        objects.words[#objects.words + 1] = Word:new()
        newWordCurrent = newWordCountdown
    end
    for i, word in ipairs(objects.words) do
        word:update(dt)
    end
    world:update(dt)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    for i, word in ipairs(objects.words) do 
        if word.state == "active" then
            local angle = word.body:getAngle()
            local x, y = word.body:getPosition()
            love.graphics.print(word.word, x, y, angle, 1, 1, word.width / 2, word.height / 2)
        elseif word.state == "exploding" then 
            love.graphics.draw(word.particleEffect, word.particleX, word.particleY)
        end
        --love.graphics.polygon("line", word.body:getWorldPoints(word.shape:getPoints()))
    end

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.polygon("fill", objects.floor.body:getWorldPoints(objects.floor.shape:getPoints()))

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(currentEntry, 20, 610)
end