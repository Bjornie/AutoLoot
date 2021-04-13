BearLoot = {
    name = "BearLoot",
    version = "1.0.0",
    svName = "BearLootSV",
    svVersion = 1,
}

local targetTypes = {
    [INTERACT_TARGET_TYPE_AOE_LOOT] = true,
    [INTERACT_TARGET_TYPE_ITEM] = true,
    [INTERACT_TARGET_TYPE_NONE] = true,
    [INTERACT_TARGET_TYPE_OBJECT] = true,
}

local uncappedCurrencies = {
    CURT_ALLIANCE_POINTS,
    CURT_CROWNS,
    CURT_CROWN_GEMS,
    CURT_MONEY,
    CURT_STYLE_STONES, -- Any style material or only mimic stone?
    CURT_TELVAR_STONES,
    CURT_UNDAUNTED_KEYS,
    CURT_WRIT_VOUCHERS,
}

local cappedCurrencies = {
    CURT_CHAOTIC_CREATIA, -- Transmute Crystal
    CURT_EVENT_TICKETS,
}

local itemTypes = {
    [ITEMTYPE_ARMOR_TRAIT] = true,
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_BOOSTER] = true,
    [ITEMTYPE_CLOTHIER_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
    [ITEMTYPE_CONTAINER] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
    [ITEMTYPE_FURNISHING_MATERIAL] = true,
    [ITEMTYPE_INGREDIENT] = true,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
    [ITEMTYPE_JEWELRY_TRAIT] = true,
    [ITEMTYPE_LURE] = true,
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
    [ITEMTYPE_REAGENT] = true,
    [ITEMTYPE_RECIPE] = true,
    [ITEMTYPE_POISON_BASE] = true,
    [ITEMTYPE_POTION_BASE] = true,
    [ITEMTYPE_RAW_MATERIAL] = true,
    [ITEMTYPE_STYLE_MATERIAL] = true,
    [ITEMTYPE_TREASURE] = true,
    [ITEMTYPE_WEAPON_TRAIT] = true,
    [ITEMTYPE_WOODWORKING_BOOSTER] = true,
    [ITEMTYPE_WOODWORKING_MATERIAL] = true,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
}

local lootTypes = {
    [LOOT_TYPE_ANTIQUITY_LEAD] = true,
}

local specializedItemTypes = {
    [SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = true,
}

local traitTypeIntricate = {
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = true,
}

local lootIds = {
    [33265] = true, -- Soul Gem (Empty)
    [33271] = true, -- Soul Gem
    [44879] = true, -- Grand Repair Kit
    [61079] = true, -- Crown Repair Kit
    [114427] = true, -- Undaunted Plunder
    [134583] = true, -- Transmutation Geode, Normal
    [134588] = true, -- Transmutation Geode, Superior
    [134590] = true, -- Transmutation Geode, Epic
    [134591] = true, -- Transmutation Geode, Legendary
    [171531] = true, -- Transmutation Geode, Fine
    [134618] = true, -- Uncracked Transmutation Geode, Legendary
    [134622] = true, -- Uncracked Transmutation Geode, Superior
    [134623] = true, -- Uncracked Transmutation Geode, Epic
}

local BL = BearLoot
local EM = GetEventManager()

local targetType, unownedCurrency, lootId, isQuest, lootType, itemLink, isSet, traitType, itemId, itemType, specializedItemType, isCollected

local function OnLootUpdated()
    _, targetType = GetLootTargetInfo()

    if targetTypes[targetType] then
        for key, value in ipairs(uncappedCurrencies) do
            unownedCurrency = GetLootCurrency(value)

            if unownedCurrency > 0 then LootCurrency(value) end
        end

        for key, value in ipairs(cappedCurrencies) do
            unownedCurrency = GetLootCurrency(value)

            -- Don't overflow
            if unownedCurrency > 0 and (GetMaxPossibleCurrency(value, CURRENCY_LOCATION_ACCOUNT) >= GetCurrencyAmount(value, CURRENCY_LOCATION_ACCOUNT) + unownedCurrency) then LootCurrency(value) end
        end

        for i = 1, GetNumLootItems() do
            lootId, _, _, _, _, _, isQuest, _, lootType = GetLootItemInfo(i)
            itemLink = GetLootItemLink(lootId, LINK_STYLE_DEFAULT)
            isSet = GetItemLinkSetInfo(itemLink, false)
            traitType = GetItemLinkTraitInfo(itemLink)
            itemId = GetItemLinkItemId(itemLink)
            itemType, specializedItemType = GetItemLinkItemType(itemLink)
            -- isCollected = IsItemSetCollectionPieceUnlocked(itemId)

            if isSet or isQuest or itemTypes[itemType] or lootTypes[lootType] or specializedItemTypes[specializedItemType] or traitTypeIntricate[traitType] or lootIds[itemId] then LootItemById(lootId)end
        end
    end
end

EM:RegisterForEvent(BL.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == BL.name then
        EM:UnregisterForEvent(BL.name, EVENT_ADD_ON_LOADED)
        EM:RegisterForEvent(BL.name, EVENT_LOOT_UPDATED, OnLootUpdated)
    end
end)