local img = love.graphics.newImage("img/player.png")
local iwidth, iheight = img:getDimensions()
local sound_shoot = love.audio.newSource("sound/playershot.wav", "static")
local sound_die = love.audio.newSource("sound/playerdie.wav", "static")
local sound_asplode = love.audio.newSource("sound/asplode.wav", "static")

local bullet_sheet = animation.sheet(0, 80, 8, 8, iwidth, iheight, 3)
local bullet = {
   new = function (self, x, y, parent)
      love.audio.stop(sound_shoot)
      love.audio.play(sound_shoot)
      local o = {
	 class = "player",
	 depth = 125,
	 x=x, y=y,
	 dx = parent.dx + 3,
	 dy = parent.dy,
	 hitbox = {shape="circle", size=2, send=true, recv=true},
      }
      setmetatable(o, self)
      self.__index = self
      return o
   end,

   update = function (self)
      self.x = self.x + self.dx
      self.y = self.y + self.dy
      self.despawn = (self.x > game.scroll+256)
   end,

   draw = function (self, x, y)
      love.graphics.draw(
	 img, bullet_sheet[1], x, y,
	 0, 1, 1, 4, 4)
      love.graphics.draw(
	 img, bullet_sheet[2],
	 x-self.dx, y-self.dy,
	 0, 1, 1, 4, 4)
      love.graphics.draw(
	 img, bullet_sheet[3],
	 x-self.dx*2, y-self.dy*2,
	 0, 1, 1, 4, 4)
   end,

   collide = function (self, with)
      self.despawn = true
   end
}

local white_sheet = animation.sheet(0, 0, 20, 16, iwidth, iheight, 7)
local white = {
   new = function (self, x, y, parent)
      local o = {
	 depth=150,
	 x=x, y=y,
	 parent = parent,
      }

      setmetatable(o, self)
      self.__index = self
      return o
   end,

   update = function (self)
      self.despawn = self.parent.despawn
   end,

   draw = function (self, x, y)
      local frame = white_sheet[math.ceil(self.parent.statetime * 2)]
	 or white_sheet[1]
      love.graphics.draw(img, frame,
			 x, y,
			 0, 1, 1, 7, 7)
      self.x = self.parent.x
      self.y = self.parent.y
   end
}

local dead_player = {
   new = function (self)
      local o = {resettimer = 120,}
      setmetatable(o, self)
      self.__index = self
      return o
   end,
   update = function (self)
      self.resettimer = self.resettimer - 1
      if(self.resettimer == 0) then game.reset() end
   end,
}

local yolk_sheet = animation.sheet(0, 16, 20, 16, iwidth, iheight, 10, 3)
local yolk_anim = {
   idle = {1, speed=0},
   shoot = {2, 3, 4, 5, 6, 7, speed=0.2},
   hurt = {11, 12, 13, 14, 15, speed=0.5},
   blink = {25, 24, 23, 22, speed=0.25},
}
local yolk = {
   anim = {
   },
   new = function (self, x, y)
      local o = {
	 class = "player",
	 depth=100,
	 x=x, y=y,
	 dx=0, dy=0,
	 anim = yolk_anim.idle,
	 statetime = 0,
	 hitbox = {shape="circle", size=3, send=true, recv=true},
      }
      setmetatable(o, self)
      self.__index = self

      game.addactor(o, white, x, y)

      return o
   end,

   update = function (self)
      -- Shooting --
      if input.b > 0 and self.anim == yolk_anim.idle then
	 game.addactor(self, bullet, self.x, self.y)
	 self.statetime = 0
	 self.anim = yolk_anim.shoot
      end

      -- Movement --
      if input.dd > 0 then self.dy = self.dy + 0.5 end -- Input
      if input.du > 0 then self.dy = self.dy - 0.5 end
      if input.dl > 0 then self.dx = self.dx - 0.5 end
      if input.dr > 0 then self.dx = self.dx + 0.5 end

      local anglemotion = math.sqrt(self.dx*self.dx + self.dy*self.dy)
      local friction = 0.95 - ((anglemotion) * 0.1)
      self.dx = self.dx * friction
      self.dy = self.dy * friction

      if math.abs(self.dx) < 0.1 then self.dx = 0 end -- Velocity floor
      if math.abs(self.dy) < 0.1 then self.dy = 0 end

      self.x = self.x + self.dx -- Velocity
      self.y = self.y + self.dy

      self.x = math.max(self.x, game.scroll) -- Screen limits
      self.x = math.min(self.x, game.scroll+240)

      -- State/animation --
      self.statetime = self.statetime + self.anim.speed -- Keep track of time

      if not self.anim[math.floor(self.statetime)+1] then -- Over? idle.
	 self.anim = yolk_anim.idle
	 self.statetime = 0
      end
   end,

   draw = function (self,x,y)
      local frame = yolk_sheet[self.anim[math.floor(self.statetime)+1]]
      love.graphics.draw(
	 img, frame, x, y,
	 0, 1, 1, 7, 7)
   end,

   collide = function (self, with)
      if with.class == "enemy" then
	 love.audio.play(sound_asplode)
	 love.audio.play(sound_die)
	 game.shake = 40
	 effect.asplode(self.x, self.y, 135, 182, 195, 5, 100)
	 game.addactor(nil, dead_player)
	 self.despawn = true
      end
   end
}

return yolk
