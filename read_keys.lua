function split(str, ts)
  -- 引数がないときは空tableを返す
  if ts == nil then return {} end

  local t = {} ; 
  i=1
  for s in string.gmatch(str, "([^"..ts.."]+)") do
    t[i] = s
    i = i + 1
  end

  return t
end



print("start")

f = io.open("max_1.txt", "r")	--ファイル名
rawdata = f:read("*a")
keys = split(rawdata, "_")
io.close(f)



savestate.loadslot(1)

count_keys = table.maxn(keys)
startframe = emu.framecount()

while true do
	joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false})
	currentframe = emu.framecount()
	count = currentframe - startframe
	if (keys[count *  6 + 1] == "1") then
		joypad.set({Up = true})
	end
	if (keys[count *  6 + 2] == "1") then
		joypad.set({Down = true})
	end
	if (keys[count *  6 + 3] == "1") then
		joypad.set({Left = true})
	end
	if (keys[count *  6 + 4] == "1") then
		joypad.set({Right = true})
	end
	if (keys[count *  6 + 5] == "1") then
		joypad.set({B = true})
	end
	if (keys[count *  6 + 6] == "1") then
		joypad.set({A = true})
	end

	if (memory.read_s16_le(0x02036414) == 16352) then	--カスタムゲージ
		if (memory.read_s8(0x0203BEC0) < 65 and memory.read_s8(0x0203BEC0) >= 0) then	--ココロウインドウ不安
			joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false, R = true})
			emu.frameadvance()	--frameadvance
			for i = 1, 14 do
				emu.frameadvance()	--frameadvance
			end
			for j = 1, 2 do
				joypad.set({Up = true})
				emu.frameadvance()	--frameadvance
			end
			for j = 1, 4 do
				joypad.set({A = true})
				emu.frameadvance()	--frameadvance
				joypad.set({Left = true})
				emu.frameadvance()	--frameadvance
				joypad.set({Left = true})
				emu.frameadvance()	--frameadvance
			end
			for j = 1, 2 do
				joypad.set({Left = true})
				emu.frameadvance()	--frameadvance
			end
			joypad.set({A = true})
			emu.frameadvance()	--frameadvance
			joypad.set({Start = true})
			emu.frameadvance()	--frameadvance
			joypad.set({A = true})
			emu.frameadvance()	--frameadvance
		else
			joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false, R = true})
			emu.frameadvance()	--frameadvance
			for i = 1, 14 do
				emu.frameadvance()	--frameadvance
			end
			for j = 1, 5 do
				joypad.set({A = true})
				emu.frameadvance()	--frameadvance
				joypad.set({Right = true})
				emu.frameadvance()	--frameadvance
				joypad.set({Right = true})
				emu.frameadvance()	--frameadvance
			end

			joypad.set({A = true})
			emu.frameadvance()	--frameadvance

		end
	end


	if (memory.read_s16_le(0x0203B1A4) ~= 1000 or memory.read_s16_le(0x0203B27C) == 0) then
		break
	end

	emu.frameadvance()
end
client.pause()
print("end")