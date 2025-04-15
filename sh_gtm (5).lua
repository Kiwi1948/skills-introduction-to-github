AOCRP.GTM = AOCRP.GTM or {}

AOCRP.GTM.Items = {}

function AOCRP.GTM:ItemExists(item)
    if AOCRP.GTM.Items[item] then
        return true
    end
    return false
end

function AOCRP.GTM:GetItemData(item)
    return AOCRP.GTM.Items[item]
end

function AOCRP.GTM:HasItem(ply, item)

    if !ply.AOCRP_GTM then return false end
    if !AOCRP.GTM:ItemExists(item) then return ply.AOCRP_GTM[item] end
    local itemData = AOCRP.GTM:GetItemData(item)

    if itemData.vipFree and ply:GetAOCVIP() then
        return true
    end

    return ply.AOCRP_GTM[item]
end

function AOCRP.GTM:GetPurchasePrice(ply, item)
    if !ply.AOCRP_GTM then return false end
    return ply.AOCRP_GTM[item].purchaseprice
end


if SERVER then
    util.AddNetworkString("AOCRP.GTM.ReloadPurchaseData")
end

function AOCRP.GTM:ReloadPurchaseData(ply,item)
    item = item or "none"
    ply.AOCRP_GTM = {}
    if SERVER then
        AOCRP.GTM:PlayerLoadPurchaseData(ply)
        net.Start("AOCRP.GTM.ReloadPurchaseData")
        net.WriteString(item)
        net.Send(ply)
    end
    if CLIENT then
        AOCRP.API:Request("getgtmbyplayer", function(data) 
            for k, v in pairs(data) do
                ply.AOCRP_GTM[v.item] = v
            end
            if item != "none" then
                AOCRP.GTM:OpenItem(item)
            end
        end, {["steamid"] = ply:SteamID64()})
    end
end

if CLIENT then

    net.Receive( "AOCRP.GTM.ReloadPurchaseData", function( len, ply )
        local item = net.ReadString()
        AOCRP.GTM:ReloadPurchaseData(LocalPlayer(), item)
    end )


end









function AOCRP.GTM:doCrossHairIcon(panel,crosshair)

    local crossmat = Material(AOCRP.Config.Crosshair[crosshair].img)
    local crosscolor = AOCRP.Config.Crosshair[crosshair].cl
    function panel:Paint(w,h)
        surface.SetDrawColor(crosscolor)
        surface.SetMaterial(crossmat)
        surface.DrawTexturedRect(0,0, w, h )
    end
end


function AOCRP.GTM:doMaterialIcon(panel,material,color)

    color = color or Color(255,255,255)
    local crossmat = Material(material)

    function panel:Paint(w,h)
        surface.SetDrawColor(color)
        surface.SetMaterial(crossmat)
        surface.DrawTexturedRect(0,0, w, h )
    end
end

function AOCRP.GTM:doImgurIcon(panel,imgur)
    function panel:Paint(w,h)
        PIXEL.DrawImgur(0,0, w, h, imgur, Color(255,255,255,255) )
    end
end

function AOCRP.GTM:doRibbon(panel,imgur)
    function panel:Paint(w,h)
        PIXEL.DrawImgur(0,h/3, w, h/2.5, imgur, Color(255,255,255,255) )
    end
end

function AOCRP.GTM:doHelmetSkinIcon(panel,texture,submat)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(20,-5,65)
    camlookat = Vector(0,0,65)
    camfov = Vector(0,0,0)

    icon:SetCamPos(campos)
    icon:SetLookAt(camlookat)

    if !istable(texture) then
        icon.Entity:SetSubMaterial(submat,texture)
    else
        for k, v in pairs(texture) do
            icon.Entity:SetSubMaterial( k, v )
        end
    end

    function icon:LayoutEntity( Entity ) return end -- disables default rotation

    return icon
end


function AOCRP.GTM:doBodySkinIcon(panel,texture,submat)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(40,-5,35)
    camlookat = Vector(0,0,35)
    camfov = Vector(0,0,0)

    icon:SetCamPos(campos)
    icon:SetLookAt(camlookat)


    if !istable(texture) then
        icon.Entity:SetSubMaterial(submat,texture)
    else
        for k, v in pairs(texture) do
            icon.Entity:SetSubMaterial( k, v )
        end
    end

    function icon:LayoutEntity( Entity ) return end -- disables default rotation

    return icon
end

function AOCRP.GTM:doSpawnIcon(panel,model)
    local icon = vgui.Create( "SpawnIcon", panel )
    icon:Dock(FILL)
    icon:SetModel( model ) -- you can only change colors on playermodels

--[[     campos = Vector(40,-5,35)
    camlookat = Vector(0,0,35)
    camfov = Vector(0,0,0)

    icon:SetCamPos(campos)
    icon:SetLookAt(camlookat)

    icon.Entity:SetSubMaterial( submat, texture )

    function icon:LayoutEntity( Entity ) return end -- disables default rotation ]]
end

function AOCRP.GTM:doSkinPreview(panel,texture,submat)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(70,-5,40)
    camlookat = Vector(0,0,40)
    camfov = Vector(0,0,0)

    --icon:SetCamPos(campos)
    --icon:SetLookAt(camlookat)


    if !istable(texture) then
        icon.Entity:SetSubMaterial(submat,texture)
    else
        for k, v in pairs(texture) do
            icon.Entity:SetSubMaterial( k, v )
        end
    end

    -- Enable mouse rotation
    icon:SetMouseInputEnabled(true)

    -- Create a variable to store the current rotation
    local rotation = Angle(0, 0, 0)

    -- Override the DModelPanel's LayoutEntity function
    function icon:LayoutEntity(Entity)
    -- Rotate the entity using the current rotation
    Entity:SetAngles(rotation)
    end

    -- Create a function to handle mouse movement
    function icon:OnCursorMoved(x, y)

    if !input.IsMouseDown( MOUSE_LEFT ) then return end
    -- Calculate the mouse movement delta
    local dx = x - self.lastX
    local dy = y - self.lastY

    -- Update the rotation using the mouse movement delta
    rotation.yaw = rotation.yaw + dx
    --rotation.pitch = rotation.pitch + dy

    -- Update the last cursor position
    self.lastX = x
    self.lastY = y
    end

    -- Initialize the last cursor position
    icon.lastX = 0
    icon.lastY = 0

   --[[  function icon:DoClick()
        self:SetMouseInputEnabled(not self:IsMouseInputEnabled())
    end ]]
end

--[[ CreateClientConVar("aocrp_gtm_kopf", "default", true, false)
CreateClientConVar("aocrp_gtm_body", "default", true, false)
 ]]

function AOCRP.GTM:ApplyCrosshair(ply, crosshair)
    ply:ConCommand("aocrp_gtm_crosshair "..crosshair)
end


function AOCRP.GTM:ApplyGTMSkin(ply, wo, mat, kopfoderbody, item)


    if !istable(mat) then
        ply:SetSubMaterial(wo,mat)
    else
        for k, v in pairs(mat) do
            ply:SetSubMaterial( k, v )
        end
    end

    if !ply:IsPlayer() then return end

    if kopfoderbody == "kopf" then
        ply:ConCommand("aocrp_gtm_skin_kopf "..item)
    end
    if kopfoderbody == "body" then
        ply:ConCommand("aocrp_gtm_skin_body "..item)
    end
end


function AOCRP.GTM:DoActPreview(panel,act)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(70,-5,40)
    camlookat = Vector(0,0,40)
    camfov = Vector(0,0,0)

    --icon:SetCamPos(campos)
    --icon:SetLookAt(camlookat)


    icon:SetAnimated(true)
    local dance = icon:GetEntity():LookupSequence(act)

    -- Make both dance
    icon:GetEntity():SetSequence(dance)

    -- Enable mouse rotation
    icon:SetMouseInputEnabled(true)

    -- Create a variable to store the current rotation
    local rotation = Angle(0, 90, 0)

    -- Override the DModelPanel's LayoutEntity function
    function icon:LayoutEntity(Entity)
    -- Rotate the entity using the current rotation
        Entity:SetAngles(rotation)
        Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )

        if Entity:GetCycle() >= 0.99 then
            Entity:SetCycle(0)
            Entity:ResetSequence(dance)
        end
    end

    -- Create a function to handle mouse movement
    function icon:OnCursorMoved(x, y)

    if !input.IsMouseDown( MOUSE_LEFT ) then return end
    -- Calculate the mouse movement delta
    local dx = x - self.lastX
    local dy = y - self.lastY

    -- Update the rotation using the mouse movement delta
    rotation.yaw = rotation.yaw + dx
    --rotation.pitch = rotation.pitch + dy

    -- Update the last cursor position
    self.lastX = x
    self.lastY = y
    end

    -- Initialize the last cursor position
    icon.lastX = 0
    icon.lastY = 0

   --[[  function icon:DoClick()
        self:SetMouseInputEnabled(not self:IsMouseInputEnabled())
    end ]]
end


function AOCRP.GTM:DoWOSPreview(panel,act)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(70,-5,40)
    camlookat = Vector(0,0,40)
    camfov = Vector(0,0,0)

    --icon:SetCamPos(campos)
    --icon:SetLookAt(camlookat)


    icon:SetAnimated(true)

    local dance = icon:GetEntity():LookupSequence(act)
	--icon:GetEntity():AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, icon:GetEntity():LookupSequence(act), 0, true)
    local dance = icon:GetEntity():LookupSequence(act)

    -- Make both dance
    icon:GetEntity():SetSequence(dance)

    -- Enable mouse rotation
    icon:SetMouseInputEnabled(true)

    -- Create a variable to store the current rotation
    local rotation = Angle(0, 90, 0)

    -- Override the DModelPanel's LayoutEntity function
    function icon:LayoutEntity(Entity)
    -- Rotate the entity using the current rotation
        Entity:SetAngles(rotation)
        Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )

        if Entity:GetCycle() >= 0.99 then
            Entity:SetCycle(0)
            Entity:ResetSequence(dance)
            --Entity:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, Entity:LookupSequence(act), 0, true)
        end
    end

    -- Create a function to handle mouse movement
    function icon:OnCursorMoved(x, y)

    if !input.IsMouseDown( MOUSE_LEFT ) then return end
    -- Calculate the mouse movement delta
    local dx = x - self.lastX
    local dy = y - self.lastY

    -- Update the rotation using the mouse movement delta
    rotation.yaw = rotation.yaw + dx
    --rotation.pitch = rotation.pitch + dy

    -- Update the last cursor position
    self.lastX = x
    self.lastY = y
    end

    -- Initialize the last cursor position
    icon.lastX = 0
    icon.lastY = 0

   --[[  function icon:DoClick()
        self:SetMouseInputEnabled(not self:IsMouseInputEnabled())
    end ]]
end


local function EntDoAnimation(ent,anim)
	if AOCRP.Animation.FreeAnims[anim] then
		for k, v in pairs(AOCRP.Animation.FreeAnims[anim].bones) do
			if ent:LookupBone(k) != nil then
				ent:ManipulateBoneAngles( ent:LookupBone(k), v.ang, true )
			end
		end
	end
end



function AOCRP.GTM:DoAnimationPreview(panel,anim)
    local icon = vgui.Create( "DModelPanel", panel )
    icon:Dock(FILL)
    icon:SetModel( LocalPlayer():GetModel() ) -- you can only change colors on playermodels

    campos = Vector(70,-5,40)
    camlookat = Vector(0,0,40)
    camfov = Vector(0,0,0)

    --icon:SetCamPos(campos)
    --icon:SetLookAt(camlookat)


    -- Make both dance
    EntDoAnimation( icon:GetEntity(),anim)
    -- Enable mouse rotation
    icon:SetMouseInputEnabled(true)

    -- Create a variable to store the current rotation
    local rotation = Angle(0, 90, 0)

    -- Override the DModelPanel's LayoutEntity function
    function icon:LayoutEntity(Entity)
    -- Rotate the entity using the current rotation
        Entity:SetAngles(rotation)
        Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
    end

    -- Create a function to handle mouse movement
    function icon:OnCursorMoved(x, y)

    if !input.IsMouseDown( MOUSE_LEFT ) then return end
    -- Calculate the mouse movement delta
    local dx = x - self.lastX
    local dy = y - self.lastY

    -- Update the rotation using the mouse movement delta
    rotation.yaw = rotation.yaw + dx
    --rotation.pitch = rotation.pitch + dy

    -- Update the last cursor position
    self.lastX = x
    self.lastY = y
    end

    -- Initialize the last cursor position
    icon.lastX = 0
    icon.lastY = 0

   --[[  function icon:DoClick()
        self:SetMouseInputEnabled(not self:IsMouseInputEnabled())
    end ]]
end



-- ARCCW Waffen Charms
local GTM_Charms = {}
GTM_Charms["emotehappy"] = { name = "Happy", price = 10000, icon = "models/weapons/arccw/fml_charm/steamhappy.mdl",vipFree = true}
GTM_Charms["gigachad"] = { name = "Gigachad", price = 50000, icon = "models/weapons/arccw/gigacharm/gigachad.mdl",vipFree = true}
GTM_Charms["emotesalty"] = { name = "Salty", price = 10000, icon = "models/weapons/arccw/fml_charm/steamsalty.mdl", vipFree = true}
GTM_Charms["emotesad"] = { name = "Sad", price = 10000, icon = "models/weapons/arccw/fml_charm/steamsad.mdl",vipFree = true }
GTM_Charms["emotemocking"] = { name = "Mocking", price = 10000, icon = "models/weapons/arccw/fml_charm/steammocking.mdl", vipFree = true}
GTM_Charms["emotefacepalm"] = { name = "Facepalm", price = 10000, icon = "models/weapons/arccw/fml_charm/steamfacepalm.mdl", vipFree = true}
GTM_Charms["emotebored"] = { name = "Bored", price = 10000, icon = "models/weapons/arccw/fml_charm/steambored.mdl", vipFree = true}
GTM_Charms["logo"] = { name = "Age of Clones", price = 10000, icon = "models/starwars/grady/props/aoc/charms/aoc-logo.mdl", vipFree = true}
GTM_Charms["ph2helm"] = { name = "Phase 2 Helm", price = 10000, icon = "models/starwars/grady/props/aoc/charms/helmet_ph2.mdl", vipFree = true}

GTM_Charms["arccw_apex_proscreen"] = { name = "Killcounter Pro", price = 80000, icon = "models/weapons/attachments/pro_screen.mdl", vipFree = false}
GTM_Charms["arccw_apex_proscreen_alt"] = { name = "Killcounter Pro (Alt)", price = 50000, icon = "models/weapons/attachments/pro_screen_2.mdl", vipFree = false}
GTM_Charms["arccw_stattrak"] = { name = "Killcounter Stattrak", price = 150000, icon = "models/weapons/arccw/stattrack.mdl", vipFree = true}
GTM_Charms["arccw_heartsensor"] = { name = "Herzschlagsensor", price = 500000, icon = "models/weapons/arccw/atts/heartsensor.mdl", vipFree = false}






for k, v in pairs(GTM_Charms) do
    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = "Erst nach Respawn nutzbar",
        price = v.price,
        category = "Charms",
        apply = false,
        buyApply = true,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = v.vipFree,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) ArcCW:PlayerGiveAtt(ply, k, 99)   ArcCW:PlayerSendAttInv(ply) end,
        applyOnSpawnFunc = function(ply) ArcCW:PlayerGiveAtt(ply, k, 99) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,v.icon) end,
        previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,v.icon) end,
    }
end


--[[ 
hook.Add("ArcCW_PlayerCanAttach","GTM_ARCCW_ATTACH", function(ply, wep, attname, slot, detach) 

   if GTM_Charms[attname] then
       if AOCRP.GTM:HasItem(ply, attname) then
           return true
       else 
           ply:ChatPrint("*** Dieses Attachment gibt es im Galactic Trade Market zu kaufen!")
           return false
       end
   end
   return
end) ]]






local GTM_Scopes = {}
GTM_Scopes["uc_optic_acog"] = { name = "ACOG 4x", vip = true, price = 35000, icon = function(panel) end}
GTM_Scopes["uc_optic_hamr"] = { name = "HAMR 3x / Holo", vip = true, price = 50000, icon = function(panel) end}
GTM_Scopes["arccw_hcog"] = { name = "HCOG (1.85x)", vip = true, price = 10000, icon = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/arccw_hcog.png",Color(255,255,255)) end}
GTM_Scopes["arccw_titholo"] = { name = "Wonyeon Holo (2.1x)", vip = true, price = 20000, icon = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/arccw_titholo.png",Color(255,255,255)) end}
GTM_Scopes["arccw_fullholo"] = { name = "Full Holographic (RDS)", vip = true, price = 5000, icon = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/arccw_fullholo.png",Color(255,255,255)) end}
GTM_Scopes["arccw_tracker"] = { name = "Ghost Tracker (RDS)", vip = false, price = 100000, icon = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/arccw_tracker.png",Color(255,255,255)) end}

--[[ uc_optic_leupold_dppro
uc_optic_comp_m2
uc_optic_elcan
uc_optic_eotech552
uc_optic_eotech553
uc_optic_holosun2
uc_grip_bcmvfg
 ]]




for k, v in pairs(GTM_Scopes) do

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = "Erst nach Respawn aktiv",
        price = v.price,
        category = "Waffenzubehör",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = v.vip,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) end,
        applyOnSpawnFunc = function(ply) ArcCW:PlayerGiveAtt(ply, k, 99) end,
        iconFunc = v.icon,
        previewFunc = v.icon,
    }

end







AOCRP.GTM.Items["crosshair_default"] = {
    name = "Standard",
    desc = "Setze das Crosshair zurück.",
    price = 1,
    category = "Crosshairs",
    apply = true,
    permanent = false,
    canSell = false,
    canBuy = true,
    vipFree = false,
    vipOnly =  false,
    limitFunc = function(ply) return true end,
    applyFunc = function(ply) AOCRP.GTM:ApplyCrosshair(ply, "default") end,
    iconFunc = function(panel) end,
    previewFunc = function(panel) end,
}

for k, v in pairs(AOCRP.Config.Crosshair) do

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = "Ein benutzerdefiniertes Crosshair für dein Helm-Overlay.",
        price = v.price,
        category = "Crosshairs",
        apply = true,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) AOCRP.GTM:ApplyCrosshair(ply, k) end,
        iconFunc = function(panel) AOCRP.GTM:doCrossHairIcon(panel,k) end,
        previewFunc = function(panel) AOCRP.GTM:doCrossHairIcon(panel,k) end,
    }
        
end

--[[
AOCRP.GTM.Items["test_helmet"] = {
    name = "Testhelm",
    desc = "Ein benutzerdefiniertes Crosshair für dein Helm-Overlay.",
    price = 187,
    category = "Skin",
    apply = true,
    permanent = true,
    limitFunc = function(ply) return true end,
    applyFunc = function(ply) end,
    iconFunc = function(panel) doHelmetSkinIcon(panel,"starwars/grady/stosstruppen/st_trooper/501st_helmet",3) end,
    previewFunc = function(panel) doSkinPreview(panel,"starwars/grady/stosstruppen/st_trooper/501st_helmet",3) end,
}
 ]]



local HeadSkins = {}

// 212TH LEGION //
-------------------
// GHOST COMPANY MAIN HELMET //
HeadSkins["ghc_helmet_1"] = {name = "Helm Clean", desc = "Clean", price = 20000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet1"}
HeadSkins["ghc_helmet_2"] = {name = "Helm Gelbschweif", desc = "Gelbschweif", price = 20000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet2"}
HeadSkins["ghc_helmet_3"] = {name = "Helm Balken", desc = "Balken", price = 20000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet3"}
HeadSkins["ghc_helmet_4"] = {name = "Helm Vollstrich", desc = "Vollstrich", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet4"}
HeadSkins["ghc_helmet_5"] = {name = "Helm Pfeil!", desc = "Pfeil", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet5"}
HeadSkins["ghc_helmet_6"] = {name = "Helm Graukinn", desc = "Graukinn", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet6"}
HeadSkins["ghc_helmet_7"] = {name = "Helm Grauvisier", desc = "Grauvisier", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet7"}
HeadSkins["ghc_helmet_8"] = {name = "Helm Vollstrich 2", desc = "Vollstrich 2", price = 35000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet8"}
HeadSkins["ghc_helmet_geonosis_1"] = {name = "Helm Geonosis", desc = "Ich hasse Sand.", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet10"}
HeadSkins["ghc_helmet_geonosis_2"] = {name = "Helm Geo-Sandig", desc = "Ich hasse Sand.", price = 55000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet12"}
HeadSkins["ghc_helmet_geonosis_3"] = {name = "Helm Geo-Strich", desc = "Ich hasse Sand.", price = 60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet11"}
HeadSkins["ghc_christmas_helm"] = {name = "Weihnachtsskin", desc = "Nur via Geschenk erhältlich.", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_christmas", cantBuy = true}
HeadSkins["ghc_veteran_heln"] = {name = "GHC Veteran", desc = "", price = 35000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet9"}
HeadSkins["hc_veteran_heln"] = {name = "HC Veteran", desc = "", price = 35000, model = {"models/starwars/grady/212th/212th_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/heavys/helmet/helmet1"}
HeadSkins["ghc_order66_helmet"] = {name = "Helm Order", desc = "Limitiert erhältlich bis: 14.04.2022", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_order66", cantBuy = true}
HeadSkins["212_foxtrot_helmet"] = {name = "Helm Foxtrot", desc = "Foxtrot!", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_foxtrot"}
HeadSkins["212_ph1_helmet"] = {name = "Helm Classic", desc = "Die guten alten Zeiten...", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_phase1"}
HeadSkins["212_triton_helmet"] = {name = "Helm Triton", desc = "Triton", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_triton"}
HeadSkins["212_umbra_helmet"] = {name = "Helm Umbra", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_umbra"}
HeadSkins["212_rallyhelmet"] = {name = "Helm Rallye", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_rallye"}
HeadSkins["212_yodahelmet"] = {name = "Helm Yoda", desc = "", price = 65000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_yoda"}
HeadSkins["212_baymaxhelmet"] = {name = "Helm Baymax", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_baymax"}
HeadSkins["212_destinyhelmet"] = {name = "Helm Destiny", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_destiny"}
HeadSkins["212_heavyhelmet"] = {name = "Helm Heavy", desc = "OG Zeiten", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_heavy"}
HeadSkins["212_helmetpointy"] = {name = "Helm Pointy", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_pointy"}
HeadSkins["gc_helm_relikt"] = {name = "Helm Relikt", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_old_republic"}
HeadSkins["gc_helm_moon"] = {name = "Helm Moon", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_moon"}
HeadSkins["gc_helm_origins"] = {name = "Helm Origins", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_origins"}
HeadSkins["gc_helm_tfu_cmd"] = {name = "Helm TFU Commander", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_tfu_commander"}
HeadSkins["gc_helm_wildcat"] = {name = "Helm Wildcat", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_wildcat"}
HeadSkins["gc_helm_2099"] = {name = "Helm 2099", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_2099", vipOnly = true }
HeadSkins["gc_helm_rook"] = {name = "Helm Rook", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_rook"}
HeadSkins["gc_helm_awen"] = {name = "Helm awen", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_awen"}
HeadSkins["gc_christmas24"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_ph2"}



// GHOST COMPANY MAIN HELMET ENDE //

-------------------
-- NEUE EINHEIT! --
-------------------

// ARF HELME (NEXU) //
HeadSkins["arf_helm1"] = {name = "Helm Grey", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet1"}
HeadSkins["arf_helm2"] = {name = "Helm Orange", desc = "", price = 35000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet2"}
HeadSkins["arf_helm3"] = {name = "Helm Smack", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet3"}
HeadSkins["arf_helm4"] = {name = "Helm Y", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet4"}
HeadSkins["arf_helm5"] = {name = "Helm Leoj", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet5"}
HeadSkins["arf_helm6"] = {name = "Helm Wildcat", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_wildcat"}
HeadSkins["arf_helm7"] = {name = "Helm Half", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_half"}
HeadSkins["arf_helm8"] = {name = "Helm Ezra", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_ezra"}
HeadSkins["arf_helm9"] = {name = "Helm Smack", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_smack"}
HeadSkins["arf_helm10"] = {name = "Helm Camo Black", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_camo_black"}
HeadSkins["arf_helm11"] = {name = "Helm Camo Felucia", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_camo_felucia"}
HeadSkins["arf_helm12"] = {name = "Helm Camo Geonosis", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_camo_geonosis"}
HeadSkins["arf_helm13"] = {name = "Helm Camo kashyyyk", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_camo_kashyyyk"}
HeadSkins["arf_helm14"] = {name = "Helm Camo mimban", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/arf/helmet/helmet_camo_mimban"}
HeadSkins["arf_helm15"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_arf"}



// ARF HELME (NEXU) ENDE! //

// ARF HELME (NEXU) //
HeadSkins["arf_cheek1"] = {name = "Cheek Black", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/full/black"}
HeadSkins["arf_cheek2"] = {name = "Cheek Brown", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/full/brown"}
HeadSkins["arf_cheek3"] = {name = "Cheek Grey", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/full/grey"}
HeadSkins["arf_cheek4"] = {name = "Cheek Hound", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/hound/grey"}
HeadSkins["arf_cheek5"] = {name = "Cheek Orange", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/full/orange"}
HeadSkins["arf_cheek6"] = {name = "Cheek Hound Black", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/hound/black"}
HeadSkins["arf_cheek7"] = {name = "Cheek Hound Brown", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/hound/brown"}
HeadSkins["arf_cheek8"] = {name = "Cheek Hound Orange", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/hound/orange"}
HeadSkins["arf_cheek9"] = {name = "Cheek Hound Red", desc = "", price = 5000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 8, mat = "starwars/grady/itemshop/212th/arf/cheek/hound/red"}

// ARF HELME (NEXU) ENDE! //


-------------------
-- NEUE EINHEIT! --
-------------------

// ENGINEERING COMPANY HELM //
HeadSkins["ec_helmet_1"] = {name = "Unklar", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet1"}
HeadSkins["ec_helmet_2"] = {name = "Pfeil", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet2"}
HeadSkins["ec_helmet_4"] = {name = "38th", desc = "", price = 35000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet4"}
HeadSkins["ec_veteran_helm"] = {name = "Veteran", desc = "", price = 35000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet3"}
HeadSkins["ec_original_helm"] = {name = "Original", desc = "", price = 35000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet5"}
HeadSkins["ec_invertiert_helm"] = {name = "Invertiert", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet6"}
HeadSkins["ec_raptor_helm"] = {name = "Raptor", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_raptor"}
HeadSkins["ec_operator_helm"] = {name = "Operator", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_operator"}
HeadSkins["ec_upgrade_helm"] = {name = "Upgrade", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_upgrade"}
HeadSkins["ec_raute_helm"] = {name = "raute", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_raute"}
HeadSkins["ec_raute_inverted_helm"] = {name = "raute inverted", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_raute_inverted"}
HeadSkins["ec_203rd_helm"] = {name = "raute inverted", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_203rd"}
HeadSkins["ft_helmet_flame"] = {name = "Flame", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_flametrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ft/helmet/helmet_flame"}
HeadSkins["ec_fixer_helm"] = {name = "Fixer inverted", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_fixer"}
HeadSkins["ec_metal_helm"] = {name = "Metal inverted", desc = "", price = 15000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ec/helmet/helmet_metal"}
HeadSkins["ec_christmas24"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_ph2"}

// !! ENGINEERING COMPANY HELM ENDE !! //

-------------------
-- NEUE EINHEIT! --
-------------------

// AIRBORNE COMPANY HELM //
HeadSkins["ac_helmet_1"] = {name = "Helm Pfeile", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet1"}
HeadSkins["ac_helmet_2"] = {name = "Helm Split", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet2"}
HeadSkins["ac_helmet_3"] = {name = "Helm V", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet3"}
HeadSkins["ac_helmet_4"] = {name = "Helm Eyestripe", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet4"}
HeadSkins["ac_helmet_5"] = {name = "Helm Doublestripe", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet5"}
HeadSkins["ac_helmet_6"] = { name = "Helm Sidestripe", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet6"}
HeadSkins["ac_helmet_7"] = { name = "Helm Fatline", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet7"}
HeadSkins["ac_helmet_8"] = { name = "Helm T", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet8"}
HeadSkins["ac_helmet_9"] = { name = "Helm T Rustikal", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet9"}
HeadSkins["ac_helmet_trio"] = { name = "Helm Trio", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_trio"}
HeadSkins["ac_helmet_curves"] = { name = "Helm Curves", desc = "", price = 25000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_curves"}
HeadSkins["ac_helmet_triangle"] = {name = "Helm Triangle", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_triangle"}
HeadSkins["ac_helmet_yirt"] = {name = "Helm Yirt", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_yirt"}
HeadSkins["ac_helmet_dragonfighter"] = {name = "Helm Dragonfighter", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_dragon"}
HeadSkins["ac_helmet_stripes"] = {name = "Helm Stripes", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_stripes"}
HeadSkins["ac_helmet_Order"] = {name = "Helm Order", desc = "Limitiert erhältlich gewesen bis 13.05.2022", price = -1, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_order66", cantBuy = true}
HeadSkins["ac_helmet_recon"] = {name = "Helm Recon", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_recon"}
HeadSkins["ac_helmet_christmas24"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_airborne"}

// !! AIRBORNE COMPANY HELM ENDE !! //


-------------------
-- NEUE LEGION! --
-------------------

-------------------
// 501st LEGION //
-------------------
// TORRENT COMPANY MAIN HELM //
HeadSkins["tc_helmet_2"] = {name = "Helm V", desc = "V wie Vandetta", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet2"}
HeadSkins["tc_helmet_3"] = {name = "Helm Asym", desc = "Weißer Strich auf blauen Grund", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet3"}
HeadSkins["tc_helmet_4"] = {name = "Helm Stumgrau", desc = "Stürmischer Kämpfer", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet4"}
HeadSkins["tc_helmet_5"] = {name = "Helm Zorn", desc = "Zorn der Torrent Company", price = 35000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet5"}
HeadSkins["tc_helmet_6"] = {name = "Helm Malerei", desc = "Sieht aus wie Höhlenmalerei", price = 60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet6"}
HeadSkins["tc_helmet_7"] = {name = "Helm Poseidon", desc = "Mit der Macht von Poseidon", price = 60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet7"}
HeadSkins["tc_helmet_8"] = {name = "Helm I", desc = "Illuminati confirmed", price = 20000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet8"}
HeadSkins["tc_christmas_helm"] = {name = "Weihnachtsskin", desc = "Nur via Geschenk erhältlich.", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_christmas", cantBuy = true}
HeadSkins["tc_veteran_heln"] = {name = "Veteran", desc = "Teil des Veteran-Packs.", price = 35000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet1"}
HeadSkins["tc_order_helm"] = {name = "Helm Order", desc = "Limitiert erhältlich bis: 14.04.2022", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_order66", cantBuy = true}
HeadSkins["501st_tano_helm"] = {name = "Helm Tano", desc = "Commander Tano ist stolz.", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_332nd"}
HeadSkins["501st_ph1_helmet"] = {name = "Helm Classic", desc = "Die guten alten Zeiten...", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_phase1"}
HeadSkins["501st_triton_helmet"] = {name = "Helm Triton", desc = "Triton", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_triton"}
HeadSkins["501st_umbra_helmet"] = {name = "Helm Umbra", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_umbra"}
HeadSkins["501st_elite_helmet"] = {name = "Helm Elite", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_elite"}
HeadSkins["501st_rallyhelmet"] = {name = "Helm Rallye", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_rallye"}
HeadSkins["501st_yodahelmet"] = {name = "Helm Yoda", desc = "", price = 65000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_yoda"}
HeadSkins["501st_baymaxhelmet"] = {name = "Helm Baymax", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_baymax"}
HeadSkins["501st_destinyhelmet"] = {name = "Helm Destiny", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_destiny"}
HeadSkins["501st_pointyhelmet"] = {name = "Helm Pointy", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_pointy"}
HeadSkins["tc_helm_relikt"] = {name = "Helm Relikt", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_old_republic"}
HeadSkins["tc_helm_moon"] = {name = "Helm Moon", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_moon"}
HeadSkins["tc_helm_origins"] = {name = "Helm Origins", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_origins"}
HeadSkins["tc_helm_tfu_commander"] = {name = "Helm Commander", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_tfu_commander"}
HeadSkins["tc_helm_2099"] = {name = "Helm 2099", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_2099", vipOnly = true }
HeadSkins["tc_helm_rook"] = {name = "Helm Rook", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_rook"}
HeadSkins["tc_helm_awen"] = {name = "Helm awen", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_awen"}
HeadSkins["tc_helm_christmas24"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_ph2"}


// TORRENT COMPANY MAIN HELM ENDE! //

-------------------
-- NEUE EINHEIT! --
-------------------

// TORRENT COMPANY JAIG HELM //
HeadSkins["JP_Helmet_1"] = {name = "Helm Jaig Arrows", desc = "Der Pfeil geht nach oben wie Lauch Fabian", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_arrow"}
HeadSkins["JP_Helmet_2"] = {name = "Helm Lowkey", desc = "Der ist Lowkey geil", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_lowkey"}
HeadSkins["JP_Helmet_3"] = {name = "Helm Wirbel", desc = "Wirbel wie beim Stress mit der ST", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_wirbel"}
HeadSkins["JP_Helmet_4"] = {name = "Helm Crescent", desc = "Der Halbmond ist schön", price = 50000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_crescent"}
HeadSkins["JP_Helmet_Umbra"] = {name = "Helm Umbra", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_umbra"}
HeadSkins["JP_Helmet_Rallye"] = {name = "Helm Rallye", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_rallye"}
HeadSkins["JP_Helmet_Dagger"] = {name = "Helm Dagger", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_dagger"}
HeadSkins["JP_Helmet_332nd"] = {name = "Helm Tano", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_332nd"}
HeadSkins["JP_Helmet_Cabo"] = {name = "Helm Cabo", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_cabo"}
HeadSkins["JP_Helmet_tfu_commander"] = {name = "Helm TFU Commander", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_tfu_commander"}
HeadSkins["JP_Helmet_rook"] = {name = "Helm Rook", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_rook"}
HeadSkins["JP_Helmet_assassine"] = {name = "Helm Assassine", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_assassine"}
HeadSkins["JP_Helmet_2099"] = {name = "Helm 2099", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_2099"}
HeadSkins["JP_Helmet_bad-batch"] = {name = "Helm Bad Batch", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_bad-batch"}
HeadSkins["JP_Helmet_awen"] = {name = "Helm Awen", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/jaig/helmet/helmet_awen"}
HeadSkins["JP_Helmet_christmas24"] = {name = "Helm Christmas", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_barc"}


// TORRENT COMPANY JAIG HELM ENDE ! //

//DP HELME
HeadSkins["DP_Helmet_Skeleton"] = {name = "Helm Skeleton", desc = "Wumgabadamdingo", price = 30000, model = {"smodels/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_halloween_skeleton"}
HeadSkins["DP_Helmet_koeniglich"] = {name = "Helm koeniglich", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_koeniglich"}
HeadSkins["DP_Helmet_Tano"] = {name = "Helm Tano", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_332nd"}
HeadSkins["DP_Helmet_Umbra"] = {name = "Helm Umbra", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_umbra"} 
HeadSkins["DP_Helmet_2099"] = {name = "Helm 2099", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_2099"} 
HeadSkins["DP_Helmet_awen"] = {name = "Helm Awen", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_awen"} 
HeadSkins["DP_Helmet_for-hevy"] = {name = "Helm For-hevy", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_for-hevy"} 
HeadSkins["DP_Helmet_nexos"] = {name = "Helm Definitivnichtvonnexos", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_nexos"} 
HeadSkins["DP_Helmet_rook"] = {name = "Helm rook", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_rook"} 
HeadSkins["DP_Helmet_phase1"] = {name = "Helm phase1", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_phase1"} 
HeadSkins["DP_Helmet_tfu_commander"] = {name = "Helm TFU COMMANDER", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_tfu_commander"} 
HeadSkins["DP_Helmet_triton"] = {name = "Helm Triton", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_triton"} 
HeadSkins["DP_Helmet_yoda"] = {name = "Helm Yoda", desc = "Wumgabadamdingo", price = 30000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/dp/helmet/helmet_yoda"} 


-------------------
-- NEUE EINHEIT! --
-------------------

// MEDICAL PLATOON HELM //
HeadSkins["mp_helmet_1"] = {name = "Helm 1", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet1"}
HeadSkins["mp_helmet_2"] = {name = "Helm 2", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 30000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet2"}
HeadSkins["mp_helmet_3"] = {name = "Helm 3", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 45000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet3"}
HeadSkins["mp_helmet_4"] = {name = "Helm 4", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet4"}
HeadSkins["mp_helmet_5"] = {name = "Helm 5", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet5"}
HeadSkins["mp_helmet_6"] = {name = "Helm 6", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet6"}
HeadSkins["mp_helmet_7"] = {name = "Helm 7", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet7"}
HeadSkins["mp_helmet_8"] = {name = "Helm 8", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet8"}
HeadSkins["mp_helmet_9"] = {name = "Helm 9", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet9"}
HeadSkins["mp_helmet_10"] = {name = "Helm 10", desc = "Wer das liest muss Grady schreiben dass er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet10"}
HeadSkins["mp_helmet_vest"] = {name = "Helm Vest", desc = "Vest", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_vest"}
HeadSkins["mp_helmet_front"] = {name = "Helm Front", desc = "Front", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_frontkaempfer"}
HeadSkins["mp_helmet_skull"] = {name = "Helm Skull", desc = "i forgor", price = 15000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_skull"}
HeadSkins["mp_helmet_sigil"] = {name = "Helm Sigil", desc = "Sigil", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_sigil"}
HeadSkins["jumptrooper_helmetjet"] = {name = "Helm Jet", desc = "Sigil", price = 20000, model = {"models/starwars/grady/501st_medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics-jumptrooper/helmet/helmet_jet"}
HeadSkins["mp_helmet_divine-wings"] = {name = "Helm Divine-Wings", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_divine-wings"}
HeadSkins["mp_helmet_dok"] = {name = "Helm Dok", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_dok"}
HeadSkins["mp_helmet_orion"] = {name = "Helm Orion", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_orion"}
HeadSkins["mp_helmet_minos"] = {name = "Helm Minos", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_minos"}
HeadSkins["mp_helmet_stratos"] = {name = "Helm Stratos", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/medics/helmet/helmet_stratos"}
HeadSkins["mp_christmas24"] = {name = "Helm Christmas", desc = "Bro", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_ph2"}


// MEDICAL PLATOON HELM ENDE ! //

-------------------
-- NEUE LEGION! --
-------------------


// SCHOCKTRUPPEN HELM //
HeadSkins["ST_ph1_helmet"] = {name = "Helm Classic", desc = "Die guten alten Zeiten...", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_phase1"}
HeadSkins["ST_triton_helmet"] = {name = "Helm Triton", desc = "Triton", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_triton"}
HeadSkins["ST_umbra_helmet"] = {name = "Helm Umbra", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_umbra"}
HeadSkins["ST_imp_helmet"] = {name = "Helm Imp", desc = "Irgendwie kommt mir das bekannt vor..", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_imperial"}
HeadSkins["ST_senat_helmet"] = {name = "Helm Senat", desc = "I am the Senate.", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_coruscant_guard"}
HeadSkins["ST_rallyhelmet"] = {name = "Helm Rallye", desc = "Umbra.", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_rallye"}
HeadSkins["ST_yodahelmet"] = {name = "Helm Yoda", desc = "", price = 65000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_yoda"}
HeadSkins["ST_baymaxhelmet"] = {name = "Helm Baymex", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_baymax"}
HeadSkins["ST_destinyhelmet"] = {name = "Helm Destiny", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_destiny"}
HeadSkins["ST_pointyhelmet"] = {name = "Helm Pointy", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_pointy"}
HeadSkins["st_helm_aurek"] = {name = "Helm Rotbacke", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet3"}
HeadSkins["st_helm_besh"] = {name = "Helm Thor", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet2"}
HeadSkins["st_helm_cresh"] = {name = "Helm Glänzer", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet1"}
HeadSkins["st_helm_relikt"] = {name = "Helm Relikt", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_old_republic"}
HeadSkins["st_helm_moon"] = {name = "Helm Moon", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_moon"}
HeadSkins["st_helm_origins"] = {name = "Helm Origins", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_origins"}
HeadSkins["st_helm_tfu_commander"] = {name = "Helm TFU Commander", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_tfu_commander"}
HeadSkins["st_helm_2099"] = {name = "Helm 2099", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_2099", vipOnly = true }
HeadSkins["st_helm_rook"] = {name = "Helm Rook", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_rook"}
HeadSkins["st_helm_awen"] = {name = "Helm awen", desc = "", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_awen"}
HeadSkins["st_helm_christmas"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_ph2"}

// SCHOCKTRUPPEN HELM ENDE! //

// AVP HELME //
HeadSkins["avp_helm1"] = {name = "Helm Eagle GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_eagle"}
HeadSkins["avp_helm2"] = {name = "Helm Eagle SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_eagle"}
HeadSkins["avp_helm3"] = {name = "Helm Eagle BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_eagle"}
HeadSkins["avp_helm4"] = {name = "Helm Hazard GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_hazard"}
HeadSkins["avp_helm5"] = {name = "Helm Hazard SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_hazard"}
HeadSkins["avp_helm6"] = {name = "Helm Hazard BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_hazard"}
HeadSkins["avp_helm7"] = {name = "Helm Outline GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_outline"}
HeadSkins["avp_helm8"] = {name = "Helm Outline SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_outline"}
HeadSkins["avp_helm9"] = {name = "Helm Outline BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_outline"}
HeadSkins["avp_helm10"] = {name = "Helm Outline", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_outline"}
HeadSkins["avp_helm11"] = {name = "Helm eagle", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_eagle"}
HeadSkins["avp_helm12"] = {name = "Helm hazard", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_hazard"}
--
HeadSkins["avp_helm13"] = {name = "Helm Contrast", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_contrast"}
HeadSkins["avp_helm14"] = {name = "Helm Contrast GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_contrast"}
HeadSkins["avp_helm15"] = {name = "Helm Contrast SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_contrast"}
HeadSkins["avp_helm16"] = {name = "Helm Contrast BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_contrast"}
--
HeadSkins["avp_helm17"] = {name = "Helm Hower", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_hower"}
HeadSkins["avp_helm18"] = {name = "Helm Hower GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_hower"}
HeadSkins["avp_helm19"] = {name = "Helm Hower SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_hower"}
HeadSkins["avp_helm20"] = {name = "Helm Hower BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_hower"}
--
HeadSkins["avp_helm21"] = {name = "Helm Hunter", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_hunter"}
HeadSkins["avp_helm22"] = {name = "Helm Hunter GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_hunter"}
HeadSkins["avp_helm23"] = {name = "Helm Hunter SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_hunter"}
HeadSkins["avp_helm24"] = {name = "Helm Hunter BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_hunter"}
--
HeadSkins["avp_helm25"] = {name = "Helm Original", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_original"}
HeadSkins["avp_helm26"] = {name = "Helm Original GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_original"}
HeadSkins["avp_helm27"] = {name = "Helm Original SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_original"}
HeadSkins["avp_helm28"] = {name = "Helm Original BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_original"}
--
HeadSkins["avp_helm29"] = {name = "Helm Stripes", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_stripes"}
HeadSkins["avp_helm30"] = {name = "Helm Stripes GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_stripes"}
HeadSkins["avp_helm31"] = {name = "Helm Stripes SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_stripes"}
HeadSkins["avp_helm32"] = {name = "Helm Stripes BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_stripes"}
--
HeadSkins["avp_helm33"] = {name = "Helm Sunrise", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_sunrise"}
HeadSkins["avp_helm34"] = {name = "Helm Sunrise GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_sunrise"}
HeadSkins["avp_helm35"] = {name = "Helm Sunrise SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_sunrise"}
HeadSkins["avp_helm36"] = {name = "Helm Sunrise BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_sunrise"}
--
HeadSkins["avp_helm37"] = {name = "Helm Sutekh", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/helmet/helmet_sutekh"}
HeadSkins["avp_helm38"] = {name = "Helm Sutekh GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/helmet/helmet_sutekh"}
HeadSkins["avp_helm39"] = {name = "Helm Sutekh SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/helmet/helmet_sutekh"}
HeadSkins["avp_helm40"] = {name = "Helm Sutekh BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/helmet/helmet_sutekh"}

HeadSkins["avp_christmas24"] = {name = "Helm Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl","models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl","models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl","models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/helmet_pilot"}

// AVP HELMET ENDE! //

local BodySkins = {}

// AVP BODY //
BodySkins["avp_body1"] = {name = "Body Eagle GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_eagle"}
BodySkins["avp_body2"] = {name = "Body Eagle SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_eagle"}
BodySkins["avp_body3"] = {name = "Body Eagle BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_eagle"}
BodySkins["avp_body4"] = {name = "Body Hazard GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_hazard"}
BodySkins["avp_body5"] = {name = "Body Hazard SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_hazard"}
BodySkins["avp_body6"] = {name = "Body Hazard BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_hazard"}
BodySkins["avp_body7"] = {name = "Body Outline GOLD", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_outline"}
BodySkins["avp_body8"] = {name = "Body Outline SHADOW", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_outline"}
BodySkins["avp_body9"] = {name = "Body Outline BLUE", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_outline"}
BodySkins["avp_body10"] = {name = "Body Outline", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_outline"}
BodySkins["avp_body11"] = {name = "Body eagle", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_eagle"}
BodySkins["avp_body12"] = {name = "Body hazard", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_hazard"}
--
BodySkins["avp_body13"] = {name = "Body Bigchill", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_bigchill"}
BodySkins["avp_body14"] = {name = "Body Bigchill Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_bigchill"}
BodySkins["avp_body15"] = {name = "Body Bigchill Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_bigchill"}
BodySkins["avp_body16"] = {name = "Body Bigchill Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_bigchill"}
--
BodySkins["avp_body17"] = {name = "Body Contrast", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_contrast"}
BodySkins["avp_body18"] = {name = "Body Contrast Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_contrast"}
BodySkins["avp_body19"] = {name = "Body Contrast Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_contrast"}
BodySkins["avp_body20"] = {name = "Body Contrast Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_contrast"}
--
BodySkins["avp_body21"] = {name = "Body Contrast", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_contrast"}
BodySkins["avp_body22"] = {name = "Body Contrast Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_contrast"}
BodySkins["avp_body23"] = {name = "Body Contrast Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_contrast"}
BodySkins["avp_body24"] = {name = "Body Contrast Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_contrast"}
--
BodySkins["avp_body21"] = {name = "Body Hower", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_hower"}
BodySkins["avp_body22"] = {name = "Body Hower Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_hower"}
BodySkins["avp_body23"] = {name = "Body Hower Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_hower"}
BodySkins["avp_body24"] = {name = "Body Hower Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_hower"}
--
BodySkins["avp_body25"] = {name = "Body Hunter", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_hunter"}
BodySkins["avp_body26"] = {name = "Body Hunter Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_hunter"}
BodySkins["avp_body27"] = {name = "Body Hunter Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_hunter"}
BodySkins["avp_body28"] = {name = "Body Hunter Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_hunter"}
--
BodySkins["avp_body29"] = {name = "Body Original", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_original"}
BodySkins["avp_body30"] = {name = "Body Original Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_original"}
BodySkins["avp_body31"] = {name = "Body Original Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_original"}
BodySkins["avp_body32"] = {name = "Body Original Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_original"}
--
BodySkins["avp_body33"] = {name = "Body Stripes", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_stripes"}
BodySkins["avp_body34"] = {name = "Body Stripes Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_stripes"}
BodySkins["avp_body35"] = {name = "Body Stripes Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_stripes"}
BodySkins["avp_body36"] = {name = "Body Stripes Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_stripes"}
--
BodySkins["avp_body37"] = {name = "Body Sunrise", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_sunrise"}
BodySkins["avp_body38"] = {name = "Body Sunrise Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_sunrise"}
BodySkins["avp_body39"] = {name = "Body Sunrise Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_sunrise"}
BodySkins["avp_body40"] = {name = "Body Sunrise Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_sunrise"}
--
BodySkins["avp_body41"] = {name = "Body Sutekh", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/standard/body/body_sutekh"}
BodySkins["avp_body42"] = {name = "Body Sutekh Gold", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/gold/body/body_sutekh"}
BodySkins["avp_body43"] = {name = "Body Sutekh Schatten", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/schatten/body/body_sutekh"}
BodySkins["avp_body44"] = {name = "Body Sutekh Blau", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/piloten/blau/body/body_sutekh"}

BodySkins["avp_body_christmas24"] = {name = "Body Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl","models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl","models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl","models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"}


// AVP BODY ENDE! //

// 212TH LEGION //
-------------------
// GHOST COMPANY BODY //

BodySkins["ghc_body_1"] = {name = "Körper Dreieck 1", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body1"}
BodySkins["ghc_body_2"] = {name = "Körper Gürtel", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body2"}
BodySkins["ghc_body_3"] = {name = "Körper Patriot", desc = "", price = 60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body3"}
BodySkins["ghc_body_4"] = {name = "Körper Dreieck 2", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body4"}
BodySkins["ghc_body_5"] = {name = "Körper Brust", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body5"}
BodySkins["ghc_body_geonosis_1"] = {name = "Körper Geonosis", desc = "Ich hasse Sand.", price = 70000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body7"}
BodySkins["ghc_body_geonosis_2"] = {name = "Körper Geo-Sandig", desc = "Ich hasse Sand.", price = 80000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body8"}
BodySkins["ghc_christmas_body"] = {name = "Weihnachtsskin", desc = "Nur via Geschenk erhältlich.", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_christmas", cantBuy = true}
BodySkins["ghc_veteran_body"] = {name = "GHC Veteran", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body6"}
BodySkins["hc_veteran_body"] = {name = "HC Veteran", desc = "", price = 50000, model = {"models/starwars/grady/212th/heavys/212th_heavy.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/heavys/body/body1"}
BodySkins["ghc_order66_body"] = {name = "Body Order", desc = "Limitiert erhältlich bis: 14.04.2022", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_order66", cantBuy = true}
BodySkins["212_foxtrot_body"] = {name = "Körper Foxtrot", desc = "Foxtrot!", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_foxtrot"}
BodySkins["212_ph1_body"] = {name = "Körper Classic", desc = "Die guten alten Zeiten...", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_phase1"}
BodySkins["212_triton_body"] = {name = "Körper Triton", desc = "Triton.", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_triton"}
BodySkins["212_umbra_body"] = {name = "Körper Umbra", desc = "Umbra.", price = 80000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_umbra"}
BodySkins["212_bodyrallye"] = {name = "Körper Rallye", desc = "Umbra.", price = 70000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_rallye"}
BodySkins["212_bodyyoda"] = {name = "Körper Yoda", desc = "", price = 90000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_yoda"}
BodySkins["212_baymaxbody"] = {name = "Körper Baymax", desc = "", price = 65000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_baymax"}
BodySkins["212_destinybody"] = {name = "Körper Destiny", desc = "", price = 70000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_destiny"}
BodySkins["212_heavybody"] = {name = "Körper Heavy", desc = "OG Zeiten", price = 65000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_heavy"}
BodySkins["212_bodypointy"] = {name = "Körper Pointy", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_pointy"}
BodySkins["gc_body_relikt"] = {name = "Körper Relikt", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_old_republic"}
BodySkins["gc_body_moon"] = {name = "Körper Moon", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_moon"}
BodySkins["gc_body_origins"] = {name = "Körper Origins", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_origins"}
BodySkins["gc_body_tfu_cmd"] = {name = "Körper TFU Commander", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_tfu_commander"}
BodySkins["gc_body_wildcat"] = {name = "Körper Wildcat", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_wildcat"}
BodySkins["gc_arf_body_wildcat"] = {name = "Körper Wildcat", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_wildcat"}
BodySkins["gc_body_2099"] = {name = "Körper 2099", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_2099", vipOnly = true }
BodySkins["gc_body_rook"] = {name = "Körper Rook", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_rook"}
BodySkins["gc_arf_body_halft"] = {name = "Körper Half", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_half"}
BodySkins["gc_arf_body_ezra"] = {name = "Körper ezra", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_ezra"}
BodySkins["gc_arf_body_smack"] = {name = "Körper smack", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_smack"}
BodySkins["gc_body_awen"] = {name = "Körper awen", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_awen"}
BodySkins["gc_arf_body_black"] = {name = "Körper camo black", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_camo_black"}
BodySkins["gc_arf_body_felucia"] = {name = "Körper camo felucia", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_camo_felucia"}
BodySkins["gc_arf_body_geonosis"] = {name = "Körper camo geonosis", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_camo_geonosis"}
BodySkins["gc_arf_body_kashyyyk"] = {name = "Körper camo kashyyyk", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_camo_kashyyyk"}
BodySkins["gc_arf_body_mimban"] = {name = "Körper camo mimban", desc = "", price = 1000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/arf/body/body_camo_mimban"}
BodySkins["gc_christmas24_body"] = {name = "Körper Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"}




// !! GHOST COMPANY BODY ENDE !! //

-------------------
-- NEUE EINHEIT! --
-------------------

// ENGINEERING COMPANY BODY //
BodySkins["ec_body_1"] = {name = "Rücken", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body1"}
BodySkins["ec_body_2"] = {name = "Unklar", desc = "", price = 30000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body2"}
BodySkins["ec_body_4"] = {name = "38th", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body4"}
BodySkins["ec_veteran_body"] = {name = "Veteran", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body3"}
BodySkins["ec_original_body"] = { name = "Original", desc = "", price = 50000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body5" }
BodySkins["ec_invertiert_body"] = { name = "Invertiert", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body6" }
BodySkins["ec_raptor_body"] = { name = "Raptor", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_raptor" }
BodySkins["ec_operator_body"] = { name = "Operator", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_operator" }
BodySkins["ec_upgrade_body"] = { name = "upgrade", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_upgrade" }
BodySkins["ec_raute_body"] = { name = "raute", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_raute" }
BodySkins["ec_raute_inverted_body"] = { name = "raute", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_raute_inverted" }
BodySkins["ec_203rd_body"] = { name = "203rd", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_203rd" }
BodySkins["ft_body_flame"] = { name = "Flame", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_flametrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ft/body/body_flame" }
BodySkins["ec_body_fixer"] = { name = "Body Fixer", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_fixer" }
BodySkins["ec_body_metal"] = { name = "Body Metal", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ec/body/body_metal" }
BodySkins["ec_body_christmas24"] = { name = "Body Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body" }


// !! ENGINEERING COMPANY BODY ENDE !! //

-------------------
-- NEUE EINHEIT! --
-------------------

// 2nd AIRBORNE COMPANY BODY //
BodySkins["ac_body_1"] = { name = "Körper T", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body1_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body1"} }
BodySkins["ac_body_2"] = { name = "Körper Fatline", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body2_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body2"} }
BodySkins["ac_body_3"] = { name = "Körper Y", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body3_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body3"} }
BodySkins["ac_body_4"] = { name = "Körper Brust", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body4_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body4"} }
BodySkins["ac_body_5"] = { name = "Körper Arrow", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body5_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body5"} }
BodySkins["ac_body_trio"] = { name = "Körper Trio", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_trio_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_trio"} }
BodySkins["ac_body_curves"] = { name = "Körper Curves", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_curves_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_curves"} }
BodySkins["ac_body_triangle"] = { name = "Körper Triangle", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_triangle_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_triangle"} }
BodySkins["ac_body_yirt"] = { name = "Körper Yirt", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_yirt_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_yirt"} }
BodySkins["ac_body_stripes"] = { name = "Körper Stripes", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_stripes_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_stripes"} }
BodySkins["ac_body_Order"] = { name = "Körper Order", desc = "", price = 45000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_order66_airborne", [2] = "starwars/grady/itemshop/212th/airborne/body/body_order66"}, cantBuy = true}
BodySkins["ac_body_recon"] = { name = "Körper Recon", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_recon", [2] = "starwars/grady/itemshop/212th/airborne/body/body_recon"} }
BodySkins["ac_body_christmas24"] = { name = "Körper Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl", "models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body", [2] = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"} }


// 2nd AIRBORNE COMPANY BODY ENDE !! //


-------------------
-- NEUE LEGION! --
-------------------


-------------------
// 501st LEGION //
-------------------
// TORRENT COMPANY MAIN BODY //
BodySkins["tc_body_2"] = { name = "Körper Arrow", desc = "Einige Pfeile", price = 60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body2" }
BodySkins["tc_body_3"] = { name = "Körper Asym", desc = "Blauer Strich auf weißen Grund", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body3" }
BodySkins["tc_body_4"] = { name = "Körper Sturmgrau", desc = "Stürmischer Kämpfer", price = 70000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body4" }
BodySkins["tc_body_5"] = { name = "Körper Zorn", desc = "Zorn der Torrent Company", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body5" }
BodySkins["tc_body_6"] = { name = "Körper Malerei", desc = "Sieht aus wie Höhlenmalerei", price = 80000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body6" }
BodySkins["tc_body_7"] = { name = "Körper Poseidon", desc = "Mit der Macht vqon Poseidon", price = 70000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body7" }
BodySkins["tc_body_8"] = { name = "Körper I", desc = "Illuminati confirmed", price = 60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body8" }
BodySkins["tc_christmas_body"] = {name = "Weihnachtsskin", desc = "Nur via Geschenk erhältlich.", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_christmas", cantBuy = true}
BodySkins["tc_veteran_body"] = {name = "Veteran", desc = "Teil des Veteran-Packs", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body1"}
BodySkins["tc_order_body"] = {name = "Body Order", desc = "Limitiert erhältlich bis: 14.04.2022", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_order66", cantBuy = true}
BodySkins["501st_tano_body"] = {name = "Körper Tano", desc = "Commander Tano ist stolz.", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_332nd"}
BodySkins["501st_ph1_body"] = {name = "Körper Classic", desc = "Die guten alten Zeiten...", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_phase1"}
BodySkins["501st_triton_body"] = {name = "Körper Triton", desc = "Triton.", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_triton"}
BodySkins["501st_umbra_body"] = {name = "Körper Umbra", desc = "Umbra.", price = 80000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_umbra"}
BodySkins["501st_elite_body"] = { name = "Körper Elite", desc = "Für die Elite.", price = 80000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_elite" }
BodySkins["501st_bodyrallye"] = { name = "Körper Rallye", desc = "Umbra.", price = 70000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_rallye" }
BodySkins["501st_bodyyoda"] = { name = "Körper Yoda", desc = "", price = 90000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_yoda" }
BodySkins["501st_baymaxbody"] = { name = "Körper Baymax", desc = "", price = 65000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_baymax" }
BodySkins["501st_destinybody"] = { name = "Körper Destiny", desc = "", price = 70000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_destiny" }
BodySkins["501st_pointybody"] = { name = "Körper Pointy", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_pointy" }
BodySkins["tc_body_relikt"] = { name = "Körper Relikt", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_old_republic" }
BodySkins["tc_body_moon"] = { name = "Körper Moon", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_moon" }
BodySkins["tc_body_origins"] = { name = "Körper Origins", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_origins" }
BodySkins["tc_body_tfu_commander"] = { name = "Körper TFU Commander", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_tfu_commander" }
BodySkins["tc_body_2099"] = { name = "Körper 2099", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_2099", vipOnly = true }
BodySkins["tc_body_rook"] = { name = "Körper Rook", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_rook" }
BodySkins["tc_body_awen"] = { name = "Körper awen", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_awen" }
BodySkins["dp_body_forheavy"] = { name = "Körper forheavy", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/dp/body/body_for-hevy" }
BodySkins["dp_body_nexos"] = { name = "Körper nexos", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/dp/body/body_nexos" }
BodySkins["tc_body_christmas24"] = { name = "Körper Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body" }


// TORRENT COMPANY BODY MAIN ENDE! //

-------------------
-- NEUE EINHEIT! --
-------------------

// TORRENT COMPANY JAIG BODY //
BodySkins["JP_Body_1"] = {name = "Körper Jaig Arrows", desc = "Der Pfeil geht nach oben wie Lauch Fabian", price = 60000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_arrow"}
BodySkins["JP_Body_2"] = {name = "Körper Lowkey", desc = "Der ist Lowkey geil", price = 60000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_lowkey"}
BodySkins["JP_Body_3"] = {name = "Körper Wirbel", desc = "Wirbel wie beim Stress mit der ST", price = 60000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_wirbel"}
BodySkins["JP_Body_4"] = {name = "Körper Crescent", desc = "Der Halbmond ist schön", price = 60000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_crescent"}
BodySkins["JP_Body_Umbra"] = {name = "Körper Umbra", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_umbra"}
BodySkins["JP_Body_Rallye"] = {name = "Körper Rallye", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_rallye"}
BodySkins["JP_Body_Dagger"] = {name = "Körper Dagger", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_dagger"}
BodySkins["JP_Body_332nd"] = {name = "Körper Tano", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 40000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_332nd"}
BodySkins["JP_Body_Cabo"] = {name = "Körper Cabo", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_cabo"}
BodySkins["JP_Body_tfu_commander"] = {name = "Körper TFU Commander", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_tfu_commander"}
BodySkins["JP_Body_rook"] = {name = "Körper Rook", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_rook"}
BodySkins["JP_Body_asssassine"] = {name = "Körper Assassine", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_assassine"}
BodySkins["JP_Body_2099"] = {name = "Körper 2099", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_2099"}
BodySkins["JP_Body_bad_batch"] = {name = "Körper Bad Batch", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_bad-batch"}
BodySkins["JP_Body_awen"] = {name = "Körper Awen", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 35000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/jaig/body/body_awen"}
BodySkins["JP_Body_christmas24"] = {name = "Körper Christmas", desc = "Wer das liest muss Grady schreiben das er blöd ist", price = 20000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"}

// TORRENT COMPANY JAIG BODY ENDE ! //

-------------------
-- NEUE EINHEIT! --
-------------------

// MEDICAL PLATOON BODY //
BodySkins["jumptrooper_Bodyjet"] = {name = "Körper Jet", desc = "", price = 60000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics-jumptrooper/body/body_jet"}
BodySkins["mp_body_1"] = {name = "Körper Bluechest", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body1"}
BodySkins["mp_body_2"] = {name = "Körper Bizeps", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body2"}
BodySkins["mp_body_3"] = {name = "Körper Armstreifen", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body3"}
BodySkins["mp_body_4"] = {name = "Körper Bluesocks", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body4"}
BodySkins["mp_body_5"] = {name = "Körper Kraftpaket", desc = "", price = 60000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body5"}
BodySkins["mp_body_6"] = {name = "Körper Patriot", desc = "", price = 30000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body6"}
BodySkins["mp_body_7"] = {name = "Körper Lauch", desc = "", price = 45000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body7"}
BodySkins["mp_body_8"] = {name = "Körper Grey", desc = "", price = 70000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body8"}
BodySkins["mp_body_9"] = {name = "Körper Spuren", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body9"}
BodySkins["mp_body_10"] = {name = "Körper Attention", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body10"}
BodySkins["mp_body_10"] = {name = "Körper Attention", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body10"}
BodySkins["mp_body_sigil"] = {name = "Körper Sigil", desc = "", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_Sigil"}
BodySkins["mp_body_skull"] = {name = "Körper Skull", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_skull"}
BodySkins["mp_body_vest"] = {name = "Körper Vest", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_vest"}
BodySkins["mp_body_front"] = {name = "Körper Front", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_frontkaempfer"}
BodySkins["mp_body_divine-wings"] = {name = "Körper Divine-Wings", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_divine-wings"}
BodySkins["mp_body_dok"] = {name = "Körper Dok", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_dok"}
BodySkins["mp_body_orion"] = {name = "Körper Orion", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_orion"}
BodySkins["mp_body_minos"] = {name = "Körper Minos", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_minos"}
BodySkins["mp_body_stratos"] = {name = "Körper Stratos", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/medics/body/body_stratos"}
BodySkins["mp_body_christmas24"] = {name = "Körper Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl","models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"}


// MEDICAL PLATOON BODY ENDE! //


-------------------
-- NEUE LEGION! --
-------------------


// SCHOCKTRUPPEN BODY //
BodySkins["ST_ph1_body"] = { name = "Körper Classic", desc = "Die guten alten Zeiten...", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_phase1"}
BodySkins["ST_triton_body"] = { name = "Körper Triton", desc = "Triton.", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_triton"}
BodySkins["ST_umbra_body"] = { name = "Körper Umbra", desc = "Umbra.", price = 80000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_umbra"}
BodySkins["ST_imp_body"] = { name = "Körper Imp", desc = "Irgendwie kommt mir das bekannt vor..", price = 20000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_imperial"}
BodySkins["ST_senat_body"] = { name = "Körper Senat", desc = "I am the Senate.", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_coruscant_guard"}
BodySkins["ST_bodyrallye"] = { name = "Körper Rallye", desc = "Umbra.", price = 70000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_rallye"}
BodySkins["ST_bodyyoda"] = { name = "Körper Yoda", desc = "", price = 90000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_yoda"}
BodySkins["ST_baymaxbody"] = { name = "Körper Baymex", desc = "", price = 65000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_baymax"}
BodySkins["ST_destinybody"] = { name = "Körper Destiny", desc = "", price = 70000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_destiny"}
BodySkins["ST_pointy"] = { name = "Körper Pointy", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_pointy"}
BodySkins["st_body_aurek"] = { name = "Körper Strich", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body3"}
BodySkins["st_body_besh"] = { name = "Körper Politic", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body2"}
BodySkins["st_body_cresh"] = { name = "Körper Glänzer", desc = "", price = 20000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body1"}
BodySkins["st_body_relikt"] = { name = "Körper Relikt", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_old_republic"}
BodySkins["st_body_moon"] = { name = "Körper Moon", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_moon"}
BodySkins["st_body_origins"] = { name = "Körper Origins", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_origins"}
BodySkins["st_body_tfu_commander"] = { name = "Körper TFU Commander", desc = "", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_tfu_commander"}
BodySkins["st_body_2099"] = { name = "Körper 2099", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_2099", vipOnly = true }
BodySkins["st_body_rook"] = { name = "Körper Rook", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_rook"}
BodySkins["st_body_awen"] = { name = "Körper Awen", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_awen"}
BodySkins["st_body_christmas24"] = { name = "Körper Christmas", desc = "", price = 20000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/special/christmas2024/clone/body"}



// SCHOCKTRUPPEN BODY ENDE! //


---- ARC SKINS GESONDERT WEIL SO VIEL HUSOBULLSHITZEUG ----

// TORRENT COMPANY ARC ARMA //
HeadSkins["501_arc_arma_helm"] = {name = "Helm Arma", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/arma/arc_helmet"}
BodySkins["501_arc_arma_body"] = {name = "Body Arma", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/arma/ct_body"}
BodySkins["501_arc_arma_gear"] = {name = "Gear Arma", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/arma/arc_gear"}
BodySkins["501_arc_arma_kama"] = {name = "Kama Arma", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/arma/arc_kama"}

// TORRENT COMPANY ARC UMBRA //
HeadSkins["501_arc_umbra_helm"] = {name = "Helm umbra", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/umbra/arc_helmet"}
BodySkins["501_arc_umbra_body"] = {name = "Body umbra", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/umbra/ct_body"}
BodySkins["501_arc_umbra_gear"] = {name = "Gear umbra", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/umbra/arc_gear"}
BodySkins["501_arc_umbra_kama"] = {name = "Kama umbra", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/umbra/arc_kama"}

// TORRENT COMPANY ARC SLICK (NICHT FÜR SLICK HEISST EINFACH SO KP) //
HeadSkins["501_arc_slick_helm"] = {name = "Helm slick", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/slick/arc_helmet"}
BodySkins["501_arc_slick_body"] = {name = "Body slick", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/slick/ct_body"}
BodySkins["501_arc_slick_gear"] = {name = "Gear slick", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/slick/arc_gear"}
BodySkins["501_arc_slick_kama"] = {name = "Kama slick", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/slick/arc_kama"}

// TORRENT COMPANY ARC KÖNIGLICH //
HeadSkins["501_arc_königlicher_helm"] = {name = "Helm Königlich", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/koeniglich/arc_helmet"}
BodySkins["501_arc_königlicher_Body"] = {name = "Body Königlich", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/koeniglich/ct_body"}
BodySkins["501_arc_königlicher_Gear"] = {name = "Gear Königlich", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/koeniglich/arc_gear"}
BodySkins["501_arc_königlicher_Kama"] = {name = "Kama Königlich", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/koeniglich/arc_kama"}
BodySkins["501_arc_königlicher_Jetpack"] = {name = "Jetpack fick dich Königlich", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/koeniglich/ct_jetpack"}

// TORRENT COMPANY ARC KÖNIGLICH ENDE! //

// TORRENT COMPANY ARC redemption //
HeadSkins["501_arc_redemption_helm"] = {name = "Helm redemption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/redemption/arc_helmet"}
BodySkins["501_arc_redemption_Body"] = {name = "Body redemption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/redemption/ct_body"}
BodySkins["501_arc_redemption_Gear"] = {name = "Gear redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/redemption/arc_gear"}
BodySkins["501_arc_redemption_Kama"] = {name = "Kama redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/redemption/arc_kama"}
BodySkins["501_arc_redemption_Jetpack"] = {name = "Jetpack fick dich redemption", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/tc/redemption/ct_jetpack"}

// TORRENT COMPANY ARC redemption ENDE! //

// MEDICAL PLATOON ARC PEAK //
HeadSkins["501_arc_mp_peak_helm"] = {name = "Helm Peak", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/peak/arc_helmet"}
BodySkins["501_arc_mp_peak_Body"] = {name = "Body Peak", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/peak/ct_body"}
BodySkins["501_arc_mp_peak_Gear"] = {name = "Gear Peak", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/peak/arc_gear"}
BodySkins["501_arc_mp_peak_Kama"] = {name = "Kama Peak", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/peak/arc_kama"}
BodySkins["501_arc_mp_peak_Jetpack"] = {name = "Jetpack Peak", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/peak/ct_jetpack"}

// MEDICAL PLATOON ARC PEAK ENDE! //

// MEDICAL PLATOON ARC redemption //
HeadSkins["501_arc_mp_redemption_helm"] = {name = "Helm redemption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/redemption/arc_helmet"}
BodySkins["501_arc_mp_redemption_Body"] = {name = "Body redemption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/redemption/ct_body"}
BodySkins["501_arc_mp_redemption_Gear"] = {name = "Gear redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/redemption/arc_gear"}
BodySkins["501_arc_mp_redemption_Kama"] = {name = "Kama redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/redemption/arc_kama"}
BodySkins["501_arc_mp_redemption_Jetpack"] = {name = "Jetpack redemption", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/501st_arc_medic.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/medic/redemption/ct_jetpack"}

// MEDICAL PLATOON ARC PEAK ENDE! //

// TORRENT COMPANY ARC FRAKTAL //
HeadSkins["501_arc_fraktal_Helm"] = {name = "Helm fraktal", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/jaig/fraktal/barc_helmet"}
BodySkins["501_arc_fraktal_body"] = {name = "Body fraktal", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/jaig/fraktal/ct_body"}
BodySkins["501_arc_fraktal_gear"] = {name = "Gear fraktal", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/jaig/fraktal/arc_gear"}
BodySkins["501_arc_fraktal_Kama"] = {name = "Kama fraktal", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/jaig/fraktal/arc_kama"}
BodySkins["501_arc_fraktal_jetpack"] = {name = "Jetpack fraktal", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/501st/jaig/fraktal/ct_jetpack"}

// TORRENT COMPANY ARC FRAKTAL ENDE!//


------------------------------------

// GHOST COMPANY ARC BRANCOS //
HeadSkins["212th_arc_brancos_Helmet"] = {name = "Helm Arma", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/broncas/arc_helmet"}
BodySkins["212th_arc_brancos_Body"] = {name = "Body Brancos", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/broncas/ct_body"}
BodySkins["212_arc_Broncas_Gear"] = {name = "Gear Brancos", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/broncas/arc_gear"}
BodySkins["212_arc_broncas_Kama"] = {name = "Kama Brancos", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/broncas/arc_kama"}

// GHOST COMPANY ARC REDEMPTION //
HeadSkins["212th_arc_redemption_Helmet"] = {name = "Helm redemption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/redemption/arc_helmet"}
BodySkins["212th_arc_redemption_Body"] = {name = "Body redemption", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/redemption/ct_body"}
BodySkins["212_arc_redemption_Gear"] = {name = "Gear redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/redemption/arc_gear"}
BodySkins["212_arc_redemption_Kama"] = {name = "Kama redemption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/redemption/arc_kama"}
BodySkins["212_arc_redemption_jetpack"] = {name = "Jetpack fickdichredemption", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/redemption/ct_jetpack"}


// GHOST COMPANY ARC UMBRA //
HeadSkins["212th_arc_umbra_Helmet"] = {name = "Helm Umbra", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/umbra/arc_helmet"}
BodySkins["212th_arc_umbra_Body"] = {name = "Body Umbra", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/umbra/ct_body"}
BodySkins["212_arc_umbra_Gear"] = {name = "Gear Umbra", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/umbra/arc_gear"}
BodySkins["212_arc_umbra_Kama"] = {name = "Kama Umbra", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/umbra/arc_kama"}

// GHOST COMPANY ARC TALLY //
HeadSkins["212th_arc_tally_Helmet"] = {name = "Helm Tally", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/tally/arc_helmet"}
BodySkins["212th_arc_tally_Body"] = {name = "Body Tally", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/tally/ct_body"}
BodySkins["212_arc_tally_Gear"] = {name = "Gear Tally", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/212th_arc_nexu.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/tally/arc_gear"}
BodySkins["212_arc_tally_Kama"] = {name = "Kama Tally", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/tally/arc_kama"}
BodySkins["212_arc_tally_jetpack"] = {name = "Jetpack fickdich", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/tally/ct_jetpack"}

// GHOST COMPANY ARC VECTOR //
HeadSkins["212th_arc_Vector_Helmet"] = {name = "Helm Vector", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/Vector/arc_helmet"}
BodySkins["212th_arc_Vector_Body"] = {name = "Body Vector", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/Vector/ct_body"}
BodySkins["212_arc_Vector_Gear"] = {name = "Gear Vector", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/Vector/arc_gear"}
BodySkins["212_arc_Vector_Kama"] = {name = "Kama Vector", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/Vector/arc_kama"}
BodySkins["212_arc_Vector_jetpack"] = {name = "Jetpack Vector", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/ghc/Vector/ct_jetpack"}

// AIRBORNE COMPANY ARC DISRUPTION //
HeadSkins["212th_airborne_disruption_helmet"] = {name = "Helm Disruption", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/arc_helmet"}
BodySkins["212th_airborne_disruption_body"] = { name = "Körper Disruption", desc = "", price = 45000, model = {"models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/ct_body2", [1] = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/ct_body"} }
BodySkins["212th_airborne_disruption_gear"] = {name = "Gear Disruption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/arc_gear"}
BodySkins["212th_airborne_disruption_kama"] = {name = "Kama Disruption", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/arc_kama"}
BodySkins["212_airborne_disruption_jetpack"] = {name = "Jetpack fickdich", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/212th_arc_airborne.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/212th/airborne/disruption/ct_jetpack"}

----------------

// ARC RANGEFINDER //
HeadSkins["arc_rangefinder_white"] = {name = "Rangefinder Weiß", desc = "", price = 5000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl", "models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 8, mat = "starwars/grady/itemshop/sonstiges/arcs/attachments-neutral/rangefinder/rangefinder_white"}
HeadSkins["arc_rangefinder_black"] = {name = "Rangefinder Schwarz", desc = "", price = 5000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl", "models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 8, mat = "starwars/grady/itemshop/sonstiges/arcs/attachments-neutral/rangefinder/rangefinder_black"}
HeadSkins["arc_rangefinder_grey"] = {name = "Rangefinder Grau", desc = "", price = 5000, model = {"models/starwars/grady/arc/aoc/212th_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_heavy.mdl", "models/starwars/grady/arc/aoc/501st_arc_trooper.mdl", "models/starwars/grady/arc/aoc/501st_arc_jaig.mdl"}, id = 8, mat = "starwars/grady/itemshop/sonstiges/arcs/attachments-neutral/rangefinder/rangefinder_grey"}
// ARC RANGEFINDER ENDE! //

-------------------------------------------------------------

// GM ARC TWONK //
HeadSkins["lyrahelmet"] = {name = "Helm huren", desc = "", price = 20000, model = {"models/starwars/grady/arc/aoc/gm_arc_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/arcs/navy/marine/lyra/arc_helmet"}
BodySkins["lyrabody"] = {name = "Body sohn", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/gm_arc_trooper.mdl"}, id = 1, mat = "starwars/grady/itemshop/sonstiges/arcs/navy/marine/lyra/ct_body"}
BodySkins["lyragear"] = {name = "Gear denkt", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/gm_arc_trooper.mdl"}, id = 12, mat = "starwars/grady/itemshop/sonstiges/arcs/navy/marine/lyra/arc_gear"}
BodySkins["lyrakama"] = {name = "Kama er", desc = "", price = 10000, model = {"models/starwars/grady/arc/aoc/gm_arc_trooper.mdl"}, id = 13, mat = "starwars/grady/itemshop/sonstiges/arcs/navy/marine/lyra/arc_kama"}
BodySkins["lyrajetpack"] = {name = "Jetpack fickdich", desc = "", price = 50000, model = {"models/starwars/grady/arc/aoc/gm_arc_trooper.mdl"}, id = 11, mat = "starwars/grady/itemshop/sonstiges/arcs/navy/marine/lyra/ct_jetpack"}

 -- 


-- Poison Skins


        
    HeadSkins["st_helm_arrow"] = { name = "Helm Arrow", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_arrow"}
    HeadSkins["st_helm_aurek"] = { name = "Helm Aurek", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_aurek"}
    HeadSkins["st_helm_blaze"] = { name = "Helm Blaze", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_blaze"}
    HeadSkins["st_helm_fleet"] = { name = "Helm Fleet", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_fleet"}
    HeadSkins["st_helm_flotille"] = { name = "Helm Flotille", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_flotille"}
    HeadSkins["st_helm_keeli"] = { name = "Helm Keeli", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_keeli"}
    HeadSkins["st_helm_loyalty"] = { name = "Helm Loyalty", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_loyalty"}
    HeadSkins["st_helm_nord"] = { name = "Helm Nord", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_nord"}
    HeadSkins["st_helm_sentinel"] = { name = "Helm Sentinel", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_sentinel"}
    HeadSkins["st_helm_sun"] = { name = "Helm Sun", desc = "", price = 40000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_sun"}




    BodySkins["st_body_arrow"] = { name = "Körper Arrow", desc = "", price = 60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_arrow"}
    BodySkins["st_body_aurek"] = { name = "Körper Aurek", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_aurek"}
    BodySkins["st_body_blaze"] = { name = "Körper Blaze", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_blaze"}
    BodySkins["st_body_fleet"] = { name = "Körper Fleet", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_fleet"}
    BodySkins["st_body_flotille"] = { name = "Körper Flotille", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_flotille"}
    BodySkins["st_body_keeli"] = { name = "Körper Keeli", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_keeli"}
    BodySkins["st_body_loyalty"] = { name = "Körper Loyalty", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_loyalty"}
    BodySkins["st_body_nord"] = { name = "Körper Nord", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_nord"}
    BodySkins["st_body_sentinel"] = { name = "Körper Sentinel", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_sentinel"}
    BodySkins["st_body_sun"] = { name = "Körper Sun", desc = "", price =  60000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/sonstiges/st/body/body_sun"}










    HeadSkins["tc_helm_aurek"] = { name = "Helm Aurek", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_aurek"}
    HeadSkins["tc_helm_blaze"] = { name = "Helm Blaze", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_blaze"}
    HeadSkins["tc_helm_dra"] = { name = "Helm Dra", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_dra"}
    HeadSkins["tc_helm_keeli"] = { name = "Helm Keeli", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_keeli"}
    HeadSkins["tc_helm_nord"] = { name = "Helm Nord", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_nord"}
    HeadSkins["tc_helm_sentinel"] = { name = "Helm Sentinel", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_sentinel"}
    HeadSkins["tc_helm_sun"] = { name = "Helm Sun", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 3, mat = "starwars/grady/itemshop/501st/tc/helmet/helmet_sun"}




    BodySkins["tc_body_aurek"] = { name = "Körper Aurek", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_aurek"}
    BodySkins["tc_body_blaze"] = { name = "Körper Blaze", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_blaze"}
    BodySkins["tc_body_dra"] = { name = "Körper Dra", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_dra"}
    BodySkins["tc_body_keeli"] = { name = "Körper Keeli", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_keeli"}
    BodySkins["tc_body_nord"] = { name = "Körper Nord", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_nord"}
    BodySkins["tc_body_sentinel"] = { name = "Körper Sentinel", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_sentinel"}
    BodySkins["tc_body_sun"] = { name = "Körper Sun", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/501st/dp/501st_dp_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/tc/body/body_sun"}









    HeadSkins["ghc_helm_aurek"] = { name = "Helm Aurek", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_aurek"}
    HeadSkins["ghc_helm_blaze"] = { name = "Helm Blaze", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_blaze"}
    HeadSkins["ghc_helm_keeli"] = { name = "Helm Keeli", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_keeli"}
    HeadSkins["ghc_helm_nord"] = { name = "Helm Nord", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_nord"}
    HeadSkins["ghc_helm_sentinel"] = { name = "Helm Sentinel", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_sentinel"}
    HeadSkins["ghc_helm_sun"] = { name = "Helm Sun", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 3, mat = "starwars/grady/itemshop/212th/ghc/helmet/helmet_sun"}




    BodySkins["ghc_body_aurek"] = { name = "Körper Aurek", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_aurek"}
    BodySkins["ghc_body_blaze"] = { name = "Körper Blaze", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_blaze"}
    BodySkins["ghc_body_keeli"] = { name = "Körper Keeli", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_keeli"}
    BodySkins["ghc_body_nord"] = { name = "Körper Nord", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_nord"}
    BodySkins["ghc_body_sentinel"] = { name = "Körper Sentinel", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_sentinel"}
    BodySkins["ghc_body_sun"] = { name = "Körper Sun", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/ghc/body/body_sun"}



    HeadSkins["tc_airborne_helm_blaze"] = { name = "Helm Blaze", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/501st/501st-airborne/helmet/helmet_blaze"}
    BodySkins["tc_airborne_body_blaze"] = { name = "Körper Blaze", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/501st-airborne/body/body_blaze"}
    HeadSkins["tc_airborne_helm_crawl"] = { name = "Helm Crawl", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/501st/501st-airborne/helmet/helmet_crawl"}
    BodySkins["tc_airborne_body_crawl"] = { name = "Körper Crawl", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/501st-airborne/body/body_crawl"}
    HeadSkins["tc_airborne_helm_keeli"] = { name = "Helm Keeli", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/501st/501st-airborne/helmet/helmet_keeli"}
    BodySkins["tc_airborne_body_keeli"] = { name = "Körper Keeli", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/501st-airborne/body/body_keeli"}
    HeadSkins["tc_airborne_helm_nord"] = { name = "Helm Nord", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/501st/501st-airborne/helmet/helmet_nord"}
    BodySkins["tc_airborne_body_nord"] = { name = "Körper Nord", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/501st-airborne/body/body_nord"}
    HeadSkins["tc_airborne_helm_sentinel"] = { name = "Helm Sentinel", desc = "", price = 40000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 4, mat = "starwars/grady/itemshop/501st/501st-airborne/helmet/helmet_sentinel"}
    BodySkins["tc_airborne_body_sentinel"] = { name = "Körper Sentinel", desc = "", price =  60000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = "starwars/grady/itemshop/501st/501st-airborne/body/body_sentinel"}


    HeadSkins["ghc_airborne_helm_blaze"] = { name = "Helm Blaze", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_blaze"}
    BodySkins["ghc_airborne_body_blaze"] = { name = "Körper Blaze", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/airborne/body/body_blaze"}
    HeadSkins["ghc_airborne_helm_crawl"] = { name = "Helm Crawl", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_crawl"}
    BodySkins["ghc_airborne_body_crawl"] = { name = "Körper Crawl", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/airborne/body/body_crawl"}
    HeadSkins["ghc_airborne_helm_keeli"] = { name = "Helm Keeli", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_keeli"}
    BodySkins["ghc_airborne_body_keeli"] = { name = "Körper Keeli", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/airborne/body/body_keeli"}
    HeadSkins["ghc_airborne_helm_nord"] = { name = "Helm Nord", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_nord"}
    BodySkins["ghc_airborne_body_nord"] = { name = "Körper Nord", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/airborne/body/body_nord"}
    HeadSkins["ghc_airborne_helm_sentinel"] = { name = "Helm Sentinel", desc = "", price = 40000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 4, mat = "starwars/grady/itemshop/212th/airborne/helmet/helmet_sentinel"}
    BodySkins["ghc_airborne_body_sentinel"] = { name = "Körper Sentinel", desc = "", price =  60000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl","models/starwars/grady/aoc/212th/2nd_airborne/2nd_trooper.mdl"}, id = 2, mat = "starwars/grady/itemshop/212th/airborne/body/body_sentinel"}


    HeadSkins["gm__helm_born"] = { name = "Helm Born", desc = "", price = 40000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 3, mat = "starwars/poison/itemshop/sonstiges/marines/born/helmet_born"}
    BodySkins["gm_body_born"] = { name = "Körper Born", desc = "", price =  60000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 0, mat = "starwars/poison/itemshop/sonstiges/marines/born/body_born"}
    HeadSkins["gm_helm_caller"] = { name = "Helm Caller", desc = "", price = 40000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 3, mat = "sstarwars/poison/itemshop/sonstiges/marines/caller/helmet_caller"}
    BodySkins["gm_body_caller"] = { name = "Körper Caller", desc = "", price =  60000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 0, mat = "starwars/poison/itemshop/sonstiges/marines/caller/body_caller"}
    HeadSkins["gm_helm_drax"] = { name = "Helm Drax", desc = "", price = 40000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 3, mat = "starwars/poison/itemshop/sonstiges/marines/drax/helmet_drax"}
    BodySkins["gm_body_drax"] = { name = "Körper Drax", desc = "", price =  60000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 0, mat = "starwars/poison/itemshop/sonstiges/marines/drax/body_drax"}
    HeadSkins["gm_helm_nautilux"] = { name = "Helm Nautliux", desc = "", price = 40000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 3, mat = "starwars/poison/itemshop/sonstiges/marines/nautilux/helmet_nautilux"}
    BodySkins["gm_body_nautilux"] = { name = "Körper Nautilux", desc = "", price =  60000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 0, mat = "starwars/poison/itemshop/sonstiges/marines/nautilux/body_nautilux"}
    HeadSkins["gm_helm_viper"] = { name = "Helm Viper", desc = "", price = 40000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 4, mat = "starwars/poison/itemshop/sonstiges/marines/viper/helmet_viper"}
    BodySkins["gm_body_viper"] = { name = "Körper Viper", desc = "", price =  60000, model = {"models/starwars/grady/aoc/navy_marine/navy_marine.mdl"}, id = 0, mat = "starwars/poison/itemshop/sonstiges/marines/viper/body_viper"}

BundleSkins = {}
//
// BAD BATCH BUNDLES //
BundleSkins["212th_Airborne_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/212th_airborne/212th_airborne2_parjai.mdl", "models/starwars/grady/212th_airborne/212th_airborne2.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/airborne/body/body_bad-batch", [4] = "starwars/grady/itemshop/212th/airborne/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/212th/airborne/body/body_bad-batch"} }
BundleSkins["212th_GC_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/212th/ghc/body/body_bad-batch"} }
BundleSkins["212th_EC_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ec/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/212th/ec/body/body_bad-batch"} }
BundleSkins["212th_ARF_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/arf/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/212th/arf/body/body_bad-batch"} }
BundleSkins["501_TC_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/501st/tc/body/body_bad-batch"} }
BundleSkins["ST_BB"] = { name = "Badbatch Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 70000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_bad-batch", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_bad-batch"} }
BundleSkins["fivesrotidingi"] = { name = "Rot Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 90000, model = {"models/starwars/grady/arc/aoc/501st_arc_fives.mdl"}, id = 2, mat = {[1] = "rino/bodyfivesrot", [3] = "rino/helmetfivesrot", [11] = "rino/arckamafivesrot", [10] = "rino/arcgearfivesrot"}  }
BundleSkins["fivesorangeidingi"] = { name = "Orange Bundle", desc = "Zeige deine Liebe zum Bad Batch", price = 90000, model = {"models/starwars/grady/arc/aoc/501st_arc_fives.mdl"}, id = 2, mat = {[1] = "rino/fivesbodyorange", [3] = "rino/fiveshelmorange", [11] = "rino/fiveskamaorange", [10] = "rino/fivesgearorange"}  }

// BAD BATCH BUNDLES ENDE !//

-------------------
-- NEUES BUNDLE! --
-------------------

// PREDATOR BUNDLE //
BundleSkins["TC_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_predator", [2] = "starwars/grady/itemshop/501st/tc/body/body_predator"}, cantBuy = true }
BundleSkins["TC_Jaig_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/jaig/helmet/helmet_predator", [2] = "starwars/grady/itemshop/501st/jaig/body/body_predator"}, cantBuy = true }
BundleSkins["MP_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/medics/helmet/helmet_predator", [2] = "starwars/grady/itemshop/501st/medics/body/body_predator"}, cantBuy = true }
BundleSkins["GC_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_predator", [2] = "starwars/grady/itemshop/212th/ghc/body/body_predator"}, cantBuy = true }
BundleSkins["GC_Arf_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/arf/helmet/helmet_predator", [2] = "starwars/grady/itemshop/212th/arf/body/body_predator"}, cantBuy = true }
BundleSkins["EC_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ec/helmet/helmet_predator", [2] = "starwars/grady/itemshop/212th/ec/body/body_predator"}, cantBuy = true }
BundleSkins["AC_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/212th_airborne/212th_airborne2.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/212th/airborne/helmet/helmet_predator", [3] = "starwars/grady/itemshop/212th/airborne/body/body_predator", [2] = "starwars/grady/itemshop/212th/airborne/body/body_predator"}, cantBuy = true }
BundleSkins["ST_Predator"] = { name = "Predator Bundle", desc = "Hunt", price = -1, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_predator", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_predator"}, cantBuy = true }
// PREDATOR BUNDLE ENDE ! //

-------------------
-- NEUES BUNDLE! --
-------------------

// JUBI2025 BUNDLE //
BundleSkins["TC_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/body"}, cantBuy = false }
BundleSkins["TC_Jaig_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/helmet_barc", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/body"}, cantBuy = false }
BundleSkins["MP_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = {[2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/body", [3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/501st/helmet_ph2"}, cantBuy = false }
BundleSkins["GC_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/212th/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/212th/body"}, cantBuy = false }
BundleSkins["GC_Arf_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/212th/helmet_arf", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/212th/body"}, cantBuy = false }
BundleSkins["EC_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/ec/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/ec/body"}, cantBuy = false }
BundleSkins["AC_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/airborne/helmet_airborne", [3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/airborne/body", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/airborne/body"}, cantBuy = false }
BundleSkins["ST_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/st/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/st/body"}, cantBuy = false }
BundleSkins["ST_K9_Jubi2025"] = { name = "Jubi2025 Bundle", desc = "Nur kaufbar bis zum 22.04.2025", price = 250000, model = {"models/starwars/grady/aoc/st/st/st_trooper_k9.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/st/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/special/jubi2025/clone/st/body"}, cantBuy = false }
// JUBI2025 BUNDLE ENDE ! //

-------------------
-- NEUES BUNDLE! --
-------------------

// HALLOWEEN BUNDLE //
BundleSkins["212th_Halloween_Airborne"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/212th_airborne/212th_airborne2.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/212th/airborne/helmet/helmet_halloween",[3] = "starwars/grady/itemshop/212th/airborne/body/body_halloween", [2] = "starwars/grady/itemshop/212th/airborne/body/body_halloween"}, cantBuy = true }
BundleSkins["212th_Halloween_arf"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/arf/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/212th/arf/body/body_halloween"}, cantBuy = true }
BundleSkins["212th_Halloween_gc"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/212th/ghc/body/body_halloween"}, cantBuy = true }
BundleSkins["212th_Halloween_ec"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ec/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/212th/ec/body/body_halloween"}, cantBuy = true }
BundleSkins["501_halloween_heavy"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/heavy/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/501st/heavy/body/body_halloween"}, cantBuy = true }
BundleSkins["501_halloween_jaig"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/jaig/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/501st/jaig/body/body_halloween"}, cantBuy = true }
BundleSkins["501_halloween_medic"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/501st_medic/501st_medic2.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/medics/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/501st/medics/body/body_halloween"}, cantBuy = true }
BundleSkins["501_halloween_tc"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/501st/tc/body/body_halloween"}, cantBuy = true }
BundleSkins["halloween_st"] = { name = "Halloween Bundle", desc = "Spooky", price = -1, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_halloween", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_halloween"}, cantBuy = true }

// HALLOWEEN BUNDLE ENDE! //

// HALLOWEEN BUNDLE 2 //
BundleSkins["212th_Halloween23_gc"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/212th/ghc/body/body_halloween_skeleton"}, cantBuy = false }
BundleSkins["212th_Halloween23_ec"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/212th/ghc/body/body_halloween_skeleton"}, cantBuy = false }
BundleSkins["501_halloween23_heavy"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/501st/tc/body/body_halloween_skeleton"}, cantBuy = false }
BundleSkins["501_halloween23_medic"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/501st_medic/501st_medic2.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/501st/tc/body/body_halloween_skeleton"}, cantBuy = false }
BundleSkins["501_halloween23_tc"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/501st/tc/body/body_halloween_skeleton"}, cantBuy = false }
BundleSkins["halloween23_st"] = { name = "Halloween 23 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_halloween_skeleton", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_halloween_skeleton"}, cantBuy = false }

// HALLOWEEN BUNDLE ENDE! //

BundleSkins["Halloween_24_PH2"] = { name = "Halloween 24 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl", "models/starwars/grady/aoc/212th/ec/212th_engineer.mdl", "models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl", "models/starwars/grady/501st_medic/501st_medic2.mdl", "models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }
BundleSkins["Halloween_24_PILOT"] = { name = "Halloween 24 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/avp/piloten/avp_pilot.mdl", "models/starwars/grady/aoc/avp/piloten/avp_schattenstaffel.mdl", "models/starwars/grady/aoc/avp/piloten/avp_goldstaffel.mdl", "models/starwars/grady/aoc/avp/piloten/avp_blaustaffel.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_pilot_ph2", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }
BundleSkins["Halloween_24_ARF"] = { name = "Halloween 24 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_arf", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }
BundleSkins["Halloween_24_JAIG"] = { name = "Halloween 24 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_barc", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }
-- BundleSkins["Halloween_24_HEAVY"] = { name = "Halloween 24 Bundle", desc = "Spooky", price = 30000, model = {"models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_barc", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }

-------------------
-- NEUES BUNDLE! --
-------------------

// Christmas navy BUNDLE ENDE! //

--BundleSkins["Fleetcrewchristmas24"] = { name = "Christmas 24 Bundle", desc = "Spooky", price = 40000, model = {"models/starwars/grady/aoc/navy/republic_navy_clone.mdl", "models/starwars/grady/aoc/navy/republic_navy_human1.mdl", "models/starwars/grady/aoc/navy/republic_navy_human2.mdl", "models/starwars/grady/aoc/navy/republic_navy_human3.mdl", "models/starwars/grady/aoc/navy/republic_navy_human4.mdl", "models/starwars/grady/aoc/navy/republic_navy_human5.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/helmet_ph2", [2] = "starwars/grady/itemshop/sonstiges/unassigned/halloween2024/body"}, cantBuy = false }

-------------------
-- NEUES BUNDLE! --
-------------------

// ARF GC REAPER BUNDLE //
BundleSkins["GC_Reaper"] = { name = "Reaper", desc = "Reaper", price = 75000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/arf/helmet/helmet_reaper", [2] = "starwars/grady/itemshop/212th/arf/body/body_reaper"} }
// ARF GC REAPER BUNDLE ENDE !//

-------------------
-- NEUES BUNDLE! --
-------------------

//  //
BundleSkins["tc_jet_shiny"] = { name = "Jet SHINY Bundle", desc = "STRENG LIMITIERT", price = 80000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_jet_shiny", [2] = "starwars/grady/itemshop/501st/tc/body/body_jet_shiny"}, cantBuy = false }
BundleSkins["st_jet_shiny"] = { name = "Jet SHINY Bundle", desc = "STRENG LIMITIERT", price = 80000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_jet_shiny", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_jet_shiny"}, cantBuy = false }
BundleSkins["gc_jet_shiny"] = { name = "Jet SHINY Bundle", desc = "STRENG LIMITIERT", price = 80000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_jet_shiny", [2] = "starwars/grady/itemshop/212th/ghc/body/body_jet_shiny"}, cantBuy = false }
BundleSkins["tc_jet"] = { name = "Jet  Bundle", desc = " ", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_jet", [2] = "starwars/grady/itemshop/501st/tc/body/body_jet"}, cantBuy = false }
BundleSkins["st_jet"] = { name = "Jet  Bundle", desc = " ", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_jet", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_jet"}, cantBuy = false }
BundleSkins["gc_jet"] = { name = "Jet  Bundle", desc = " ", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_jet", [2] = "starwars/grady/itemshop/212th/ghc/body/body_jet"}, cantBuy = false }
-------------------
-- NEUES BUNDLE! --
-------------------

// KÖNIGLICH BUNDLES (INAKTIV?) //
BundleSkins["501st_koeniglich"] = { name = "Eine königliche Mischung!", desc = "Zeige deine Liebe zum Bad Batch ", price = 175000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl", "models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_koeniglich", [2] = "starwars/grady/itemshop/501st/tc/body/body_koeniglich"} }
BundleSkins["501st_koeniglich_Arc"] = { name = "Eine königliche Mischung!", desc = "Zeige deine Liebe zum Bad Batch", price = 175000, model = {"models/starwars/grady/arc/aoc/501st_arc_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/heavy/helmet/helmet_koeniglich", [2] = "starwars/grady/itemshop/501st/heavy/body/body_koeniglich"} }
// KÖNIGLICH BUNDLES ENDE ! //

// DRAGONSTONE BUNDLE //
BundleSkins["TC_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/501st/tc/501st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/501st/tc/body/body_dragonstone"}, cantBuy = false }
BundleSkins["TC_Heavy_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/501st/heavy/501st_heavy.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/heavy/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/501st/heavy/body/body_dragonstone"}, cantBuy = false }
-- BundleSkins["TC_JAIG_DRAGONSTONE"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/501st/jaig/501st_jaig.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/jaig/helmet/helmet_predator", [2] = "starwars/grady/itemshop/501st/jaig/body/body_predator"}, cantBuy = true }
BundleSkins["MP_DRAGONSTONE"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/501st/medic/501st_medic.mdl", "models/starwars/grady/aoc/501st/medic/501st_medic_jumptrooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/501st/tc/body/body_dragonstone"}, cantBuy = false }
BundleSkins["GC_DRAGONSTONE"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/212th/ghc/212th_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/212th/ghc/body/body_dragonstone"}, cantBuy = false }
BundleSkins["GC_Arf_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/212th/arf/212th_arf.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/arf/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/212th/arf/body/body_dragonstone"}, cantBuy = false }
BundleSkins["EC_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/212th/ec/212th_engineer.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/212th/ghc/helmet/helmet_dragonstone", [2] = "starwars/grady/itemshop/212th/ghc/body/body_dragonstone"}, cantBuy = false }
BundleSkins["TRITON_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/501st/airborne/501st_airborne.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/501st/airborne/helmet/helmet_dragonstone", [3] = "starwars/grady/itemshop/501st/airborne/body/body_dragonstone", [2] = "starwars/grady/itemshop/501st/airborne/body/body_dragonstone"}, cantBuy = false }
BundleSkins["PARJAI_DRAGONSTONE"] = { name = "Dragonstone Bundle", desc = "Fick Delta", price = 50000, model = {"models/starwars/grady/aoc/212th/2nd_airborne/2nd_parjai.mdl"}, id = 2, mat = {[4] = "starwars/grady/itemshop/212th/airborne/helmet/helmet_dragonstone", [3] = "starwars/grady/itemshop/212th/airborne/body/body_dragonstone", [2] = "starwars/grady/itemshop/212th/airborne/body/body_dragonstone"}, cantBuy = false }
-- BundleSkins["ST_Dragonstone"] = { name = "Dragonstone Bundle", desc = "Hunt", price = 50000, model = {"models/starwars/grady/aoc/st/st/st_trooper.mdl"}, id = 2, mat = {[3] = "starwars/grady/itemshop/sonstiges/st/helmet/helmet_predator", [2] = "starwars/grady/itemshop/sonstiges/st/body/body_predator"}, cantBuy = false }
// PREDATOR BUNDLE ENDE ! //

CustomSkins = {}
--CustomSkins["76561198879798564_1"] = { name = "Tom Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198879798564"}, id = 2, mat = {[3] = "starwars/grady/itemshop/501st/tc/helmet/helmet_jet_shiny", [2] = "starwars/grady/itemshop/501st/tc/body/body_jet_shiny"}, cantBuy = false }
CustomSkins["76561198421239333_1"] = { name = "Pita Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198421239333"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/06_48_pita/helmet", [2] = "starwars/grady/itemshop/custom/06_48_pita/body"}, cantBuy = false }
CustomSkins["76561197995228042_1"] = { name = "Benni Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561197995228042"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/02_49_breaker/helmet", [2] = "starwars/grady/itemshop/custom/02_49_breaker/body"}, cantBuy = false }
CustomSkins["76561198450281238_1"] = { name = "Midnight Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198450281238"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/01_51_midnight/helmet", [2] = "starwars/grady/itemshop/custom/01_51_midnight/body"}, cantBuy = false }
CustomSkins["76561198979991069_1"] = { name = "Attie Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198979991069"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/04_57_baghira/helmet", [2] = "starwars/grady/itemshop/custom/04_57_baghira/body"}, cantBuy = false }
CustomSkins["76561198273696005_1"] = { name = "Nexos Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198273696005"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/03_67_nexos/helmet", [2] = "starwars/grady/itemshop/custom/03_67_nexos/body"}, cantBuy = false }
CustomSkins["76561198124373784_1"] = { name = "Kraw Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198124373784"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/08_69_riboflavin/helmet", [2] = "starwars/grady/itemshop/custom/08_69_riboflavin/body"}, cantBuy = false }
CustomSkins["76561199167552823_1"] = { name = "Kira Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199167552823"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/05_27_kira/helmet", [2] = "starwars/grady/itemshop/custom/05_27_kira/body"}, cantBuy = false }
CustomSkins["76561198410324827_1"] = { name = "Kotu Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198410324827"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/07_68_kotu/helmet", [2] = "starwars/grady/itemshop/custom/07_68_kotu/body"}, cantBuy = false }
CustomSkins["76561199204492653_1"] = { name = "Wave Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199204492653"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/10_74_wave/helmet", [2] = "starwars/grady/itemshop/custom/10_74_wave/body"}, cantBuy = false }
CustomSkins["76561198353985180_1"] = { name = "Thatch Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198353985180"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/09_75_thatch/helmet", [2] = "starwars/grady/itemshop/custom/09_75_thatch/body"}, cantBuy = false }
CustomSkins["76561199055369098_1"] = { name = "Reapzz Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199055369098"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/11_77_reapzz/helmet", [2] = "starwars/grady/itemshop/custom/11_77_reapzz/body"}, cantBuy = false }
CustomSkins["76561199230131345_1"] = { name = "Stormer Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199230131345"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/12_80_stormer/body", [4] = "starwars/grady/itemshop/custom/12_80_stormer/helmet", [2] = "starwars/grady/itemshop/custom/12_80_stormer/body"} }
CustomSkins["76561198979991069_2"] = { name = "Baghira Custom Skin 2", desc = "Dein eigener Custom Skin x2 bro!", price = 0, steamid = {"76561198979991069"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/13_57_baghira/body", [4] = "starwars/grady/itemshop/custom/13_57_baghira/helmet", [2] = "starwars/grady/itemshop/custom/13_57_baghira/body"} }
CustomSkins["76561199062255854_1"] = { name = "Burner Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199062255854"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/15_108_burner/helmet", [2] = "starwars/grady/itemshop/custom/15_108_burner/body"}, cantBuy = false }
CustomSkins["76561199121789698_1"] = { name = "Viper Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199121789698"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/14_81_tigerviper/helmet", [2] = "starwars/grady/itemshop/custom/14_81_tigerviper/body"}, cantBuy = false }
CustomSkins["76561198410324827_1"] = { name = "Kotu Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198410324827"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/17_112_kotu/helmet", [2] = "starwars/grady/itemshop/custom/17_112_kotu/body"}, cantBuy = false }
CustomSkins["76561199403340981_1"] = { name = "May Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199403340981"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/18_103_may/helmet", [2] = "starwars/grady/itemshop/custom/18_103_may/body"}, cantBuy = false }
CustomSkins["76561198365870079_1"] = { name = "Law Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198365870079"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/19_105_max/helmet", [2] = "starwars/grady/itemshop/custom/19_105_max/body"}, cantBuy = false }
CustomSkins["76561198799175456_1"] = { name = "Oneshot Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198799175456"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/20_110_oneshot/helmet", [2] = "starwars/grady/itemshop/custom/20_110_oneshot/body"}, cantBuy = false }
CustomSkins["76561198410324827_1"] = { name = "Kotu 2 Custom Skin", desc = "Dein eigener Custom Skin x2 !", price = 0, steamid = {"76561198410324827"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/17_112_kotu/helmet", [2] = "starwars/grady/itemshop/custom/17_112_kotu/body"}, cantBuy = false }
CustomSkins["76561198837558657_2"] = { name = "Zerek Custom Skin 2", desc = "Dein eigener Custom Skin x2 bro!", price = 0, steamid = {"76561198837558657"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/16_114_zerek/body", [4] = "starwars/grady/itemshop/custom/16_114_zerek/helmet", [2] = "starwars/grady/itemshop/custom/16_114_zerek/body"} }
CustomSkins["76561198979991069_3"] = { name = "Baghira Custom Skin 3", desc = "Dein eigener Custom Skin x3 !", price = 0, steamid = {"76561198979991069"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/22_57_baghira/helmet", [2] = "starwars/grady/itemshop/custom/22_57_baghira/body"}, cantBuy = false }
CustomSkins["76561199189617635_1"] = { name = "Axe Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199189617635"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/26_192_axe/body", [4] = "starwars/grady/itemshop/custom/26_192_axe/helmet", [2] = "starwars/grady/itemshop/custom/26_192_axe/body"} }
CustomSkins["76561198156716789_1"] = { name = "Nitro Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198156716789"}, id = 2, mat = {[4] = "starwars/grady/itemshop/custom/25_173_nitro/helmet", [2] = "starwars/grady/itemshop/custom/25_173_nitro/body"}, cantBuy = false }
CustomSkins["76561198450281238_2"] = { name = "Midnight Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198450281238"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/21_51_midnight/helmet", [2] = "starwars/grady/itemshop/custom/21_51_midnight/body"}, cantBuy = false }
CustomSkins["76561198417817201_1"] = { name = "Hammer Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198417817201"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/24_167_hammer/helmet", [2] = "starwars/grady/itemshop/custom/24_167_hammer/body"}, cantBuy = false }
CustomSkins["76561199378792328_1"] = { name = "Tone Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199378792328"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/33_198_tone/helmet", [2] = "starwars/grady/itemshop/custom/33_198_tone/body"}, cantBuy = false }
CustomSkins["76561198078686237_1"] = { name = "Skirmish Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198078686237"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/31_197_skirmish/helmet", [2] = "starwars/grady/itemshop/custom/31_197_skirmish/body"}, cantBuy = false }
CustomSkins["76561199022200778_1"] = { name = "Shade Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199022200778"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/30_195_shade/helmet", [2] = "starwars/grady/itemshop/custom/30_195_shade/body"}, cantBuy = false }
CustomSkins["76561199015929301_1"] = { name = "Lyks Custom Skin 2", desc = "Dein eigener Custom Skin x2 bro!", price = 0, steamid = {"76561199015929301"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/28_178_lux/body", [4] = "starwars/grady/itemshop/custom/28_178_lux/helmet", [2] = "starwars/grady/itemshop/custom/28_178_lux/body"} }
CustomSkins["76561198076228255_1"] = { name = "Coldeye Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198076228255"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/29_174_slidecurry/helmet", [2] = "starwars/grady/itemshop/custom/29_174_slidecurry/body"}, cantBuy = false }
CustomSkins["76561199230131345_2"] = { name = "Stormer Custom Skin 2", desc = "Dein eigener Custom Skin x2 bro!", price = 0, steamid = {"76561199230131345"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/27_80_stormer/body", [4] = "starwars/grady/itemshop/custom/27_80_stormer/helmet", [2] = "starwars/grady/itemshop/custom/27_80_stormer/body"} }
CustomSkins["76561198096084263_1"] = { name = "Jumpi Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198096084263"}, id = 2, mat = {[4] = "starwars/grady/itemshop/custom/37_202_jumpi/helmet", [2] = "starwars/grady/itemshop/custom/37_202_jumpi/body"}, cantBuy = false }
CustomSkins["76561198445305250_1"] = { name = "Nylar Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198445305250"}, id = 2, mat = {[4] = "starwars/grady/itemshop/custom/36_93_nylar/helmet", [2] = "starwars/grady/itemshop/custom/36_93_nylar/body"}, cantBuy = false }
CustomSkins["76561198100419508_1"] = { name = "Hammerhead Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198100419508"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/68_437_hammerhead/helmet", [2] = "starwars/grady/itemshop/custom/34_200_hammerhead/body"}, cantBuy = false }
CustomSkins["76561198388606711_1"] = { name = "Chip Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198388606711"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/32_199_chip/helmet", [2] = "starwars/grady/itemshop/custom/32_199_chip/body"}, cantBuy = false }
CustomSkins["76561198943547080_1"] = { name = "Grandle Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198943547080"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/23_139_grandle/helmet", [2] = "starwars/grady/itemshop/custom/23_139_grandle/body"}, cantBuy = false }
CustomSkins["76561199161270771_1"] = { name = "HAWKEYE Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199161270771"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/35_97_hawkeye/helmet", [2] = "starwars/grady/itemshop/custom/35_97_hawkeye/body"}, cantBuy = false }
CustomSkins["76561198164545482_1"] = { name = "Quanit Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198164545482"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/39_79_quanite/helmet", [2] = "starwars/grady/itemshop/custom/39_79_quanite/body"}, cantBuy = false }
CustomSkins["76561198277529992_1"] = { name = "Theckray Custom Skin", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198277529992"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/38_21_theckray/body", [4] = "starwars/grady/itemshop/custom/38_21_theckray/helmet", [2] = "starwars/grady/itemshop/custom/38_21_theckray/body"} }
CustomSkins["76561198220313240_1"] = { name = "Sabaton Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198220313240"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/40_92_sabaton/helmet", [2] = "starwars/grady/itemshop/custom/40_92_sabaton/body"}, cantBuy = false }
CustomSkins["76561198979991069_4"] = { name = "Baghira Custom Skin 4", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198979991069"}, id = 2, mat = {[4] = "starwars/grady/itemshop/custom/42_111_akaanir/helmet", [2] = "starwars/grady/itemshop/custom/42_111_akaanir/body"}, cantBuy = false }
CustomSkins["76561198372429376_1"] = { name = "Faid Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198372429376"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/43_124_faid/helmet", [2] = "starwars/grady/itemshop/custom/43_124_faid/body"}, cantBuy = false }
CustomSkins["76561199229864836_1"] = { name = "SYconsti Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199229864836"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/46_162_syconsti/helmet", [2] = "starwars/grady/itemshop/custom/46_162_syconsti/body"}, cantBuy = false }
CustomSkins["76561197995228042_2"] = { name = "Breaker Custom Skin x2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561197995228042"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/41_138_breaker/helmet", [2] = "starwars/grady/itemshop/custom/41_138_breaker/body"}, cantBuy = false }
CustomSkins["76561198803370161_1"] = { name = "Dark Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198803370161"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/44_154_dark/body", [4] = "starwars/grady/itemshop/custom/44_154_dark/helmet", [2] = "starwars/grady/itemshop/custom/44_154_dark/body"} }
CustomSkins["76561199167552823_2"] = { name = "Lukas Custom Skin x2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199167552823"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/47_160_lukas/helmet", [2] = "starwars/grady/itemshop/custom/47_160_lukas/body"}, cantBuy = false }
CustomSkins["76561198448840888_1"] = { name = "Caide Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198448840888"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/45_153_caide/helmet", [2] = "starwars/grady/itemshop/custom/45_153_caide/body"}, cantBuy = false }
CustomSkins["76561198356715191_1"] = { name = "Poison Custom Skin 2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198356715191"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/50_199_poison/body", [4] = "starwars/grady/itemshop/custom/50_199_poison/helmet", [2] = "starwars/grady/itemshop/custom/50_199_poison/body"} }
CustomSkins["76561198169861555_1"] = { name = "Ghost Custom Skin", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198169861555"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/48_179_ghost/body", [4] = "starwars/grady/itemshop/custom/48_179_ghost/helmet", [2] = "starwars/grady/itemshop/custom/48_179_ghost/body"} }
CustomSkins["76561198273696005_2"] = { name = "Nexos Custom Skin 2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198273696005"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/49_189_Nexos/body", [4] = "starwars/grady/itemshop/custom/49_189_Nexos/helmet", [2] = "starwars/grady/itemshop/custom/49_189_Nexos/body"} }
CustomSkins["76561198415146805_1"] = { name = "Unknock Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198415146805"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/51_208_unknockname/helmet", [2] = "starwars/grady/itemshop/custom/51_208_unknockname/body"}, cantBuy = false }
CustomSkins["76561199068471591_1"] = { name = "Kenner Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199068471591"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/53_257_keck25/helmet", [2] = "starwars/grady/itemshop/custom/53_257_keck25/body"}, cantBuy = false }
CustomSkins["76561198134492877_1"] = { name = "Schneider Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198134492877"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/54_320_schneider/arc_helmet", [1] = "starwars/grady/itemshop/custom/54_320_schneider/ct_body", [12] = "starwars/grady/itemshop/custom/54_320_schneider/arc_gear", [13] = "starwars/grady/itemshop/custom/54_320_schneider/arc_kama"}, cantBuy = false }
CustomSkins["76561199015929301_2"] = { name = "Luke Custom Skin 2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199015929301"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/55_307_luke/helmet", [2] = "starwars/grady/itemshop/custom/55_307_luke/body"} }
CustomSkins["76561198388606711_2"] = { name = "Yesgo Custom Skin x2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198388606711"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/56_226_yesgo/helmet", [2] = "starwars/grady/itemshop/custom/56_226_yesgo/body"}, cantBuy = false }
CustomSkins["76561198095563011_1"] = { name = "Trace Custom Skin x2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198095563011"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/60_305_trace/helmet", [2] = "starwars/grady/itemshop/custom/60_305_trace/body"}, cantBuy = false }
CustomSkins["76561199179713072_1"] = { name = "Gamma Custom Skin x2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199179713072"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/59_313_pilz/helmet", [2] = "starwars/grady/itemshop/custom/59_313_pilz/body"}, cantBuy = false }
CustomSkins["76561198277529992_2"] = { name = "Theckray Custom Skinx2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198277529992"}, id = 2, mat = {[2] = "starwars/grady/itemshop/custom/62_276_liasgeist/body", [3] = "starwars/grady/itemshop/custom/62_276_liasgeist/helmet"}, cantBuy = false }
CustomSkins["76561199091742350_1"] = { name = "Dyr Custom Skin", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199091742350"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/57_302_dyrr/body", [4] = "starwars/grady/itemshop/custom/57_302_dyrr/helmet", [2] = "starwars/grady/itemshop/custom/57_302_dyrr/body"} }
CustomSkins["76561199390128572_1"] = { name = "Fireblast Custom Skin", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199390128572"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/58_311_fireblast/body", [4] = "starwars/grady/itemshop/custom/58_311_fireblast/helmet", [2] = "starwars/grady/itemshop/custom/58_311_fireblast/body"} }
CustomSkins["76561198413402694_1"] = { name = "Dreamz Custom Skinx2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561198413402694"}, id = 2, mat = {[2] = "starwars/grady/itemshop/custom/64_343_dreamz/body", [3] = "starwars/grady/itemshop/custom/64_343_dreamz/helmet"}, cantBuy = false }
CustomSkins["76561199091742350_2"] = { name = "Dyr Custom Skinx2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199091742350"}, id = 2, mat = {[2] = "starwars/grady/itemshop/custom/65_397_dyrr/body", [3] = "starwars/grady/itemshop/custom/65_397_dyrr/helmet"}, cantBuy = false }
CustomSkins["76561199437896680_1"] = { name = "Raphi Custom Skinx2", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199437896680"}, id = 2, mat = {[2] = "starwars/grady/itemshop/custom/66_402_raphi/body", [3] = "starwars/grady/itemshop/custom/66_402_raphi/helmet"}, cantBuy = false }
CustomSkins["76561198355915034_1"] = { name = "Cappybara Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198355915034"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/70_534_cappy/helmet", [1] = "starwars/grady/itemshop/custom/70_534_cappy/body", [11] = "starwars/grady/itemshop/custom/70_534_cappy/arc_gear", [12] = "starwars/grady/itemshop/custom/70_534_cappy/arc_kama"}, cantBuy = false }
CustomSkins["76561199091742350_3"] = { name = "Dyr Custom Skinx3", desc = "Dein eigener Custom Skin bro!", price = 0, steamid = {"76561199091742350"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/67_451_dyrr/body", [4] = "starwars/grady/itemshop/custom/67_451_dyrr/helmet", [2] = "starwars/grady/itemshop/custom/67_451_dyrr/body"} }
CustomSkins["76561198100419508_2"] = { name = "Hammerhead Custom Skinx2", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198100419508"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/68_437_hammerhead/helmet", [2] = "starwars/grady/itemshop/custom/68_437_hammerhead/body"}, cantBuy = false }
CustomSkins["76561199452520626_1"] = { name = "idk Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561199452520626"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/69_440_idk/helmet", [2] = "starwars/grady/itemshop/custom/69_440_idk/body"}, cantBuy = false }
CustomSkins["76561198265517411_1"] = { name = "Corenight Custom Skin", desc = "Dein eigener Custom Skin!", price = 0, steamid = {"76561198265517411"}, id = 2, mat = {[3] = "starwars/grady/itemshop/custom/71_548_corenight/helmet", [2] = "starwars/grady/itemshop/custom/71_548_corenight/body"}, cantBuy = false }

CustomAttachments = {}
CustomAttachments["76561199167552823_attachment_1"] = { name = "Lukas Custom Attachment", desc = "Skibedi Toilet", price = 0, steamid = {"76561199167552823"}, id = 2, mat = {[13] = "starwars/grady/itemshop/custom/_attachments/02_20_lukas/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/02_20_lukas/ct_arf_helmet_attachments"}, cantBuy = false }
CustomAttachments["76561198450281238_attachment_1"] = { name = "Wils Custom Attachment", desc = "Wils Custom Skin", price = 0, steamid = {"76561198450281238"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/03_25_wils/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/03_25_wils/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198421239333_attachment_1"] = { name = "Pita Custom Attachment", desc = "Pita Custom Skin", price = 0, steamid = {"76561198421239333"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/01_42_pita/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/01_42_pita/ct_specialist"}, cantBuy = false }
CustomAttachments["76561199121789698_attachment_1"] = { name = "Tiger Custom Attachment", desc = "Tiger Custom Skin", price = 0, steamid = {"76561199121789698"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/06_35_tiger/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/06_35_tiger/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198329012755_attachment_1"] = { name = "Admirallp Custom Attachment", desc = "Tiger Custom Skin", price = 0, steamid = {"76561198329012755"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/07_14_admirallp/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/07_14_admirallp/ct_specialist"}, cantBuy = false }
CustomAttachments["76561199161270771_attachment_1"] = { name = "Lxonix Custom Attachment", desc = "Lxonix Custom Skin", price = 0, steamid = {"76561199161270771"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/08_72_lxonix/ct_heavy"}, cantBuy = false }
CustomAttachments["76561199041243146_attachment_1"] = { name = "Dec Custom Attachment", desc = "Dec Custom Skin", price = 0, steamid = {"76561199041243146"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/05_28_dec/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/05_28_dec/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198076228255S_attachment_1"] = { name = "Slidecurry Custom Attachment", desc = "Slidecurry Custom Skin", price = 0, steamid = {"76561198076228255"}, id = 2, mat = {[12] = "starwars/grady/itemshop/custom/_attachments/04_23_slidecurry/ct_heavy", [10] = "starwars/grady/itemshop/custom/_attachments/04_23_slidecurry/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198372429376_attachment_1"] = { name = "Faid Custom Attachment", desc = "Faid Custom Skin", price = 0, steamid = {"76561198372429376"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/10_124_faid/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/10_124_faid/ct_specialist"}, cantBuy = false }
CustomAttachments["76561197995228042_attachment_1"] = { name = "Breaker Custom Attachment", desc = "Breaker Custom Skin", price = 0, steamid = {"76561197995228042"}, id = 2, mat = {[13] = "starwars/grady/itemshop/custom/_attachments/09_139_breaker/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/09_139_breaker/ct_arf_helmet_attachments"}, cantBuy = false }
CustomAttachments["76561198943547080_attachment_1"] = { name = "Mulmrius Custom Attachment", desc = "Mulmrius Custom Skin", price = 0, steamid = {"76561198943547080"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/11_145_mulmrius/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/11_145_mulmrius/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198220313240_attachment_1"] = { name = "Sabaton Custom Attachment", desc = "Sabaton Custom Skin", price = 0, steamid = {"76561198220313240"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/13_92_sabaton/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/13_92_sabaton/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198078846517_attachment_1"] = { name = "Aura Custom Attachment", desc = "Aura Custom Skin", price = 0, steamid = {"76561198078846517"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/12_47_Aura/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/12_47_Aura/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198365870079_attachment_1"] = { name = "Max Custom Attachment", desc = "Max Custom Skin", price = 0, steamid = {"76561198365870079"}, id = 2, mat = {[12] = "starwars/grady/itemshop/custom/_attachments/14_167_law/ct_heavy", [10] = "starwars/grady/itemshop/custom/_attachments/14_167_law/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198273696005_attachment_1"] = { name = "Nexos Custom Attachment", desc = "Nexos Custom Skin", price = 0, steamid = {"76561198273696005"}, id = 2, mat = {[11] = "starwars/grady/itemshop/custom/_attachments/15_108_nexos/ct_heavy"}, cantBuy = false }
CustomAttachments["76561199230131345_attachment_1"] = { name = "Stormer Custom Attachment", desc = "Stormer Custom Skin", price = 0, steamid = {"76561199230131345"}, id = 2, mat = {[11] = "starwars/grady/itemshop/custom/_attachments/17_006_stormer/ct_heavy", [9] = "starwars/grady/itemshop/custom/_attachments/17_006_stormer/ct_specialist"}, cantBuy = false } --gcpj
CustomAttachments["76561198450281238_attachment_2"] = { name = "Wils Custom Attachment 2", desc = "Wils Custom Skin", price = 0, steamid = {"76561198450281238"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/16_322_wils/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/16_322_wils/ct_specialist"}, cantBuy = false } --?kp
CustomAttachments["76561198388606711_attachment_1"] = { name = "Yesgo Custom Attachment", desc = "Yesgo Custom Skin", price = 0, steamid = {"76561198388606711"}, id = 2, mat = {[13] = "starwars/grady/itemshop/custom/_attachments/18_226_yesgo/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/18_226_yesgo/ct_arf_helmet_attachments"}, cantBuy = false }
CustomAttachments["76561199068471591_attachment_1"] = { name = "Biba Custom Attachment", desc = "biba Custom Skin", price = 0, steamid = {"76561199068471591"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/20_394_chaoskenner/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/20_394_chaoskenner/ct_specialist"}, cantBuy = false }
CustomAttachments["76561198337950991_attachment_1"] = { name = "Pentatron Custom Attachment", desc = "Pentatron Custom Skin", price = 0, steamid = {"76561198337950991"}, id = 2, mat = {[13] = "starwars/grady/itemshop/custom/_attachments/19_387_pentatron/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/19_387_pentatron/ct_arf_helmet_attachments"}, cantBuy = false }
CustomAttachments["76561198337950991_attachment_1"] = { name = "Chaoskenner Custom Attachment", desc = "Chaoskenner Custom Skin", price = 0, steamid = {"76561198337950991"}, id = 2, mat = {[13] = "starwars/grady/itemshop/custom/_attachments/19_387_pentatron/ct_heavy", [8] = "starwars/grady/itemshop/custom/_attachments/19_387_pentatron/ct_arf_helmet_attachments"}, cantBuy = false }
CustomAttachments["76561199122044100_attachment_1"] = { name = "Maddox Custom Attachment", desc = "Maddox Custom Skin", price = 0, steamid = {"76561199122044100"}, id = 2, mat = {[10] = "starwars/grady/itemshop/custom/_attachments/21_519_maddox/ct_heavy"}, cantBuy = false }
CustomAttachments["76561199569069240_attachment_1"] = { name = "leah Custom Attachment", desc = "leah Custom Skin", price = 0, steamid = {"76561199569069240"}, id = 2, mat = {[8] = "starwars/grady/itemshop/custom/_attachments/22_561_leah/ct_specialist", [10] = "starwars/grady/itemshop/custom/_attachments/22_561_leah/ct_heavy"}, cantBuy = false }
CustomAttachments["76561199071394648_attachment_1"] = { name = "Cardo Custom Attachment", desc = "Cardo Custom Skin", price = 0, steamid = {"76561199071394648"}, id = 2, mat = {[8] = "starwars/grady/itemshop/custom/_attachments/23_525_cardo/ct_specialist", [10] = "starwars/grady/itemshop/custom/_attachments/23_525_cardo/ct_heavy"}, cantBuy = false }
CustomAttachments["76561198078686237_attachment_1"] = { name = "Skirmish Custom Attachment", desc = "Skirmish Custom Skin", price = 0, steamid = {"76561198078686237"}, id = 2, mat = {[8] = "starwars/grady/itemshop/custom/_attachments/24_374_skirmish/ct_specialist", [10] = "starwars/grady/itemshop/custom/_attachments/24_374_skirmish/ct_heavy"}, cantBuy = false }
CustomAttachments["76561198372429376_attachment_1"] = { name = "Faid Custom Attachment", desc = "Faid Custom Skin", price = 0, steamid = {"76561198372429376"}, id = 2, mat = {[8] = "starwars/grady/itemshop/custom/_attachments/25_569_faid/ct_specialist", [10] = "starwars/grady/itemshop/custom/_attachments/25_569_faid/ct_heavy"}, cantBuy = false }
for k, v in pairs(HeadSkins) do

    local buy = true
    if v.cantBuy then
        buy = false 
    end

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = v.desc,
        price = v.price,
        category = "Helmskins",
        apply = true,
        permanent = true,
        canSell = true,
        canBuy = buy,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(v.model,ply:GetModel()) end,
        applyFunc = function(ply) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "kopf", k) end,
        iconFunc = function(panel)  AOCRP.GTM:doHelmetSkinIcon(panel,v.mat,v.id) end,
        previewFunc = function(panel)  AOCRP.GTM:doSkinPreview(panel,v.mat,v.id) end,
    }
end

for k, v in pairs(BodySkins) do

    local buy = true
    if v.cantBuy then
        buy = false 
    end

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = v.desc,
        price = v.price,
        category = "Körperskins",
        apply = true,
        permanent = true,
        canSell = true,
        canBuy = buy,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(v.model,ply:GetModel()) end,
        applyFunc = function(ply) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "body", k) end,
        iconFunc = function(panel)  AOCRP.GTM:doBodySkinIcon(panel,v.mat,v.id) end,
        previewFunc = function(panel)  AOCRP.GTM:doSkinPreview(panel,v.mat,v.id) end,
    }
end


for k, v in pairs(BundleSkins) do

    local buy = true
    if v.cantBuy then
        buy = false 
    end

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = v.desc,
        price = v.price,
        category = "Skinbundles",
        apply = true,
        permanent = true,
        canSell = true,
        canBuy = buy,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(v.model,ply:GetModel()) end,
        applyFunc = function(ply) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "body", k) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "kopf", k) end,
        iconFunc = function(panel)  AOCRP.GTM:doBodySkinIcon(panel,v.mat,v.id) end,
        previewFunc = function(panel)  AOCRP.GTM:doSkinPreview(panel,v.mat,v.id) end,
    }
end

for k, v in pairs(CustomSkins) do

    local buy = true
    if v.cantBuy then
        buy = false 
    end

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = v.desc,
        price = v.price,
        category = "CustomSkins",
        apply = true,
        permanent = true,
        canSell = false,
        canBuy = buy,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(v.steamid,ply:SteamID64()) end,
        applyFunc = function(ply) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "body", k) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "kopf", k) end,
        iconFunc = function(panel)  AOCRP.GTM:doBodySkinIcon(panel,v.mat,v.id) end,
        previewFunc = function(panel)  AOCRP.GTM:doSkinPreview(panel,v.mat,v.id) end,
    }
end

for k, v in pairs(CustomAttachments) do

    local buy = true
    if v.cantBuy then
        buy = false 
    end

    AOCRP.GTM.Items[k] = {
        name = v.name,
        desc = v.desc,
        price = v.price,
        category = "CustomAttachments",
        apply = true,
        permanent = true,
        canSell = false,
        canBuy = buy,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(v.steamid,ply:SteamID64()) end,
        applyFunc = function(ply) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "body", k) AOCRP.GTM:ApplyGTMSkin(ply, v.id, v.mat, "kopf", k) end,
        iconFunc = function(panel)  AOCRP.GTM:doBodySkinIcon(panel,v.mat,v.id) end,
        previewFunc = function(panel)  AOCRP.GTM:doSkinPreview(panel,v.mat,v.id) end,
    }
end


    AOCRP.GTM.Items["animation_flugzeug"] = {
        name = "Flugzeug",
        desc = "Ich heb ab..",
        price = 125000,
        category = "Animationen",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) end,
        iconFunc = function(panel) AOCRP.GTM:DoAnimationPreview(panel,"flugzeug") end,
        previewFunc = function(panel) AOCRP.GTM:DoAnimationPreview(panel,"flugzeug") end,
    }

    

    AOCRP.GTM.Items["animation_middlefinger"] = {
        name = "Mittelfinger",
        desc = "Zeige deinen Hass.",
        price = 300000,
        category = "Animationen",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) end,
        iconFunc = function(panel) AOCRP.GTM:DoAnimationPreview(panel,"middle") end,
        previewFunc = function(panel) AOCRP.GTM:DoAnimationPreview(panel,"middle") end,
    }



    local GTM_ACTS = {}
--[[     GTM_ACTS["act_dance"] = { name = "Act Dance", price = 10000, icon = "BTZqdvS"}
    GTM_ACTS["act_laugh"] = { name = "Act Laugh", price = 5000, icon = "ouFyVyC"}
    GTM_ACTS["act_forward"] = { name = "Act Forward", price = 1000, icon = "sQw1bzg"}
    GTM_ACTS["act_group"] = { name = "Act Group", price = 1000, icon = "b5YEj1p"}
    GTM_ACTS["act_halt"] = { name = "Act Halt", price = 1000, icon = "Tkfic8D"}
    GTM_ACTS["act_agree"] = { name = "Act Agree", price = 5000, icon = "JGZQQZQ"}
    GTM_ACTS["act_becon"] = { name = "Act Becon", price = 2000, icon = "djRzfdT"}
    GTM_ACTS["act_bow"] = { name = "Act Bow", price = 5000, icon = "o8Ern3j"}
    GTM_ACTS["act_disagree"] = { name = "Act Disagree", price = 2000, icon = "UNOkaZo"}
    GTM_ACTS["act_salute"] = { name = "Act Salute", price = 1000, icon = "dX1cSuQ"}
    GTM_ACTS["act_wave"] = { name = "Act Wave", price = 2000, icon = "BIWZYlE"}
    GTM_ACTS["act_pers"] = { name = "Act Pers", price = 10000, icon = "dFxpxgj"}
    GTM_ACTS["act_cheer"] = { name = "Act Cheer", price = 2000, icon = "uBkqpKq"}
    GTM_ACTS["act_zombie"] = { name = "Act Zombie", price = 10000, icon = "qieILw8"}
    GTM_ACTS["act_robot"] = { name = "Act Robot", price = 10000, icon = "GyzImhs"} ]]

    --GTM_ACTS["act_dance"] = { name = "Act Dance", price = 10000, sequence = "taunt_dance" }
    --GTM_ACTS["act_laugh"] = { name = "Act Laugh", price = 5000, sequence = "taunt_laugh" }
    GTM_ACTS["act_forward"] = { name = "Act Forward", price = 1000, sequence = "gesture_signal_forward" }
    GTM_ACTS["act_group"] = { name = "Act Group", price = 1000, sequence = "gesture_signal_group" }
    GTM_ACTS["act_halt"] = { name = "Act Halt", price = 1000, sequence = "gesture_signal_halt" }
    GTM_ACTS["act_agree"] = { name = "Act Agree", price = 5000, sequence = "gesture_agree" }
    GTM_ACTS["act_becon"] = { name = "Act Beacon", price = 2000, sequence = "gesture_becon" }
    GTM_ACTS["act_bow"] = { name = "Act Bow", price = 5000, sequence = "gesture_bow" }
    GTM_ACTS["act_disagree"] = { name = "Act Disagree", price = 2000, sequence = "gesture_disagree" }
    GTM_ACTS["act_salute"] = { name = "Act Salute", price = 1000, sequence = "gesture_salute" }
    GTM_ACTS["act_wave"] = { name = "Act Wave", price = 2000, sequence = "gesture_wave" }
    GTM_ACTS["act_pers"] = { name = "Act Pers", price = 10000, sequence = "taunt_persistence" }
    GTM_ACTS["act_cheer"] = { name = "Act Cheer", price = 2000, sequence = "taunt_cheer" }
    GTM_ACTS["act_zombie"] = { name = "Act Zombie", price = 10000, sequence = "taunt_zombie" }
    GTM_ACTS["act_robot"] = { name = "Act Robot", price = 10000, sequence = "taunt_robot" }
    GTM_ACTS["act_muscle"] = { name = "Act Muscle", price = 10000, sequence = "taunt_muscle" }
    



    for k, v in pairs(GTM_ACTS) do
        AOCRP.GTM.Items[k] = {
            name = v.name,
            desc = "Nach Kauf über Konsole nutzbar.",
            price = v.price,
            category = "Acts",
            apply = false,
            permanent = true,
            canSell = true,
            canBuy = true,
            vipFree = true,
            vipOnly =  false,
            limitFunc = function(ply) return true end,
            applyFunc = function(ply) end,
            iconFunc = function(panel) AOCRP.GTM:DoActPreview(panel,v.sequence) end,
            previewFunc = function(panel) AOCRP.GTM:DoActPreview(panel,v.sequence)  end,
        }
    end




    


    AOCRP.GTM.Items["vibroknife"] = {
        name = "Vibromesser",
        desc = "Schlitze deine Gegner auf",
        price = 350000,
        category = "Waffen",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = false,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyOnSpawnFunc = function(ply) ply:Give("aocrp_vibroknife") end,
        applyFunc = function(ply) ply:Give("aocrp_vibroknife") end,
        iconFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/sopsmisc/vibroknife.png",Color(255,255,255)) end,
        previewFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/sopsmisc/vibroknife.png",Color(255,255,255)) end,
    }

    AOCRP.GTM.Items["dualdc17"] = {
        name = "Dual DC-17",
        desc = "Nimm dir doch einfach ne Zweite.",
        price = 1250000,
        category = "Waffen",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyOnSpawnFunc = function(ply) ply:Give("aocrp_dual_dc17_ext") end,
        applyFunc = function(ply) ply:Give("aocrp_dual_dc17_ext") end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/meeks/worldmodels/w_dc17_ext_dual.mdl") end,
        previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/meeks/worldmodels/w_dc17_ext_dual.mdl") end,
    }


    AOCRP.GTM.Items["helmet_hud"] = {
        name = "Helm",
        desc = "Erlaubt Zugriff auff /helmoverlay",
        price = 30000,
        category = "HUDs",
        apply = false,
        permanent = true,
        canSell = true,
        canBuy = true,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
        end,
        iconFunc = function(panel)  end,
        previewFunc = function(panel) end,
    }


    AOCRP.GTM.Items["singletime_headcrab"] = {
        name = "Haustier",
        desc = "Du hast ein unbekanntes Wesen einfach mitgenommen.",
        price = 50000,
        category = "Aktionen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
        
            local eyetracePos = ply:GetEyeTrace().HitPos

  

            timer.Simple(5, function() 
                local button = ents.Create( "npc_headcrab_fast" )
                button:SetPos( eyetracePos )
                button:Spawn() 
            end)


        end,
        iconFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/npc_headcrab.png") end,
        previewFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/npc_headcrab.png") end,
    }

    AOCRP.GTM.Items["singletime_guard"] = {
        name = "Großes Haustier",
        desc = "Du hast ein unbekanntes Wesen einfach mitgenommen.",
        price = 100000,
        category = "Aktionen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
        
            local eyetracePos = ply:GetEyeTrace().HitPos


            timer.Simple(5, function() 
                local button = ents.Create( "npc_antlionguard" )
                button:SetPos( eyetracePos )
                button:Spawn() 
            end)


        end,
        iconFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/npc_antlionguard.png") end,
        previewFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,"entities/npc_antlionguard.png") end,
    }

    
--[[     AOCRP.GTM.Items["singletime_vip"] = {
        name = "Temporäres VIP",
        desc = "Du erhälst VIP, aber nur bis zum \nnächsten Disconnect oder Mapchange",
        price = 100000,
        category = "Aktionen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
    
           ply:SetAOCVIP(true)

        end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/balloons/balloon_star.mdl") end,
        previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/balloons/balloon_star.mdl") end,
    } ]]

    AOCRP.GTM.Items["singletime_training"] = {
        name = "Trainingsgranate",
        desc = "Macht nicht wirklich boom.",
        price = 1000,
        category = "Waffen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = true,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
    
           ply:Give("rw_sw_nade_training")

        end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/cs574/explosif/grenade_train.mdl") end,
        previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/cs574/explosif/grenade_train.mdl") end,
    }



    AOCRP.GTM.Items["singletime_soccerball"] = {
        name = "Fußball",
        desc = "Perfekt zum Basketballspielen.",
        price = 10000,
        category = "Aktionen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
        
                local entit = ents.Create("prop_physics")
                entit:SetModel("models/props_phx/misc/soccerball.mdl")
                entit:SetPos(ply:GetEyeTrace().HitPos+Vector(0,0,10))
                entit:Spawn()
                undo.Create("prop")
                undo.AddEntity(entit)
                undo.SetPlayer(ply)
               undo.Finish()
                ply:ChatPrint("*** Du hast jetzt einen Fußball. Du kannst ihn mit (Z) entfernen.")

        end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/props_phx/misc/soccerball.mdl") end,
        previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/props_phx/misc/soccerball.mdl") end,
    }



    function AOCRP.GTM:GetDroidAmount()
        local currentCount = 0
        for k,v in ipairs(player.GetAll()) do 
            if v:GetNetVar("AOCRP_DroidEvchr", false) then
                currentCount = currentCount + 1
            end
        end 
        return currentCount
    end

    function AOCRP.GTM:GetEvchrMode()
        return GetGlobalNetVar( "AOCRP_EvchrMode", 1 )
    end

    function AOCRP.GTM:droidEvchr() 


        local count = 0
        local limit = GetGlobalNetVar( "AOCRP_EvchrDroid", 0 )
        local current = AOCRP.GTM:GetDroidAmount()


        if current >= limit then return false end

        return true
    end

    AOCRP.GTM.Items["eventchars_b1"] = {
        name = "B1 Kampfdroide",
        desc = "Spiele einen B1-Kampfdroiden (begrenzt)",
        price = 1000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "b1", 1000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/cis_npc/b1_battledroids/assault/b1_battledroid_assault.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/cis_npc/b1_battledroids/assault/b1_battledroid_assault.mdl") end,
    }

    AOCRP.GTM.Items["eventchars_bx"] = {
        name = "BX Kommandodroide",
        desc = "Spiele einen BX Kommandodroiden (begrenzt)",
        price = 10000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "bx", 10000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/player/cheddar/commando_droid/bx_commando_droid.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/player/cheddar/commando_droid/bx_commando_droid.mdl") end,
    }

    AOCRP.GTM.Items["eventchars_bxcpt"] = {
        name = "BX Captain",
        desc = "Spiele einen BX Captain (begrenzt)",
        price = 15000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "bxcpt", 15000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/player/cheddar/commando_droid/bx_commando_droid.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/player/cheddar/commando_droid/bx_commando_droid.mdl") end,
    }


    AOCRP.GTM.Items["eventchars_droideka"] = {
        name = "Droideka",
        desc = "Spiele einen Droideka (begrenzt)",
        price = 18000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "droideka", 18000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/starwars/stan/droidekas/droideka.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/starwars/stan/droidekas/droideka.mdl") end,
    }

    AOCRP.GTM.Items["eventchars_b2"] = {
        name = "B2 Kampfdroide",
        desc = "Spiele einen B2-Kampfdroiden (begrenzt)",
        price = 5000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1 end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "b2", 5000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/player/hydro/b2_battledroid/b2_battledroid.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/player/hydro/b2_battledroid/b2_battledroid.mdl") end,
    }

    AOCRP.GTM.Items["eventchars_b1heavy"] = {
        name = "B1 Heavy Kampfdroide",
        desc = "Spiele einen B1-Kampfdroiden (begrenzt)",
        price = 5000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 1  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "b1heavy", 5000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/cis_npc/b1_battledroids/heavy/b1_battledroid_heavy.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/cis_npc/b1_battledroids/heavy/b1_battledroid_heavy.mdl") end,
    }


    AOCRP.GTM.Items["eventchr_einwohner"] = {
        name = "Einwohner",
        desc = "Spiele einen Einwohner (begrenzt)",
        price = 1000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 2  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "einwohner", 1000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
    }
    
    AOCRP.GTM.Items["eventchr_aufstand"] = {
        name = "Bewaffneter Aufständischer",
        desc = "Spiele einen Angreifer (begrenzt)",
        price = 1000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 3  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "aufständiger", 1000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
    }
    AOCRP.GTM.Items["eventchr_schweraufstand"] = {
        name = "Bewaffneter Aufständischer (MG)",
        desc = "Spiele einen Angreifer (begrenzt)",
        price = 5000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 3  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "schwaufstand", 5000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/npc_hcn/starwars/bf/weequay/weequay.mdl") end,
    }

    AOCRP.GTM.Items["eventchar_zvk"] = {
        name = "Ziviler Kampfdroide",
        desc = "Spiele einen Droiden (begrenzt)",
        price = 10000,
        category = "Eventcharaktere",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  true,
        limitFunc = function(ply) return AOCRP.GTM:droidEvchr() and AOCRP.GTM:GetEvchrMode() == 3  end,
        applyFunc = function(ply) AOCRP.GTM:DoDroidEventChar(ply, "zivkampfdroid", 10000) end,
        iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/player/swtor/droids/enforcerdroid.mdl") end,
        previewFunc = function(panel)  AOCRP.GTM:doSpawnIcon(panel,"models/player/swtor/droids/enforcerdroid.mdl") end,
    }


    if SERVER then
        util.AddNetworkString("AOCRP.GTM.RecieveCloneID")
        util.AddNetworkString("AOCRP.GTM.RequestCloneID")
        util.AddNetworkString("AOCRP.GTM.RequestZivName")
        util.AddNetworkString("AOCRP.GTM.RecieveZivName")

        net.Receive( "AOCRP.GTM.RecieveCloneID", function( len, ply )
            local idstr = net.ReadString()
            local cloneid = tonumber(idstr)

            if !isnumber(cloneid) then return end
            if cloneid < 111111 or cloneid > 999999 then ply:ChatPrint("*** Die neue ID muss zwischen 111111 und 999999 liegen.") return end

            AOCRP.CharSys:IsCloneIDFree(cloneid, function(free) 
                if free then
                    AOCRP.CharSys:PlayerChangeCloneID(ply, cloneid)
                else
                    ply:ChatPrint("*** Diese ID ist bereits vergeben.")
                    net.Start("AOCRP.GTM.RequestCloneID")
                    net.Send(ply)
                end
            end)
        end )

        net.Receive( "AOCRP.GTM.RecieveZivName", function( len, ply )
            
            local text = net.ReadString()

            if ply:GetNetVar("AOCRP_DroidEvchr", false) then
                ply:SetCloneName(text)
            end 
        end )
    end
    if CLIENT then
        
        
        net.Receive( "AOCRP.GTM.RequestCloneID", function( len, ply )
            AOCDerma:Derma_RequestString( "CloneID Anpassen", "Gebe deine Wunsch-ID an. Sie muss 6 Zahlen enthalten.", "Ok", function(text) 
            
                net.Start("AOCRP.GTM.RecieveCloneID")
                    net.WriteString(text)
                net.SendToServer()
                
            end )
        end )

        local function RequestZivName()
            AOCDerma:SmallStringRequest( "Wähle einen Namen für deinen Eventcharakter", function(text) 
                if #text < 3 then 
                    RequestZivName()
                    return
                end 

                net.Start("AOCRP.GTM.RecieveZivName")
                net.WriteString(text)
                net.SendToServer()
            end, "", "[^a-zA-Z%s]", function() 
                RequestZivName()
            end )
        end
                
        net.Receive( "AOCRP.GTM.RequestZivName", function( len, ply )

            RequestZivName()
    
        end )

   
    end

    AOCRP.GTM.Items["singletime_cloneid"] = {
        name = "Klon-ID ändern",
        desc = "Ändere deine ID.",
        price = 1,
        category = "Aktionen",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return table.HasValue(AOCRP.Config.CloneID, ply:GetUserGroup()) or ply:GetAOCVIP() end,
        applyFunc = function(ply) 
    
           net.Start("AOCRP.GTM.RequestCloneID")
           net.Send(ply)

        end,
        iconFunc = function(panel) AOCRP.GTM:doImgurIcon(panel,"Fpr11IH") end,
        previewFunc = function(panel) AOCRP.GTM:doImgurIcon(panel,"Fpr11IH") end,
    }
 

    local GTM_Attachments_Color = {}
--[[     GTM_Attachments_Color["blaster_aqua"] = {vipfree = true, price = 80000, icon = "cs574/impacts/sw_laser_bit_aqua", name = "Aqua", tracer = "rw_sw_laser_aqua", impact = "rw_sw_impact_aqua"}
    GTM_Attachments_Color["blaster_black"] = {vipfree = false, price = 1000000, icon = "cs574/impacts/sw_laser_bit_black", name = "Unsichtbar", tracer = "rw_sw_laser_black", impact = "rw_sw_impact_black"}
    GTM_Attachments_Color["blaster_grey"] = {vipfree = true, price = 30000, icon = "cs574/impacts/sw_laser_bit_grey", name = "Grau", tracer = "rw_sw_laser_grey", impact = "rw_sw_impact_grey"}
    GTM_Attachments_Color["blaster_orange"] = {vipfree = true, price = 100000, icon = "cs574/impacts/sw_laser_bit_orange", name = "Orange", tracer = "rw_sw_laser_orange", impact = "rw_sw_impact_orange"}
    GTM_Attachments_Color["blaster_green"] = {vipfree = true, price = 100000, icon = "effects/sw_laser_green_front", name = "Grün", tracer = "effect_sw_laser_green", impact = "rw_sw_impact_blue"}
    GTM_Attachments_Color["blaster_white"] = {vipfree = true, price = 200000, icon = "effects/sw_laser_white_front", name = "Weiß", tracer = "effect_sw_laser_white", impact = "rw_sw_impact_blue"}
    GTM_Attachments_Color["blaster_yellow"] = {vipfree = true, price = 200000, icon = "effects/sw_laser_yellow_front", name = "Gelb", tracer = "effect_sw_laser_yellow", impact = "rw_sw_impact_blue"}

 ]]


    
    for k, v in pairs(GTM_Attachments_Color) do
        local ATTACHMENT = {}


        ATTACHMENT.Name = v.name
        ATTACHMENT.ShortName = "BF" --Abbreviation, 5 chars or less please
        ATTACHMENT.Description = { 
            TFA.AttachmentColors["="],"Im GTM erhältlich",
        }
        ATTACHMENT.Icon = v.icon --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"


        ATTACHMENT.WeaponTable = {
            ["TracerName"] = v.tracer,
            ["ImpactEffect"] = v.impact,
        }


        function ATTACHMENT:CanAttach(wep)
            return AOCRP.GTM:HasItem(wep:GetOwner(), k)
        end

        function ATTACHMENT:Attach(wep)
        end

        function ATTACHMENT:Detach(wep)
        end


        TFA.Attachments.Register(k, ATTACHMENT)
        ATTACHMENT = nil


        AOCRP.GTM.Items[k] = {
            name = v.name,
            desc = "Ändert die Farbe deines Schusses. \n Muss im C-Menü der Waffe ausgewählt werden",
            price = v.price,
            category = "Blasterfarben",
            apply = false,
            permanent = true,
            canSell = true,
            canBuy = true,
            vipFree = v.vipfree,
            vipOnly =  false,
            limitFunc = function(ply) return true end,
            applyFunc = function(ply) end,
            iconFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,v.icon) end,
            previewFunc = function(panel) AOCRP.GTM:doMaterialIcon(panel,v.icon) end,
        }
    

    end


    local function IsInNewYearRange()
        -- Hole die aktuelle Zeit
        local currentTime = os.time()
        
        -- Erstelle die Zeitpunkte für den Beginn und das Ende des Zeitraums
        local startRange = os.time({year = 2025, month = 1, day = 1, hour = 0, min = 1, sec = 0})
        local endRange = os.time({year = 2025, month = 1, day = 1, hour = 0, min = 10, sec = 0})
    
        -- Prüfe, ob die aktuelle Zeit im Bereich liegt
        return currentTime >= startRange and currentTime <= endRange
    end

    AOCRP.GTM.Items["ribbon_2025"] = {
        name = "Tag des Lichts 2025",
        desc = "Nur innerhalb von 10min des Neujahres 2025 kaufbar.",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = false,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 
            if IsInNewYearRange() then
                AOCRP.Ribbons:GTMGiveRibbon(ply, 46)
            else 
                local currentTime = os.time()

                -- Konvertiere den Zeitstempel in ein lesbares Format
                local readableTime = os.date("%d-%m-%Y %H:%M:%S", currentTime)
                ply:ChatPrint("*** Das Ribbon kannst du nur am 01.01.2025 von 00:01 bis 00:10 kaufen. Aktuell ist es der "..readableTime)
            end
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"T2vd1Ya") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"T2vd1Ya") end,
    }



    AOCRP.GTM.Items["ribbon_fox"] = {
        name = "Sonderorden - Fox",
        desc = "Bestich Commander Fox für einzigartiges Ribbon.",
        price = 10000000,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return true end,
        applyFunc = function(ply) 

            AOCRP.Ribbons:GTMGiveRibbon(ply, 7)

        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"m8qSjvH") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"m8qSjvH") end,
    }


    AOCRP.GTM.Items["ribbon_vip"] = {
        name = "VIP",
        desc = "Claime diesen Ribbon für dein aktuellen Char",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return ply:GetAOCVIP() end,
        applyFunc = function(ply) 
            AOCRP.Ribbons:GTMGiveRibbon(ply, 2)
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"pfyyO8H") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"pfyyO8H") end,
    }

    AOCRP.GTM.Items["ribbon_old_dono"] = {
        name = "Veteran",
        desc = "Claime diesen Ribbon für dein aktuellen Char",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) local donators = {"Donator_T1", "Donator_T2", "Donator_T3"}
            return table.HasValue(donators, ply:GetUserGroup())  end,
        applyFunc = function(ply) 
            AOCRP.Ribbons:GTMGiveRibbon(ply, 3)
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"zrwHLS8") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"zrwHLS8") end,
    }


    AOCRP.GTM.Items["ribbon_team"] = {
        name = "Teammitglied",
        desc = "Claime diesen Ribbon für dein aktuellen Char",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return AOCRP.Admin:IsTeamMember(ply) end,
        applyFunc = function(ply) 
            AOCRP.Ribbons:GTMGiveRibbon(ply, 5)
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"QaTYavt") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"QaTYavt") end,
    }


    AOCRP.GTM.Items["ribbon_ausbilder"] = {
        name = "Ausbilder",
        desc = "Claime diesen Ribbon für dein aktuellen Char",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return ply:GetAusbilder() end,
        applyFunc = function(ply) 
            AOCRP.Ribbons:GTMGiveRibbon(ply, 4)
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"eWSR5tH") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"eWSR5tH") end,
    }


    AOCRP.GTM.Items["ribbon_reich"] = {
        name = "Monopolorden",
        desc = "Claime diesen Ribbon für dein aktuellen Char",
        price = 0,
        category = "Ribbons",
        apply = true,
        permanent = false,
        canSell = false,
        canBuy = true,
        vipFree = false,
        vipOnly =  false,
        limitFunc = function(ply) return ply:getMoney() > 999999 end,
        applyFunc = function(ply) 
            AOCRP.Ribbons:GTMGiveRibbon(ply, 15)
        end,
        iconFunc = function(panel) AOCRP.GTM:doRibbon(panel,"waWSdOj") end,
        previewFunc = function(panel) AOCRP.GTM:doRibbon(panel,"waWSdOj") end,
    }

--[[     AOCRP.Ribbons.HardCoded = {}
    AOCRP.Ribbons.HardCoded["vip"] = 2
    AOCRP.Ribbons.HardCoded["donator"] = 3
    AOCRP.Ribbons.HardCoded["ausbilder"] = 4
    AOCRP.Ribbons.HardCoded["team"] = 5
    AOCRP.Ribbons.HardCoded["richest"] = 15
    
    


        -- Feste Ribbons

        if ply:GetAOCVIP() then
            table.insert(ribbons, AOCRP.Ribbons.HardCoded["vip"])
        end

        if ply:GetAusbilder() then
            table.insert(ribbons, AOCRP.Ribbons.HardCoded["ausbilder"])
        end

        if ply == getRichestPlayer() then 
            table.insert(ribbons, AOCRP.Ribbons.HardCoded["richest"])
        end 

        local donators = {"Donator_T1", "Donator_T2", "Donator_T3"}
        if table.HasValue(donators, ply:GetUserGroup()) then
            table.insert(ribbons, AOCRP.Ribbons.HardCoded["donator"])
        end

        if AOCRP.Admin:IsTeamMember(ply) then
            table.insert(ribbons, AOCRP.Ribbons.HardCoded["team"])
        end

 ]]

--[[ function AOCRP.GTM:GetZivCount()

    local count = 0

    count = count + AOCRP.Gear:GetCurrentCount(259)
    count = count + AOCRP.Gear:GetCurrentCount(304)
    return count
end

function AOCRP.GTM:GetMaxZiv()
    return GetGlobalNetVar( "AOCRP_ZIVMAX", 0)
end

if SERVER then 

    function AOCRP.GTM:BecomeZiv(ply, gear)

        if AOCRP.GTM:GetZivCount() < AOCRP.GTM:GetMaxZiv() then


            ply:SetGearID(gear)
            ply:ApplyGear()
            ply:SetUnitID(10)

            ply:SetHideCloneID(true)
            ply:SetRankID(0)
            ply:Spawn()

            
            ply.KickOutOfCharOnRespawn = true 

        end
    end
end 

 AOCRP.GTM.Items["zivs"] = {
    name = "Zivilist",
    desc = "Spiele einen Zivilisten.",
    price = 5000,
    category = "Temporäre Charaktere",
    apply = true,
    permanent = false,
    canSell = false,
    canBuy = true,
    vipFree = true,
    vipOnly =  false,
    limitFunc = function(ply) return AOCRP.GTM:GetZivCount() < AOCRP.GTM:GetMaxZiv() end,
    applyFunc = function(ply) AOCRP.GTM:BecomeZiv(ply, 259) end,
    iconFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/hcn/starwars/bf/human/human_male_4.mdl") end,
    previewFunc = function(panel) AOCRP.GTM:doSpawnIcon(panel,"models/hcn/starwars/bf/human/human_male_4.mdl") end,
}
 ]]
