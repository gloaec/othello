(** Othello application using Minimax Alpha Beta algorithm to compute the moves of the artificial intelligence. *)
(** Authors: Ghislain Loaec - Abjel Djalil Ramoul *)
(*******************************************************************)

(** Définition de la largeur des cellules en pixels *)
let cell_size = ref 75 
(** Défaut: 75 *)

(** Niveau de rouge de couleur du fond: [0:255] *)
let bg_r = ref 50
(** Défaut: 50 *)

(** Niveau de vert de couleur du fond : [0:255] *)
let bg_g = ref 150
(** Défaut: 150 *)

(** Niveau de bleu de couleur du fond : [0:255] *)
let bg_b = ref 50
(** Défaut: 50 *)

(** Nombre de cases qui constitue l'arrête du plateau de jeu *)
let size = ref 8
(** Défaut: 8 *)

(** Utilisation ou non de l'intelligence artificielle *)
let ia = ref true
(** Défaut: true (Activée) *)

(** Profondeur d'exploration de l'arbre de coups légaux *)
let depth = ref 4
(** Défaut: 4 *)

(** Valeurs possibles d'une case *)
type cell = 
| White (** Jeton blanc *)
| Black (** Jeton noir *)
| Empty (** Case vide *)


(** Matrice représentative du tablier : tableau de cases à 2 dimensions *)
type board = (cell array) array

(** Représentation d'un position par ses coordonnées *)
type coord = (int * int)

(** Liste représentative de positions *)
type coord_list = coord list

(** Méthode de construction du plateau *)
let make_board = Array.make_matrix !size !size Empty ;;
(** Retourne un tablier de case vides *)

(** Méthode de copie d'un état du tablier *)
let copy_board board = 
Array.init !size (fun y ->
  Array.init !size (fun x -> board.(y).(x)) (** Création d'un nouvelle référence avec la valeur de la case *)
)
(** Retrourne une matrice avec les références des nouvelles case *)

(** Méthode d'initialisation des positions des jetons lors d'une nouvelle partie  *)
let init_board = 
  let board = make_board in
    board.((Array.length board) / 2 - 1).((Array.length board) / 2 - 1) <- White; (** 1ier jeton Blanc *) 
    board.((Array.length board) / 2 + 0).((Array.length board) / 2 + 0) <- White; (** 2nd jeton Blanc *)
    board.((Array.length board) / 2 + 0).((Array.length board) / 2 - 1) <- Black; (** 1ier jeton Noir *)
    board.((Array.length board) / 2 - 1).((Array.length board) / 2 + 0) <- Black; (** 2nd jeton Noir *)
  board
;;
(** Retourne un tablier avec 4 jetons positionés sur les cases D4 E4 D5 E5 *)

(** Méthode d'affichage d'une case *)
let display_cell board x y =
	
  (** Construction d'un carré de couleur *)	
  Graphics.set_color (Graphics.rgb !bg_r !bg_g !bg_b);
  Graphics.fill_rect
  (y * !cell_size + 1)
  (x * !cell_size + 1)
  (!cell_size - 2)
  (!cell_size - 2);

  (** Construction de la bordure du carré *)	
  Graphics.set_color (Graphics.rgb 0 70 0);
  Graphics.draw_rect 
  (y * !cell_size)
  (x * !cell_size) 
  (y + !cell_size - y) 
  (x + !cell_size - x);

  (** Définition de la couleur du jeton sur la case *)
  Graphics.set_color 
  (
	match board.(y).(x) with 
    | Black -> Graphics.black
    | _ 	-> Graphics.white
  );

  (** Construction du jeton si la case n'est pas vide *)
  if (not (board.(y).(x) = Empty)) then
  (
	(** Construction d'un cercle de couleur éxtérieur *)
    Graphics.fill_circle
    (y * !cell_size + !cell_size/2) 
    (x * !cell_size + !cell_size/2) 
    (!cell_size / 2 - 2);

	(** Construction de la bordure du cercle *)
    Graphics.set_color (Graphics.rgb 100 100 100);
    Graphics.draw_circle 
    (y * !cell_size + !cell_size/2) 
    (x * !cell_size + !cell_size/2) 
    (!cell_size / 2 - 2);    

  	(** Définition de la couleur du jeton sur la case *)
	Graphics.set_color 
	  (
		match board.(y).(x) with 
	    | Black -> Graphics.rgb 50 50 50
	    | _ 	-> Graphics.rgb 200 200 200
	  );

	(** Construction d'un cercle de couleur intérieur *)
    Graphics.fill_circle
    (y * !cell_size + !cell_size/2) 
    (x * !cell_size + !cell_size/2) 
    (!cell_size / 2 - 5);

	(* Construction de la bordure du cercle *)
    Graphics.set_color (Graphics.rgb 100 100 100);
    Graphics.draw_circle 
    (y * !cell_size + !cell_size/2) 
    (x * !cell_size + !cell_size/2) 
    (!cell_size / 2 - 5);
  )
;;

(** Méthode d'affichage du plateau de jeu *)
let display_board board =
  Graphics.open_graph
  (
	Printf.sprintf
    " %dx%d"
    (!cell_size * Array.length board.(0)+1)
    (45 + !cell_size * Array.length board.(0))
  );

  (** Affichage de la zone supérieure *)
  Graphics.set_color (Graphics.rgb 145 80 30);
  Graphics.fill_rect
  0
  (Graphics.size_y()-45)
  (Graphics.size_x())
  (Graphics.size_y());
  
  (** Affichage des cases de jeu *)
  for i=0 to Array.length board-1 do	
  	for j=0 to Array.length board.(i)-1 do
  	  display_cell board i j;
	done;
  done;
;;

(** Méthode d'affichage des messages *)
let display_message message =
  Graphics.moveto 5 (Graphics.size_y()-18);
  Graphics.set_color Graphics.white;
  let iastring = match !ia with
  | true -> "AI: Enabled (Depth=" ^ string_of_int !depth ^ ") "
  | _ -> "AI: Disabled - "
  in  Graphics.draw_string (iastring ^ message)
;;

(** Méthode pour compter le nombre de jeton d'une couleur donnée sur un état donné *)
let count board c = 
  let res = ref 0 in
    for i = 0 to (Array.length board) - 1 do
      for j = 0 to (Array.length board.(0)) - 1 do
        if board.(i).(j) = c then res := succ !res;
      done;
    done;
    !res
;;

(** Méthode de test de fin de partie *)
let is_finished board = 
  let finished = ref true in
  for i=0 to Array.length board-1 do
    for j=0 to Array.length board.(i)-1 do
      if board.(j).(i) = Empty then finished := false; (* Jeu en cours si au moins une case de vide *)
    done;
   done;
  !finished || (count board White = 0) || (count board Black = 0)
;;

(** Methode de test de position => Vrai si sur le plateau *)
let check_pos board x y =
  x >= 0 && 
  y >= 0 && 
  y < Array.length board && 
  x < Array.length board.(0)
;;

(** Methode de recupération de la couleur de l'adversaire *)
let get_opponent c =
  match c with
  | White -> Black
  | _ -> White
;;

(** Methode de test de direction légal => Vrai si la direction est légale *)
let playable_dir board c (x, y) (dx, dy) =
  let rec playable_dir_rec (x, y) valid = 
    if not (check_pos board x y) then 				(* Test si la position est sur le plateau *)
      false											  (* Hors du plateau => direction non autorisée *)
    else (
      match board.(x).(y) with						(* Test de valeur de la case *)
        | Empty -> false							  (* Case Vide => direction non autorisée *)
        | cell ->
          if cell = (get_opponent c) then 			  (* Test si la jeton sur la case est de couleur adverse *)
            playable_dir_rec (x + dx, y + dy) true	    (* => Test du prochain jeton dans cette direction *)
          else 										  (* Case Couleur Joueur courant *)
            valid										(* => Direction autorisée si ce n'est pas le premier jeton de la direction *)
    ) 
    in playable_dir_rec (x + dx, y + dy) false		(* Test du premier jeton de la direction donnée *)
;;

(** Methode de test de coup légal => Vrai si le coup est légal *)
let playable_cell board c x y =
  if not (check_pos board x y) then					(* Test si la position est sur le plateau *)
    false											  (* Hors du plateau => direction non autorisée *)
  else (
    let directions = [ 								(* Définition des directions possibles *)
      (-1, -1); (-1, 0); (-1, 1); 
      (0 , -1); (* X *)  (0 , 1); 
      (1 , -1); (1 , 0); (1 , 1) 
    ]
    in match board.(x).(y) with						(* Test si le coup est légal => Légal si : *)
      | Empty -> ( true && (						  (* 1 - Case vide *)
		    List.fold_left 							  (* 2 - Au moins une direction est légale *)
		      (fun a b -> a || b) 					    (* Function de comparaison des éléments de la liste *)
		      false										(* Initialisation de l'accumulateur *)
              (List.map 								(* Liste de légalité des directions *)						
                (fun d -> playable_dir board c (x, y) d)  (* Function de mapping des éléments de la liste *)
                directions								  (* Liste des directions possibles *)
              )
            )
          ) 
       | _ -> false	
  )
;;

(** Méthode pour jouer une case *)
let play_cell board c x y =
  let directions = [ 								(* Définition des directions possibles de la case cliquée *)
    (-1, -1); (-1, 0); (-1, 1); 
    (0 , -1); (* X *)  (0 , 1); 
    (1 , -1); (1 , 0); (1 , 1) 
  ]
  and opponent = (get_opponent c) 					(* Définition de l'adversaire *)
  in (
    List.iter 											
      (fun (dx, dy) -> 									(* Fonction d'iteration de la liste des directions *)
        if (playable_dir board c (x, y) (dx, dy)) then	(* Test si la direction est legale  : *)
          let rec take (x, y) =							  (* Function récursive de prise de jeton *)
            if (check_pos board x y) then				    (* Test si la position est sur le plateau *)
            if (board.(x).(y) = opponent) then (			(* Test si le jeton est à l'adversaire *)
              board.(x).(y) <- c; 							  (* Prise du jeton *)
              take (x + dx, y + dy)							  (* Tentative de prise du prochain jeton dans la direction donnée *)
            )
          in take (x + dx, y + dy)						  (* Tentative de prise du premier jeton dans la direction donnée *)
      )
      directions										(* Liste des directions possibles  *)
  ); 
  board.(x).(y) <- c                                (* Prise de la case cliquée *)
;;

let display_taken board x y =
	(** Construction de la bordure du cercle *)
    Graphics.set_color (Graphics.rgb 0 255 0);
    Graphics.draw_circle 
    (y * !cell_size + !cell_size/2) 
    (x * !cell_size + !cell_size/2) 
    (!cell_size / 2 - 2);	
;;

(** Méthode pour simuler le jeu sur une case *)
let sim_play_cell board c x y =
  let sim_board = (copy_board board) in				(* Copie de l'état de la board *)
  let directions = [ 								(* Définition des directions possibles de la case cliquée *)
    (-1, -1); (-1, 0); (-1, 1); 
    (0 , -1); (* X *)  (0 , 1); 
    (1 , -1); (1 , 0); (1 , 1) 
  ]
  and opponent = (get_opponent c) 					(* Définition de l'adversaire *)
  in (
    List.iter 											
      (fun (dx, dy) -> 									(* Fonction d'iteration de la liste des directions *)
        if (playable_dir sim_board c (x, y) (dx, dy)) then	(* Test si la direction est legale  : *)
          let rec take (x, y) =							  (* Function récursive de prise de jeton *)
            if (check_pos sim_board x y) then				    (* Test si la position est sur le plateau *)
            if (sim_board.(x).(y) = opponent) then (			(* Test si le jeton est à l'adversaire *)
              sim_board.(x).(y) <- c; 							  (* Prise du jeton *)
			  display_taken board x y;
              take (x + dx, y + dy)							  (* Tentative de prise du prochain jeton dans la direction donnée *)
            )
          in take (x + dx, y + dy)						  (* Tentative de prise du premier jeton dans la direction donnée *)
      )
      directions										(* Liste des directions possibles  *)
  ); 
  sim_board.(x).(y) <- c;
  sim_board
;;
(** Retourne la matrice de références sur les nouvelles positions de jetons *)

(** Méthode de récupération de la liste des coups jouables *)
let playable_cells board c = 
  let cells = ref [] in
  for i = 0 to (Array.length board) - 1 do
  	for j = 0 to (Array.length board.(0)) - 1 do
  	  if (playable_cell board c i j) then 
	  (
		Graphics.set_color
		(
		  match c with 
		  | Black -> (Graphics.rgb (!bg_r - 30) (!bg_g - 30) (!bg_r - 30))
	      | _ 	-> (Graphics.rgb (!bg_r + 30) (!bg_g + 30) (!bg_r + 30))
		);
	    (* Construction d'un cercle de couleur *)
	    Graphics.fill_circle
	    (i * !cell_size + !cell_size/2) 
	    (j * !cell_size + !cell_size/2) 
	    (!cell_size / 2 - 2);
	
        Graphics.set_color (Graphics.rgb  !bg_r !bg_g !bg_b);
		Graphics.fill_circle
	    (i * !cell_size + !cell_size/2) 
	    (j * !cell_size + !cell_size/2) 
	    (!cell_size / 2 - 5);
	    cells := (i, j)::!cells;
	  )
      else if board.(i).(j) = Empty then display_cell board i j;
	done;
  done;
  !cells 
;;
(** Retourne une liste des coordonnées des coup légaux *)

(** Methode qui retourne le score pour un état de jeu et un joueur *)
let score board c =
  match c with
  | White -> (count board White) - (count board Black)
  | _ -> (count board Black) - (count board White)
;;

(** Méthode pour afficher les scores *)
let display_scores board =
  let whites = (count board White)
  and blacks = (count board Black) in
    let percent_whites = ((Graphics.size_x()-14)*(whites)/((Array.length board) * (Array.length board.(0))))
    and percent_blacks = ((Graphics.size_x()-14)*(blacks)/((Array.length board) * (Array.length board.(0)))) in
    
    Graphics.set_color (Graphics.rgb 55 30 10);
	Graphics.fill_rect
	5
	(Graphics.size_y()-40)
	(Graphics.size_x()-10)
	19;
	
	Graphics.set_color (Graphics.rgb 90 55 30);
	Graphics.fill_rect
	7
	(Graphics.size_y()-38)
	(Graphics.size_x()-14)
	15;

	Graphics.set_color (Graphics.rgb 0 0 0);
	Graphics.fill_rect
	7
	(Graphics.size_y()-38)
    percent_blacks
	15;
	
	Graphics.set_color (Graphics.rgb 255 255 255);
	Graphics.fill_rect
	(7+percent_blacks)
	(Graphics.size_y()-38)
	percent_whites
	15;
	
    Graphics.moveto (percent_blacks/2) (Graphics.size_y()-36);
    Graphics.set_color (Graphics.rgb 255 255 255);
    Graphics.draw_string (string_of_int blacks);
	Graphics.moveto (percent_blacks+percent_whites/2) (Graphics.size_y()-36);
    Graphics.set_color (Graphics.rgb 0 0 0);
    Graphics.draw_string (string_of_int whites);
;;

(** Méthode récursive de Fold left sur une liste avec la function [f] 
   jusqu'à que ce que le prédicat [p] soit satisfait *)
let rec fold_until f p acc l = 
  match l with
  | t :: q when p acc -> acc				
  | t :: q -> fold_until f p (f acc t) q
  | [] -> acc
;;
(** Retourne l'accumulateur *)

(** Méthode récursive de calcul alphabeta des noeuds de l'arbre *)
let rec alpha_beta board c d a b =
  if (is_finished board or d = 0) then
	score board White
  else let playable_cells = playable_cells board c in 
    match c with
    | White -> let a2 = ref a in
	    fold_until 
		  (
		    fun v (x, y) -> 
              let v2 = max v (alpha_beta (sim_play_cell board c x y) Black (d - 1) !a2 b) in
			  	a2 := max v2 !a2;
			    v2
		  )	
		  (fun v -> v > b) 
		  (-((Array.length board) * (Array.length board.(0))))
		  playable_cells
    | _ -> let b2 = ref b in
		fold_until 
		  (
		    fun v (x, y) -> 
			  let v2 = min v (alpha_beta (sim_play_cell board c x y) White (d - 1) a !b2) in
			    b2 := min v2 !b2;
			    v2
		  )	
		  (fun v -> v < a) 
		  ((Array.length board) * (Array.length board.(0)))
		  playable_cells
;;

(** Methode: Tour de la machine intelligente *)
let ia_turn board = 
  let playable_cells = playable_cells board White in 
	match (List.length playable_cells) with
	| 0 -> ()
	| _ -> 
	  (let x, y =
	    let rec get_best_move ab cell playable_cells =
	      match playable_cells with
	      | (x, y) :: q -> 
		    let a = -((Array.length board) * (Array.length board.(0)))
		    and b = ((Array.length board) * (Array.length board.(0)))
		    and old_ab = ab in 
		      let ab = (alpha_beta (sim_play_cell board White x y) Black (!depth - 1) a b) in
		        if ab > old_ab then get_best_move ab (x, y) q 
		        else get_best_move old_ab cell q
	      | [] -> cell
	    in get_best_move (-((Array.length board) * (Array.length board.(0)))) (List.hd playable_cells) (List.tl playable_cells)
      in play_cell board White x y)
;;

(** Methode: Tour de la machine aléatoire *)
let rec rdm_turn board = 
  let x = Random.int (Array.length board) in
  let y = Random.int (Array.length board.(0)) in
  match board.(x).(y) with
  | Empty -> 
    if (playable_cell board White x y) then
      play_cell board White x y
    else
      rdm_turn board
  | _ -> rdm_turn board
;;

(** Methode: Tour du joueur *)
let player_turn board =	
  let playable_cells = playable_cells board Black in 
	match (List.length playable_cells) with
	| 0 -> ()
	| _ ->									
      let rec player_turn_rec ()=									  (* Function récursive *)
        let st = Graphics.wait_next_event [Graphics.Button_down] in		(* Ecoute de de l'évenement "Click de souris" *)
          let x = (st.Graphics.mouse_x / !cell_size) and 			      (* Determination de la case cliquée *)
              y = (st.Graphics.mouse_y / !cell_size) 			 		  (* grâce à la postion de la souris  *)
    	  in if (playable_cell board Black x y) then					  (* Test si le coup est légal *)
            play_cell board Black x y										(* Légal => Prise de la case *)
          else															  
            player_turn_rec ()												(* Illégal => Au joueur de jouer *)
       in player_turn_rec ()											  (* Au joueur de jouer *)
;;

(** Méthode d'affichage du message en fin de partie *)
let end_message board = 
  let whites = (count board White) 
  and total = ((Array.length board) * (Array.length board.(0))) in
  if (whites > (total / 2)) then
  "White wins by "^string_of_int(whites - total + whites)^" !"
else
  if (whites < (total / 2)) then
  "Black wins by "^string_of_int(total - whites - whites)^" !"
else
  "Draw !"
;;

(** Méthode d'attente d'un évenement click de souris *)
let continue() =
let st = (Graphics.wait_next_event [Graphics.Button_down]) in 
st.Graphics.button <> true
;;

(** Methode de définition d'une partie *)
let game ()=
let board = ref init_board in

display_board !board;
display_scores !board;

while not (is_finished !board) do
  display_message "Black to play...";
  player_turn !board;  
  display_board !board;
  display_scores !board;
  display_message "White to play...";
  if (!ia) then ia_turn !board
  else rdm_turn !board;
  display_board !board;
  display_scores !board;
done;

display_message (end_message !board);

while continue() do
  ()
done;
Graphics.close_graph
;;

(** Définition des spécifications et des arguments possibles *)
let speclist = [
("-cellsize", Arg.Int (fun s -> cell_size := s), "<int> : Set cell size in pixels");
("-size", Arg.Int (fun s -> size := s), "<int> : Set Board length");
("-ia", Arg.Bool (fun i -> ia := i), "<bool> : Artificial intelligence on/off");
("-depth", Arg.Int (fun d -> depth := d), "<int> : Algorithm minimax depth");
("-background", Arg.Tuple [
  Arg.Int (fun r -> bg_r := r); 
  Arg.Int (fun g -> bg_g := g); 
  Arg.Int (fun b -> bg_b := b)], "<int> <int> <int> : set background (RGB)");
]

(** Définition de la function prinicipale *)
let main () =
  (Arg.parse
    speclist
    (fun x -> raise (Arg.Bad ("Bad argument : " ^ x)))
    "othello");
  game()
;;

(** Lance le jeu *)
main();