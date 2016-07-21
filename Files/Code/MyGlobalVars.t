%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Programmer: Steven Xiong
%Date: June 17, 2016
%Course:  ICS3CU1
%Teacher: Mr. Huang
%Program Name: SpaceTetris.t
%Descriptions:  In this game, the player is provided with "tetrminoes" which are groups of 4 blocks clustered together. The player can rotate the tetrominoes, make the move horizontally, etc. The purpose of the game is to stack up the blocks so that they form complete and filled up rows. Rows which are filled become emptied, causing the player earns points. The player loses if blocks accumulate all the way to the top of the screen/ grid. This game has additional features: it interacts with a text file containing high scores data, it animates pictures onscreen, etc. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   MyGlobalVars.t
%   All global variables are coded in this file.
%   These will have FILE scope.
%   These must be document thoroughly - Descriptive name,
%   where used and for what purpose
% Main program variables

%Introduction Window
% Flag for Introduction Window state open or closed
var isIntroWindowOpen : boolean
var isFontWindowOpen : boolean
% Allow the player to select whether to view instructions, view high scores, or play the game. The user provides input before the game begins in the main window screen
var introSelection : string (1)
% Allow the player to select a level of difficulty. The user provides input right before the game begins in the main windows screen
var difficultySelection : string (1)

% the upper iteration of a for statement which has the "delay" command. This controls the time it takes for tetrominoes to drop one level. The higher the level of difficulty, the smaller this number is, and the faster the tetrominoes drop
var dropTime : int
% stores the rank, username, and high score values of every player. There are 5 high scores in total
var highScoreData : array 1 .. 5, 1 .. 3 of string
% set the upper iteration of the for statement which draws the grid. These are the upper bounds for the boolean array which tracks whether specific squares on the middle grid have blocks or are empty
var numberOfColumns : int := 10
var numberOfRows : int := 22

% set borders in which the falling tetromino must lie. Used in calculations that prevent the falling tetromino from going out of bounds
var edgeYD : int := 20
var edgeXL : int := 220
% the distance between successive squares on the grid. Used in calculations for draw the grid and move the tetrominoes horizontally and vertically to exactly the right distance
var separation : int := 20
% the border lines in which the falling tetromino must lie.
var edgeYU : int := edgeYD + separation * numberOfRows
var edgeXR : int := edgeXL + separation * numberOfColumns
% tracks whether squares on the grid are full. True means the square contains a block. False means an empty square.
var gridFill : array 1 .. numberOfRows, 1 .. numberOfColumns of boolean
% set border lines for the "next tetromino" and "reserved tetromino" grids
var edgeXLNext : int := edgeXR + separation * 2
var edgeYUNext : int := edgeYU - separation * 2
var edgeXLResv : int := edgeXL - separation * 6
var edgeYUResv : int := edgeYUNext

% the distance from the centre of a tetromino block to its outer edge. Used in draw commands which draw every tetromino's blocks
var halfWidth : int := 9
% Signal to the main program whether the user has reserved a tetromino for later use. If true, a tetromino is already on reserve. Reserving a block for the first time does not require the "reserve tetromino" and the "currently-dropping tetromino" to switch places. After the first switch, the "reserve tetromino" and currently-dropping tetromino must switch places. Used in if statements
var alreadyReserved : boolean 
% Signals whether the player wants to place a tetromino on reserve. Used in multiple if statements, thereby changing the code that runs every round depending on whether the user reserves blocks
var willReserve : boolean
% Signals whether the player already reserved a tetromino during the last round. Used in if statements to prevent players from switching/ reserving blocks infinitely during one round 
var reservedLastRound : boolean 
% Signals whether the player lost or quit the game. Used in multiple if statements
var shouldEndGame : boolean 
% Keeps track of the player's score throughout the game
var score : int 

% stores the color of tetrominoes and every square the program will draw
var blockColour : int
% Randomly determines the shape of the tetromino in the "next grid". Ex) Square (O-tetromino), Z-Shaped (Z-tetromino). 
var blockShape : int := Rand.Int (1, 7)
% Stores the shapes of tetrominoes in the left and right grids (next and reserve grids). "tempShape" facilitates swapping of variables
var blockShapeNext, blockShapeResv, tempShape : int

% The higher the level of difficulty, the more points the player can earn. This increment value is constantly added to the player's score
var scoreIncrement : int

proc setInitialGameValues

    isIntroWindowOpen := false
    isFontWindowOpen := false
    % set the initial score to 0
    score := 0
    shouldEndGame := false
    alreadyReserved := false
    willReserve := false
    reservedLastRound := false
end setInitialGameValues
