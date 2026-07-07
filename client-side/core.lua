-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICATION HELPER
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendNotification(title, message, type, duration)
	TriggerEvent("Notify", title, message, type, duration)
	
	-- Native fallback
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName("~r~[" .. title .. "]~w~ " .. message)
	EndTextCommandThefeedPostTicker(false, true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Opened = false
local Camera = nil
local ZoomOffset = 0.0
local Init = "torso"
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAMERA & ROTATION FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function UpdateCameraBasedOnInit()
	local Ped = PlayerPedId()
	if not Camera then return end

	local camCoords
	local fov = 40.0
	local targetZOffset = 0.0

	local baseCoords = GetOffsetFromEntityInWorldCoords(Ped, 0.25, 1.2, 0.0)
	local baseZ = baseCoords.z
	
	if Init == "head" then
		camCoords = vector3(baseCoords.x, baseCoords.y, baseZ + 0.62)
		fov = 28.0
		targetZOffset = 0.62
	elseif Init == "torso" then
		camCoords = vector3(baseCoords.x, baseCoords.y, baseZ + 0.22)
		fov = 42.0
		targetZOffset = 0.22
	elseif Init == "pants" then
		camCoords = vector3(baseCoords.x, baseCoords.y, baseZ - 0.22)
		fov = 38.0
		targetZOffset = -0.22
	elseif Init == "shoes" then
		camCoords = vector3(baseCoords.x, baseCoords.y, baseZ - 0.68)
		fov = 28.0
		targetZOffset = -0.68
	else -- full body
		camCoords = GetOffsetFromEntityInWorldCoords(Ped, 0.40, 2.5, 0.0)
		fov = 45.0
		targetZOffset = 0.0
	end

	fov = fov + ZoomOffset
	if fov < 10.0 then fov = 10.0 end
	if fov > 75.0 then fov = 75.0 end

	SetCamCoord(Camera, camCoords.x, camCoords.y, camCoords.z)
	SetCamFov(Camera, fov)
	PointCamAtEntity(Camera, Ped, 0.0, 0.0, targetZOffset, true)
end

function CameraActive()
	if DoesCamExist(Camera) then
		RenderScriptCams(false,false,0,false,false)
		SetCamActive(Camera,false)
		DestroyCam(Camera,false)
		Camera = nil
	end

	local Ped = PlayerPedId()
	Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
	UpdateCameraBasedOnInit()

	RenderScriptCams(true,true,1000,false,false)
	SetCamActive(Camera,true)

	CreateThread(function()
		while DoesCamExist(Camera) do
			local CurrentPed = PlayerPedId()
			FreezeEntityPosition(CurrentPed,true)
			SetEntityVisible(CurrentPed,true)
			Wait(1)
		end
		FreezeEntityPosition(PlayerPedId(),false)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCLOTHINGDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function GetClothingData()
	local Ped = PlayerPedId()
	local Model = GetEntityModel(Ped)
	
	local ModelName = nil
	if Model == GetHashKey("mp_m_freemode_01") then
		ModelName = "mp_m_freemode_01"
	elseif Model == GetHashKey("mp_f_freemode_01") then
		ModelName = "mp_f_freemode_01"
	else
		return nil
	end
	
	local ClothingData = {
		["hat"] = { item = GetPedPropIndex(Ped,0), texture = GetPedPropTextureIndex(Ped,0) },
		["pants"] = { item = GetPedDrawableVariation(Ped,4), texture = GetPedTextureVariation(Ped,4) },
		["arms"] = { item = GetPedDrawableVariation(Ped,3), texture = GetPedTextureVariation(Ped,3) },
		["tshirt"] = { item = GetPedDrawableVariation(Ped,8), texture = GetPedTextureVariation(Ped,8) },
		["torso"] = { item = GetPedDrawableVariation(Ped,11), texture = GetPedTextureVariation(Ped,11) },
		["vest"] = { item = GetPedDrawableVariation(Ped,9), texture = GetPedTextureVariation(Ped,9) },
		["shoes"] = { item = GetPedDrawableVariation(Ped,6), texture = GetPedTextureVariation(Ped,6) },
		["mask"] = { item = GetPedDrawableVariation(Ped,1), texture = GetPedTextureVariation(Ped,1) },
		["backpack"] = { item = GetPedDrawableVariation(Ped,5), texture = GetPedTextureVariation(Ped,5) },
		["glass"] = { item = GetPedPropIndex(Ped,1), texture = GetPedPropTextureIndex(Ped,1) },
		["ear"] = { item = GetPedPropIndex(Ped,2), texture = GetPedPropTextureIndex(Ped,2) },
		["watch"] = { item = GetPedPropIndex(Ped,6), texture = GetPedPropTextureIndex(Ped,6) },
		["bracelet"] = { item = GetPedPropIndex(Ped,7), texture = GetPedPropTextureIndex(Ped,7) },
		["accessory"] = { item = GetPedDrawableVariation(Ped,7), texture = GetPedTextureVariation(Ped,7) },
		["decals"] = { item = GetPedDrawableVariation(Ped,10), texture = GetPedTextureVariation(Ped,10) }
	}
	
	-- Ajusta valores -1 para 0 (sem item)
	for k,v in pairs(ClothingData) do
		if v.item == -1 then
			v.item = 0
		end
		if v.texture == -1 then
			v.texture = 0
		end
	end
	
	return {
		model = ModelName,
		clothing = ClothingData
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUPAID:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("M-Westy_ClothID:Open")
AddEventHandler("M-Westy_ClothID:Open",function()
	if not Opened then
		Opened = true
		SetNuiFocus(true,true)
		-- TransitionToBlurred(1000)
		TriggerEvent("hud:Active",false)
		TriggerEvent("dynamic:Close")
		
		local Data = GetClothingData()
		if Data then
			SendNUIMessage({ Action = "Open", Payload = Data })
			CameraActive()
		else
			SendNotification("M-Westy ClothID","Você precisa estar usando um personagem válido (mp_m_freemode_01 ou mp_f_freemode_01).","vermelho",5000)
			SetNuiFocus(false,false)
			-- TransitionFromBlurred(1000)
			TriggerEvent("hud:Active",true)
			Opened = false
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Close",function(Data,Callback)
	Opened = false
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	
	if DoesCamExist(Camera) then
		RenderScriptCams(false,false,0,false,false)
		SetCamActive(Camera,false)
		DestroyCam(Camera,false)
		Camera = nil
	end

	-- TransitionFromBlurred(1000)
	TriggerEvent("hud:Active",true)
	
	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REFRESH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Refresh",function(Data,Callback)
	local Data = GetClothingData()
	if Data then
		Callback(Data)
	else
		Callback(nil)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COPY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Copy",function(Data,Callback)
	-- Formata os dados para o formato do preset
	local Model = Data.model
	local Clothing = Data.clothing
	
	if not Model or not Clothing then
		Callback("Error")
		return
	end
	
	local Formatted = string.format([[
		["%s"] = {
			["hat"] = { item = %d, texture = %d },
			["pants"] = { item = %d, texture = %d },
			["arms"] = { item = %d, texture = %d },
			["tshirt"] = { item = %d, texture = %d },
			["torso"] = { item = %d, texture = %d },
			["vest"] = { item = %d, texture = %d },
			["shoes"] = { item = %d, texture = %d },
			["mask"] = { item = %d, texture = %d },
			["backpack"] = { item = %d, texture = %d },
			["glass"] = { item = %d, texture = %d },
			["ear"] = { item = %d, texture = %d },
			["watch"] = { item = %d, texture = %d },
			["bracelet"] = { item = %d, texture = %d },
			["accessory"] = { item = %d, texture = %d },
			["decals"] = { item = %d, texture = %d }
		}
	]],Model,
		Clothing.hat.item, Clothing.hat.texture,
		Clothing.pants.item, Clothing.pants.texture,
		Clothing.arms.item, Clothing.arms.texture,
		Clothing.tshirt.item, Clothing.tshirt.texture,
		Clothing.torso.item, Clothing.torso.texture,
		Clothing.vest.item, Clothing.vest.texture,
		Clothing.shoes.item, Clothing.shoes.texture,
		Clothing.mask.item, Clothing.mask.texture,
		Clothing.backpack.item, Clothing.backpack.texture,
		Clothing.glass.item, Clothing.glass.texture,
		Clothing.ear.item, Clothing.ear.texture,
		Clothing.watch.item, Clothing.watch.texture,
		Clothing.bracelet.item, Clothing.bracelet.texture,
		Clothing.accessory.item, Clothing.accessory.texture,
		Clothing.decals.item, Clothing.decals.texture
	)
	
	Callback(Formatted)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COPYJSON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CopyJSON",function(Data,Callback)
	local JSON = json.encode(Data)
	
	if not JSON then
		Callback("Error")
		return
	end
	
	Callback(JSON)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAMERA CONTROLS CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("RotateLeft", function(Data, Callback)
	local Ped = PlayerPedId()
	local Heading = GetEntityHeading(Ped)
	SetEntityHeading(Ped, Heading - 15.0)
	Callback("Ok")
end)

RegisterNUICallback("RotateRight", function(Data, Callback)
	local Ped = PlayerPedId()
	local Heading = GetEntityHeading(Ped)
	SetEntityHeading(Ped, Heading + 15.0)
	Callback("Ok")
end)

RegisterNUICallback("ChangeCameraFocus", function(Focus, Callback)
	Init = Focus
	ZoomOffset = 0.0
	UpdateCameraBasedOnInit()
	Callback("Ok")
end)

RegisterNUICallback("Zoom", function(Direction, Callback)
	if Direction == "in" then
		ZoomOffset = ZoomOffset - 2.0
		if ZoomOffset < -15.0 then ZoomOffset = -15.0 end
	elseif Direction == "out" then
		ZoomOffset = ZoomOffset + 2.0
		if ZoomOffset > 15.0 then ZoomOffset = 15.0 end
	end
	UpdateCameraBasedOnInit()
	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENDER TOGGLE CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ToggleGender", function(Data, Callback)
	local Ped = PlayerPedId()
	local CurrentModel = GetEntityModel(Ped)
	local TargetModel = nil

	if CurrentModel == GetHashKey("mp_m_freemode_01") then
		TargetModel = GetHashKey("mp_f_freemode_01")
	else
		TargetModel = GetHashKey("mp_m_freemode_01")
	end

	RequestModel(TargetModel)
	local StartTime = GetGameTimer()
	while not HasModelLoaded(TargetModel) do
		Wait(10)
		if GetGameTimer() - StartTime > 3000 then
			Callback(nil)
			return
		end
	end

	SetPlayerModel(PlayerId(), TargetModel)
	local NewPed = PlayerPedId()
	SetPedComponentVariation(NewPed, 3, 15, 0, 0) -- Braços limpos
	SetEntityVisible(NewPed, true)
	
	if DoesCamExist(Camera) then
		UpdateCameraBasedOnInit()
	end
	
	local RefreshData = GetClothingData()
	Callback(RefreshData)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("M-Westy_ClothID:ClientRequestOpen")
AddEventHandler("M-Westy_ClothID:ClientRequestOpen", function()
	TriggerServerEvent("M-Westy_ClothID:RequestOpen")
end)

RegisterCommand("m-westy_clothid",function()
	TriggerEvent("M-Westy_ClothID:ClientRequestOpen")
end)

RegisterCommand("clothid",function()
	TriggerEvent("M-Westy_ClothID:ClientRequestOpen")
end)

RegisterCommand("roupaid",function()
	TriggerEvent("M-Westy_ClothID:ClientRequestOpen")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTEGRATION WITH DYNAMIC
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("dynamic:AddButtons",function()
	exports["dynamic"]:AddButton("M-Westy ClothID","Capturar valores das roupas atuais.","M-Westy_ClothID:ClientRequestOpen","","others",false)
end)
