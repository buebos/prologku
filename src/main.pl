:- use_module(library(clpfd)).
:- use_module(templates).

/*----------------------------------------------------------------
    Sudoku solver predicates
------------------------------------------------------------------*/

solve_sudoku(Rows) :-
    % Validate length of rows and columns
	length(Rows, 9),
    maplist(same_length(Rows), Rows),

    % Validate elements within 1 to 9
	append(Rows, Vs),
    Vs ins 1..9,

    % Validate all distinct elements within same row
	maplist(all_distinct, Rows),

    % Transpose the sudoku to be able to apply the all_distinct
    % predicate in an easy way
	transpose(Rows, Columns),
    % Validate all distinct elements within same column
    maplist(all_distinct, Columns),

    % Validate each block on a 3 by 3 basis due to the
    % block size 
	Rows = [As,Bs,Cs,Ds,Es,Fs,Gs,Hs,Is],
	validate_blocks(As, Bs, Cs), validate_blocks(Ds, Es, Fs), validate_blocks(Gs, Hs, Is),

    % With the given rules above, the label predicate will fill
    % the values within the rows that match them. This part is where
    % the back tracking and iteration will be done until the sudoku
    % is finished
	maplist(label, Rows),

    % Formats the output of each solution to print a
    % row per line.
    maplist(portray_clause, Rows).

validate_blocks([], [], []).
validate_blocks([N1,N2,N3|Ns1], [N4,N5,N6|Ns2], [N7,N8,N9|Ns3]) :-
	all_distinct([N1,N2,N3,N4,N5,N6,N7,N8,N9]),
	validate_blocks(Ns1, Ns2, Ns3).

/*----------------------------------------------------------------
    Sudoku print predicate helpers
------------------------------------------------------------------*/

print_sudoku_element(Element):-
    (number(Element) 
        -> write(Element), !;
        write("_")),
    write(" | ").
print_sudoku_separator(_) :-
    write("__|_").

print_sudoku_row(Row):-
    maplist(print_sudoku_separator, Row),
    write("\n"),
    maplist(print_sudoku_element, Row),
    write("\n").

print_sudoku(Rows) :-
    maplist(print_sudoku_row, Rows),
    write("\n").

/*----------------------------------------------------------------
    Empty sudoku template
------------------------------------------------------------------*/

empty_template(Rows):-
        Rows = [
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_],
        
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_],
        
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_],
            [_,_,_, _,_,_, _,_,_]
        ].

/*----------------------------------------------------------------
    Replace predicate helper to handle the input and replace
    the corresponding cell in the sudoku
------------------------------------------------------------------*/

replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 1, 
    NI is I-1, 
    replace(T, NI, X, R), !.

/*----------------------------------------------------------------
    Displays the menu to capture all inputs from the user and
    modify the template
------------------------------------------------------------------*/

menu_read_inputs(Rows) :-
    write('[INPUT]: Ingresa ("resolver" | FILA,COLUMNA,VALOR): '),
    read_line_to_codes(user_input, Input),
    string_codes(StrInput, Input),
    (StrInput == "resolver" -> !;
        atomic_list_concat(Entradas, ',', StrInput), %divide las entradas
        maplist(atom_number, Entradas, [Fila,Columna,Valor]), %los convierte en numeros y almacena en la lista Entradas
        nth1(Fila, Rows, Row), %obtiene la posicion (Fila) de la plantilla (Rows) y la guarda en row
        nth1(Columna, Row, _), %se posiciona en la Columna de la Fila (Row)
        replace(Row, Columna, Valor, NewRow), 
        replace(Rows, Fila, NewRow, NewRows),
        writeln("[INFO]: Plantilla actual:"),
        print_sudoku(NewRows),
        Rows = NewRows,
        menu_read_inputs(NewRows)). 
        
/*----------------------------------------------------------------
    Entry point for the program
------------------------------------------------------------------*/

main(Rows):-
	writeln("--------- PROLOGKU ---------"),
    empty_template(Rows),
    writeln("[INFO]: Bienvenido al solucionador de sudoku!"),
    writeln("[INFO]: Plantilla actual:"),
    print_sudoku(Rows),

    writeln('\n[INFO]: Para modificar alguna celda de la plantilla original escribe los datos en el siguiente formato: FILA,COLUMNA,VALOR'),
    writeln('[INFO]: Para pasar a las soluciones de la plantilla de sudoku escribe: "resolver"'),

    menu_read_inputs(Rows),

    writeln('[INFO] Los resultados son los siguientes, presiona ";" para ver el siguiente resultado y "Enter" para terminar el programa:'),

    solve_sudoku(Rows).
