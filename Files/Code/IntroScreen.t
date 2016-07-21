%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Programmer:
%Date:
%Course:  ICS3CU1
%Teacher:
%Program Name:
%Descriptions:  Demos how to implement a button and a process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % play music while intro screen is open
process playIntroMusic
    loop
	Music.PlayFile("sounds/IntroMusic.MP3")
	exit when isIntroWindowOpen = false
    end loop
    Music.PlayFileStop
end playIntroMusic

process displayBanner

    var picID : int := Pic.FileNew ("images/starry background.JPG")
    var newPicID : int := Pic.Scale (picID, 640, 480)
    Pic.Draw (newPicID, 0, 0, picCopy)
    var intfont : int := Font.New ("Castellar:22")
    var intfont2 : int := Font.New ("Castellar:14")

    % create a flashing banner that welcomes the player to the introduction screen
    loop
	Font.Draw ("Welcome to Space Tetris", maxx div 6, maxy * 2 div 3 + 12, intfont, 34)
	Font.Draw ("Press Close to begin", maxx div 3, maxy * 2 div 3 - 6, intfont2, 34)
	delay (400)
	% stop displaying the banner when the introduction screen is closed. This allows further instructions to be displayed without visual disturbances onscreen
	exit when isIntroWindowOpen = false
	Font.Draw ("Welcome to Space Tetris", maxx div 6, maxy * 2 div 3 + 12, intfont, black)
	Font.Draw ("Press Close to begin", maxx div 3, maxy * 2 div 3 - 6, intfont2, black)
	delay (400)
	exit when isIntroWindowOpen = false
    end loop

end displayBanner

% display a series of photos which animate a spinning satellite. This is for enhancing visual effect/ appeal
process moveSatellite
    var filename : string
    var c : int := 0
    var picID : int

    loop
	% all images are defined by spaceship2#.jpg. We will try to cycle through 0 .. 11 for filenames
	c := c mod 12
	filename := "images/spaceship2" + intstr (c) + ".JPG"
	picID := Pic.FileNew (filename)
	var newPicID : int := Pic.Scale (picID, 220, 220)
	% display the image of the satelite in its current orientation
	Pic.Draw (newPicID, 410, 30, picCopy)
	Pic.Free (picID)
	Pic.Free (newPicID)
	% update to the next image (change the orientation of the satellite)
	c := c + 1;
	delay (100)
	% stop displaying this satellite when the introduction screen is closed.
	exit when isIntroWindowOpen = false
    end loop
end moveSatellite

% main procedure to handle the intro window
procedure displayIntroWindow

    % flag that intro screen is open - global var isIntroWindowOpen
    isIntroWindowOpen := true
    % Open the window
    var winID : int
    winID := Window.Open ("position:top;center,graphics:640;480,title:Introduction Window")

    % display a flashing banner/ welcoming message
    fork displayBanner
    % animate a spinning satellite
    fork moveSatellite
    % play music while intro screen is open
    fork playIntroMusic

    % create a button for closing the intro screen
    var quitIntroWindowButton := GUI.CreateButton (maxx div 2 - 20, 25, 0, "Close", QuitIntroWindowButtonPressed)

    loop
	exit when GUI.ProcessEvent or isIntroWindowOpen = false
    end loop
    % release the button
    GUI.Dispose (quitIntroWindowButton)
    % close/release the window
    Window.Close (winID)
end displayIntroWindow

