Citizen.CreateThread(function()
	Opod.PlayerPed = PlayerPedId()
	Opod.Combobox = FillCombo()
	Opod.RotationOffsets = FillRotations()

	while true do
		if Opod.PlayerPed ~= PlayerPedId() then
			Opod.PlayerPed = PlayerPedId()
		end
		Opod.PlayerPosition = GetEntityCoords(Opod.PlayerPed)
		Citizen.Wait(100)
	end
end)


function FillCombo()
	local obj = {}
	for i = 0, 2, 0.05 do
		obj[#obj + 1] = i
	end
	for i = 2, 0, -0.05 do
		obj[#obj + 1] = i * -1
	end
	return obj
end

function FillRotations()
	local obj = {}
	for i = 0, 360, 5.00 do
		obj[#obj + 1] = i
	end
	return obj
end

local boneKey = 1

local positionIndexes = {}
local currentOffset = { offX = 0.0, offY = 0.0, offZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0 }
Opod.currentBone = 0

WarMenu.CreateMenu('dev_menu', 'Dev Menu', 'test')
WarMenu.CreateMenu('prop_menu', 'Prop Menu', 'test')
WarMenu.CreateMenu('animation_menu', 'Prop Menu', 'test')

Citizen.CreateThread(function()
	while true do
		if IsControlJustReleased(0, 38) then
			WarMenu.OpenMenu('dev_menu')
		-- else
			-- Citizen.Wait(20)
		end

		if WarMenu.Begin('dev_menu') then
			WarMenu.MenuButton("Attach Props", 'prop_menu')
			WarMenu.MenuButton("Animations", 'animation_menu')

		elseif WarMenu.Begin('prop_menu') then
			if Opod.currentProp == nil then
				local pressed, inputText = WarMenu.InputButton('Spawn Prop')
				if pressed then
					if inputText then
						local hash = GetHashKey(inputText)
						if IsModelValid(hash) then
							Opod.currentProp = GetHashKey(inputText)
							Opod:SpawnObject(Opod.currentProp)
						end
					end
				end
			else
				local pressed, key = WarMenu.ComboBox('Bone Indexes', Opod.BoneNames, boneKey or 1)
				boneKey = key
				if pressed then
					Opod.currentBone = Opod.BoneIndexes[boneKey]
					Opod:AttachProp(currentOffset.offX, currentOffset.offY, currentOffset.offZ, currentOffset.rotX, currentOffset.rotY, currentOffset.rotZ)
				end
				for i = 1, 6 do
					local type = ''
					local label = ''
					local object = Opod.Combobox
					if i == 1 then
						label = 'Offset X'
						type = 'offX'
					elseif i == 2 then
						label = 'Offset Y'
						type = 'offY'
					elseif i == 3 then
						label = 'Offset Z'
						type = 'offZ'
					elseif i == 4 then
						label = 'Rotation X'
						type = 'rotX'
						object = Opod.RotationOffsets
					elseif i == 5 then
						label = 'Rotation Y'
						type = 'rotY'
						object = Opod.RotationOffsets
					elseif i == 6 then
						label = 'Rotation Z'
						type = 'rotZ'
						object = Opod.RotationOffsets
					end
					local pressed, key = WarMenu.ComboBox(label, object, positionIndexes[i] or 1)
					positionIndexes[i] = key
					if currentOffset[type] ~= object[key] and WarMenu.IsItemHovered() then
						currentOffset[type] = object[key]
						Opod:AttachProp(currentOffset.offX, currentOffset.offY, currentOffset.offZ, currentOffset.rotX, currentOffset.rotY, currentOffset.rotZ)
					end
				end
				local pressed = WarMenu.Button('Copy Offsets')
				if pressed then
					SendNuiMessage(json.encode({
						text = string.format("AttachEntityToEntity(<PROP>, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), %s or 0), %s or 0.0, %s or 0.0, %s or 0.0, %s or 0.0, %s or 0.0, %s or 0.0, 1, 1, 0, 1, 1, 1)", Opod.currentBone, currentOffset.offX, currentOffset.offY, currentOffset.offZ, currentOffset.rotX, currentOffset.rotY, currentOffset.rotZ)
					}))
				end
				local pressed = WarMenu.Button('Delete Prop')
				if pressed then
					SetEntityAsMissionEntity(Opod.currentProp, 1)
					DeleteObject(Opod.currentProp)
					Opod.currentProp = nil
					currentOffset = { offX = 0.0, offY = 0.0, offZ = 0.0, rotX = 0.0, rotY = 0.0, rotZ = 0.0 }
				end

			end
		-- elseif WarMenu.Begin('animation_menu') then
		-- 	for i = 0, 100 do
		-- 		WarMenu.MenuButton("Attach Props", 'prop_menu')				
		-- 	end
		else
			Citizen.Wait(5)
		end
		WarMenu.End()
		Citizen.Wait(6)
	end
end)

function Opod:SpawnObject(prop)
	while not HasModelLoaded(prop) do
		RequestModel(prop)
		Citizen.Wait(10)
	end
	Opod.currentProp = CreateObject(prop, Opod.PlayerPosition, 1, 1, 1)
	self:AttachProp()
	SetModelAsNoLongerNeeded(prop)
end

function Opod:AttachProp(offX, offY, offZ, rotX, rotY, rotZ)
	AttachEntityToEntity(self.currentProp, self.PlayerPed, GetPedBoneIndex(self.PlayerPed, self.currentBone or 0), offX or 0.0, offY or 0.0, offZ or 0.0, rotX or 0.0, rotY or 0.0, rotZ or 0.0, 1, 1, 0, 1, 1, 1)
end