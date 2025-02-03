local modem = peripheral.wrap("top") -- Adjust for modem location
local monitor = peripheral.wrap("right") -- Adjust for monitor side
local spawners = {} -- Store spawner info: {id = label}
local spawnerStates = {} -- Track ON/OFF states

modem.open(os.getComputerID()) -- Open main computer channel

-- Function to draw a bordered button
local function drawButton(x, y, width, height, label, isOn)
    local borderColor = isOn and colors.green or colors.red
    local textColor = colors.white

    -- Draw top and bottom border
    monitor.setTextColor(borderColor)
    for i = 0, width - 1 do
        monitor.setCursorPos(x + i, y)
        monitor.write("-")
        monitor.setCursorPos(x + i, y + height - 1)
        monitor.write("-")
    end

    -- Draw left and right border
    for i = 0, height - 1 do
        monitor.setCursorPos(x, y + i)
        monitor.write("|")
        monitor.setCursorPos(x + width - 1, y + i)
        monitor.write("|")
    end

    -- Draw label centered inside the button
    monitor.setTextColor(textColor)
    local labelX = x + math.floor((width - #label) / 2)
    local labelY = y + math.floor(height / 2)
    monitor.setCursorPos(labelX, labelY)
    monitor.write(label)

    -- Reset text color
    monitor.setTextColor(colors.white)
end

-- Function to draw the UI
local function drawUI()
    monitor.setTextScale(1) -- Adjust text scale for better visibility
    monitor.clear()
    monitor.setCursorPos(2, 1)
    monitor.write("Spawner Control Hub")

    local i = 3
    for id, label in pairs(spawners) do
        drawButton(2, i, 20, 3, label, spawnerStates[id])
        i = i + 4
    end
    
    -- Draw the refresh button at the bottom right
    local width, height = monitor.getSize()
    drawButton(width - 10, height - 2, 10, 3, "Refresh", false)
end

-- Function to send commands to spawners
local function toggleSpawner(spawnerID)
    spawnerStates[spawnerID] = not spawnerStates[spawnerID] -- Toggle state
    local command = spawnerStates[spawnerID] and "on" or "off"
    modem.transmit(spawnerID, os.getComputerID(), command)
    print("Sent " .. command .. " to " .. spawners[spawnerID])
    drawUI() -- Update the UI
end

-- Function to refresh spawner list
local function refreshSpawners()
    spawners = {} -- Clear existing spawner list
    spawnerStates = {}

    -- Broadcast a request for spawners to send their labels
    modem.transmit(0, os.getComputerID(), "request_labels")
    
    -- Wait a moment for responses
    sleep(2)
    
    drawUI() -- Redraw UI with updated spawners
end

-- Listen for incoming spawner labels
local function listenForLabels()
    while true do
        local _, _, senderID, _, message = os.pullEvent("modem_message")
        if type(message) == "table" and message.id and message.label then
            spawners[message.id] = message.label
            spawnerStates[message.id] = false -- Default state is OFF
            drawUI()
        end
    end
end

-- Start listening for labels in a separate thread
parallel.waitForAny(listenForLabels, function()
    -- Initial UI draw
    drawUI()

    -- Event loop for touch input
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        -- Check if refresh button was clicked
        local width, height = monitor.getSize()
        if x >= width - 10 and y >= height - 2 then
            print("Refreshing spawners...")
            refreshSpawners()
        else
            -- Find the corresponding spawner
            local i = 3
            for id, label in pairs(spawners) do
                if y >= i and y < i + 3 then
                    toggleSpawner(id)
                    break
                end
                i = i + 4
            end
        end
    end
end)
