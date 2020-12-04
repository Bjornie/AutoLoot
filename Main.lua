BearLoot = {
    name = "BearLoot",
    version = "1.0.0",
    svName = "BearLootSV",
    svVersion = 1,

    Default = {},
}

local TargetTypes = {
    [INTERACT_TARGET_TYPE_AOE_LOOT] = true,
    [INTERACT_TARGET_TYPE_ITEM] = true,
    [INTERACT_TARGET_TYPE_NONE] = true,
    [INTERACT_TARGET_TYPE_OBJECT] = true,
}

local UncappedCurrencies = {
    CURT_ALLIANCE_POINTS,
    CURT_CROWNS,
    CURT_CROWN_GEMS,
    CURT_MONEY,
    CURT_STYLE_STONES, -- Any style material or only mimic stone?
    CURT_TELVAR_STONES,
    CURT_UNDAUNTED_KEYS,
    CURT_WRIT_VOUCHERS,
}

local CappedCurrencies = {
    CURT_CHAOTIC_CREATIA, -- Transmute Crystal
    CURT_EVENT_TICKETS,
}

local TraitTypeIntricate = {
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = true,
}

local LootIds = {
    [33271] = true, -- Soul Gem
    [44879] = true, -- Grand Repair Kit
    [114427] = true, -- Undaunted Plunder
}

local ItemTypes = {
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
    [ITEMTYPE_TREASURE] = true,
}

local TransmutationGeodes = {
    [134583] = true, -- Deprecated?
    [134588] = true,
    [134590] = true,
    [134591] = true,
    [134618] = true, -- Deprecated?
    [134622] = true, -- Deprecated?
    [134623] = true, -- Deprecated?
    [171531] = true,
}

local BL = BearLoot
local EM = GetEventManager()

local targetType, unownedCurrency, lootId, itemLink, isSet, traitType, itemId, itemType, isCollected, _

local function OnLootUpdated()
    _, targetType = GetLootTargetInfo()

    if TargetTypes[targetType] then
        for key, value in ipairs(UncappedCurrencies) do
            unownedCurrency = GetLootCurrency(value)

            if unownedCurrency > 0 then LootCurrency(value) end
        end

        for key, value in ipairs(CappedCurrencies) do
            unownedCurrency = GetLootCurrency(value)

            -- Don't overflow
            if unownedCurrency > 0 and (GetMaxPossibleCurrency(value, CURRENCY_LOCATION_ACCOUNT) >= GetCurrencyAmount(value, CURRENCY_LOCATION_ACCOUNT) + unownedCurrency) then LootCurrency(value) end
        end

        for i = 1, GetNumLootItems() do
            lootId = GetLootItemInfo(i)
            itemLink = GetLootItemLink(lootId, LINK_STYLE_DEFAULT)
            isSet = GetItemLinkSetInfo(itemLink, false)
            traitType = GetItemLinkTraitInfo(itemLink)
            itemId = GetItemLinkItemId(itemLink)
            itemType = GetItemLinkItemType(itemLink)
            -- isCollected = IsItemSetCollectionPieceUnlocked(itemId)

            if isSet or ItemTypes[itemType] or TraitTypeIntricate[traitType] or LootIds[itemId] or TransmutationGeodes[itemId] then LootItemById(lootId)end
        end
    end
end

local function Initialise()
    BL.SV = ZO_SavedVars:NewAccountWide(BL.svName, BL.svVersion, nil, BL.Default)

    EM:RegisterForEvent(BL.name, EVENT_LOOT_UPDATED, OnLootUpdated)
end

EM:RegisterForEvent(BL.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == BL.name then
        EM:UnregisterForEvent(BL.name, EVENT_ADD_ON_LOADED)
        Initialise()
    end
end)