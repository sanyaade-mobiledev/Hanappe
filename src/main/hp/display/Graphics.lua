local table = require("hp/lang/table")
local class = require("hp/lang/class")
local DisplayObject = require("hp/display/DisplayObject")

--------------------------------------------------------------------------------
-- Graphics機能を持ったDisplayObjectです.
-- DisplayObjectの機能に加えて、基本図形の描画を行う機能があります.
-- 
-- draw*,fill*関数で描画を行います.
-- set*関数で状態の設定を行います.
-- 描画した結果をクリアしたい場合は、clear関数をコールしてください.
-- 
-- <code>
-- example)
-- local g = Graphics:new({width = 100, height = 100})
-- g:setPenColor(1, 0, 0, 1)
-- g:fillRect()
-- g:drawRect()
-- g:setPenColor(0, 1, 0, 1)
-- g:fillRect(25, 25, 50, 50)
-- g:drawRect(25, 25, 50, 50)
-- g.parent = scene
-- </code>
--
-- @class table
-- @name Graphics
--------------------------------------------------------------------------------
local M = class(DisplayObject)

--------------------------------------------------------------------------------
-- Graphicsインスタンスを生成して返します.
-- @param params
-- @return インスタンス
--------------------------------------------------------------------------------
function M:init(params)
    assert(params)
    assert(params.width)
    assert(params.height)

    params = params or {}

    local deck = MOAIScriptDeck.new()
    self:setDeck(deck)
    self.deck = deck
    self.commands = {}

    deck:setDrawCallback(
        function(index, xOff, yOff, xFlip, yFlip)
            MOAIGfxDevice.setPenColor(self:getRed(), self:getGreen(), self:getBlue(), self:getAlpha())
            MOAIGfxDevice.setPenWidth(1)
            MOAIGfxDevice.setPointSize(1)
            for i, gfx in ipairs(self.commands) do
                gfx(self)
            end
        end
    )
    
    self:copyParams(params)
end

--------------------------------------------------------------------------------
-- パラメータを各プロパティにコピーします.
--------------------------------------------------------------------------------
function M:copyParams(params)
    if params.width and params.height then
        self.deck:setRect(0, 0, params.width, params.height)
        self:setPiv(params.width / 2, params.height / 2, 0)
    end
    DisplayObject.copyParams(self, params)
end

---------------------------------------
-- 円を描画します.
-- @param x ローカル座標
-- @param y ローカル座標
-- @param r 半径
-- @param steps 点の数
-- @return self
---------------------------------------
function M:drawCircle(x, y, r, steps)
    steps = steps and steps or 360
    local command = function(self)
        if x and y and r and steps then
            MOAIDraw.drawCircle(x, y, r, steps)
        else
            local rw = math.min(self:getWidth(), self:getHeight())
            MOAIDraw.drawCircle(0, 0, rw, 360)
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 楕円を描画します.
-- @param x ローカル座標
-- @param y ローカル座標
-- @param xRad x方向の半径
-- @param yRad y方向の半径
-- @param steps 点の数
-- @return self
---------------------------------------
function M:drawEllipse(x, y, xRad, yRad, steps)
    steps = steps and steps or 360
    local command = function(self)
        if x and y and xRad and yRad and steps then
            MOAIDraw.drawEllipse(x, y, xRad, yRad, steps)
        else
            MOAIDraw.drawEllipse(0, 0, self:getWidth(), self:getHeight(), steps)
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 引数の点を結んだ線を描画します.
-- @param ... 点の座標.x0, y0, x1, y1...
-- @return self
---------------------------------------
function M:drawLine(...)
    local args = {...}
    local command = function(self)
        MOAIDraw.drawLine(unpack(args))
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 引数の点を描画します.
-- @param ... 点の座標.x0, y0, x1, y1...
-- @return self
---------------------------------------
function M:drawPoints(...)
    local args = {...}
    local command = function(self)
        MOAIDraw.drawPoints(unpack(args))
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 放射線を描画します.
-- @param x ローカル座標
-- @param y ローカル座標
-- @param dx 線の長さ
-- @param dy 線の長さ
-- @return self
---------------------------------------
function M:drawRay(x, y, dx, dy)
    local command = function(self)
        if x and y and dx and dy then
            MOAIDraw.drawRay(x, y, dx, dy)
        else
            MOAIDraw.drawRay(0, 0, self:getWidth(), self:getHeight())
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 四角形を描画します.
-- TODO:使用してみると座標に違和感がある・・・
-- @param x0 開始のローカル座標
-- @param y0 開始のローカル座標
-- @param x1 終了のローカル座標
-- @param y1 終了のローカル座標
-- @return self
---------------------------------------
function M:drawRect(x0, y0, x1, y1)
    local command = function(self)
        if x0 and y0 and x1 and y1 then
            MOAIDraw.drawRect(x0, y0, x1, y1)
        else
            MOAIDraw.drawRect(0, 0, self:getWidth(), self:getHeight())
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 円を塗りつぶします.
-- @param x ローカル座標
-- @param y ローカル座標
-- @param r 半径
-- @param steps 点の数
-- @return self
---------------------------------------
function M:fillCircle(x, y, r, steps)
    steps = steps and steps or 360
    local command = function(self)
        if x and y and r and steps then
            MOAIDraw.fillCircle(x, y, r, steps)
        else
            local r = math.min(self:getWidth(), self:getHeight())
            MOAIDraw.fillCircle(0, 0, r, steps)
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 楕円を塗りつぶします.
-- @param x ローカル座標
-- @param y ローカル座標
-- @param xRad 半径
-- @param yRad 半径
-- @param steps 点の数
-- @return self
---------------------------------------
function M:fillEllipse(x, y, xRad, yRad, steps)
    local command = function(self)
        if x and y and xRad and yRad then
            MOAIDraw.fillEllipse(x, y, xRad, yRad, steps)
        else
            MOAIDraw.fillEllipse(0, 0, self:getWidth(), self:getHeight(), 360)
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 三角形を塗りつぶします.
-- TRIANGLE_FANに該当します.
-- @param ... 点(x, y).x0, y0, x1, y1...
-- @return self
---------------------------------------
function M:fillFan(...)
    local args = {...}
    local command = function(self)
        MOAIDraw.fillFan(unpack(args))
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 四角形を塗りつぶします.
-- @param x0 開始のローカル座標
-- @param y0 開始のローカル座標
-- @param x1 終了のローカル座標
-- @param y1 終了のローカル座標
-- @return self
---------------------------------------
function M:fillRect(x0, y0, x1, y1)
    local command = function(self)
        if x0 and y0 and x1 and y1 then
            MOAIDraw.fillRect(x0, y0, x1, y1)
        else
            MOAIDraw.fillRect(0, 0, self:getWidth(), self:getHeight())
        end
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 指定した色に設定します.
-- 設定後に描画したコマンドに反映されます.
-- @param r red
-- @param g green
-- @param b blue
-- @param a alpha
-- @return self
---------------------------------------
function M:setPenColor(r, g, b, a)
    a = a and a or 1
    local command = function(self)
        local red = r * self:getRed()
        local green = g * self:getGreen()
        local blue = b * self:getBlue()
        local alpha = a * self:getAlpha()
        MOAIGfxDevice.setPenColor(red, green, blue, alpha)
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 指定したペンのサイズに設定します.
-- 設定後に描画したコマンドに反映されます.
-- @return self
---------------------------------------
function M:setPenWidth(width)
    local command = function(self)
        MOAIGfxDevice.setPenWidth(width)
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 指定したポイントのサイズに設定します.
-- 設定後に描画したコマンドに反映されます.
-- @return self
---------------------------------------
function M:setPointSize(size)
    local command = function(self)
        MOAIGfxDevice.setPointSize(size)
    end
    table.insert(self.commands, command)
    return self
end

---------------------------------------
-- 描画処理をクリアします.
---------------------------------------
function M:clear()
    self.commands = {}
    return self
end

return M