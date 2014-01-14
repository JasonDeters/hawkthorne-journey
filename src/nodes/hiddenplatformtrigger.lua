local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'

local hiddenPlatformTrigger = {}
hiddenPlatformTrigger.__index = hiddenPlatformTrigger
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
hiddenPlatformTrigger.isInteractive = true

function hiddenPlatformTrigger.new(node, collider)
    local art = {}
    setmetatable(art, hiddenPlatformTrigger)
    art.x = node.x
    art.y = node.y
    art.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    art.bb.node = art
    art.player_touched = false
    art.fixed = false
    art.prompt = nil
    
    assert( node.properties.sprite, 'You must provide a sprite property for the hiddenPlatformTrigger node' )
    assert( node.properties.width, 'You must provide a width property for the hiddenPlatformTrigger node' )
    assert( node.properties.height, 'You must provide a height property for the hiddenPlatformTrigger node' )
    assert( node.properties.message, 'You must provide a message property for the hiddenPlatformTrigger node' )
    assert( node.properties.target, 'You must provide a target property for the hiddenPlatformTrigger node' )
    
    art.sprite = node.properties.sprite
    art.width = tonumber(node.properties.width)
    art.height = tonumber(node.properties.height)
    art.message = node.properties.message
    art.target = node.properties.target
    
    art.image = love.graphics.newImage('images/' .. art.sprite .. '.png')
    art.crooked_img = love.graphics.newQuad( art.width, 0, art.width, art.height, art.image:getWidth(), art.image:getHeight() )
    art.fixed_img = love.graphics.newQuad( 0, 0, art.width, art.height, art.image:getWidth(), art.image:getHeight() )
    
    collider:setPassive(art.bb)
    return art
end

function hiddenPlatformTrigger:update(dt)
end

function hiddenPlatformTrigger:enter()
    Gamestate.currentState().platform[self.target].node:hide()
end

function hiddenPlatformTrigger:draw()
    if self.fixed then
        love.graphics.drawq(self.image, self.fixed_img, self.x, self.y)
    else
        love.graphics.drawq(self.image, self.crooked_img, self.x, self.y)
    end
end

function hiddenPlatformTrigger:keypressed( button, player )
    if button == 'INTERACT' and self.prompt == nil then
        player.freeze = true
        self.prompt = Prompt.new(self.message, function(result)
            if result == 'Yes' then
              Gamestate.currentState().platform[self.target].node:show()
            end
            player.freeze = false
            self.fixed = result == 'Yes'
            Timer.add(2, function() self.fixed = false end)
            self.prompt = nil
        end)
    end

    if self.prompt then
        return self.prompt:keypressed( button )
    end
end

return hiddenPlatformTrigger
