-- AK-74M Recoil Control Script
-- Logitech G HUB
-- Operator: Deimos | Game: Rainbow Six Siege
-- Setup: No grip / No barrel | 13H 14V sens @ 1600 DPI | 41 rounds

-- ┌─────────────────────────────────────┐
-- │         SETTINGS                    │
-- └─────────────────────────────────────┘
local yBase    = 7     -- sustained pull after pattern ends (bullets 31+)
local xDrift   = 0     -- horizontal correction after pattern ends
local interval = 13    -- ms between steps (~680 RPM for AK-74M)
local sensX    = 1.0   -- horizontal multiplier (pattern x values are pre-tuned)
local sensY    = 1.0   -- vertical multiplier   (pattern y values are pre-tuned)

-- ┌─────────────────────────────────────┐
-- │         TOGGLE SETTINGS             │
-- └─────────────────────────────────────┘
local TOGGLE_TYPE   = "MOUSE"
local TOGGLE_KEY    = "G1"
local TOGGLE_BUTTON = 5   -- G304 back side button (Mouse5)

-- ┌──────────────────────────────────────────────────────┐
-- │  AK-74M RECOIL PATTERN (41 bullets)                  │
-- │  No grip / No barrel | 13H 14V @ 1600 DPI            │
-- │  x and y are DIRECT pixel moves — no multiplier math │
-- │  Negative x = pull left  |  Positive y = pull down   │
-- └──────────────────────────────────────────────────────┘
local recoilPattern = {
    {  0,  5 },  -- 1  initial kick
    {  0,  6 },  -- 2
    { -2,  7 },  -- 3  left drift starts
    { -2,  7 },  -- 4
    { -3,  7 },  -- 5
    { -3,  6 },  -- 6
    { -3,  6 },  -- 7
    { -2,  6 },  -- 8
    { -2,  6 },  -- 9
    {  0,  8 },  -- 10 mid-spray bump UP — stronger pull needed here
    {  0,  8 },  -- 11
    {  3,  8 },  -- 12 right drift stronger
    {  3,  8 },  -- 13
    {  3,  8 },  -- 14
    {  0,  8 },  -- 15 back to center — keep pulling hard
    { -3,  8 },  -- 16 left drift stronger
    { -3,  8 },  -- 17
    { -3,  8 },  -- 18
    {  0,  8 },  -- 19
    {  0,  8 },  -- 20
    {  0,  8 },  -- 21
    {  0,  7 },  -- 22 slight ease
    {  0,  7 },  -- 23
    {  0,  7 },  -- 24
    {  0,  7 },  -- 25
    {  0,  7 },  -- 26
    {  0,  7 },  -- 27
    {  0,  7 },  -- 28
    {  0,  7 },  -- 29
    {  0,  7 },  -- 30
    {  0,  7 },  -- 31
    {  0,  7 },  -- 32
    {  0,  7 },  -- 33
    {  0,  7 },  -- 34
    {  0,  6 },  -- 35 slight ease toward end of mag
    {  0,  6 },  -- 36
    {  0,  6 },  -- 37
    {  0,  6 },  -- 38
    {  0,  6 },  -- 39
    {  0,  6 },  -- 40
    {  0,  6 },  -- 41
}

-- ┌─────────────────────────────────────┐
-- │         SCRIPT LOGIC                │
-- └─────────────────────────────────────┘
local shooting  = false
local rcEnabled = true

local function printState()
    if rcEnabled then
        OutputLogMessage("[Deimos RCS] >> ENABLED\n")
    else
        OutputLogMessage("[Deimos RCS] >> DISABLED\n")
    end
end

function OnEvent(event, arg)
    if event == "PROFILE_ACTIVATED" then
        EnablePrimaryMouseButtonEvents(true)
        OutputLogMessage("[Deimos RCS] Loaded. AK-74M RCS ON. Mouse5 to toggle.\n")
    end

    -- ── Toggle ────────────────────────────────────────────────
    if TOGGLE_TYPE == "GKEY" then
        if event == "G_PRESSED" and arg == tonumber(string.sub(TOGGLE_KEY, 2)) then
            rcEnabled = not rcEnabled
            printState()
        end
    elseif TOGGLE_TYPE == "MOUSE" then
        if event == "MOUSE_BUTTON_PRESSED" and arg == TOGGLE_BUTTON then
            rcEnabled = not rcEnabled
            printState()
            return
        end
    end

    -- ── Recoil compensation ───────────────────────────────────
    if event == "MOUSE_BUTTON_PRESSED" and arg == 1 then
        if not rcEnabled then return end

        shooting = true
        local step = 1

        repeat
            if step <= #recoilPattern then
                local dx = math.floor(recoilPattern[step][1] * sensX)
                local dy = math.floor(recoilPattern[step][2] * sensY)
                MoveMouseRelative(dx, dy)
                step = step + 1
            else
                MoveMouseRelative(xDrift, yBase)
            end
            Sleep(interval)
        until not IsMouseButtonPressed(1)

        shooting = false
    end
end
