-- Table of all game sprite
local sprites = {}

-- Functions for manipulating tables
sprite = {
   add = function (parent, newsprite, x, y)
      index = table.getn(sprites)+1
      sprites[index] = newsprite:new()
      sprites[index].x = x
      sprites[index].y = y
      sprites[index].parent = parent
   end
}

local test = require "sprites/test"
sprite.add(nil, test, 10, 10)
sprite.add(nil, test, 60, 10)

-- Basic a^2 + b^2 = c^2 circle collision
local collideswith = function (send, recv)
   local sq = function(x) return x*x end
   local size = sq(send.size + recv.size)
   local dist = sq(send.x-recv.x) + sq(send.y-recv.y)
   return (dist < size)
end

return {
   update = function ()
      -- Check all hitboxes
      for _,recv in ipairs(sprites) do
	 for _,send in ipairs(sprites) do
	    if recv.recvbox and send.sendbox and
	    collideswith(recv.recvbox, send.sendbox) then
	       recv.collide(send)
	    end
	 end
      end

      -- Update all spritesect states
      for _,v in ipairs(sprites) do v:update() end
   end,

   draw = function ()
      -- Passes x and y to self for scrolling...todo
      for _,v in ipairs(sprites) do v:draw(v.x,v.y) end
   end,
}
