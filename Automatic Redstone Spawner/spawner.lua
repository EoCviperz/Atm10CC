local modem = peripheral.wrap("top") -- Adjust for modem location
local side = "back" -- Adjust for redstone output side
local spawnerID = os.getComputerID() -- Unique ID
local spawnerLabel = os.getComputerLabel() or ("Spawner " .. spawnerID) -- Get label or default to ID
local mainComputerID = 1 -- Change this to your main computer's ID

modem.open(spawnerID) -- Open unique channel

-- Announce presence to the main computer
modem.transmit(mainComputerID, spawnerID, {type="register", id=spawnerID, label=spawnerLabel})

print("Spawner Controller Running on ID: " .. spawnerID)

while true do
    local _, _, senderID, _, message = os.pullEvent("modem_message")

    if type(message) == "table" and message.type == "status_request" then
        -- Respond with status when requested
        modem.transmit(mainComputerID, spawnerID, {type="status", id=spawnerID, active=redstone.getOutput(side)})

    elseif message == "on" then
        redstone.setOutput(side, true)
        print("Spawner " .. spawnerID .. " Activated!")
        modem.transmit(mainComputerID, spawnerID, {type="update", id=spawnerID, active=true})

    elseif message == "off" then
        redstone.setOutput(side, false)
        print("Spawner " .. spawnerID .. " Deactivated!")
        modem.transmit(mainComputerID, spawnerID, {type="update", id=spawnerID, active=false})
    end
end
