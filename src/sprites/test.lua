local img = love.graphics.newImage("img/testcirc.png")

test = {
   new = function (self)
      o = {}
      setmetatable(o, self)
      self.__index = self

      o.sendbox = {
	 size = 23,
      }
      o.recvbox = {
	 size = 23,
      }
      o.dx, o.dy = 0, 0

      return o
   end,

   update = function (self)
      self.dx = self.dx * 0.95
      self.dy = self.dy * 0.95
      self.x = self.x + self.dx
      self.y = self.y + self.dy
      self.sendbox.x = self.x
      self.sendbox.y = self.y
      self.recvbox.x = self.x
      self.recvbox.y = self.y
   end,

   draw = function (self,x,y)
      love.graphics.draw(img,math.floor(x),math.floor(y))
   end,

   collide = function (self, with)
      self.dx = with.dx
      self.dy = with.dy
      self.x = self.x + with.dx
      self.y = self.y + with.dy
   end
}

return test
