
Word = {}
Word.__index = Word

function Word:new(o)
    local this = o or {}
    setmetatable(this, self)
    this.word = word_collection[math.random(#word_collection)]
    this.width = font:getWidth(this.word)
    this.height = font:getHeight()
    this.state = "active"
    this.body = love.physics.newBody(world, math.random(650 - this.width) + this.width / 2, 0, "dynamic")
    this.shape = love.physics.newRectangleShape(this.width, this.height)
    this.fixture = love.physics.newFixture(this.body, this.shape)
    return this
end

function Word:setState(newState)
    if self.state == "active" and newState == "exploding" then
        local x, y = self.body:getPosition()
        self.body:destroy()
        self.explosionTimer = 2
        self.particleX = x
        self.particleY = y
        local image = love.graphics.newImage("particle.png")
        self.particleEffect = love.graphics.newParticleSystem(image, 32)
        self.particleEffect:setParticleLifetime(1, 3)
        self.particleEffect:setEmissionRate(8)
	    self.particleEffect:setSizeVariation(1)
    	self.particleEffect:setLinearAcceleration(-500, -200, 500, 200)
        self.particleEffect:setColors(1, 1, 1, 1, 1, 1, 1, 0)
        --print("exploding")
    elseif self.state == "exploding" and newState == "finished" then
        --print("Finished")
    end
    self.state = newState
end

function Word:update(dt) 
    if self.state == "exploding" then
        self.particleEffect:update(dt)
        self.explosionTimer = self.explosionTimer - dt
        if self.explosionTimer <= 0 then
            self:setState("finished")
        end
    end
end

function Word:draw()
    if self.state == "active" then
        local angle = self.body:getAngle()
        local x, y = self.body:getPosition()
        love.graphics.print(self.word, x, y, angle, 1, 1, self.width / 2, self.height / 2)
    elseif self.state == "exploding" then 
        love.graphics.draw(self.particleEffect, self.particleX, self.particleY)
    end
    --love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end

function Word:destroy()
    if self.state ~= "exploding" then
        self.body:destroy()
    end
    self:setState("finished")
end

return Word