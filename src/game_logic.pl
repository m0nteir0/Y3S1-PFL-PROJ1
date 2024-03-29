% ================================= GAME MOVES =================================

% separate_tower(+Board, +X, +Y, +NewX, +NewY, -NewBoard)
% Separates the tower into two parts, keeping the bottom one at (X, Y) and moving the top NPieces to (NewX, NewY). Returns the new board.
separate_tower(Board, X, Y, NewX, NewY, NPieces, NewBoard) :-
  get_tower(Board, X, Y, Tower),
  split_list(Tower, Part1, NPieces, Part2),
  place_tower(Board, X, Y, Part1, Board1),
  move_pieces(Board1, NewX, NewY, Part2, NewBoard).

% move_tower(+Board, +X, +Y, +NewX, +NewY, -NewBoard)
% Moves the tower at (X, Y) to the top of yhe tower at (NewX, NewY) and returns the new board.
move_tower(Board, X, Y, NewX, NewY, NewBoard) :-
  get_tower(Board, X, Y, Tower),
  place_tower(Board, X, Y, empty, Board1),
  move_pieces(Board1, NewX, NewY, Tower, NewBoard).

% move_pieces(+Board, +X, +Y, +NPieces, -NewBoard)
% Moves NPieces to the top of the tower at (X,Y) and returns the new board.
move_pieces(Board, X, Y, NPieces, NewBoard):-
  get_tower(Board, X, Y, Tower),
  append(Tower, NPieces, NewTower),
  place_tower(Board, X, Y, NewTower, NewBoard).

% place_tower(+Board, +X, +Y, +Piece, -NewBoard)
% Places a piece of type Piece on the Board at the specified X and Y coordinates and returns the resulting NewBoard
place_tower(Board, X, Y, Piece, NewBoard) :-
  nth1(Y, Board, Row),
  replace_nth1(X, Row, Piece, NewRow),
  replace_nth1(Y, Board, NewRow, NewBoard).

% place_pawn(+Board, +X, +Y, +Player, -NewBoard)
% Places a pawn of the given player on the Board, if possible, at the specified X and Y coordinates and returns the resulting NewBoard.
% When cell's not empty, prints a feedback message and fails.
place_pawn(Board, X, Y, _Player, _NewBoard) :-
  \+empty_cell(Board, X, Y),
  format('\nCannot place pawn in cell [~w,~w]!\n', [X, Y]), !, fail.

% When cell's empty, checks if the number of pieces of the given player in the board is under the limit. If not, prints a feedback message and fails.
place_pawn(Board, X, Y, Player, _NewBoard) :-
  empty_cell(Board, X, Y),
  length(Board, Size),
  player_char(Player, Char),
  \+under_piece_limit(Board, Size, Char), !,
  write('\nCannot place pawn! Limit of pawns reached!\n'),
  fail.

% When cell's empty and the number of pieces of the given player in the board is under the limit, places the pawn and returns the resulting NewBoard.
place_pawn(Board, X, Y, Player, NewBoard) :-
  empty_cell(Board, X, Y),
  length(Board, Size),
  player_char(Player, Char),
  under_piece_limit(Board, Size, Char),
  place_tower(Board, X, Y, [Char], NewBoard).


% ================================= CHECKING =================================
%under_piece_limit(+Board, +Size, +Char)
%Checks if the number of pieces of type Char in Board is under the limit for the given board size.
under_piece_limit(Board, Size, Char):-
  board_pieces(Size, NPieces),
  count_pieces(Board, Char, Count), !,
  Count < NPieces.

% count_pieces(+Board, +Piece, -Count)
% Counts the number of occurrences of Piece in Board.
count_pieces(Board, Piece, Count) :-
  flatten(Board, FlatBoard),
  count(Piece, FlatBoard, Count).

% count(+Element, +List, -Count)
% Counts the number of occurrences of Element in List.
count(_, [], 0).
count(X, [X|T], Count) :-
  count(X, T, Count1),
  Count is Count1 + 1.
count(X, [Y|T], Count) :-
  X \= Y,
  count(X, T, Count).

% check_possible_tower(+Board, +Player, +NewX, +NewY, +L, +Top)
% Checks if the tower at (NewX, NewY) can be built by the given player.
check_possible_tower(Board, Player, NewX, NewY, L, Top):-
  get_tower(Board, NewX, NewY, Tower),
  length(Tower, L1),
  L2 is L1+L,
  (L2 >= 6 ->
    top_to_player(Top, Player);
    L2 < 6
  ).
  
% ================================= VALID MOVES =================================

% valid_moves(+Board, +Player, +X, +Y, -ListOfMoves)
% Calculates all the valid moves for the tower at position (X, Y) for the given player.
valid_moves(Board, Player, X, Y, ListOfMoves) :-
  get_tower(Board, X, Y, Tower),
  \+ empty_cell(Board, X, Y),
  findall([NewX, NewY], (
      valid_move(Board, Player, X, Y, NewX, NewY, Tower)
  ), ValidMoves),
  sort(ValidMoves, ListOfMoves).

% valid_moves(+Board, +Player, +X, +Y, -ListOfMoves, +NPieces)
% Calculates all the valid moves for the separating NPieces from the tower at position (X, Y) for the given player.
valid_moves(Board, Player, X, Y, ListOfMoves, NPieces) :-
  get_tower(Board, X, Y, Tower),
  \+ empty_cell(Board, X, Y),
  findall([NewX, NewY], (
      valid_move(Board, Player, X, Y, NewX, NewY, Tower, NPieces)
  ), ValidMoves),
  sort(ValidMoves, ListOfMoves).
  
% valid_move(+Board, +Player, +X, +Y, +NewX, +NewY, +Tower)
% Checks if the move from (X, Y) to (NewX, NewY) is valid for the given piece and player.
valid_move(Board, Player, X, Y, NewX, NewY, Tower) :-
  inside_board(Board, NewX, NewY),
  \+ empty_cell(Board, NewX, NewY),
  length(Tower, L),
  valid_piece_movement(Board, X, Y, NewX, NewY, L),
  tower_top(Tower, Top),
  check_possible_tower(Board, Player, NewX, NewY, L, Top).

valid_move(Board, Player, X, Y, NewX, NewY, Tower, NPieces) :-
  inside_board(Board, NewX, NewY),
  \+ empty_cell(Board, NewX, NewY),
  length(Tower, L),
  valid_piece_movement(Board, X, Y, NewX, NewY, L),
  tower_top(Tower, Top),
  check_possible_tower(Board, Player, NewX, NewY, NPieces, Top).

% valid_piece_movement(+Board, +X, +Y, -NewX, -NewY, +TowerHeight)
% Returns the coordinates (NewX, NewY) of a valid move for the piece at (X, Y) with the given height.
% Pawn - can move 1 cell horizontally or vertically
valid_piece_movement(_, X, Y, NewX, NewY, 1) :-
  (X =:= NewX; Y =:= NewY),
  (X =:= NewX + 1; X =:= NewX - 1; Y =:= NewY + 1; Y =:= NewY - 1).

% Rook - can move any number of cells horizontally or vertically, until it reaches another piece. Can only move to cells that are not empty.
valid_piece_movement(Board, X, Y, NewX, NewY, 2) :-
  X = NewX,
  vertical_up(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 2) :-
  X = NewX,
  vertical_down(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 2) :-
  Y = NewY,
  horizontal_left(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 2) :-
  Y = NewY,
  horizontal_right(Board, X, Y, NewX, NewY).

% Knight - can move 2 cells horizontally or vertically and then 1 cell in the other direction
valid_piece_movement(_, X, Y, NewX, NewY, 3) :-
  (abs(X - NewX) =:= 2, abs(Y - NewY) =:= 1 ; abs(X - NewX) =:= 1, abs(Y - NewY) =:= 2).

% Bishop - can move any number of cells diagonally, until it reaches another piece. Can only move to cells that are not empty.
valid_piece_movement(Board, X, Y, NewX, NewY, 4) :-
  up_right(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 4) :-
  up_left(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 4) :-
  down_right(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 4) :-
  down_left(Board, X, Y, NewX, NewY).

% Queen - can move any number of cells horizontally, vertically or diagonally, until it reaches another piece. Can only move to cells that are not empty.
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  X = NewX,
  vertical_up(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  X = NewX,
  vertical_down(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  Y = NewY,
  horizontal_left(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  Y = NewY,
  horizontal_right(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  up_right(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  up_left(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  down_right(Board, X, Y, NewX, NewY).
valid_piece_movement(Board, X, Y, NewX, NewY, 5) :-
  down_left(Board, X, Y, NewX, NewY).

% vertical_up(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the vertical line from (X, Y) to (X, 1)
vertical_up(Board, X, Y, OccupiedX, OccupiedY) :-
  Z is Y - 1,
  between_rev(1, Z, Y1),
  \+ empty_cell(Board, X, Y1), !,
  OccupiedX = X,
  OccupiedY = Y1. 

% vertical_down(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the vertical line from (X, Y) to (X, Size)
vertical_down(Board, X, Y, OccupiedX, OccupiedY) :-
  length(Board, Size),
  Z is Y + 1,
  between(Z, Size, Y1), 
  \+ empty_cell(Board, X, Y1), !,
  OccupiedX = X,
  OccupiedY = Y1. 

% horizontal_left(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the horizontal line from (X, Y) to (1, Y)
horizontal_left(Board, X, Y, OccupiedX, OccupiedY) :-
  Z is X - 1,
  between_rev(1, Z, X1),
  \+ empty_cell(Board, X1, Y), !,
  OccupiedX = X1,
  OccupiedY = Y. 
  
% horizontal_right(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the horizontal line from (X, Y) to (Size, Y)
horizontal_right(Board, X, Y, OccupiedX, OccupiedY) :-
  length(Board, Size),
  Z is X + 1,
  between(Z, Size, X1),
  \+ empty_cell(Board, X1, Y), !,
  OccupiedX = X1,
  OccupiedY = Y.

% up_right(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the diagonal line from (X, Y) to the top right corner
up_right(Board, X, Y, OccupiedX, OccupiedY) :-
  length(Board, Size),
  X1 is X + 1, X1 =< Size,
  Y1 is Y - 1, Y1 >= 1,
  (empty_cell(Board, X1, Y1) ->
    up_right(Board, X1, Y1, OccupiedX, OccupiedY);
    OccupiedX is X1,
    OccupiedY is Y1, !
  ).

% up_left(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the diagonal line from (X, Y) to the top left corner
up_left(Board, X, Y, OccupiedX, OccupiedY) :-
  X1 is X - 1, X1 >= 1,
  Y1 is Y - 1, Y1 >= 1,
  (empty_cell(Board, X1, Y1) ->
    up_left(Board, X1, Y1, OccupiedX, OccupiedY);
    OccupiedX is X1,
    OccupiedY is Y1, !
  ).

% down_right(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the diagonal line from (X, Y) to the bottom right corner
down_right(Board, X, Y, OccupiedX, OccupiedY) :-
  length(Board, Size),
  X1 is X + 1, X1 =< Size,
  Y1 is Y + 1, Y1 =< Size,
  (empty_cell(Board, X1, Y1) ->
    down_right(Board, X1, Y1, OccupiedX, OccupiedY);
    OccupiedX is X1,
    OccupiedY is Y1, !
  ).

% down_left(+Board, +X, +Y, -OccupiedX, -OccupiedY)
% Checks if there are any occupied cells in the diagonal line from (X, Y) to the bottom left corner
down_left(Board, X, Y, OccupiedX, OccupiedY) :-
  length(Board, Size),
  X1 is X - 1, X1 >= 1,
  Y1 is Y + 1, Y1 =< Size,
  (empty_cell(Board, X1, Y1) ->
    down_left(Board, X1, Y1, OccupiedX, OccupiedY);
    OccupiedX is X1,
    OccupiedY is Y1, !
  ).

% check_winner(+Board, -Top)
% Iterates through the board and returns the top piece of the first tower with more than 6 pieces.
check_winner(Board, Top):-
  length(Board, Rows),
  between(1, Rows, Row),
  nth1(Row, Board, RowList),
  length(RowList, Cols),
  between(1, Cols, Col),
  nth1(Col, RowList, Tower),
  Tower \= empty,
  length(Tower, L),
  L >= 6,
  tower_top(Tower, Top).
