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

n = 100 --個体数
scores = {}	--個体の評価点
tbl_keys = {}	--全部の個体の情報

generation = 1	--最初に読み込む世代
startgeneration = generation


while (generation < 1000) do
	
	--evaluation--
	for k = 1, n do


		f = io.open("key_" .. k .. ".txt", "r")
		rawdata = f:read("*a")
		keys = split(rawdata, "_")
		tbl_keys[k]  = keys
		io.close(f)
	
	
		
		if (generation == startgeneration) then
			savestate.loadslot(1)
			count_keys = table.maxn(keys)
			startframe = emu.framecount()
	
			while true do
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
					scores[k] = (3000 - memory.read_s16_le(0x0203B27C))
					break
				end
		
				emu.frameadvance()
			end
		end
	end
	client.pause()
	
	
	
	maxscore = 0
	index_maxscore = 0
	for k = 1, n do
		if (maxscore < scores[k]) then
			maxscore = scores[k]
			index_maxscore = k
		end
	end
	--print("generation:" .. generation)
	--print("MAXscore:" .. maxscore)
	--print("index:" .. index_maxscore)
	print(generation .. "," .. maxscore)
	

	--MAXだけ書き出し--
	f = io.open("max_" .. generation .. ".txt", "w")
	for k = 1, table.maxn(tbl_keys[index_maxscore]) do
		f:write(tbl_keys[index_maxscore][k])
		f:write("_")
	end
	io.close(f)

	if (maxscore == 3000) then
		break
	end
	


	generation = generation + 1
	
	
	
	--tmp作る--
	for num = 1, n do
	
		--selection--
		mother = 0
		father = 0
		scores_selection = {}

		for k = 1, n do
			scores_selection[k] = scores[k]
			if (scores_selection[k] < 0) then
				scores_selection[k] = 0
			end
		end
		totalscore = 0
		for k = 1, n do
			totalscore = totalscore + scores_selection[k]
		end
		
		roulette = math.random(1, totalscore)
		a = 0
		for k = 1, n do
			if (roulette >= (a + 1) and roulette <= (a + scores_selection[k])) then
				mother = k
				break
			end
			a = a + scores_selection[k]
		end
		
		while (father == 0) do
			roulette = math.random(1, totalscore)
			a = 0
			for k = 1, n do
				if (roulette >= (a + 1) and roulette <= (a + scores_selection[k])) then
					father = k
					break
				end
				a = a + scores_selection[k]
			end
		end
		
		if (math.random(0, 1) == 1) then
			tmp = mother
			mother = father
			father = tmp
		end
		
		
		--crossover--
		parent_length =  table.maxn(tbl_keys[mother])
		if (table.maxn(tbl_keys[father]) < table.maxn(tbl_keys[mother])) then
			parent_length =  table.maxn(tbl_keys[father])
		end
		
		crosspoint1 = math.random(1, parent_length)
		crosspoint2 = math.random(1, parent_length)
		if (crosspoint1 > crosspoint2) then	--crosspoint1が手前
			tmp = crosspoint1
			crosspoint1 = crosspoint2
			crosspoint2 = tmp
		end
		
		child = {}
		for k = 1, crosspoint1 do
			child[k] = tbl_keys[mother][k]
		end
		for k = crosspoint1, crosspoint2 do
			child[k] = tbl_keys[father][k]
		end
		for k = crosspoint2 + 1, table.maxn(tbl_keys[mother]) do
			child[k] = tbl_keys[mother][k]
		end
		
		
		
		--mutation--
		for k = 1, table.maxn(child) do
			if (math.random(1, 200) == 1) then
				if (child[k] == 0) then
					child[k] = 1
				else
					child[k] = 0
				end
			end
		end
		
		
		
		--書き出し--
		f = io.open("tmp_" .. num .. ".txt", "w")
		for k = 1, table.maxn(child) do
			f:write(child[k])
			f:write("_")
		end
		io.close(f)
	
	end
		
		
		
	--tmpを正しくする--
	client.unpause()
	for num = 1, n do
		savestate.loadslot(1)
	
		f = io.open("tmp_" .. num .. ".txt", "r")
		rawdata = f:read("*a")
		keys = split(rawdata, "_")
		io.close(f)
	
		count_keys = table.maxn(keys)
		startframe = emu.framecount()


		f = io.open("key_" .. num .. ".txt", "w")
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
	
			if (keys[count *  6 + 1] == nil) then
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
			end
	
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
				scores[num] = (3000 - memory.read_s16_le(0x0203B27C))
				break
			end

			if (emu.framecount() > startframe + 60 * 300) then
				scores[num] = 0
				print("crashed")
				break
			end


			current_keys = joypad.get()
			if current_keys["Up"] == true then
			f:write("1_")
			else
				f:write("0_")
			end
			if current_keys["Down"] == true then
				f:write("1_")
			else
				f:write("0_")
			end
			if current_keys["Left"] == true then
				f:write("1_")
			else
				f:write("0_")
			end
			if current_keys["Right"] == true then
				f:write("1_")
			else
				f:write("0_")
			end
			if current_keys["B"] == true then
				f:write("1_")
			else
				f:write("0_")
			end
			if current_keys["A"] == true then
				f:write("1_")
			else
				f:write("0_")
			end
			emu.frameadvance()
		end
		io.close(f)

	end

end


print("end")