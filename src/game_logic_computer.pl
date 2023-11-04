
% A move is of this type [MoveFlag, Player, X, Y, NewX, NewY, NPieces]

% get_moves_by_type(+Board, +Player, -Moves, +MoveType)
% Gets all the moves of type 1 (place pawn) for a given player and board.
get_moves_by_type(Board, Player, Moves, 1) :-
    findall([1, Player, 0, 0, NewX, NewY, -1], empty_cell(Board, NewX, NewY), Moves).


% !DELETE
test_get_moves_by_type :-
  Board = [
    [[x,o], [x], empty, empty, [x,o,o,x,o]],
    [empty, empty, [x,o,x], empty, [o]],
    [empty, empty, empty, empty, empty],
    [[o,o], empty, empty, [x,x,x], empty],
    [empty, empty, empty, empty, empty]
],
  get_moves_by_type(Board, player1, Moves, 1),
  length(Moves, L),
  write('HERE Length: '), write(L), nl,
  write(Moves).
    
% Gets all the moves of type 2 (move tower) for a given player and board.
get_moves_by_type(Board, Player, Moves, 2) :-
    length(Board, Size),
    findall([2, Player, X, Y, NewX, NewY, -1], (
      %iterate through all the cells of the board
      between(1, Size, Row),
      nth1(Row, Board, RowList),
      between(1, Size, Col),
      nth1(Col, RowList, Cell),
      %if the cell is a tower, find all the valid moves for that tower
      \+ empty_cell(Board, Row, Col),
      X is Row, Y is Col,
      % write('X: '), write(X), write(' Y: '), write(Y), nl,
      valid_moves(Board, Player, Row, Col, ListOfMoves),
      % write('HERE Moves of type 2: '), write(ListOfMoves), nl,
      member([NewX, NewY], ListOfMoves)
      
      ), Moves).

% !DELETE
test_get_moves_by_type :-
  Board = [
    [[x,o], [x], empty, empty, [x,o,o,x,o]],
    [empty, empty, [x,o,x], empty, [o]],
    [empty, empty, empty, empty, empty],
    [[o,o], empty, empty, [x,x,x], empty],
    [empty, empty, empty, empty, empty]
],
  get_moves_by_type(Board, player2, Moves, 2),
  length(Moves, L),
  write('HERE Length: '), write(L), nl,
  write(Moves).


% Gets all the moves of type 3 (separate tower) for a given player and board.
get_moves_by_type(Board, Player, Moves, 3) :-
    length(Board, Size),
    findall([3, Player, X, Y, NewX, NewY, NPieces], (
      between(1, Size, Row),
      nth1(Row, Board, RowList),
      between(1, Size, Col),
      nth1(Col, RowList, Cell),
      check_if_tower_exists(Board, Row, Col, L),
      L1 is L-1,
      between(1, L1, NPieces),
      X is Row, Y is Col,
      valid_moves(Board, Player, Row, Col, ListOfMoves, NPieces),
      member([NewX, NewY], ListOfMoves)
      ), Moves).


% !DELETE
test_get_moves_by_type :-
  Board = [
    [[x,o], [x], empty, empty, [x,o,o,x,o]],
    [empty, empty, [x,o,x], empty, [o]],
    [empty, empty, empty, empty, empty],
    [[o,o], empty, empty, [x,x,x], empty],
    [empty, empty, empty, empty, empty]
  ],
  % valid_moves(Board, player1, 2, 1, ListOfMovesMoves),
  % write('HERE list: '), write(ListOfMovesMoves), nl,
  get_moves_by_type(Board, player2, Moves, 3),
  length(Moves, L),
  write('HERE Length: '), write(L), nl,
  write(Moves).


% get_all_moves(+Board, +Player, -Moves)
% Gets all the moves from each type for a given player and board.
get_all_moves(Board, Player, Moves) :-
  get_moves_by_type(Board, Player, Moves1, 1),
  get_moves_by_type(Board, Player, Moves2, 2),
  get_moves_by_type(Board, Player, Moves3, 3),
  append(Moves1, Moves2, Moves12),
  append(Moves12, Moves3, Moves).


% !DELETE
test_get_all_moves:-
  Board = [
    [[x,o], [x], empty, empty, [x,o,o,x,o]],
    [empty, empty, [x,o,x], empty, [o]],
    [empty, empty, empty, empty, empty],
    [[o,o], empty, empty, [x,x,x], empty],
    [empty, empty, empty, empty, empty]
  ],
  get_all_moves(Board, player2, Moves),
  length(Moves, L),
  write('HERE Length: '), write(L), nl,
  write(Moves).
 
%======================= MOVES FOR COMPUTER EASY AND HARD ===========================================================================

% move_computer(+GameState, -NewGameState, +Level)
% Gets a move for the computer based on the level of difficulty. In this case, easy level.
move_computer(GameState, NewGameState, 1) :-
  [Board, Player] = GameState,
  write('HERE IN move_computer EASY (implemented)') , nl,
  get_all_moves(Board, Player, Moves),
  write('HERE Moves: '), write(Moves), nl,
  random_member(Move, Moves),
  write('HERE Move: '), write(Move), nl,
  translate_move(Board, Move, NewBoard),
  change_player(Player, NewPlayer),
  NewGameState = [NewBoard, NewPlayer].

/*
%hard mode with minimax
move_computer(GameState, NewGameState, 2) :-
  write('HERE IN move_computer HARD (to implement)') , nl,
  [Board, Player] = GameState,
  get_all_moves(Board, Player, Moves),
  findall(Delta-Board1, (
    member(Move, Moves),
    translate_move(Board, Move, Board1),
    value(Board1, Player, Value1),
    % write('HERE Value1: '), write(Value1), nl,
    second_level(Board1, Player, Value2),
    % write('HERE Value2: '), write(Value2), nl,
    Delta is Value1-Value2
    % write('HERE Delta: '), write(Delta), nl
    ), EvaluatedBoards),
  % write('HERE EvaluatedBoards: '), write(EvaluatedBoards), nl,
  sort(EvaluatedBoards, SortedBoard),
  % write('HERE SortedBoard: '), write(SortedBoard), nl,
  last(SortedBoard, Delta-NewBoard),
  write('HERE Delta: '), write(Delta), nl,
  write('HERE NewBoard: '), write(NewBoard), nl,
  change_player(Player, NewPlayer),
  NewGameState = [NewBoard, NewPlayer].

second_level(Board1, Player, Value2) :-
  change_player(Player, NewPlayer),
  % write('HERE NewPlayer: '), write(NewPlayer), nl,
  get_all_moves(Board1, NewPlayer, Moves2),
  write('HERE Moves2: '), write(Moves2), nl,
  setof(ValueAux, (Move2, Board2)^(
    % write('HERE Before member\n'),
    member(Move2, Moves2),
    write('HERE Move2: '), write(Move2), nl,  
    translate_move(Board1, Move2, Board2), 
    write('HERE Board2: '), write(Board2), nl,
    value(Board2, NewPlayer, ValueAux),
    write('HERE ValueAux: '), write(ValueAux), nl
  ), AuxValues),
  % write('HERE AuxValues: '), write(AuxValues), nl,
  sort(AuxValues, SortedValues),
  last(SortedValues, Value2). 
  % write('HERE BoardAux: '), write(BoardAux), nl.
*/






%

% !DELETE
test_move_computer :-
  Board = [
    [[x,o], [x], empty, empty, empty],
    [empty, empty, empty, empty, empty],
    [empty, empty, [x,x,x], empty, empty],
    [empty, empty, empty, empty, [x,o,o,x,o]],
    [empty, empty, empty, empty, empty]
  ],
  % Board = [
  %   [[x,o], [x], empty, empty, [x,o,o,x,o]],
  %   [empty, empty, [x,o,x], empty, [o]],
  %   [empty, empty, empty, empty, empty],
  %   [[o,o], empty, empty, [x,x,x], empty],
  %   [empty, empty, empty, empty, empty]
  % ],
  GameState = [Board, player1],
  move_computer(GameState, NewGameState, 2),
  % write('HERE NewGameState: '), write(NewGameState), nl,
  [NewBoard, NewPlayer] = NewGameState,
  length(NewBoard, Size),
  display_game(Size, NewBoard).


% Gets a move for the computer based on the level of difficulty. In this case, hard level.
move_computer(GameState, NewGameState, 2) :-
  [Board, Player] = GameState,
  get_all_moves(Board, Player, Moves),
  calculate_value(Board, Player, Moves, List, 2),
  sort(List, SortedList),
  % write('HERE SortedList: '), write(SortedList), nl,
  last(SortedList, Delta-NewBoard),
  % write('HERE Delta: '), write(Delta), nl,
  change_player(Player, NewPlayer),
  NewGameState = [NewBoard, NewPlayer].


calculate_value(Board, Player, Moves, FinalList, Value1, 1) :- 
  calculate_value(Board, Player, Moves, [], FinalList, Value1, 1).

calculate_value(_, _, [], Acc, Acc, _, 1):- !.
calculate_value(Board, Player, Moves, Acc, FinalList, MaxValue, 1) :-
  [CurrMove|T] = Moves,
  translate_move(Board, CurrMove, Board2),
  value(Board2, Player, Value2),
  max_or_min(min, Value2, MinValue),
  Delta is MaxValue + MinValue,
  NewAcc = [Delta | Acc],
  calculate_value(Board, Player, T, NewAcc, FinalList, MaxValue, 1).


% calculate_value(+Board, +Player, +Moves, -FinalList, +Depth)
calculate_value(Board, Player, Moves, FinalList, 2) :- 
  calculate_value(Board, Player, Moves, [], FinalList, 2).

calculate_value(_, _, [], Acc, Acc, 2):- !.
calculate_value(Board, Player, Moves, Acc, FinalList, Depth) :-
  [CurrMove|T] = Moves,
  translate_move(Board, CurrMove, Board1),
  value(Board1, Player, Value1),

  change_player(Player, NewPlayer),
  get_all_moves(Board1, NewPlayer, Moves2),
  \+ Moves2 = [],
  NewDepth is Depth - 1,
  calculate_value(Board1, NewPlayer, Moves2, List2, Value1, NewDepth),
  sort(List2, SortedList2),
  [Delta | _] = SortedList2,
  NewAcc = [Delta-Board1 | Acc],
  calculate_value(Board, Player, T, NewAcc, FinalList, Depth).




max_or_min(min, Value, MinValue):- MinValue is -Value.
max_or_min(max, Value, Value).



%============================ GET BOARD VALUE ======================================================================

% value(+Board, +Player, -Value)
% Calculates the value of a board for a given player. Used for the hard level in computer mode.
% value(Board, Player, Value, min) :-
%   iterate_board(Board, XValue, OValue),
%   (Player == player1 -> TempValue is XValue - OValue; TempValue is OValue - XValue),
%   Value is -TempValue.
value(Board, Player, Value) :-
  iterate_board(Board, XValue, OValue),
  (Player == player1 -> Value is XValue - OValue; Value is OValue - XValue).

% % value(+Board, -Value)
% % !TODO:
% value(Board, Value) :-
%   iterate_board(Board, XValue, OValue),
%   Value is XValue - OValue.


% iterate_board(+Board, -XValue, -OValue)
% Iterates through the board and calculates the value of the board for each player based on tower heights and tops.
iterate_board(Board, FinalXValue, FinalOValue) :-
  RowIndex is 1,
  XValue is 0,
  OValue is 0,
  iterate_rows(Board, RowIndex, XValue, OValue, FinalXValue, FinalOValue).

% iterate_rows(+Board, +RowIndex, +XValue, +OValue, -FinalXValue, -FinalOValue)
% Iterates through the rows of the board and calculates the value of the board for each player based on tower heights and tops. Calls iterate_columns/6.
iterate_rows([], _, XValue, OValue, XValue, OValue).
iterate_rows([Row|Rest], RowIndex, XValue, OValue, FinalXValue, FinalOValue) :-
  iterate_columns(Row, RowIndex, 1, XValue, OValue, NewXValue, NewOValue),
  NextRow is RowIndex + 1,
  iterate_rows(Rest, NextRow, NewXValue, NewOValue, FinalXValue, FinalOValue).

% iterate_columns(+Row, +RowIndex, +ColIndex, +XValue, +OValue, -FinalXValue, -FinalOValue)
% Iterates through the columns of the board and calculates the value of the board for each player based on tower heights and tops, by calling process_cell/7.
iterate_columns([], _, _, XValue, OValue, XValue, OValue).
iterate_columns([Cell|Rest], RowIndex, ColIndex, XValue, OValue, FinalXValue, FinalOValue) :-
  process_cell(Cell, RowIndex, ColIndex, XValue, OValue, NewXValue, NewOValue),
  NextCol is ColIndex + 1,
  iterate_columns(Rest, RowIndex, NextCol, NewXValue, NewOValue, FinalXValue, FinalOValue).

% process_cell(+Cell, +RowIndex, +ColIndex, +XValue, +OValue, -NewXValue, -NewOValue)
% Calculates the value of the board for each player based on tower heights and tops.
process_cell(empty, _, _, XValue, OValue, XValue, OValue).
/*
process_cell(Cell, _, _, XValue, OValue, NewXValue, NewOValue) :-
  % Cell \= empty,
  length(Cell, TowerHeight),
  ( tower_top(Cell, Top), Top == x -> NewXValue is XValue + TowerHeight, NewOValue = OValue ;
                                    NewXValue = XValue, NewOValue is OValue + TowerHeight ).
*/
process_cell(Cell, _, _, XValue, OValue, NewXValue, NewOValue) :-
  length(Cell, TowerHeight),
  tower_top(Cell, Top),
  update_values(Top, TowerHeight, XValue, OValue, NewXValue, NewOValue).
                                    
% update_values(+Top, +TowerHeight, +XValue, +OValue, -NewXValue, -NewOValue)
% Updates the values based on the top of the tower and the tower height. If there is a king, the value is increased by 100.
update_values(x, TowerHeight, XValue, OValue, NewXValue, OValue) :-
  TowerHeight >= 6,
  NewXValue is XValue + (TowerHeight * TowerHeight) + 100.
update_values(x, TowerHeight, XValue, OValue, NewXValue, OValue) :-
  TowerHeight < 6,
  NewXValue is XValue + (TowerHeight * TowerHeight).
update_values(o, TowerHeight, XValue, OValue, XValue, NewOValue) :-
  TowerHeight >= 6,
  NewOValue is OValue + (TowerHeight * TowerHeight) + 100.
update_values(o, TowerHeight, XValue, OValue, XValue, NewOValue) :-
  TowerHeight < 6,
  NewOValue is OValue + (TowerHeight * TowerHeight).



% !DELETE
test_value:-
  Board = [
    [[x,o], [x], empty, empty, [x,o,o,x,o,x]],
    [empty, empty, [x,o,x], empty, [o]],
    [empty, empty, empty, empty, empty],
    [[o,o], empty, empty, [x,x,x], empty],
    [empty, empty, empty, empty, empty]
  ],
  % value(Board, player2, Value),
  value(Board, Value),
  write('HERE Value: '), write(Value), nl.


%=============================== TRANSLATE MOVES INTO BOARDS ===================================================================

% translate_move(+Board, +Move, -NewBoard)
% Translates a move into a board.
% translate_move(Board, Move, NewBoard) :-
%   % write('HERE IN translate_move') , nl,
%   [MoveFlag, Player, X, Y, NewX, NewY, NPieces] = Move,
%   % write('HERE IN translate_move') , nl,
%   (MoveFlag =:= 1 ->
%     % write('HERE MOVE TYPE 1'), nl,
%     place_pawn(Board, NewX, NewY, Player, NewBoard);
%   MoveFlag =:= 2 ->
%     % write('HERE MOVE TYPE 2'), nl,
%     % translate_move_2(Board, Player, X, Y, NewX, NewY, NewBoard);
%     move_tower(Board, X, Y, NewX, NewY, NewBoard);
%   MoveFlag =:= 3 ->
%     % write('HERE MOVE TYPE 3'), nl,
%     % translate_move_3(Board, Player, X, Y, NewX, NewY, NPieces, NewBoard)
%     separate_tower(Board, X, Y, NewX, NewY, NPieces, NewBoard)
%   ).

% translate_move(+Board, +Move, -NewBoard)
% Translates a move into a board, depending on the move type:
% Moves of type 1 (place pawn).
translate_move(Board, [1, Player, X, Y, NewX, NewY, NPieces], NewBoard) :-
    place_pawn(Board, NewX, NewY, Player, NewBoard).
% Moves of type 2 (move tower).
translate_move(Board, [2, Player, X, Y, NewX, NewY, NPieces], NewBoard) :-
    move_tower(Board, X, Y, NewX, NewY, NewBoard).
% Moves of type 3 (separate tower).
translate_move(Board, [3, Player, X, Y, NewX, NewY, NPieces], NewBoard) :-
    separate_tower(Board, X, Y, NewX, NewY, NPieces, NewBoard).

test_translate_move :-
  Board = [
    [[x,o], [x], empty, empty, empty],
    [empty, empty, empty, empty, empty],
    [empty, empty, [x,x], empty, empty],
    [[o,o], empty, empty, empty, empty],
    [empty, empty, empty, empty, empty]
  ],
  translate_move(Board, [3, player1, 1, 1, 2, 1, 2], NewBoard),
  length(NewBoard, Size),
  display_game(Size, NewBoard).