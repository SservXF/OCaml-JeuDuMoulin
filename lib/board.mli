val board_size : int
val maxPiecesPerPlayer : int
val nbToGetMill : int
val notUpdatedGame : Type.gameUpdate -> Type.gameUpdate
val coordinatesFromDirections :
  Type.directionDeplacement -> int * int -> int * int
val pathToHaveFromDirection : Type.directionDeplacement -> Type.square
val getSquare : 'a list list -> int * int -> 'a option
val getRow : Type.board -> int -> Type.square list
val getColumn : Type.board -> int -> Type.square list
val coordinateFromDirection :
  Type.board ->
  Type.coordinates -> Type.directionDeplacement -> Type.coordinates option
val checkMillFromPosition :
  Type.board -> Type.coordinates -> Type.color -> bool
val boardMap :
  (Type.square -> Type.square) ->
  Type.board -> Type.coordinates -> Type.square list list
val placePieceOnBoard :
  Type.board -> Type.coordinates -> Type.color -> Type.gotMill
val placeStartPiece :
  Type.gameUpdate -> Type.coordinates -> Type.color -> Type.gameUpdate
val removeFromBoard :
  Type.board -> Type.coordinates -> Type.color -> Type.board
val eliminatePiece :
  Type.gameUpdate -> Type.coordinates -> Type.color -> Type.gameUpdate
val moveToCoordinates :
  Type.gameUpdate ->
  Type.coordinates -> Type.coordinates -> Type.color -> Type.gameUpdate
val initBoard : Type.square list list
val initBoardQuarter : Type.board -> Type.board
val moveToDirection :
  Type.gameUpdate ->
  Type.coordinates ->
  Type.directionDeplacement -> Type.color -> Type.gameUpdate
val possibleMoves :
  Type.gameUpdate ->
  Type.coordinates -> Type.color -> bool -> Type.directionDeplacement list
