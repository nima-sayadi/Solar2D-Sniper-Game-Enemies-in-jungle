-- Imports
local widget = require( "widget" );
util = require("library.utils");

-- Set variables
local w = display.actualContentWidth;
local h = display.actualContentHeight;
local midX,midY = w/2,h/2;
local posDiffX,posDiffY,firstX,firstY,secondX,secondY;
local currentScore = 0;
local enemiesArr = {};
local enemiesAreDeadArr = {};
local enemiesArryOldCoordinatesX,enemiesArryOldCoordinatesY = {},{};
local groupEnemyOldCoordinatesX,groupEnemyOldCoordinatesY = {},{};
local sumDiffX,sumDiffY = 0,0;
local enemyCounter,movesCounter = 1,1;
local enemiesArrSize = 0;
-- Number of total enemies :
local EnemiesNumbers = 20;

-- Main objects
local maskGroup = display.newGroup();
local topLayerGroup = display.newGroup();
local groupEnemy = display.newGroup();
local groupEnemyTopLayer = display.newGroup();
local mask = graphics.newMask("./assets/snipe.jpg");
local maskLayerBackground = display.newImageRect("./assets/bg.png",w,h,0,0);
local topLayerBackground = display.newImageRect("./assets/bg.png",w,h,0,0);
local scoreBox = display.newRoundedRect(w/2,70,350,100,25);
local scoreText = display.newText("Score : 0" , w/2 , 70 , native.systemFont , 64);
local scopeBtn = widget.newButton({
    label = "Scope",
    fontSize = 45,
    width = 200,
    height = 200,
    defaultFile = "./assets/circle-btn.png",
    overFile = "./assets/circle-btn.png",
    labelColor = { default={ 0/255, 0/255, 0/255 } },
    labelYOffset = 120,
});
local closeBtn = widget.newButton({
    width = 200,
    height = 200,
    defaultFile = "./assets/close.png",
    overFile = "./assets/close.png",
});
local shootBtn = widget.newButton({
    width = 200,
    height = 200,
    defaultFile = "./assets/fire-btn.png",
    overFile = "./assets/fire-btn.png",
});
--[[
    For further develpment (Adding menu and loading Screen) : 
    local menuGroup = display.newGroup();
    local menuLayerBackground = display.newImageRect("./assets/bg.png",w,h,0,0);
]]

-- Set initial values
scoreText:setFillColor(255/255,0/255,0/255);
maskGroup:insert(maskLayerBackground);
topLayerGroup:insert(topLayerBackground);
maskGroup.x,maskGroup.y = midX,midY;
topLayerGroup.x,topLayerGroup.y = midX,midY;
scopeBtn.x,closeBtn.x,shootBtn.x = w - 100,w - 120,120;
scopeBtn.y,closeBtn.y,shootBtn.y = h - 150,h - 120,h - 120;
closeBtn.isVisible,shootBtn.isVisible = false,false;

--[[
    For further develpment (Adding menu and loading Screen) : 
    scoreText.isVisible,scoreBox.isVisible,scopeBtn.isVisible = false,false,false;
    menuGroup:insert(menuLayerBackground);
    menuGroup.x,menuGroup.y = midX,midY;
]]

local function makeEnemies(number)
    if (number%2 ~= 0) then
        number = number + 1;
    end
    for i = 1 , number do
        local gp = display.newGroup();
        local randChar = math.random(1,3);
        local randX,randY,scale;
        if (i > number/2) then
            randX = math.random(700,5000);
            randY = math.random(-50,500);
            scale = -1;
        else
            randX = -w - math.random(100,5000);
            randY = math.random(-50,500);
            scale = 1;
        end
        local eachEnemyArry = {};
        for j = 1, 19 do
            local eachEnemyState = display.newImage("./assets/" .. randChar .. "/" .. j .. ".png");
            eachEnemyState.width,eachEnemyState.height = 450,250;
            eachEnemyState.x,eachEnemyState.y,eachEnemyState.xScale = randX,randY,scale;
            if j ~= 1 then
                eachEnemyState.isVisible = false;
            end
            table.insert(eachEnemyArry,eachEnemyState);
            gp:insert(eachEnemyState);
        end
        groupEnemy:insert(gp);
        enemiesArr[i] = eachEnemyArry;
        enemiesAreDeadArr[i] = false;
    end
    maskGroup:insert(groupEnemy);
    topLayerGroup:insert(groupEnemy);
    enemiesArrSize = table.getn(enemiesArr);
    maskGroup:setMask(mask);
end

local function isOnTarget(character)
    if(midX > character.contentBounds.xMin) and
    (midX < character.contentBounds.xMax) and
    (midY > character.contentBounds.yMin) and
    (midY < character.contentBounds.yMax) then
        return true;
    end
    return false;
end

function handleScopeOpen(e)
    if ( "began" == e.phase ) then
        sumDiffX,sumDiffY = 0,0;
        maskGroup:insert(groupEnemy);
        topLayerGroup:remove(groupEnemy);
        topLayerGroup.isVisible = false;
        maskGroup.isVisible = true;
        maskLayerBackground:addEventListener("touch", handleCoordinates);
        maskGroup.maskScaleX,maskGroup.maskScaleY = .2,.4;
        maskLayerBackground.xScale,maskLayerBackground.yScale = 2,2;
        for i = 1, enemiesArrSize do
            for j = 1,19 do
                if enemiesArr[i][j].xScale == -1 then
                    enemiesArr[i][j].xScale,enemiesArr[i][j].yScale = -2,2;
                else
                    enemiesArr[i][j].xScale,enemiesArr[i][j].yScale = 2,2;
                end
                enemiesArr[i][j]:translate(enemiesArr[i][j].x,enemiesArr[i][j].y)
            end
            groupEnemy[i]:translate(groupEnemy[i].x,groupEnemy[i].y)
        end
        scopeBtn.isVisible = false;
        closeBtn.isVisible = true;
        shootBtn.isVisible = true;
    end
end

function handleScopeClose(e)
    maskLayerBackground:removeEventListener("touch",handleCoordinates);
    if ( "began" == e.phase ) then
        maskGroup:remove(groupEnemy);
        topLayerGroup:insert(groupEnemy);
        topLayerGroup.isVisible = true;
        maskGroup.isVisible = false;
        maskLayerBackground.xScale,maskLayerBackground.yScale = 1,1;
        maskLayerBackground.x,maskLayerBackground.y = 0,0;
        local tempGX,tempGY,tempX,tempY;
        for i = 1, enemiesArrSize do
            tempGX,tempGY = groupEnemy[i].x,groupEnemy[i].y;
            for j = 1,19 do
                if enemiesArr[i][j].xScale == -2 then
                    enemiesArr[i][j].xScale,enemiesArr[i][j].yScale = -1,1;
                else
                    enemiesArr[i][j].xScale,enemiesArr[i][j].yScale = 1,1;
                end
                enemiesArr[i][j].x,enemiesArr[i][j].y = enemiesArr[i][j].x/2,enemiesArr[i][j].y/2;
            end
            if(groupEnemyOldCoordinatesX[1] == nil) then
                groupEnemy[i].x,groupEnemy[i].y = tempGX/2,tempGY/2;
            else
                groupEnemy[i].x,groupEnemy[i].y = groupEnemyOldCoordinatesX[i]/2,groupEnemyOldCoordinatesY[i]/2;
            end

        end
        
        groupEnemyOldCoordinatesX = {};
        scopeBtn.isVisible = true;
        closeBtn.isVisible = false;
        shootBtn.isVisible = false;
    end
end

function handleCoordinates(e)
    if ("began" == e.phase) then
        firstX = e.x;
        firstY = e.y;
    end
    if ( "moved" == e.phase ) then
        secondX = e.x;
        secondY = e.y;
        posDiffX = secondX - firstX;
        posDiffY = secondY - firstY;
        sumDiffX = sumDiffX + posDiffX/30;
        sumDiffY = sumDiffY + posDiffY/30;
        maskLayerBackground:translate(posDiffX/30,posDiffY/30);
        for i = 1, enemiesArrSize do
            groupEnemy[i]:translate(posDiffX/30,posDiffY/30);
            groupEnemyOldCoordinatesX[i] = groupEnemy[i].x - sumDiffX;
            groupEnemyOldCoordinatesY[i] = groupEnemy[i].y - sumDiffY;
        end
    end
end

function handleShooting(e)
    if ( "began" == e.phase ) then
        util:playShoot("gunshot.mp3",06,1);
        for i = 1,enemiesArrSize do
            for j = 1 , 18 do
                if (isOnTarget(enemiesArr[i][j]) and enemiesAreDeadArr[i] == false) then
                    currentScore = currentScore + 1;
                    scoreText.text = "Score : " .. currentScore;
                    enemiesArr[i][19].isVisible = true;
                    enemiesArr[i][j].isVisible = false;
                    enemiesAreDeadArr[i] = true;
                    return;
                end
            end
        end
    end
end

local function framesLogic()
    local moveAmount;
    for i = 1, enemiesArrSize do
        for j = 1, 19 do
            enemiesArr[i][j].isVisible = false;
        end
    end
    for i = 1, enemiesArrSize do
        if (enemiesAreDeadArr[i] == false) then
            if enemiesArr[i][movesCounter].xScale == -1 or enemiesArr[i][movesCounter].xScale == -2 then
                moveAmount = -6;
            else
                moveAmount = 6;
            end
            enemiesArr[i][movesCounter].isVisible = true;
            groupEnemy[i].x = groupEnemy[i].x + moveAmount;
        else
            enemiesArr[i][19].isVisible = true;
        end
    end
end

function fps()
    if movesCounter == 19 then
        movesCounter = 1
    end
    framesLogic();
    movesCounter = movesCounter + 1;
end

function init()
    makeEnemies(EnemiesNumbers);
    Runtime:addEventListener("enterFrame" , fps);
    scopeBtn:addEventListener("touch", handleScopeOpen );
    closeBtn:addEventListener("touch", handleScopeClose );
    shootBtn:addEventListener("touch", handleShooting );
end

init();
