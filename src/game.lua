require "effect"

love.graphics.setDefaultFilter("nearest","nearest")

-- Table of all game actor
local actors = {}

local game = {
   scroll = 0
}

local cateye = require "actors/cateye"
local wall = require "actors/bg"

game.shake = 0

game.init = function ()
   game.addactor(nil, cateye, 180, 40)
   game.addactor(nil, cateye, 200, 120)
   game.addactor(nil, cateye, 220, 40)
   game.addactor(nil, cateye, 240, 120)
   game.addactor(nil, cateye, 260, 40)
   game.addactor(nil, cateye, 280, 120)
   game.addactor(nil, require "actors/player", 40, 80)
   game.addactor(nil, wall, 0, 0)
   game.addactor(nil, wall, 0, 160)
end

game.addactor = function (parent, newactor, x, y)
   local index = table.getn(actors) + 1
   actors[index] = {} -- Fixes issue with :new calling actors.add
   actors[index] = newactor:new(x, y, parent)
end

local collideswith = function (send, recv)
   local sq = function(x) return x*x end

   -- a^2 + b^2 < c^2
   local circle_circle = function (c1, c2)
      local size = sq(c1.size + c2.size)
      local dist = sq(c1.x-c2.x) + sq(c1.y-c2.y)
      return (size > dist)
   end

   -- Rectangle collisions
   local field_field = function (f1, f2)
      local distx = f1.x - f2.x
      local sizex = f1.width + f2.width
      local skewdist = distx * (f1.skew + f2.skew)
      local disty = f1.y - f2.y
      local sizey = f1.height + f2.height
      return(math.abs(distx) < sizex and math.abs(disty)+skewdist < sizey)
   end

   -- Treat a circle like a field.
   -- This makes corner collisions not work right. Avoid those.
   local circle_field = function (c, f)
      local circ2field = {
	 x = c.x, y = c.y,
	 width = c.size, height = c.size,
	 skew = 0,
      }
      return field_field(circ2field, f)
   end

   if send.shape == "circle" then
      if recv.shape == "circle" then return circle_circle(send, recv) end
      if recv.shape == "field"  then return circle_field(send, recv) end
   elseif send.shape == "field" then
      if recv.shape == "circle" then return circle_field(recv, send) end
      if recv.shape == "field"  then return field_field(send, recv) end
   end
end

game.update = function ()
   -- Check all hitboxes
   for irecv,recv in ipairs(actors) do
      if recv.recvbox then
	 for isend,send in ipairs(actors) do
	    if send.sendbox and send.class ~= recv.class then
	       recv.recvbox.x = recv.x
	       recv.recvbox.y = recv.y
	       send.sendbox.x = send.x
	       send.sendbox.y = send.y
	       if collideswith(recv.recvbox, send.sendbox) then
		  recv:collide(send)
	       end
	    end
	 end
      end
   end

   for k,v in ipairs(actors) do
      if v.despawn then table.remove(actors, k) end
   end

      -- Update all actor states
   for _,v in ipairs(actors) do v:update() end

   -- TODO: add visscroll for when video is separate
   game.scroll = game.scroll + 0.25

   game.shake = (game.shake > 1) and game.shake-1 or 0
end

game.draw = function ()
   -- Passes x and y to self for scrolling...todo
   table.sort(actors,
	      function (o1, o2)
		 return (o1.depth > o2.depth)
	      end
   )
   effect.draw(game.scroll)
   for _,v in ipairs(actors) do
      local shake = game.shake * ((game.shake % 2) - 0.5)
      if v.draw then
	 v:draw(math.floor(v.x - game.scroll + 0.5),
		math.floor(v.y + 0.5 + shake))
      end
   end
end

return game
