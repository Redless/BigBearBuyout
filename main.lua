function love.load(arg)
	debug = false

	--images
	bgm = love.audio.newSource('assets/Tech Live.mp3')
	bgm:play()
	bgm:setLooping(true)
	groupPlaced = love.audio.newSource('assets/Blip_Select12.wav','static')
	scorerCleared = love.audio.newSource('assets/Pickup_Coin44.wav','static')
	uWin = love.audio.newSource('assets/Randomize10.wav','static')
	uLose = love.audio.newSource('assets/Randomize101.wav','static')

	timer = love.timer.getTime()
	sfx = true
	--(love.filesystem.getRealDirectory('saves.txt'))
	--({love.filesystem.read('saves.txt')}[1])
	--(string.gmatch({love.filesystem.read('saves.txt')}[1],'%A+'))

	if not love.filesystem.isFile('saves.txt') then
		love.filesystem.write('saves.txt','15v30v45')
	end

	lBorderList = {250,150,50}
	uBorderList = {600,700,800}
	---(love.filesystem.getRealDirectory('saves.txt'))
	---save files
	saveFiles = {}
	j = 1
	for i in string.gmatch(love.filesystem.read('saves.txt'),"%A+") do
		saveFiles[j] = tonumber(i)
		j = j +1
	end
	file = 1
	--entity storage
	placedBlocks = {} --array of blocks currently around
	heldBlocks = {}
	heldMino = nil
	comingBlocks = {}
	stage = 1
	scoregoals = {4,9,14}
	--stage 3 is 16 by 16, goes 50 to 800
	--stage 2 is 12 by 12, goes 150 to 700
	--stage 1 is 8 by 8, goes 250 to 600
	blockSpawnPattern = {6,8,11}
	scorerSpawnPattern = {2,-- the inner 36 make the first stage easier
	2,--the next few make the first stage harder (the same?) and the second stage easier
	3,--the next few make the second stage easier
	3,--these make the second stage harder and the third easier
	3,--these make the third stage easier
	}
	pointScaler = {1,1.6,1.6}


	blockSpawnRegions = {
	{{250,250},{250,300},{250,350},{250,400},{250,450},{250,500},{250,550},{250,600},
	{300,250},{300,300},{300,350},{300,400},{300,450},{300,500},{300,550},{300,600},
	{350,250},{350,300},{350,350},{350,400},{350,450},{350,500},{350,550},{350,600},
	{400,250},{400,300},{400,350},{400,400},{400,450},{400,500},{400,550},{400,600},
	{450,250},{450,300},{450,350},{450,400},{450,450},{450,500},{450,550},{450,600},
	{500,250},{500,300},{500,350},{500,400},{500,450},{500,500},{500,550},{500,600},
	{550,250},{550,300},{550,350},{550,400},{550,450},{550,500},{550,550},{550,600},
	{600,250},{600,300},{600,350},{600,400},{600,450},{600,500},{600,550},{600,600}},

	{{150,150},{150,200},{150,250},{150,300},{150,350},{150,400},{150,450},
	{150,500},{150,550},{150,600},{150,650},{150,700},
	{200,150},{200,200},{200,250},{200,300},{200,350},{200,400},{200,450},
	{200,500},{200,550},{200,600},{200,650},{200,700},
	{700,150},{700,200},{700,250},{700,300},{700,350},{700,400},{700,450},
	{700,500},{700,550},{700,600},{700,650},{700,700},
	{650,150},{650,200},{650,250},{650,300},{650,350},{650,400},{650,450},
	{650,500},{650,550},{650,600},{650,650},{650,700},

	{250,150},{300,150},{350,150},{400,150},{450,150},{500,150},{550,150},{600,150},
	{250,650},{300,650},{350,650},{400,650},{450,650},{500,650},{550,650},{600,650},
	{250,200},{300,200},{350,200},{400,200},{450,200},{500,200},{550,200},{600,200},
	{250,700},{300,700},{350,700},{400,700},{450,700},{500,700},{550,700},{600,700}

	},

	{{50,50},{50,100},{50,150},{50,200},{50,250},{50,300},{50,350},{50,400},
	{50,450},{50,500},{50,550},{50,600},{50,650},{50,700},{50,750},{50,800},
	{800,50},{800,100},{800,150},{800,200},{800,250},{800,300},{800,350},{800,400},
	{800,450},{800,500},{800,550},{800,600},{800,650},{800,700},{800,750},{800,800},
	{100,50},{150,50},{200,50},{250,50},{300,50},{350,50},{400,50},{450,50},{500,50},
	{550,50},{600,50},{650,50},{700,50},{750,50},
	{100,800},{150,800},{200,800},{250,800},{300,800},{350,800},{400,800},{450,800},{500,800},
	{550,800},{600,800},{650,800},{700,800},{750,800},
	
	{100,150},{100,200},{100,250},{100,300},{100,350},{100,400},
	{100,450},{100,500},{100,550},{100,600},{100,650},{100,700},
	{750,100},{750,150},{750,200},{750,250},{750,300},{750,350},{750,400},
	{750,450},{750,500},{750,550},{750,600},{750,650},{750,700},{750,750},
	{100,100},{150,100},{200,100},{250,100},{300,100},{350,100},{400,100},{450,100},{500,100},
	{550,100},{600,100},{650,100},{700,100},
	{100,750},{150,750},{200,750},{250,750},{300,750},{350,750},{400,750},{450,750},{500,750},
	{550,750},{600,750},{650,750},{700,750}}
	}

	scorerSpawnRegions = {
	{{300,300},{300,350},{300,400},{300,450},{300,500},{300,550},
	{350,300},{350,350},{350,400},{350,450},{350,500},{350,550},
	{400,300},{400,350},{400,400},{400,450},{400,500},{400,550},
	{450,300},{450,350},{450,400},{450,450},{450,500},{450,550},
	{500,300},{500,350},{500,400},{500,450},{500,500},{500,550},
	{550,300},{550,350},{550,400},{550,450},{550,500},{550,550}},
	
	{{250,250},{250,300},{250,350},{250,400},{250,450},{250,500},{250,550},{250,600},
	{300,250},{300,600},
	{350,250},{350,600},
	{400,250},{400,600},
	{450,250},{450,600},
	{500,250},{500,600},
	{550,250},{550,600},
	{600,250},{600,300},{600,350},{600,400},{600,450},{600,500},{600,550},{600,600}},
	
	{{200,200},{250,200},{300,200},{350,200},{400,200},{450,200},{500,200},{550,200},{600,200},{650,200},
	{200,650},{250,650},{300,650},{350,650},{400,650},{450,650},{500,650},{550,650},{600,650},{650,650},
	{200,250},{200,300},{200,350},{200,400},{200,450},{200,500},{200,550},{200,600},
	{650,250},{650,300},{650,350},{650,400},{650,450},{650,500},{650,550},{650,600}
	},
	{
	{150,150},{200,150},{250,150},{300,150},{350,150},{400,150},{450,150},{500,150},{550,150},{600,150},{650,150},{700,150},
	{150,700},{200,700},{250,700},{300,700},{350,700},{400,700},{450,700},{500,700},{550,700},{600,700},{650,700},{700,700},
	{150,200},{150,250},{150,300},{150,350},{150,400},{150,450},{150,500},{150,550},{150,600},{150,650},
	{700,200},{700,250},{700,300},{700,350},{700,400},{700,450},{700,500},{700,550},{700,600},{700,650}
	},
	{
	{100,100},{150,100},{200,100},{250,100},{300,100},{350,100},{400,100},{450,100},{500,100},{550,100},{600,100},{650,100},{700,100},{750,100},
	{100,750},{150,750},{200,750},{250,750},{300,750},{350,750},{400,750},{450,750},{500,750},{550,750},{600,750},{650,750},{700,750},{750,750},
	{100,150},{100,200},{100,250},{100,300},{100,350},{100,400},{100,450},{100,500},{100,550},{100,600},{100,650},{100,700},
	{750,150},{750,200},{750,250},{750,300},{750,350},{750,400},{750,450},{750,500},{750,550},{750,600},{750,650},{750,700}
	}
	}

	possibleMinos = {1,5,9,13,17,21,25} --table to convert that piece into a minotype index

	rotations = {2,3,4,1,6,7,8,5,12,9,10,11,14,15,16,13,18,19,20,17,22,23,24,21,26,27,28,25}
	brotations = {4,1,2,3,8,5,6,7,10,11,12,9,16,13,14,15,20,17,18,19,24,21,22,23,28,25,26,27}

	minoTypes = {
	{{-1,-1},{0,-1},{0,0},{-1,0}},
	{{0,-1},{0,0},{-1,0},{-1,-1}},
	{{0,0},{-1,0},{-1,-1},{0,-1}},
	{{-1,0},{-1,-1},{0,-1},{0,0}},


	{{0,-2},{0,-1},{0,0},{0,1}}, --2: vertical 1 by 4
	{{1,0},{0,0},{-1,0},{-2,0}},
	{{0,1},{0,0},{0,-1},{0,-2}},
	{{-2,0},{-1,0},{0,0},{1,0}}, --3: horizontal 1 by 4



	{{0,-1},{0,0},{1,0},{1,1}},--4: vertical top bottom squiggle
	{{-1,0},{0,0},{0,-1},{1,-1}}, --5: horizontal top bottom squiggle
	{{0,1},{0,0},{-1,0},{-1,-1}},
	{{1,0},{0,0},{0,1},{-1,1}},

	{{0,1},{0,0},{1,0},{1,-1}},--6: vertical bottom top squiggle
	{{-1,0},{0,0},{0,1},{1,1}},--7: horizontal bottom top squiggle
	{{0,-1},{0,0},{-1,0},{-1,1}},
	{{1,0},{0,0},{0,-1},{-1,-1}},

	{{0,-1},{0,0},{0,1},{1,1}},--8: L shape
	{{1,0},{0,0},{-1,0},{-1,1}},--9: clockwise L shape
	{{0,1},{0,0},{0,-1},{-1,-1}},--10: upside down L shape
	{{-1,0},{0,0},{1,0},{1,-1}},--11: counterclockwise L shape

	{{-1,1},{0,1},{0,0},{0,-1}},--12: rL shape
	{{-1,-1},{-1,0},{0,0},{1,0}},--13: clockwise rL shape
	{{1,-1},{0,-1},{0,0},{0,1}},--14: upside down rL shape
	{{1,1},{1,0},{0,0},{-1,0}},--15: counterclockwise rL shape
	
	{{-1,0},{0,0},{1,0},{0,1}},--16: T shape
	{{0,-1},{0,0},{0,1},{-1,0}},--17: clockwise T shape
	{{1,0},{0,0},{-1,0},{0,-1}},--18: upside down T shape
	{{0,1},{0,0},{0,-1},{1,0}}--19: counterclockwise T shape
	}
	borderImgs = {love.graphics.newImage('assets/largebg.png'),
	love.graphics.newImage('assets/midbg.png'),
	love.graphics.newImage('assets/smallbg.png')}
	blockImgs = 
	{love.graphics.newImage('assets/placedbear.png'),
	love.graphics.newImage('assets/heldbear.png'),
	love.graphics.newImage('assets/rabbit.png')}
	--love.window.setIcon(blockImgs[1])
	--{love.graphics.newImage('assets/redblock.png'),
	--love.graphics.newImage('assets/orangeblock.png')}
	--love.graphics.newImage('assets/yellowblock.png')}
	--love.graphics.newImage('assets/greenblock.png'),
	--love.graphics.newImage('assets/blueblock.png'),
	---love.graphics.newImage('assets/violetblock.png'),
	--love.graphics.newImage('assets/indigoblock.png'),
	--love.graphics.newImage('assets/greyblock.png'),
	--love.graphics.newImage('assets/fadedredblock.png'),
	--love.graphics.newImage('assets/fadedorangeblock.png'),
	--love.graphics.newImage('assets/fadedyellowblock.png'),
	--love.graphics.newImage('assets/fadedgreenblock.png'),
	--love.graphics.newImage('assets/fadedblueblock.png'),
	--love.graphics.newImage('assets/fadedvioletblock.png'),
	--love.graphics.newImage('assets/fadedindigoblock.png'),
	--love.graphics.newImage('assets/inactiveredblock.png'),
	--love.graphics.newImage('assets/inactiveorangeblock.png'),
	--love.graphics.newImage('assets/inactiveyellowblock.png'),
	--love.graphics.newImage('assets/inactivegreenblock.png'),
	--love.graphics.newImage('assets/inactiveblueblock.png'),
	--love.graphics.newImage('assets/inactivevioletblock.png'),
	---love.graphics.newImage('assets/inactiveindigoblock.png'),
	--love.graphics.newImage('assets/generator.png'),
	--love.graphics.newImage('assets/1charge.png'),
	--love.graphics.newImage('assets/2charge.png'),
	--love.graphics.newImage('assets/3charge.png')}
	musicPlaying = true
	sfxOn = true
	sfx1 = love.graphics.newImage('assets/speaker.png')
	sfx2 = love.graphics.newImage('assets/speaker-off.png')
	music1 = love.graphics.newImage('assets/sound-on.png')
	music2 = love.graphics.newImage('assets/sound-off.png')
	heldBlocks = {}
	--table.insert(placedBlocks,{x=500, y=500, powered = true, img = blockImgs[23]})
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(30,65,24)
	menu = 1
	font = love.graphics.newFont(28)
	biggerfont = love.graphics.newFont(48)
	love.graphics.setFont(font)
	love.graphics.setColor(32,88,23)
	menubuttonlist = {{
	{'Play',0,600,300,200,50},
	{'File Select',2,600,355,200,50},
	{'Instructions',3,600,410,200,50},
	{'Story',4,600,465,200,50},
	{'Credits',5,600,520,200,50},
	{'Quit',love.event.quit,600,575,200,50},
	{'',function() if musicPlaying then musicPlaying = false bgm:stop() else musicPlaying = true bgm:play() end end,600,640,95,95},
	{'',function() sfxOn = not sfxOn end,700,640,95,95}
	},{
	{'File 1',function() file = 1 end,600,350,200,50},
	{'File 2',function() file = 2 end,600,450,200,50},
	{'File 3',function() file = 3 end,600,550,200,50}
	},{
	{'Each turn you will be given a group, which you must seat on the grid. Your goal is to surround\nthe shareholders with bears. Doing so will remove that shareholder and give you points. As\nyou gain points, more seats will become available and eventually you will win. Shareholders\non edge seats act like bears and cannot be cleared until the edge is pushed back. Rotate the\npiece with z and c keys.',
	3,50,50,1335,185},
	{'Back',1,600,290,150,45}
	},{
	{"Every animal in the forest has a job. The deer are sprightly messengers, the woodpeckers are\ncareful architects, and the bears are ruthless capitalists who buy out other animals'\ncompanies and liquidate them for a profit. Today is the shareholder meeting for the next\ncompany that the bears want, and Claude Grizzly, the youngest bear, is acting as an usher,\nseating the shareholders on as they enter the banquet hall in groups of four. In each group\nare three bears and one other animal. Claude's goal is to position the seating so that every\nnon-bear shareholder is surrounded by bears. Then, the bears can peer pressure the\nshareholder into selling their stock.",
	4,50,50,1335,270},
	{'Back',1,600,330,150,45}
	},{
	{'Design and Programming: Redless (redless.github.io)',5,50,50,800,50},
	{'Art: gameicons.net',5,50,120,400,50},
	{'Music:"Tech Live"\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 3.0\nhttp://creativecommons.org/licenses/by/3.0/',5,50,190,800,150},
	{'Back',1,50,440,100,45},
	{'SFX: bfxr.net',5,50,390,350,45}
	}}
	--menu 0 is playing the game
	--menu 1 is the main menu
	--menu 2 is file-select screen
	--menu 3 is how to playing
	--menu 4 is the story
	--menu 5 is the credits
end

function love.update(dt)
	if menu == 0 then
		if pastHeldMino then
			for i,block in ipairs(minoTypes[pastHeldMino]) do
				heldBlocks[i].x = (love.mouse.getX()-(love.mouse.getX()%50)+block[1]*50)
				heldBlocks[i].y = (love.mouse.getY()-(love.mouse.getY()%50)+block[2]*50)
			end
		end
		if timeMax < love.timer.getTime() and saveFiles[file] > 18 then
			score = score -1
			timeMax = timeMax+5
		end
	end
end

function love.keypressed(key)
	if key == 'z' and pastHeldMino then
		pastHeldMino = rotations[pastHeldMino]
	end
	if key == 'c' and pastHeldMino then
		pastHeldMino = brotations[pastHeldMino]
	end
end

function love.mousepressed(x, y, button)
	if menu == 0 then
		if button == 1 then
			collisions = false
			lowerBorder = lBorderList[stage]
			upperBorder = uBorderList[stage]
			for i,block in ipairs(heldBlocks) do
				if block.x > upperBorder or 
					block.y > upperBorder or 
					block.x < lowerBorder or 
					block.y < lowerBorder then
						collisions = true
				end
				for j,placedBlock in ipairs(placedBlocks) do
					if (block.x == placedBlock.x and block.y == placedBlock.y) then
						collisions = true
					end
				end
			end
			if not collisions then
			--for i,block in ipairs(placedBlocks) do
				--if block.holdimg == blockImgs[8] then
					--placedBlocks[i].chargeLeft = block.chargeLeft - 1
					--if placedBlocks[i].chargeLeft == 0 then
						--table.remove(placedBlocks,i)
					--end
				--end
			--end
				timeMax = timeMax + 5
				for i,block in ipairs(heldBlocks) do
					table.insert(placedBlocks,block)
				end
				heldBlocks = comingBlocks
				if sfxOn then
					groupPlaced:play()
				end
				comingBlocks = {}
				pieceChosen = math.random(1,7) --randomizes which piece is chosen
				--colorChosen = math.random(1,7) --randomizes the color
				scorerChosen = math.random(1,4) --randomizes which block will be the scorer
				pastHeldMino = heldMino
				heldMino = possibleMinos[pieceChosen] --fishes out the minotype index for that piece
			
				for i,block in ipairs(minoTypes[heldMino]) do
					table.insert(comingBlocks,{x = 1200 +block[1]*50,--love.mouse.getX()-(love.mouse.getX()%100)+block[1]*100,
					y = 400 +block[2]*50,--love.mouse.getY()-(love.mouse.getY()%100)+block[2]*100,
					exposed = false,
					img = 1,
					holdimg = 2,
					scorer = false
				--inactiveimg = blockImgs[colorChosen+15],
				--chargeLeft = 3
					})
				end
				comingBlocks[scorerChosen].img = 3
				comingBlocks[scorerChosen].holdimg = 3
				comingBlocks[scorerChosen].scorer = true
			--heldBlocks[scorerChosen].inactiveimg = blockImgs[8]
			end
		end
		for i,block in ipairs(placedBlocks) do
			placedBlocks[i].exposed = false
		end
	
		for arbitrary,upperbound in ipairs(placedBlocks) do
			for i,block in ipairs(placedBlocks) do
				blocksOnBorder = 0
				for j,maybeAdjacentBlock in ipairs(placedBlocks) do
					if ((block.x + 50 == maybeAdjacentBlock.x and block.y == maybeAdjacentBlock.y) or
					(block.x - 50 == maybeAdjacentBlock.x and block.y == maybeAdjacentBlock.y) or
					(block.x == maybeAdjacentBlock.x and block.y + 50 == maybeAdjacentBlock.y) or
					(block.x == maybeAdjacentBlock.x and block.y - 50 == maybeAdjacentBlock.y)) and
					not maybeAdjacentBlock.exposed then
						blocksOnBorder = blocksOnBorder + 1
					end
				end
				if stage == 1 then
					ontheLower = 250
					ontheUpper = 600
				end
				if stage == 2 then
					ontheLower = 150
					ontheUpper = 700
				end
				if stage == 3 then
					ontheLower = 50
					ontheUpper = 800
				end
				if blocksOnBorder < 4 and block.scorer and not
				(block.x == ontheLower or block.y == ontheLower or block.x == ontheUpper or block.y == ontheUpper) then
					placedBlocks[i].exposed = true
				end
			end
		end
	
		while true do
			doneRemoving = true
			for i,block in ipairs(placedBlocks) do
				if not block.exposed and block.scorer and not
				(block.x == upperBorder or block.y == upperBorder or block.x == lowerBorder or block.y == lowerBorder) then
					table.remove(placedBlocks,i)
					if sfxOn then
						scorerCleared:play()
					end
					doneRemoving = false
					score = score + 1
					if score > scoregoals[3] then
						saveFiles[file] = saveFiles[file] + 2
						love.filesystem.write('saves.txt',tostring(saveFiles[1])..'v'..tostring(saveFiles[2])..'v'..tostring(saveFiles[3]))
						menu = 1
						placedBlocks = {} --array of blocks currently around
						heldBlocks = {}
						heldMino = nil
						comingBlocks = {}
						score = 0
						pastHeldMino = nil
						if sfxOn then
							uWin:play()
						end
					elseif score > scoregoals[2] then
						stage = 3
					elseif score > scoregoals[1] then
						stage = 2
					end
					break
				end
			end
			if doneRemoving then
				break
			end
		end
			--now we check for the lost condition
		spaceleft = false
		if stage == 1 then
			lowerBorder = 250
			upperBorder = 600
		end
		if stage == 2 then
			lowerBorder = 150
			upperBorder = 700
		end
		if stage == 3 then
			lowerBorder = 50
			upperBorder = 800
		end
		if pastHeldMino then
			for i=1,4 do   --check each rotation
				pastHeldMino = rotations[pastHeldMino]
				for ychecking = 25,825,50 do
					for xchecking = 25,825,50 do
						collisions = false
						for j,block in ipairs(minoTypes[pastHeldMino]) do
							adjustedxchecking = (xchecking-(xchecking%50)+block[1]*50)
							adjustedychecking = (ychecking-(ychecking%50)+block[2]*50)
							if adjustedxchecking > upperBorder or
								adjustedychecking > upperBorder or 
								adjustedxchecking < lowerBorder or 
								adjustedychecking < lowerBorder then
								collisions = true
							end
							for k,placedBlock in ipairs(placedBlocks) do
								if (adjustedxchecking == placedBlock.x and adjustedychecking == placedBlock.y) then
									collisions = true
								end
							end
						end
						if not collisions then
							spaceleft = true
						end
					end
				end
			end
				---end of checking for loss condition
			if not spaceleft then
					menu = 1
					if sfxOn then
						uLose:play()
					end
			end
		end
		--if button == 2 and pastHeldMino then
		--	pastHeldMino = rotations[pastHeldMino]
		--end
	--for i,block in ipairs(placedBlocks) do
		--if not block.img == blockImgs[23] then
			--block.powered = false
			--(block.x,block.y,'unpowered')
		--end
	--end
	--while true do
		--maybeIncomplete = false
		--for i,block in ipairs(placedBlocks) do
			--if block.powered then
				--adjacentBlocks = {}
				--for j,maybeAdjacentBlock in ipairs(placedBlocks) do
					--if (block.x + 100 == maybeAdjacentBlock.x and block.y == maybeAdjacentBlock.y) or
					--(block.x - 100 == maybeAdjacentBlock.x and block.y == maybeAdjacentBlock.y) or
					--(block.x == maybeAdjacentBlock.x and block.y + 100 == maybeAdjacentBlock.y) or
					--(block.x == maybeAdjacentBlock.x and block.y - 100 == maybeAdjacentBlock.y) then
						--table.insert(adjacentBlocks,placedBlocks[j])
					--end
				--end
				--for j,adjacentBlock in ipairs(adjacentBlocks) do
					--if not adjacentBlock.powered then
						--maybeIncomplete = true
					--end
					--adjacentBlock.powered = true
					--adjacentBlock.x,adjacentBlock.y,'powered',block.x,block.y)
				--end
			--end
		--end
		--if not maybeIncomplete then
			--break
		--end
	--end
	else   -- if on the menu screen
		for i,button in ipairs(menubuttonlist[menu]) do
			if love.mouse.getX() > button[3] and
			love.mouse.getX() < button[3]+button[5] and
			love.mouse.getY() < button[4]+button[6] and
			love.mouse.getY() > button[4] then
				if "number" == type(button[2]) then
					menu = button[2]
				else
					button[2]()
					menu = 1
				end
				if menu == 0 then
					timeMax = love.timer.getTime() + 8
					tempList = {7,14,20}
					for i =1,3 do
						blockSpawnPattern[i] = math.random(0,math.floor(tempList[i]))
					end
					tempList = {3,5,7,7,9}
					for i =1,5 do
						scorerSpawnPattern[i] = math.random(0,tempList[i])
					end
					scoregoals[1] = math.floor(saveFiles[file]/5+ scorerSpawnPattern[1]*.7 -.3*(blockSpawnPattern[1]+scorerSpawnPattern[2]))
					scoregoals[2] = math.floor(scoregoals[1]+saveFiles[file]*2/5+ (scorerSpawnPattern[3]+scorerSpawnPattern[2])*.7 -.3*(blockSpawnPattern[2]+scorerSpawnPattern[4]))
					scoregoals[3] = math.floor(scoregoals[2]+saveFiles[file]*3/5+ (scorerSpawnPattern[4]+scorerSpawnPattern[5])*.7 -.3*(blockSpawnPattern[3]))
					saveFiles[file] = saveFiles[file] - 1
					love.filesystem.write('saves.txt',tostring(saveFiles[1])..'v'..tostring(saveFiles[2])..'v'..tostring(saveFiles[3]))
					print(saveFiles[file])
					placedBlocks = {} --array of blocks currently around
					heldBlocks = {}
					heldMino = nil
					comingBlocks = {}
					score = 0
					pastHeldMino = nil
					stage = 1
					occupiedSpaces = {}
					for layer = 1,5 do
						doneGenerating = false
						blocksGenerated = 0
						while not doneGenerating do
							overlap = false
							insertionCoords = scorerSpawnRegions[layer][math.random(1,table.getn(scorerSpawnRegions[layer]))]
							for i,value in ipairs(occupiedSpaces) do
								if value[1] == insertionCoords and value[2] == insertionCoords[2] then
									overlap = true
								end
							end
							if not overlap then
								table.insert(placedBlocks,{x = insertionCoords[1],
								y = insertionCoords[2],
								img = 3,
								scorer = true,
								exposed = false})
								blocksGenerated = blocksGenerated + 1
								table.insert(occupiedSpaces,insertionCoords)
								--rint(blocksGenerated)
								if blocksGenerated >= scorerSpawnPattern[layer] then
									doneGenerating = true
								end
							end
						end
					end
					for layer = 1,3 do
						doneGenerating = false
						blocksGenerated = 0
						while not doneGenerating do
							overlap = false
							insertionCoords = blockSpawnRegions[layer][math.random(1,table.getn(blockSpawnRegions[layer]))]
							for i,value in ipairs(occupiedSpaces) do
								if value[1] == insertionCoords[1] and value[2] == insertionCoords[2] then
									overlap = true
								end
							end
							if not overlap then
								table.insert(placedBlocks,{x = insertionCoords[1],
								y = insertionCoords[2],
								img = 1,
								scorer = false,
								exposed = false})
								blocksGenerated = blocksGenerated + 1
								table.insert(occupiedSpaces,insertionCoords)
								if blocksGenerated >= blockSpawnPattern[layer] then
									doneGenerating = true
								end
							end
						end
					end
				end
			end
		end
	end
end

function love.draw(dt)
	if menu == 0 then
		love.graphics.draw(borderImgs[3],255,255)
		if stage > 1 then
			love.graphics.draw(borderImgs[2],155,155)
			if stage > 2 then
				love.graphics.draw(borderImgs[1],55,55)
			end
		end
		for i,block in ipairs(placedBlocks) do
		--if block.powered then
			love.graphics.draw(blockImgs[block.img], block.x+5, block.y+5)
		--(block.x+5)
		--end
		--if not block.powered then
		--	love.graphics.draw(block.inactiveimg, block.x+5, block.y+5)
		--end
		--if block.chargeLeft == 2 then
		--	love.graphics.draw(blockImgs[25], block.x+5, block.y+5)
		--end
		--if block.chargeLeft == 1 then
		--	love.graphics.draw(blockImgs[24], block.x+5, block.y+5)
		--end
		end
		for i,block in ipairs(heldBlocks) do
			love.graphics.draw(blockImgs[block.holdimg], block.x, block.y)
		end
		for i,block in ipairs(comingBlocks) do
			love.graphics.draw(blockImgs[block.holdimg], block.x, block.y)
		end
		love.graphics.print(score,1000,40)
		love.graphics.print(scoregoals[1]+1,950,40)
		love.graphics.print(scoregoals[2]+1,950,80)
		love.graphics.print(scoregoals[3]+1,950,120)
		if saveFiles[file] > 13 then
			love.graphics.print(math.floor(timeMax-love.timer.getTime())+1, 1000,500)
		end
		if not (table.getn(heldBlocks) == 0) then
		end
	end
	if not (menu == 0) then
		for i,button in ipairs(menubuttonlist[menu]) do
			love.graphics.setColor(32,88,23)
			love.graphics.rectangle('fill',button[3],button[4],button[5],button[6])
			love.graphics.setColor(236,214,191)
			love.graphics.print(button[1],button[3],button[4])
		end
		if menu == 1 then
			love.graphics.setFont(biggerfont)
			love.graphics.print('Big Bear\nBUYOUT',600,170)
			love.graphics.setFont(font)
			if musicPlaying then
				love.graphics.draw(music1,600,640)
			else
				love.graphics.draw(music2,600,640)
			end
			if sfxOn then
				love.graphics.draw(sfx1,700,640)
			else
				love.graphics.draw(sfx2,700,640)
			end
		end
		if menu == 2 then
			love.graphics.print(tostring(saveFiles[1]),750,350)
			love.graphics.print(tostring(saveFiles[2]),750,450)
			love.graphics.print(tostring(saveFiles[3]),750,550)
		end
	end
end
