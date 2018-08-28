-- Settings
-- TODO: Make UI for these
local AUTOSELL_ENABLED = true
local AUTOREPAIR_ENABLED = true

-- Constants
local ADDON_NAME = "Mowsh_Automation"
local QUALITY_GREY = 0

local addon_title = GetAddOnMetadata(ADDON_NAME, "Title")
local addon_version = GetAddOnMetadata(ADDON_NAME, "Version")
local frame = CreateFrame("Frame")
local events = {}

function events:MERCHANT_SHOW(...)
    if AUTOSELL_ENABLED then
        sell_items()
    end

    if AUTOREPAIR_ENABLED then
        repair_items()
    end
end

-- Sell all grey quality items, print profit
function sell_items()
    local total_grey = 0
    local total_sell_price = 0
    for bag_index = 0, NUM_BAG_SLOTS do
        for slot_index = 1, GetContainerNumSlots(bag_index) do
            local item_id = GetContainerItemID(bag_index, slot_index)

            -- Empty inventory slots have a nil ItemID
            if item_id ~= nil then
                local _, item_link, item_quality, _, _, _, _, _, _, _, item_sell_price = GetItemInfo(item_id)

                if item_quality == QUALITY_GREY then
                    if item_sell_price == 0 then
                        print("Unabled to sell " .. item_link)
                    else 
                        total_grey = total_grey + 1
                        total_sell_price = total_sell_price + item_sell_price

                        -- Using an item sells it
                        UseContainerItem(bag_index, slot_index)
                    end
                end
            end
        end
    end

    -- No need to print if nothing was sold
    if total_grey ~= 0 then
        print("Sold " .. total_grey .. " items for " .. GetCoinTextureString(total_sell_price))
    end
end

-- Repair all items, print repair cost
function repair_items()
    -- Don't try to repair if this merchant cannot repair
    if not CanMerchantRepair() then
        return
    end

    -- Don't print if nothing will be repaired
    local repair_cost = GetRepairAllCost()
    if repair_cost ~= 0 then
        RepairAllItems()
        print("Repaired all items for " .. GetCoinTextureString(repair_cost))
    end
end

-- Can register events by having a function with the event's name in the events table
frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

print ("Loaded " .. addon_title .. " - Version " .. addon_version)
