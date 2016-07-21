%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Programmer: Steven Xiong
%Program Name: Space Tetris
%Date: June 17, 2016
%Course:  ICS3CU1  
%Teacher:  Mr. Huang
%Descriptions:  In this game, the player is provided with "tetrminoes" which are groups of 4 blocks clustered together. The player can rotate the tetrominoes, make the move horizontally, etc. The purpose of the game is to stack up the blocks so that they form complete and filled up rows. Rows which are filled become emptied, causing the player earns points. The player loses if blocks accumulate all the way to the top of the screen/ grid. This game has additional features: it interacts with a text file containing high scores data, it animates pictures onscreen, etc. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% files/code folder
include "files/code/includes.t"

% play music while the game runs
process playMusic
    loop
	Music.PlayFile ("sounds/PlayMusic.MP3")
	exit when shouldEndGame = true
    end loop
    Music.PlayFileStop
end playMusic

% Store information in the high scores text file in an array.
initializeScores ()

loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % procedure to set all initial global variable with file scope
    % even if already set (located in MyGlobalVars.t)
    setInitialGameValues
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ID numbers for all pictures and fonts
    var picID, newPicID, planetPicID, newPlanetPicID, shipPicID, newShipPicID, font1 : int
    % A.      display title screen
    displayIntroWindow
    cls
    setscreen ("graphics:640;480,nocursor")
    % store the numerical IDs of pictures in the background
    % resize the pictures and draw them onscreen
    picID := Pic.FileNew ("images/starry background.JPG")
    newPicID := Pic.Scale (picID, 640, 480)
    shipPicID := Pic.FileNew ("images/SpaceshipBlue.JPG")
    newShipPicID := Pic.Scale (shipPicID, 81, 40)
    planetPicID := Pic.FileNew ("images/GoodPlanet1.JPG")
    newPlanetPicID := Pic.Scale (planetPicID, 200, maxx div 7)
    Pic.Draw (newPicID, 0, 0, picCopy)

    colorback (black)
    color (white)
    locate (3, 1)
    % Ask the player whether they want to view instructions, view high scores, or play
    put "Enter 'I' or 'i' to view instructions"
    put "Enter 'H' or 'h' to view high scores"
    put "Enter any other key to play!"

    getch (introSelection)

    if introSelection = "I" or introSelection = "i" then
	% The Instruction screen will display and pause the program
	put "High Scores"
	put ""
	displayInstructionWindow
    elsif introSelection = "H" or introSelection = "h" then
	% The high scores screen will display and pause the program
	displayHighScores
    end if
    % Redraw the background image to erase the previous instructions/ words
    Pic.Draw (newPicID, 0, 0, picCopy)
    locate (3, 1)
    put "Choose your level of difficulty"
    put "Enter C or c for Challenging"
    put "Enter H or h for Hard"
    put "Enter M or m for medium"
    put "Enter E or e for easy"
    put "Enter any other key for relaxed"
    % allow the user to select a level of difficulty
    getch (difficultySelection)
    % Assign the "time" it takes for tetrominoes to drop one level. The higher the level of difficulty, the faster the tetrominoes drop, and the more points the player is awarded
    if difficultySelection = "C" or difficultySelection = "c" then
	% Assign the time it takes for tetrominoes to drop
	dropTime := 2
	% Assign the number of points the player earns on an ongoing basis
	scoreIncrement := 222
    elsif difficultySelection = "H" or difficultySelection = "h" then
	dropTime := 3
	scoreIncrement := 73
    elsif difficultySelection = "M" or difficultySelection = "m" then
	dropTime := 5
	scoreIncrement := 35
    elsif difficultySelection = "E" or difficultySelection = "e" then
	dropTime := 7
	scoreIncrement := 17
    else
	dropTime := 9
	scoreIncrement := 13
    end if

    cls
    Pic.Draw (newPicID, 0, 0, picCopy)
    Pic.Draw (newShipPicID, 40, 40, picCopy)
    Pic.Draw (newShipPicID, 40, 100, picCopy)
    Pic.Draw (newShipPicID, 120, 60, picCopy)
    Pic.Draw (newPlanetPicID, 440, 0, picCopy)
    % run a separate process which plays music
    fork playMusic

    % No squares within the grid should contain blocks when the game starts. Set all squares to "false"
    for i : 1 .. upper (gridFill, 1)
	for j : 1 .. upper (gridFill, 2)
	    gridFill (i, j) := false
	end for
    end for
    % Drawing grids which the tetrominoes reside in -- Centre grid: where the game happens
    drawGridCol (edgeXL, edgeYD, edgeYU, numberOfColumns)
    drawGridRow (edgeXL, edgeXR, edgeYU, numberOfRows)
    % Right grid: shows the next tetromino that will fall
    drawGridCol (edgeXLNext, edgeYUNext - separation * 4, edgeYUNext, 4)
    drawGridRow (edgeXLNext, edgeXLNext + separation * 4, edgeYUNext, 4)
    % Left grid: shows the tetromino on reserve
    drawGridCol (edgeXLResv, edgeYUResv - separation * 4, edgeYUResv, 4)
    drawGridRow (edgeXLResv, edgeXLResv + separation * 4, edgeYUResv, 4)

    font1 := Font.New ("Castellar:12")
    Font.Draw ("Next", edgeXLNext + 15, maxy - 40, font1, white)
    Font.Draw ("Reserved", edgeXLResv - 5, maxy - 40, font1, white)

    % array which stores the coordinates of the "next" tetromino. 4 blocks and 2 coordinates (x and y) for the centres of these blocks
    var blockCoordNext : array 1 .. 4, 1 .. 2 of int
    % initialize coordinates for the blocks in the "next" tetromino. Regardless of shape, every tetromino shares 2 blocks that are in the same position (side-by-side). Initialize the coordinates of the first 2 blocks
    blockCoordNext (1, 1) := edgeXLNext + separation + halfWidth + 1
    blockCoordNext (2, 1) := blockCoordNext (1, 1) - separation
    blockCoordNext (1, 2) := edgeYUNext - separation - halfWidth - 1
    blockCoordNext (2, 2) := blockCoordNext (1, 2)
    % store the coordinates of the "reserve" tetromino
    var blockCoordReserve : array 1 .. 4, 1 .. 2 of int
    % initialize the coordinates of the blocks in the "reserve" tetromino. Regardless of shape, every tetromino shares 2 blocks that are in the same position (side-by-side). Initialize the coordinates of the first 2 blocks
    blockCoordReserve (1, 1) := edgeXLResv + separation + halfWidth + 1
    blockCoordReserve (2, 1) := blockCoordReserve (1, 1) - separation
    blockCoordReserve (1, 2) := edgeYUResv - separation - halfWidth - 1
    blockCoordReserve (2, 2) := blockCoordReserve (1, 2)
    % display the player's initial score
    colorback (black)
    color (white)
    locate (11, 60)
    put "Current Score"
    locate (12, 63)
    put score
    % main program. Includes the tetrominos' dropping animations and updating of the score.
    loop
	% use a 2-D array to store the coordinates of the centres of the tetromino's blocks. There are 4 blocks and 2 coordinates (x and y)
	var blockCoord : array 1 .. 4, 1 .. 2 of int
	% Randomly select the color of the blocks that the program will draw.
	loop
	    blockColour := Rand.Int (0, 143)
	    % Avoid using colors that match the background's color.
	    exit when (blockColour ~= 7 and (blockColour < 16 or blockColour > 20))
	end loop
	% The value ranges from 1 to 4. This changes when the player spins the tetromino
	var orientation : int := 1
	% delayTime and "dropTime" both control the speed at which tetrominoes drop
	var delayTime : int := 50
	% Signals whether the player wants to "hard drop" the tetromino
	var willDropInstant : boolean := false
	% Keeps track of how many rows/ levels the current tetromino falls. This is used to calculate the player's score if they decide to "hard drop" the tetromino
	var rowsCovered : int := 0

	% initialize coordinates for the blocks of the tetromino that drops (starts at the top of the middle grid). These are for the "common 2" blocks
	blockCoord (1, 1) := edgeXL + 5 * separation + halfWidth + 1
	blockCoord (2, 1) := blockCoord (1, 1) - separation
	% Each tetromino spawns with its "first" and "second" squares in the second-highest row of the grid
	blockCoord (1, 2) := edgeYU - separation - halfWidth - 1
	blockCoord (2, 2) := edgeYU - separation - halfWidth - 1
	% Initialize the remaining x-coordinates and y-coordinates for the 4 squares of the dropping tetromino. This depends on the shape of the tetromino. (there are 7 shapes in total)
	initPosition (blockCoord, blockShape)
	% Draw the "next" tetromino in the grid to the right. Do not change the position of the "next" tetromino in the case where the user already reserved a tetromino previously and wanted to reserve a tetromino during the previous round. 
	if willReserve = false or alreadyReserved = false then
	    blockShapeNext := Rand.Int (1, 7)
	    initPosition (blockCoordNext, blockShapeNext)
	    
	    % Draw the tetromino in the "next grid" in its initial position
	    for j : 1 .. 4
		Draw.FillBox (blockCoordNext (j, 1) - halfWidth, blockCoordNext (j, 2) - halfWidth, blockCoordNext (j, 1) + halfWidth, blockCoordNext (j, 2) + halfWidth, blockColour)
	    end for
	end if

	% if the new, dropping tetromino overlaps with already-existing blocks, exit the game and take the player to the game over screen
	for block : 1 .. 4
	    var currentRow : int := (blockCoord (block, 2) - edgeYD) div separation + 1
	    var currentColumn : int := (blockCoord (block, 1) - edgeXL) div separation + 1
	    if gridFill (currentRow, currentColumn) = true then
		shouldEndGame := true
		exit
	    end if
	end for

	exit when shouldEndGame = true

	if willReserve = true then
	    % Set the coordinates of the "reserve" tetromino's blocks.
	    initPosition (blockCoordReserve, blockShapeResv)
	    % Draw the tetromino in the "reserve grid" in its initial position
	    for j : 1 .. 4
		Draw.FillBox (blockCoordReserve (j, 1) - halfWidth, blockCoordReserve (j, 2) - halfWidth, blockCoordReserve (j, 1) + halfWidth, blockCoordReserve (j, 2) + halfWidth, blockColour)
	    end for
	    % If the player reserved a block during the last round and reserves blocks for the first time, flag to the program that from now on the program has a block in the reserve grid.
	    if alreadyReserved = false then
		alreadyReserved := true
	    end if
	end if

	% Assume the player does not want to reserve the current tetromino during this round/ run.
	willReserve := false
	loop
	    % Draw the tetromino. After a time delay, make the tetromino drop one level
	    for j : 1 .. 4
		Draw.FillBox (blockCoord (j, 1) - halfWidth, blockCoord (j, 2) - halfWidth, blockCoord (j, 1) + halfWidth, blockCoord (j, 2) + halfWidth, blockColour)
	    end for

	    % Call functions and perform operations which respond to user input. This allow the user to move the tetrominoes horizontally, change their orientation, etc.
	    for j : 1 .. dropTime
		% Detects what key the player inputs
		if hasch = true then
		    var input : string (1)
		    getch (input)
		    % Reserving/ switching tetrominoes
		    if input = "p" and reservedLastRound = false then
			for i : 1 .. 4
			    % Erase the block that is currently dropping
			    Draw.FillBox (blockCoord (i, 1) - halfWidth, blockCoord (i, 2) - halfWidth, blockCoord (i, 1) + halfWidth, blockCoord (i, 2) + halfWidth, black)
			end for
			willReserve := true
			% Later on, prevent the user from reserving/ switching tetrominoes infinitely. One switch is allowed per round
			reservedLastRound := true
			% Placing the previous tetromino on reserve means we no longer animate it dropping continuously. Therefore, exit
			exit
		    % Allow the tetromino to drop faster
		    elsif input = "s" then
			% If the tetromino has no blocks under it, move it down as directed by the player's input.
			if shouldStay (blockCoord, gridFill) = false then
			    % Redraw the blocks in their new, lower position
			    for i : 1 .. 4
				Draw.FillBox (blockCoord (i, 1) - halfWidth, blockCoord (i, 2) - halfWidth, blockCoord (i, 1) + halfWidth, blockCoord (i, 2) + halfWidth, black)
				blockCoord (i, 2) := blockCoord (i, 2) - separation
			    end for
			    for i : 1 .. 4
				Draw.FillBox (blockCoord (i, 1) - halfWidth, blockCoord (i, 2) - halfWidth, blockCoord (i, 1) + halfWidth, blockCoord (i, 2) + halfWidth, blockColour)
			    end for
			    % Give the player points for making blocks drop faster. Output the new score
			    score := score + scoreIncrement
			    locate (12, 63)
			    put score
			end if
		    elsif input = "o" then
			% Signal that the player wants to "hard drop". Shorten "delay" so that the tetromino drop instantly.
			delayTime := 0
			willDropInstant := true
		    elsif input = " " then
			% Allow the player to quit the game
			shouldEndGame := true
			exit
		    else
		    % Change the orientation and control horizontal movement of the tetromino. "blockShape" and the specific blocks on the very left/ right (ex. block #4 or block #3) of the tetromino affect this operation
			if blockShape = 1 then
			    % In these orientations, the left-most block is block 4. The right-most block is block 3.
			    if orientation = 1 or orientation = 4 then
				% Call the function that repositions the tetromino for horizontal movement. The program calculates the coordinates which are just outside the grid; this prevents tetrominoes from going out of bounds
				changePositionX (blockCoord, 4, 3, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 3, 4, blockShape, orientation, input)
			    end if
			elsif blockShape = 2 then
			    changePositionX (blockCoord, 2, 1, blockShape, orientation, input)
			elsif blockShape = 3 then
			    if orientation = 1 or orientation = 4 then
				% Call the function that repositions the tetromino for horizontal movement. The program calculates the coordinates which are just outside the grid; this prevents tetrominoes from going out of bounds
				changePositionX (blockCoord, 2, 4, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 4, 2, blockShape, orientation, input)
			    end if
			elsif blockShape = 4 then
			    if orientation = 1 then
				changePositionX (blockCoord, 2, 4, blockShape, orientation, input)
			    elsif orientation = 2 then
				changePositionX (blockCoord, 3, 1, blockShape, orientation, input)
			    elsif orientation = 3 then
				changePositionX (blockCoord, 4, 2, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 1, 3, blockShape, orientation, input)
			    end if
			elsif blockShape = 5 then
			    if orientation = 1 then
				changePositionX (blockCoord, 2, 4, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 4, 2, blockShape, orientation, input)
			    end if
			elsif blockShape = 6 then
			    if orientation = 1 or orientation = 4 then
				changePositionX (blockCoord, 2, 4, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 4, 2, blockShape, orientation, input)
			    end if
			else
			    if orientation = 3 or orientation = 4 then
				changePositionX (blockCoord, 3, 4, blockShape, orientation, input)
			    else
				changePositionX (blockCoord, 4, 3, blockShape, orientation, input)
			    end if
			end if
		    end if
		end if
		delay (delayTime)
		% determine whether there are blocks under the dropping tetromino. Stop animating the dropping of the tetromino once these conditions are met.
		exit when shouldStay (blockCoord, gridFill) = true or shouldEndGame = true
	    end for
	    % Stopping animating the dropping of the tetromino if there are blocks under the current tetromino or the player wants to reserve
	    exit when (willReserve = true or shouldStay (blockCoord, gridFill) = true or shouldEndGame = true)

	    for j : 1 .. 4
		% Erase the dropping tetromino. Change the position for its dropping animation
		Draw.FillBox (blockCoord (j, 1) - halfWidth, blockCoord (j, 2) - halfWidth, blockCoord (j, 1) + halfWidth, blockCoord (j, 2) + halfWidth, black)
		blockCoord (j, 2) := blockCoord (j, 2) - separation
	    end for
	    if willDropInstant = true then
		% If the player wants to hard drop, track the number of rows the tetromino covers. This determines the player's new score
		rowsCovered := rowsCovered + 1
	    end if
	end loop

	exit when shouldEndGame = true
	% Update score.
	score := score + rowsCovered * scoreIncrement
	locate (12, 63)
	put score

	if willReserve = false then
	    for i : 1 .. 4
		% Once the tetromino reaches the bottom or has to stay in position, let the program know that certain squares now hold blocks (true)
		gridFill ((blockCoord (i, 2) - edgeYD) div separation + 1, (blockCoord (i, 1) - edgeXL) div separation + 1) := true
	    end for
	    % After the falling tetromino touches the ground, allow the player to reserve/ switch tetrominoes again
	    reservedLastRound := false

	    for block : 1 .. 4
		var rowFull : boolean := true
		var currentCol := (blockCoord (block, 1) - edgeXL) div separation + 1
		var currentRow := (blockCoord (block, 2) - edgeYD) div separation + 1
		% After getting the current row which each block is located, scan the squares in each row and find out whether the row is full
		for column : 1 .. numberOfColumns
		    if gridFill (currentRow, column) = false then
			rowFull := false
			exit
		    end if
		end for
		% When the row is full, update the score, make the row black (empty), and make all the blocks positioned above drop one level
		if rowFull = true then
		    score := score + 1200
		    locate (12, 63)
		    put score
		    % the left, right, upper, and lower sides of all squares. These are coordinates which are used to draw black (empty) squares on the tetromino grid
		    var leftSide : int := edgeXL - separation + 1
		    var rightSide : int := edgeXL - 1
		    var upperSide : int := blockCoord (block, 2) + halfWidth
		    var lowerSide : int := blockCoord (block, 2) - halfWidth
		    for column : 1 .. numberOfColumns
			Draw.FillBox (leftSide + (column * separation), lowerSide, rightSide + (column * separation), upperSide, black)
			gridFill (currentRow, column) := false
		    end for
		    upperSide := edgeYD - 1
		    lowerSide := edgeYD - separation + 1
		    for row : currentRow .. numberOfRows
			for column : 1 .. numberOfColumns
			    % Scan all squares above the current row. Move only the filled squares down one row
			    if gridFill (row, column) = true then
				gridFill (row, column) := false
				gridFill (row - 1, column) := true
				Draw.FillBox (leftSide + (column * separation), lowerSide + (row * separation), rightSide + (column * separation), upperSide + (row * separation), black)
				Draw.FillBox (leftSide + (column * separation), lowerSide + ((row - 1) * separation), rightSide + (column * separation), upperSide + ((row - 1) * separation),
				    blockColour)
			    end if
			end for
		    end for
		end if
	    end for
	end if
	% If the player reserves tetrominoes for the first time or does not want to reserve this round ...
	if willReserve = false or alreadyReserved = false then
	    % The tetromino in the "next" window is erased.
	    for i : 1 .. 4
		Draw.FillBox (blockCoordNext (i, 1) - halfWidth, blockCoordNext (i, 2) - halfWidth, blockCoordNext (i, 1) + halfWidth, blockCoordNext (i, 2) + halfWidth, black)
	    end for
	    if willReserve = true then
		% If the player wants to reserve/ switch tetrominoes, make tetromino on reserve the the same shape as the currently dropping tetromino
		blockShapeResv := blockShape
	    end if
	    % Make the new dropping tetromino the same shape as the old "next" tetromino. This prepares for the next round/ run
	    blockShape := blockShapeNext
	% if the player reserved a tetromino already and wants to reserve this round...
	else
	    % Erase the previous tetromino in the "reserved grid"
	    for i : 1 .. 4
		Draw.FillBox (blockCoordReserve (i, 1) - halfWidth, blockCoordReserve (i, 2) - halfWidth, blockCoordReserve (i, 1) + halfWidth, blockCoordReserve (i, 2) + halfWidth, black)
	    end for
	    % Switch shapes for the dropping and "reserve" tetrominoes
	    tempShape := blockShapeResv
	    blockShapeResv := blockShape
	    blockShape := tempShape
	end if
    end loop

    cls
    Pic.Draw (newPicID, 0, 0, picCopy)
    var key : string (1)
    
    % Updating high scores data
    updateScores ()
    locate (3, maxcol div 2 - 4)
    put "Game Over"
    locate (4, maxcol div 2 - 17)
    put "Your final score is ", score
    locate (5, maxcol div 2 - 9)
    put "Play Again? (y/n) " ..
    getch (key)
    exit when key = "N" or key = "n"

end loop
