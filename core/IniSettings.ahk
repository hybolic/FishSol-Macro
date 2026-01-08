;@cleanupnuke
UpdateLoopCount:
    Gui, Submit, nohide
    if (MaxLoopInput > 0) {
        maxLoopCount := MaxLoopInput
        IniWrite, %maxLoopCount%, %iniFilePath%, "Macro", "maxLoopCount"
    }
    if (FishingLoopInput > 0) {
        fishingLoopCount := FishingLoopInput
        IniWrite, %fishingLoopCount%, %iniFilePath%, "Macro", "fishingLoopCount"
    }
return

ToggleSellAll:
    sellAllToggle := !sellAllToggle
    Toggle_GuiControl("SellAllStatus", sellAllToggle, "sellAllToggle")
return

ToggleAdvancedFishingDetection:
    advancedFishingDetection := !advancedFishingDetection
    Toggle_GuiControl("AdvancedFishingDetectionStatus", advancedFishingDetection, "sellAllToggle")
return

ToggleAzertyPathing:
    azertyPathing := !azertyPathing
    Toggle_GuiControl("AzertyPathingStatus", azertyPathing, "azertyPathing")
return

ToggleAutoUnequip:
    autoUnequip := !autoUnequip
    Toggle_GuiControl("AutoUnequipStatus", autoUnequip, "autoUnequip")
return

ToggleAutoCloseChat:
    autoCloseChat := !autoCloseChat
    Toggle_GuiControl("AutoCloseChatStatus", autoCloseChat, "autoCloseChat")
return

ToggleStrangeController:
    strangeController := !strangeController
    Toggle_GuiControl("StrangeControllerStatus", strangeController, "strangeController")
return

ToggleBiomeRandomizer:
    biomeRandomizer := !biomeRandomizer
    Toggle_GuiControl("BiomeRandomizerStatus", biomeRandomizer, "biomeRandomizer")
return

ToggleFailsafeWebhook:
    failsafeWebhook := !failsafeWebhook
    Toggle_GuiControl("failsafeWebhookStatus", failsafeWebhook, "failsafeWebhook")
return

TogglePathingWebhook:
    pathingWebhook := !pathingWebhook
    Toggle_GuiControl("pathingWebhookStatus", pathingWebhook, "pathingWebhook")
return

ToggleItemWebhook:
    itemWebhook := !itemWebhook
    Toggle_GuiControl("itemWebhookStatus", itemWebhook, "itemWebhook")
return

UpdatePrivateServer:
    Gui, Submit, nohide
    privateServerLink := PrivateServerInput
    IniWrite, %privateServerLink%, %iniFilePath%, "Macro", "privateServerLink"
return

UpdateFishingFailsafe:
    Gui, Submit, nohide
    if (FishingFailsafeInput > 0) {
        fishingFailsafeTime := FishingFailsafeInput
        IniWrite, %fishingFailsafeTime%, %iniFilePath%, "Macro", "fishingFailsafeTime"
    }
return

UpdatePathingFailsafe:
    Gui, Submit, nohide
    if (PathingFailsafeInput > 0) {
        pathingFailsafeTime := PathingFailsafeInput
        IniWrite, %pathingFailsafeTime%, %iniFilePath%, "Macro", "pathingFailsafeTime"
    }
return

UpdateAutoRejoinFailsafe:
    Gui, Submit, nohide
    if (AutoRejoinFailsafeInput > 0) {
        autoRejoinFailsafeTime := AutoRejoinFailsafeInput
        IniWrite, %autoRejoinFailsafeTime%, %iniFilePath%, "Macro", "autoRejoinFailsafeTime"
    }
return

UpdateAdvancedThreshold:
    Gui, Submit, nohide
    if (AdvancedThresholdInput >= 0 && AdvancedThresholdInput <= 40) {
        advancedFishingThreshold := AdvancedThresholdInput
        IniWrite, %advancedFishingThreshold%, %iniFilePath%, "Macro", "advancedFishingThreshold"
    }
return

UpdateWebhook:
    Gui, Submit, nohide
    webhookURL := WebhookInput
    IniWrite, %webhookURL%, %iniFilePath%, "Macro", "webhookURL"
return

SelectRes:
    Gui, Submit, nohide
    res := Resolution
    IniWrite, %res%, %iniFilePath%, "Macro", "resolution"
    ManualGUIUpdate()
return

SelectPathing:
    Gui, Submit, nohide
    IniWrite, %PathingMode%, %iniFilePath%, "Macro", "pathingMode"
    pathingMode := PathingMode
return