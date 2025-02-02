local modem = peripheral.wrap("top") -- Adjust for modem location
local monitor = peripheral.wrap("right") -- Adjust for monitor side
local spawnerStates = {} -- Track ON/OFF states

modem.open(os.getComputerID()) -- Open main computer channel

-- Function to draw the UI
local function drawUI()
    monitor.setTextScale(1) -- Adjust text scale for better visibility
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Spawner Control Hub")

    local i = 2 -- Start from row 2 since row 1 is the title
    for spawnerID, state in pairs(spawnerStates) do
        monitor.setCursorPos(1, i)
        if state then
            monitor.setTextColor(colors.green)
            monitor.write("Spawner " .. spawnerID .. " [ON] ")
        else
            monitor.setTextColor(colors.red)
            monitor.write("Spawner " .. spawnerID .. " [OFF]")
        end
        i = i + 1
    end
    monitor.setTextColor(colors.white) -- Reset text color
end

-- Function to send commands to spawner computers
local function toggleSpawner(spawnerID)
    spawnerStates[spawnerID] = not spawnerStates[spawnerID] -- Toggle state
    local command = spawnerStates[spawnerID] and "on" or "off"

    -- Error handling with pcall for transmitting the signal
    local success, err = pcall(function()
        modem.transmit(spawnerID, os.getComputerID(), command)
    end)

    if success then
        print("Sent " .. command .. " to Spawner " .. spawnerID)
    else
        print("Error sending command: " .. err)
    end

    drawUI() -- Update the UI
end

-- Debounce mechanism to prevent multiple triggers
local debounceTime = 0.5  -- seconds
local lastTouchTime = 0

-- Listen for spawners reporting their IDs
while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    local currentTime = os.clock()

    -- Only process touch input if debounce time has passed
    if currentTime - lastTouchTime >= debounceTime then
        lastTouchTime = currentTime

        -- Ensure that the touch position is within the valid range
        if y >= 2 then
            -- Get the selected spawner ID from the dynamic list
            local spawnerID = spawnerStates[y - 1]
            if spawnerID then
                toggleSpawner(spawnerID) -- Toggle the spawner ON/OFF
            end
        end
    end

    -- Listen for spawners reporting their ID
    local _, _, senderID = os.pullEvent("modem_message")
    -- Update the spawnerStates with the senderID if it's not already tracked
    if not spawnerStates[senderID] then
        spawnerStates[senderID] = false -- Set the initial state to OFF
        print("Discovered new spawner with ID: " .. senderID)
        drawUI() -- Update the UI with the new spawner
    end
end
