proc displayHighScores
    cls
    var stream : int
    open : stream, "Files/Text/highScores.txt", get
    
    if stream > 0 then
    
	var lines : string
	loop
	% Read high scores data from a text file and display it onscreen
	    exit when eof (stream)
	    get : stream, lines : * 
	    put lines

	end loop
	close : stream
    else
	put "Unable to open file."
    end if

    var anyKey : string (1)

    put "\n\n   Enter any key to exit:  " ..
    getch (anyKey)
end displayHighScores

proc initializeScores ()
    var stream : int
    open : stream, "Files/Text/highScores.txt", get
    for rank : 1 .. upper (highScoreData, 1)
	for column : 1 .. upper (highScoreData, 2)
	    get : stream, skip
	    exit when eof (stream)
	    % initialize the array's elements as separate pieces of data in the high scores text file
	    get : stream, highScoreData (rank, column)
	end for
    end for
    close : stream
end initializeScores
% Updating high scores data
proc updateScores ()
    var rankDeserved : int := 0
    var stream : int
    var shouldSaveScore : string (1)
    var newUserName : string

    for rank : 1 .. upper (highScoreData, 1)

	% Detect whether the player's current score is high enough for the top 5 ranking
	if score >= strint (highScoreData (rank, 3)) then
	    % Store the rank which the player deserves
	    rankDeserved := rank
	    exit when rankDeserved > 0
	end if
    end for
    if rankDeserved > 0 then
	put "You earned a high score! Do you want to save it? <y/n>" ..
	getch (shouldSaveScore)
	put ""
	if shouldSaveScore ~= "N" and shouldSaveScore ~= "n" then
	    loop
		put "Enter a username: " ..
		get newUserName
		% only accept usernames which are 23 characters or less in length and has no spaces
		exit when length (newUserName) <= 23 and index (newUserName, " ") = 0
		put "Your input is either too long or invalid because it has spaces"
	    end loop
	    for decreasing rank : upper (highScoreData, 1) .. rankDeserved + 1
		% Each player and their high score get moved down one rank
		highScoreData (rank, 2) := highScoreData (rank, 2) (1 .. 0) + highScoreData (rank - 1, 2)
		highScoreData (rank, 3) := highScoreData (rank, 3) (1 .. 0) + highScoreData (rank - 1, 3)
	    end for
	    % store the username and score of the new highest-scoring player in their appropriate rank
	    highScoreData (rankDeserved, 2) := highScoreData (rankDeserved, 2) (1 .. 0) + newUserName
	    highScoreData (rankDeserved, 3) := highScoreData (rankDeserved, 3) (1 .. 0) + intstr (score)
	    open : stream, "files/text/highScores.txt", put
	    % print the new "high score data" to the text file
	    for rank : 1 .. upper (highScoreData, 1)
		for column : 1 .. upper (highScoreData, 2)
		    put : stream, highScoreData (rank, column) ..
		    put : stream, " " ..
		end for
		put : stream, ""
	    end for
	    close : stream
	end if
    end if
end updateScores
