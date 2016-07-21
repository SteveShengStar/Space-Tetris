proc displayInstructionWindow
    cls
    var stream : int
    open : stream, "files/text/Instructions.txt", get

    if stream > 0 then
	var Lines : string
	locate (1, 1)
	loop
	% read instructions which are stored in a text file and print them out one-by-one
	    exit when eof (stream)
	    get : stream, Lines : *
	    put Lines
	end loop
	close : stream
    else
	put "Unable to open file."
    end if

    var anyKey : string (1)

    put "     Enter any key to exit:  " ..
    getch (anyKey)
end displayInstructionWindow
