local Games = 
loadstring(game:HttpGet("#"))()

local URL = Games[game.GameId]

if URL then loadstring(game:HttpGet(URL))()
end
