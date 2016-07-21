% initialize the remaining coordinates of the tetromino's blocks depending on its shape.
proc initPosition (var block : array 1 .. 4, 1 .. 2 of int, shape : int)
    % initialize coordinates for the S-tetromino
    if shape = 1 then
	block (3, 1) := block (1, 1)
	block (3, 2) := block (1, 2) - separation
	block (4, 1) := block (2, 1)
	block (4, 2) := block (2, 2) + separation
	% initialize coordinates for the O-tetromino
    elsif shape = 2 then
	block (3, 1) := block (1, 1)
	block (3, 2) := block (1, 2) - separation
	block (4, 1) := block (2, 1)
	block (4, 2) := block (3, 2)
	% initialize coordinates for the Z-tetromino
    elsif shape = 3 then
	block (3, 1) := block (1, 1)
	block (3, 2) := block (1, 2) - separation
	block (4, 1) := block (1, 1) + separation
	block (4, 2) := block (3, 2)
	% initialize coordinates for the T-tetromino
    elsif shape = 4 then
	block (3, 1) := block (1, 1)
	block (3, 2) := block (1, 2) - separation
	block (4, 1) := block (1, 1) + separation
	block (4, 2) := block (1, 2)
	% initialize coordinates for the I-tetromino
    elsif shape = 5 then
	block (3, 1) := block (1, 1) + separation
	block (3, 2) := block (1, 2)
	block (4, 1) := block (3, 1) + separation
	block (4, 2) := block (1, 2)
	% initialize coordinates for the L-tetromino
    elsif shape = 6 then
	block (3, 1) := block (1, 1) + separation
	block (3, 2) := block (1, 2)
	block (4, 1) := block (3, 1)
	block (4, 2) := block (1, 2) - separation
	% initialize coordinates for the J-tetromino
    else
	block (3, 1) := block (1, 1) + separation
	block (3, 2) := block (1, 2)
	block (4, 1) := block (2, 1)
	block (4, 2) := block (1, 2) - separation
    end if
end initPosition

% Determine whether the tetromino should continue dropping (false) or stay in place (true)
function shouldStay (bArray : array 1 .. 4, 1 .. 2 of int, gArray : array 1 .. *, 1 .. * of boolean) : boolean
    var currentColumn, currentRow : int
    for j : 1 .. 4
	% the current column of the tetromino's block
	currentColumn := (bArray (j, 1) - edgeXL) div separation + 1
	% the current row of the tetromino's block
	currentRow := (bArray (j, 2) - edgeYD) div separation + 1
	% when a block is in row 1 or has another block underneath it, let the tetromino stay in place. Return "true"
	if currentRow = 1 then
	    result currentRow = 1
	end if
	if gArray (currentRow - 1, currentColumn) = true then
	    result gArray (currentRow - 1, currentColumn) = true
	end if
    end for
    % when the tetromino can still move down, return false.
    result (false)
end shouldStay

% changes the horizontal position and orientation of the tetromino depending on user input
proc changePositionX (var bArray : array 1 .. 4, 1 .. 2 of int, bLeft, bRight, shape : int, var state : int, input : string)

    % erase the previous tetromino. Draw it later in its new location
    for i : 1 .. 4
	Draw.FillBox (bArray (i, 1) - halfWidth, bArray (i, 2) - halfWidth, bArray (i, 1) + halfWidth, bArray (i, 2) + halfWidth, black)
    end for

    % Shift the coordinates of the tetromino's squares to the left but only if the tetromino remains within the borders
    if input = "a" and bArray (bLeft, 1) - halfWidth - 1 > edgeXL then
	var canShift : boolean := true
	% when there are blocks to the left of the dropping tetromino, prevent the tetromino from shifting left
	for i : 1 .. 4
	    if gridFill ((bArray (i, 2) - edgeYD) div separation + 1, (bArray (i, 1) - edgeXL) div separation) = true then
		canShift := false
		exit
	    end if
	end for
	if canShift = true then
	    for i : 1 .. 4
		bArray (i, 1) := bArray (i, 1) - separation
	    end for
	end if
	% Shift the coordinates of the tetromino's squares to the right but only if the tetromino remains within the borders
    elsif input = "d" and bArray (bRight, 1) + halfWidth + 1 < edgeXR then
	var canShift : boolean := true
	% when there are blocks to the right of the dropping tetromino, prevent the tetromino from shifting right
	for i : 1 .. 4
	    if gridFill ((bArray (i, 2) - edgeYD) div separation + 1, (bArray (i, 1) - edgeXL) div separation + 2) = true then
		canShift := false
		exit
	    end if
	end for
	if canShift = true then
	    for i : 1 .. 4
		bArray (i, 1) := bArray (i, 1) + separation
	    end for
	end if
	% do not allow the 2-by-2, square-shaped tetromino to rotate
    elsif input = "w" and shape ~= 2 then
	var canRotate : boolean := true
	for i : 2 .. 4
	    % calculate the vertical and horizontal distances between the centres of each tetromino's block to the centre of "block 1" (set the centre of block 1 as (0, 0), the origin). This makes the calculations for rotating easier.
	    var xFromCentre : int := bArray (i, 1) - bArray (1, 1)
	    var yFromCentre : int := bArray (i, 2) - bArray (1, 2)
	    % swap the coordinates. This is gives us the new coordinates after the tetromino is rotated.
	    var temp : int := -1 * xFromCentre
	    xFromCentre := yFromCentre
	    yFromCentre := temp
	    % if one of the tetromino's blocks goes our of bounds (off the grid), do not rotate the tetromino. Or, if the tetromino is expected to rotate onto another block, do not rotate.
	    if (bArray (1, 1) + xFromCentre < edgeXL) or (bArray (1, 1) + xFromCentre > edgeXR) or gridFill ((bArray (1, 2) + yFromCentre - edgeYD) div separation + 1, (bArray (1, 1) + xFromCentre -
		    edgeXL) div separation + 1) = true then
		canRotate := false
		exit
	    end if
	end for
	if canRotate = true then
	    for i : 2 .. 4
		% calculate the vertical and horizontal distances between the centres of each block to the centre of block 1 (set the centre of square 1 as (0, 0), the origin). This makes the calculations for rotating easier.
		var xFromCentre : int := bArray (i, 1) - bArray (1, 1)
		var yFromCentre : int := bArray (i, 2) - bArray (1, 2)
		var temp : int := -1 * xFromCentre
		xFromCentre := yFromCentre
		yFromCentre := temp
		% set the "origin" as what it originally was before rotating. Calculate the new coordinates after rotating.
		bArray (i, 1) := bArray (1, 1) + xFromCentre
		bArray (i, 2) := bArray (1, 2) + yFromCentre
	    end for
	    % after rotating, signal that the tetromino's orientation changed
	    if state ~= 4 then
		state := state + 1
	    else
		state := 1
	    end if
	end if
    end if
    % draw the tetromino in its new location/ orientation
    for i : 1 .. 4
	Draw.FillBox (bArray (i, 1) - halfWidth, bArray (i, 2) - halfWidth, bArray (i, 1) + halfWidth, bArray (i, 2) + halfWidth, blockColour)
    end for
end changePositionX

% Draw grid columns based on preset boundaries and number of desired columns
proc drawGridCol (leftSide, lowerSide, upperSide, totalColumn : int)
    for i : 0 .. totalColumn
	Draw.Line (leftSide + i * separation, lowerSide, leftSide + i * separation, upperSide, white)
    end for
end drawGridCol

% Draw grid rows based on preset boundaries and number of desired rows
proc drawGridRow (leftSide, rightSide, upperSide, totalRow : int)
    for i : 0 .. totalRow
	Draw.Line (leftSide, upperSide - i * separation, rightSide, upperSide - i * separation, white)
    end for
end drawGridRow
