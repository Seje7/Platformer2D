local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.Sounds"
local Player = require "src.game.Player"
local Camera = require "libs.sxcamera"
local HUD = require "src.game.HUDimproved"
local Tween = require "libs.tween"
local wordPostion = { x = 0, y = 120, alpha = 0 }  -- creates a table of the word position
local liftWord = Tween.new(2, wordPostion, { y = 50 }) -- Tween animation


local scoreStore = 0

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("CS489 Platformer")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, { fullscreen = false, resizable = true })
    math.randomseed(os.time()) -- RNG setup for later

    player = Player(0, 0)
    hud = HUD(player)

    camera = Camera(gameWidth / 2, gameHeight / 2,
        gameWidth, gameHeight)
    camera:setFollowStyle('PLATFORMER')

    stagemanager:setPlayer(player)
    stagemanager:setCamera(camera)
    --stagemanager:setStage(1)

    titleFont = love.graphics.newFont("fonts/Kaph-Regular.ttf", 26)       -- font of game over sentence
    smallerTitleFont = love.graphics.newFont("fonts/Kaph-Regular.ttf", 13) -- font of game over sentence
    stagemanager:setStage(0)
end

-- When the game window resizes
function love.resize(w, h)
    Push:resize(w, h) -- must called Push to maintain game resolution
end

-- Event for keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    elseif key == "return" and gameState == "start" then
        gameState = "play"
        stagemanager:setStage(1)
    else
        player:keypressed(key)
    end
end

-- Event to handle mouse pressed (there is another for mouse release)
function love.mousepressed(x, y, button, istouch)
    gx, gy = Push:toGame(x, y)
end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    scoreStore = player.gems
    if player.lives <= 0 and gameState ~= "over" then
        gameState = "over"
        stagemanager:currentStage():stopMusic()
        Sounds["game_over"]:play()
    end

    if gameState == "play" then
        stagemanager:currentStage():update(dt)
        player:update(dt, stagemanager:currentStage())
        hud:update(dt)

        camera:update(dt)
        camera:follow(
            math.floor(player.x + 48), math.floor(player.y))
        if scoreStore == 3 then
            gameState = "completed"
        end
    elseif gameState == "start" then

    elseif gameState == "over" then

    elseif gameState == "completed" then
        liftWord:update(dt)
    end
end

-- Draws the game after the update
function love.draw()
    Push:start()
    -- always draw between Push:start() and Push:finish()

    if gameState == "play" then
        drawPlayState()
    elseif gameState == "start" then
        drawStartState()
    elseif gameState == "completed" then
        drawCompletionState()
    elseif gameState == "over" then
        drawGameOverState()
    else                              --Error, should not happen
        love.graphics.setColor(1, 1, 0) -- Yellow
        love.graphics.printf("Error", 0, 20, gameWidth, "center")
    end

    Push:finish()
end

function drawPlayState()
    stagemanager:currentStage():drawBg()

    camera:attach()

    stagemanager:currentStage():draw()
    player:draw()

    camera:detach()

    hud:draw()
end

function drawStartState()
    love.graphics.setColor(0.3, 0.3, 0.3)                                       -- dark gray
    stagemanager:currentStage():drawBg()
    stagemanager:currentStage():draw()                                          -- draw Stage zero
    player:draw()                                                               -- and the player sprite
    love.graphics.setColor(1, 1, 0)                                             -- Yellow
    love.graphics.printf("CS489 Platformer", titleFont, 0, 20, gameWidth, "center") -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
    love.graphics.printf("Press Enter to Start", 0, 100, gameWidth, "center")   -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
end

function drawGameOverState()
    love.graphics.setColor(0.3, 0.3, 0.3) -- makes it show ontop the already exisiting background
    stagemanager:currentStage():drawBg()
    camera:attach()                     -- draw moving objects within attach() - detach()
    stagemanager:currentStage():draw()
    player:draw()
    camera:detach() -- ends camera effect

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.printf("Game Over", titleFont, 0, 80, gameWidth, "center")
    love.graphics.printf("Total Score " .. player.score, 0, 110, gameWidth, "center") -- shows the score

    --love.graphics.printf("Press Enter to Start Again", 0,120,gameWidth,"center")
end

function drawCompletionState()
    love.graphics.setColor(0.3, 0.3, 0.3) -- makes it show ontop the already exisiting background
    stagemanager:currentStage():drawBg()

    stagemanager:currentStage():drawBg()
    stagemanager:currentStage():draw()                                         -- draw Stage zero

    love.graphics.setColor(1, 0, 0)                                            -- red
    love.graphics.printf("STAGE COMPLETED", titleFont, 0, 20, gameWidth, "center") -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
    love.graphics.printf("SCORE: " .. player.score, smallerTitleFont, wordPostion.x, wordPostion.y, gameWidth, "center")
    love.graphics.printf("GEMS: " .. player.gems, smallerTitleFont, wordPostion.x, wordPostion.y + 20, gameWidth,"center")
    love.graphics.printf("COINS COLLECTED: " .. player.coins, smallerTitleFont, wordPostion.x, wordPostion.y + 40,
        gameWidth, "center")
    --love.graphics.printf("Press Enter to Continue",smallerTitleFont ,wordPostion.x, wordPostion.y + 100,gameWidth,"center") -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
end
