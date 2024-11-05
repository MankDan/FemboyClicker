debug = false

-- DO NOT EDIT
MOUSE_LEFT_BUTTON = 1

WINDOW_TITLE = "Femboy clicker"
SCORE_LABEL = "Sharks: "
LEVEL_LABEL = "Level: "
DEBUG_KEY = "f3"

assets_path = "assets/"

font = love.graphics.newFont(50)

background = {
    red = 0.5,
    green = 0.7,
    blue = 1
}

shark = {
    image_url = assets_path .. "shark.png",
    image = love.graphics.newImage( assets_path .. "shark.png"),
    x = 100,
    y = 100,
}

upgrade = {
    button = {
        x = 20,
        y = 500,
        enabled_image_url = assets_path .. "upgrade_enabled.png",
        disabled_image_url = assets_path .. "upgrade_disabled.png",
        image = love.graphics.newImage(assets_path .. "upgrade_disabled.png")
    },
    score_increment_label = {
        x = 20,
        y = 470
    },
    cost_label = {
        x = 300,
        y = 535
    },
    starting_cost = 10,
    cost_multiplier = 5,
    cost = 1
}


score = {
    x = 10,
    y = 10,
    multiplier = 1,
    increment = 1,
    value = 0,
    next_increment = 1
}

level = {
    value = 1,
    x = 700,
    y = 10
}

function updateScoreIncrement()
    score.increment = level.value * level.value * score.multiplier
    score.next_increment = (level.value + 1) * (level.value + 1) * score.multiplier
end

function updateNextUpgradeCost()
    upgrade.cost = level.value * level.value * level.value * upgrade.cost_multiplier + upgrade.starting_cost
end

function updateUpgradeButtonImage()
    if score.value >= upgrade.cost then
        upgrade.button.image = love.graphics.newImage(upgrade.button.enabled_image_url)
    else
        upgrade.button.image = love.graphics.newImage(upgrade.button.disabled_image_url)
    end
end

function clickUpgradeButton()
    if (score.value >= upgrade.cost) then
        score.value = score.value - upgrade.cost
        level.value = level.value + 1
    end

    updateScoreIncrement()
    updateNextUpgradeCost()
end

function drawBackground()
    love.graphics.setBackgroundColor(background.red, background.green, background.blue)
end

function drawWindowTitle()
    love.window.setTitle(WINDOW_TITLE)
end

function drawShark()
    love.graphics.draw(shark.image, shark.x, shark.y)
end

function drawUpgradeButton()
    love.graphics.draw(upgrade.button.image, upgrade.button.x, upgrade.button.y)
    love.graphics.print(upgrade.cost, upgrade.cost_label.x, upgrade.cost_label.y)
    love.graphics.print(score.increment .. " -> " .. score.next_increment .. " " .. "sharks/click",
    upgrade.score_increment_label.x, upgrade.score_increment_label.y)
end

function drawScore()
    love.graphics.print(SCORE_LABEL .. score.value, score.x, score.y)
    love.graphics.print(LEVEL_LABEL .. level.value, level.x, level.y)
end

function addClickToScoreValue()
    score.value = score.value + score.increment
end

function animateShark()
    background.blue = math.random() * 0.2 + 0.8
    background.green = math.random() * 0.2 + 0.6
    background.red = math.random() * 0.2 + 0.4
end

function checkMouseSquareHitbox(object, object_x, object_y)
    object_width = object:getWidth()
    object_height = object:getHeight()

    local cursor_x, cursor_y = love.mouse.getPosition()

    left_border = object_x
    right_border = left_border + object_width
    top_border = object_y
    bottom_border = object_y + object_height

    horizontal_hit_box = (left_border <= cursor_x and right_border >= cursor_x)
    vertical_hit_box = (bottom_border >= cursor_y and top_border <= cursor_y)

    object_overlap = (horizontal_hit_box and vertical_hit_box)

    return object_overlap
end

debug_button_pressed = false
function checkDebugToggleButton()
    res = not debug_button_pressed and love.keyboard.isDown(DEBUG_KEY)
    debug_button_pressed = love.keyboard.isDown(DEBUG_KEY)
    return res
end

mouse_pressed = false
function mouseClick()
    res = (not mouse_pressed and love.mouse.isDown(MOUSE_LEFT_BUTTON))
    mouse_pressed = love.mouse.isDown(MOUSE_LEFT_BUTTON)
    return res
end

function checkMouseSquareHitboxClick(object, object_x, object_y)
    return (checkMouseSquareHitbox(object, object_x, object_y) and mouseClick())
end

function love.load()
    updateNextUpgradeCost()
    updateScoreIncrement()
    font = love.graphics.newFont(25)
    love.graphics.setFont(font)
    cursor = love.mouse.newCursor(assets_path .. "cursor.png", 0, 0)
    love.mouse.setCursor(cursor)
end

function love.update()
    if checkMouseSquareHitboxClick(shark.image, shark.x, shark.y) then
        addClickToScoreValue()
        animateShark()
    end
    if checkMouseSquareHitboxClick(upgrade.button.image, upgrade.button.x, upgrade.button.y) then
        clickUpgradeButton()
    end

    if checkDebugToggleButton() then
        debug = not debug
    end

    updateUpgradeButtonImage()
end

function love.draw()
    drawBackground()
    drawWindowTitle()

    drawShark()
    drawUpgradeButton()
    drawScore()

    _ = (debug and drawDebug())
end

function drawDebug()
    local mouse_x, mouse_y = love.mouse.getPosition()
    
    love.graphics.print("next upgrade cost: " .. upgrade.cost, 400, 460)
    love.graphics.print("click: " .. (love.mouse.isDown(MOUSE_LEFT_BUTTON) and 'true' or 'false'), 400, 480)
    love.graphics.print("Mouse position: " .. mouse_x .. ", " .. mouse_y, 400, 500)
    love.graphics.print("Shark size: " .. shark.image:getWidth() .. ", " .. shark.image:getHeight(), 400, 520)
    love.graphics.print("mouse pressed: " .. (mouse_pressed and 'true' or 'false'), 400, 540)
end
