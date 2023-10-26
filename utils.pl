:- use_module(library(lists)).

:- dynamic difficulty/2.

:- dynamic name_of/2.

% name_of(Player, Name) :-
%     retract(name_of(Player, _)),
%     string_codes(NameStr, Name),
%     asserta(name_of(Player, NameStr)).

% === GAME RELATED ===

change_player(player1, NewPlayer) :-
    NewPlayer = player2.
change_player(player2, NewPlayer) :-
    NewPlayer = player1.

% other_player(+CurrentPlayer,-NextPlayer)
% Change player turn
other_player(player1, player2).
other_player(player2, player1).

% get_name(+Player)
% Asks player name. Dynamically adds the name_of/2 fact to the base fact
get_name(Player) :-
    format('Hello ~a, what is your name? ', [Player]),
    read_line(Codes),
    atom_codes(Name, Codes),
    asserta(name_of(Player, Name)).


print_heart :-
    write('  /\\  /\\  '), nl,
    write(' /  \\/  \\ '), nl,
    write(' \\      / '), nl,
    write('  \\    /  '), nl,
    write('   \\  /   '), nl,
    write('    \\/    ').

chess_pieces :-
    write(' K  Q  R  B  N  P'), nl,
    write(' k  q  r  b  n  p').
    
% init_random_state/0
% Initialize the random module
init_random_state :-
    now(X),
    setrand(X).

% get_option(+Min,+Max,+Context,-Value)
% Unifies Value with the value given by user input between Min and Max when asked about Context
choose_number(Min,Max,Context,Value):-
    format('~a between ~d and ~d: ', [Context, Min, Max]),
    repeat,
    read_number(Value),
    between(Min, Max, Value), !.


% read_number(-Number)
% Unifies Number with input number from console
read_number(X):-
    read_number_aux(X,0).
read_number_aux(X,Acc):- 
    get_code(C),
    between(48, 57, C), !,
    Acc1 is 10*Acc + (C - 48),
    read_number_aux(X,Acc1).
read_number_aux(X,X).



% === GUI ===

% split_list(+List, -Part1, +Part2Length, -Part2)
% Splits a list into two parts, Part1 and Part2, where Part2 has length Part2Length
split_list(List, Part1, Part2Length, Part2) :-
    length(Part1, N),
    length(Part2, Part2Length),
    append(Part1, Part2, List),
    length(List, ListLength),
    ListLength =:= N + Part2Length.

% !DELETE: apenas para testes
test_split_list :-
    split_list([1,2,3,4,5,6,7,8,9], Part1, 3, Part2),
    write('Part1: '), write(Part1), nl,
    write('Part2: '), write(Part2), nl.

% print_list(+List)
% Prints the elements of List to the console in the format "1 - Element1"
print_list(List) :-
    print_list(List, 1).

% print_list(+List, +Index)
% Prints the elements of List to the console in the format "Index - Element"
print_list([], _).
print_list([H|T], Index) :-
    write(Index), write(' - '), write(H), nl,
    NewIndex is Index + 1,
    print_list(T, NewIndex).
  
tower_top(Tower, Top) :-
  last(Tower, Top).

  % Convert lowercase atom to uppercase atom
lowercase_to_uppercase(LowercaseAtom, UppercaseAtom) :-
  atom_chars(LowercaseAtom, [LowercaseChar]),
  char_code(LowercaseChar, LowercaseCode),
  UppercaseCode is LowercaseCode - 32,
  char_code(UppercaseChar, UppercaseCode),
  atom_chars(UppercaseAtom, [UppercaseChar]).


% ================== CLEARING ==================


% clear_data/0
% removes all waters, names and difficul from the fact base for the next game
clear_data :-
    retractall(difficulty(_, _)),
    retractall(name_of(_, _)).

% clear_console/0
% Clears the console
clear_console :-
    write('\33\[2J').
