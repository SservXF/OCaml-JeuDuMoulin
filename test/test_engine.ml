open Mill.Engine
open Utils


let test_place_piece =
    let open QCheck in
    Test.make ~name:"place_piece" ~count:1000 (triple arbitrary_color small_int small_int) (fun (color, x, y) ->
        let i = x mod 9 in
        let j = y mod 9 in
        let coord = (i, j) in
        let game_update = init_game_update Nine_mens_morris in
        if get_square (get_board game_update) (i, j) == Some Empty
        then
          let newGU = apply game_update (get_player game_update color) (Placing coord) in
          get_square (get_board newGU) coord = Some (Color color)
        else true)

let test_mill =
    let open QCheck in
    Test.make ~name:"mill" ~count:1000 (pair arbitrary_color arbitrary_templates) (fun (color, template) ->
        let board = fill_all_node template color in
        let flat = board_flatten board in
        let rec loop list acc x =
            match list with
            | [] -> acc
            | y :: ys -> (
                match y with
                | Color c when c = color ->
                    let j = x mod board_length board in
                    let i = x / board_length board in
                    let coord = (i, j) in
                    loop ys (acc && check_mill_from_position board coord color) (x + 1)
                | _ -> loop ys acc (x + 1))
        in
        loop flat true 0)

let check_mill_from_position_property =
    QCheck.Test.make arbitrary_triple_template_coordinates_color ~name:"check_mill_from_position" ~count:1000
      (fun (template, (i, j), color) ->
        let board = fill_template_with_colors template in
        let result = check_mill_from_position board (i, j) color in
        (* Properties *)
        QCheck.assume (i >= 0 && j >= 0 && i < board_length board && j < board_length board);
        (if result
         then
           (* Property 1: If a mill is detected, there must be at least 3 pieces in a row/column/diagonal *)
           let count_pieces d =
               (* Count pieces in a certain direction *)
               let rec count_from_dir (x, y) d =
                   match node_from_direction board (x, y) d with
                   | Some (a, b) ->
                       if get_square board (a, b) = Some (Color color) then 1 + count_from_dir (a, b) d else 0
                   | _ -> 0
               in
               let reverse_direction : direction_deplacement -> direction_deplacement = function
                   | Up -> Down
                   | Down -> Up
                   | Right -> Left
                   | Left -> Right
                   | Up_right -> Down_left
                   | Up_left -> Down_right
                   | Down_right -> Up_left
                   | Down_left -> Up_right
               in
               count_from_dir (i, j) d + count_from_dir (i, j) (reverse_direction d) + 1
           in
           QCheck.assume
             (count_pieces Right >= 3
             || count_pieces Down >= 3
             || count_pieces Up_right >= 3
             || count_pieces Down_left >= 3
             || count_pieces Up_left >= 3
             || count_pieces Down_right >= 3));
        (* Add more properties as needed *)
        true)

let place_start_piece_test =
    QCheck.Test.make ~name:"place_start_piece" ~count:1000 arbitrary_templates (fun template ->
        let game_update = init_game_update template in
        let initial_player = get_player_1 game_update in
        let coordinates = (Random.int 10, Random.int 10) in
        let updated_game = apply game_update initial_player (Placing coordinates) in

        let expected_piece_placed =
            if get_square (get_board game_update) (fst coordinates, snd coordinates) = Some Empty
               && initial_player.piece_placed < get_max_pieces game_update
            then initial_player.piece_placed + 1
            else initial_player.piece_placed
        in
        let expected_nb_pieces_on_board =
            if get_square (get_board game_update) (fst coordinates, snd coordinates) = Some Empty
               && initial_player.piece_placed < get_max_pieces game_update
            then initial_player.nb_pieces_on_board + 1
            else initial_player.nb_pieces_on_board
        in
        let expected_bag =
            if get_square (get_board game_update) (fst coordinates, snd coordinates) = Some Empty
               && initial_player.piece_placed < get_max_pieces game_update
            then initial_player.bag @ [coordinates]
            else initial_player.bag
        in
        let () =
            Alcotest.(check bool)
              "Piece placed incremented"
              (expected_piece_placed = (get_player_1 updated_game).piece_placed)
              true
        in
        let () =
            Alcotest.(check bool)
              "Number of pieces on board incremented"
              (expected_nb_pieces_on_board = (get_player_1 updated_game).nb_pieces_on_board)
              true
        in
        let () =
            Alcotest.(check (list (pair int int))) "Piece added to bag" expected_bag (get_player_1 updated_game).bag
        in
        let () =
            Alcotest.(check bool)
              "Player have a finite number of pieces"
              (expected_piece_placed <= get_max_pieces game_update)
              true
        in

        true)

let test_place_exceed_max_pieces =
    let open QCheck in
    Test.make ~name:"place_start_piece" ~count:1000 (pair small_int small_int) (fun (x, y) ->
        let i = x mod 9 in
        let j = y mod 9 in
        let coord = (i, j) in
        let initial_game_state = init_game_update Nine_mens_morris in

        (* try to place a piece for the player *)
        let updated_game_state = apply initial_game_state (get_player_1 initial_game_state) (Placing coord) in

        (* check if the piece is placed or not *)
        if get_board_is_changed updated_game_state
        then
          (get_player_1 updated_game_state).piece_placed = (get_player_1 initial_game_state).piece_placed + 1
          && (get_player_1 updated_game_state).piece_placed <= max_piece_from_template Nine_mens_morris
        else (get_player_1 initial_game_state).piece_placed = (get_player_1 updated_game_state).piece_placed)




let gen_template =
    let open QCheck in
    make (
    Gen.oneof [
        Gen.return Three_mens_morris;
        Gen.return Six_mens_morris;
        Gen.return Nine_mens_morris;
        Gen.return Twelve_mens_morris;
    ])


      
let test_template_property =
let open QCheck in
Test.make ~name:"Test template property" ~count:50 gen_template (fun template ->
    let game_update = init_game_update template in
        let expected_empty_cells = match template with
            | Three_mens_morris -> 9
            | Six_mens_morris -> 16
            | Nine_mens_morris -> 24
            | Twelve_mens_morris -> 24
          in
          List.length (get_all_free_positions game_update) = expected_empty_cells
        )


          

let () =
    let open Alcotest in
    run "TEST ENGINE"
      [
        ("Test place piece", [QCheck_alcotest.to_alcotest test_place_piece]);
        ("Test mill", [QCheck_alcotest.to_alcotest test_mill]);
        ("Test mill from position", [QCheck_alcotest.to_alcotest check_mill_from_position_property]);
        ("Test place start piece", [QCheck_alcotest.to_alcotest place_start_piece_test]);
        ("Test place more than max piece", [QCheck_alcotest.to_alcotest test_place_exceed_max_pieces]);
        ("Test template property", [QCheck_alcotest.to_alcotest test_template_property]);
      ]
