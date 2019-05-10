print("start")

generation = 1
n = 100	--個体数

for k = 1, n do

	f = io.open("key_" .. k .. ".txt", "w")

	savestate.loadslot(1)
	startframe = emu.framecount()

	while true do
		joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false})
		U = math.random(0, 1)
		D = math.random(0, 1)
		L = math.random(0, 5)
		R = math.random(0, 5)
		B = math.random(0, 10)
		A = math.random(0, 1)
		if (U == 1) then
			joypad.set({Up = true})
		end
		if (D == 1) then
			joypad.set({Down = true})
		end
		if (L == 1) then
			joypad.set({Left = true})
		end
		if (R == 1) then
			joypad.set({Right = true})
		end
		if (B == 1) then
			joypad.set({B = true})
		end
		if (A == 1) then
			joypad.set({A = true})
		end
	
		keys = joypad.get()
		if keys["Up"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		if keys["Down"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		if keys["Left"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		if keys["Right"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		if keys["B"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		if keys["A"] == true then
			f:write("1_")
		else
			f:write("0_")
		end
		emu.frameadvance()	--frameadvance


		if (memory.read_s16_le(0x02036414) == 16352) then	--カスタムゲージ
			if (memory.read_s8(0x0203BEC0) < 65 and memory.read_s8(0x0203BEC0) >= 0) then	--ココロウインドウ不安
				joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false, R = true})
				f:write("0_0_0_0_0_0_")
				emu.frameadvance()	--frameadvance

				for i = 1, 14 do
					f:write("0_0_0_0_0_0_")
					emu.frameadvance()	--frameadvance
				end

				for j = 1, 2 do
					joypad.set({Up = true})
					f:write("1_0_0_0_0_0_")
					emu.frameadvance()	--frameadvance
				end

				for j = 1, 4 do
					joypad.set({A = true})
					f:write("0_0_0_0_0_1_")
					emu.frameadvance()	--frameadvance

					joypad.set({Left = true})
					f:write("0_0_1_0_0_0_")
					emu.frameadvance()	--frameadvance

					joypad.set({Left = true})
					f:write("0_0_1_0_0_0_")
					emu.frameadvance()	--frameadvance
				end

				for j = 1, 2 do
					joypad.set({Left = true})
					f:write("0_0_1_0_0_0_")
					emu.frameadvance()	--frameadvance
				end

				joypad.set({A = true})
				f:write("0_0_0_0_0_1_")
				emu.frameadvance()	--frameadvance

				joypad.set({Start = true})
				f:write("0_0_0_0_0_0_")
				emu.frameadvance()	--frameadvance

				joypad.set({A = true})
				f:write("0_0_0_0_0_1_")
				emu.frameadvance()	--frameadvance
			else
				joypad.set({Up = false, Down = false, Left = false, Right = false, B = false, A = false, R = true})
				f:write("0_0_0_0_0_0_")
				emu.frameadvance()	--frameadvance

				for i = 1, 14 do
					f:write("0_0_0_0_0_0_")
					emu.frameadvance()	--frameadvance
				end

				for j = 1, 5 do
					joypad.set({A = true})
					f:write("0_0_0_0_0_1_")
					emu.frameadvance()	--frameadvance

					joypad.set({Right = true})
					f:write("0_0_0_1_0_0_")
					emu.frameadvance()	--frameadvance

					joypad.set({Right = true})
					f:write("0_0_0_1_0_0_")
					emu.frameadvance()	--frameadvance
				end

				joypad.set({A = true})
				f:write("0_0_0_0_0_1_")
				emu.frameadvance()	--frameadvance

			end

		end

		if (memory.read_s16_le(0x0203B1A4) ~= 1000 or memory.read_s16_le(0x0203B27C) == 0) then
			break
		end

		if (emu.framecount() > startframe + 60 * 300) then
			print("crashed")
			break
		end

	end

	io.close(f)



end

client.pause()
print("end")