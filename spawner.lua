local modem = peripheral.wrap("top") -- Adjust for modem location
local side = "back" -- Adjust for redstone output side
local spawnerID = os.getComputerID() -- Get unique ID for this spawner

modem.open(spawnerID) -- Open a unique channel

print("Spawner Controller Running on ID: " .. spawnerID)

-- Report the spawner's ID to the main computer
modem.transmit(os.getComputerID(), 0, "ID")

while true do
    local _, _, senderID, _, message = os.pullEvent("modem_message")
    
    -- Ensure the message is for this spawner
    if senderID == spawnerID then
        if message == "on" then
            redstone.setOutput(side, true) -- Activate redstone signal
            print("Spawner " .. spawnerID .. " Activated!")
        elseif message == "off" then
            redstone.setOutput(side, false) -- Deactivate redstone signal
            print("Spawner " .. spawnerID .. " Deactivated!")
        end
    end
end
