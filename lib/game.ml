open Type;;
open Board;;
open Player;;


let gameRandomly seed =
  let rec play (game :gameUpdate) (player:color):gameUpdate =
    prettyPrintBoard game.board;
    if (getPlayer game player).piecePlaced<maxPiecesPerPlayer
      then let () = print_string "Positionnement \n" in let newGameUpdate = playRandomly seed player game Placing in play newGameUpdate (reverseColor player)
    else

      if (getPlayer game player).nbPiecesOnBoard <= 3
        then let () = print_string "Flying \n" in if lost game (getPlayer game player) false BothFlying then let () = afficheVainqueur (reverseColor player) in game 
          else let newGameUpdate = playRandomly seed player game BothFlying  in play newGameUpdate (reverseColor player)
      else

        let () = print_string "Deplacement \n" in 
        if lost game (getPlayer game player) false Moving then let () = afficheVainqueur (reverseColor player) in game
        else let newGameUpdate = playRandomly seed player game Moving  
      in play newGameUpdate (reverseColor player)
  in let board = initBoard2 in let (p1,p2) = (initPlayer Black,initPlayer White) in 
  let game = {board = board;mill=false;player1 = p1;player2=p2;gameIsChanged=false} in 
  play game Black
      