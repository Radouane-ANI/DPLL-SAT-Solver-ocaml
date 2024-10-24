(* MP1 2024/2025 - dpll.ml *)

open List

(* fonctions utilitaires *)
(* ----------------------------------------------------------- *)
(* filter_map : ('a -> 'b option) -> 'a list -> 'b list
   disponible depuis la version 4.08.0 de OCaml dans le module List :
   pour chaque élément de `list', appliquer `filter' :
   - si le résultat est `Some e', ajouter `e' au résultat ;
   - si le résultat est `None', ne rien y ajouter.
   Attention, cette implémentation inverse l'ordre de la liste *)
let filter_map filter list =
  let rec aux list ret =
    match list with
    | []   -> ret
    | h::t -> match (filter h) with
      | None   -> aux t ret
      | Some e -> aux t (e::ret)
  in aux list []

(* print_modele : int list option -> unit
   afficher le résultat *)
let print_modele: int list option -> unit = function
  | None   -> print_string "UNSAT\n"
  | Some modele -> print_string "SAT\n";
     let modele2 = sort (fun i j -> (abs i) - (abs j)) modele in
     List.iter (fun i -> print_int i; print_string " ") modele2;
     print_string "0\n"

(* ensembles de clauses de test *)
let exemple_3_12 = [[1;2;-3];[2;3];[-1;-2;3];[-1;-3];[1;-2]]
let exemple_7_2 = [[1;-1;-3];[-2;3];[-2]]
let exemple_7_4 = [[1;2;3];[-1;2;3];[3];[1;-2;-3];[-1;-2;-3];[-3]]
let exemple_7_8 = [[1;-2;3];[1;-3];[2;3];[1;-2]]
let systeme = [[-1;2];[1;-2];[1;-3];[1;2;3];[-1;-2]]
let coloriage = [
  [1;2;3];[4;5;6];[7;8;9];[10;11;12];[13;14;15];[16;17;18];
  [19;20;21];[-1;-2];[-1;-3];[-2;-3];[-4;-5];[-4;-6];[-5;-6];
  [-7;-8];[-7;-9];[-8;-9];[-10;-11];[-10;-12];[-11;-12];[-13;-14];
  [-13;-15];[-14;-15];[-16;-17];[-16;-18];[-17;-18];[-19;-20];
  [-19;-21];[-20;-21];[-1;-4];[-2;-5];[-3;-6];[-1;-7];[-2;-8];
  [-3;-9];[-4;-7];[-5;-8];[-6;-9];[-4;-10];[-5;-11];[-6;-12];
  [-7;-10];[-8;-11];[-9;-12];[-7;-13];[-8;-14];[-9;-15];[-7;-16];
  [-8;-17];[-9;-18];[-10;-13];[-11;-14];[-12;-15];[-13;-16];
  [-14;-17];[-15;-18]]

(* ----------------------------------------------------------- *)

(* simplifie : int -> int list list -> int list list 
   applique la simplification de l'ensemble des clauses en mettant
   le littéral l à vrai *)
let simplifie l clauses =
(* Fonction auxiliaire récursive qui prend un accumulateur acc et une clause fin_clause *)
  let rec aux acc fin_clause =
    match fin_clause with
    | [] -> Some acc  (* Si la clause est vide, on renvoie l'accumulateur *)
    | h :: tl -> (* On analyse le premier élément de la clause *)
        if h = l then None  (* Si on trouve le littéral l, la clause est satisfaite, on l'élimine (None) *)
        else if h = -l then aux acc tl  (* Si on trouve -l, on l'élimine de la clause (continue) *)
        else aux (h :: acc) tl  (* Sinon, on garde le littéral h dans l'accumulateur *)
  in
  (* On applique la simplification sur toutes les clauses, et on inverse la liste pour garder l'ordre original *)
  rev (filter_map (aux []) clauses)
    
(* solveur_split : int list list -> int list -> int list option
   exemple d'utilisation de `simplifie' *)
(* cette fonction ne doit pas être modifiée, sauf si vous changez 
   le type de la fonction simplifie *)
let rec solveur_split clauses interpretation =
  (* l'ensemble vide de clauses est satisfiable *)
  if clauses = [] then Some interpretation else
  (* la clause vide n'est jamais satisfiable *)
  if mem [] clauses then None else
  (* branchement *) 
  let l = hd (hd clauses) in
  let branche = solveur_split (simplifie l clauses) (l::interpretation) in
  match branche with
  | None -> solveur_split (simplifie (-l) clauses) ((-l)::interpretation)
  | _    -> branche

(* tests *)
(* let () = print_modele (solveur_split systeme []) *)
(* let () = print_modele (solveur_split coloriage []) *)

(* solveur dpll récursif *)
(* ----------------------------------------------------------- *)

(* pur : int list list -> int
    - si `clauses' contient au moins un littéral pur, retourne
      ce littéral ;
    - sinon, lève une exception `Failure "pas de littéral pur"' *)
let pur clauses =
  (* Crée une table de hachage pour stocker les littéraux *)
  let table = Hashtbl.create 100 in
    (* Initialise la table en ajoutant chaque littéral des clauses *)
    let init = List.iter (fun clause -> iter(fun l -> Hashtbl.replace table l true ) clause) clauses
    in init ;
    (* Recherche d'un littéral pur en parcourant la table de hachage *)
    (* Si on trouve à la fois l et -l, l n'est pas pur *)
    (* Sinon, l est pur et on le renvoie, il remplace l'accumulateur*)
    match Hashtbl.fold (fun l a acc -> if acc = 0 then if Hashtbl.mem table (-l) then acc else l
    else acc) table 0 with 
      | 0 -> raise(Failure "pas de littéral pur") (* Si aucun littéral pur n'est trouvé *)
      | l -> l (* Renvoie le littéral pur trouvé *)


(* unitaire : int list list -> int
    - si `clauses' contient au moins une clause unitaire, retourne
      le littéral de cette clause unitaire ;
    - sinon, lève une exception `Not_found' *)
let rec unitaire clauses =
  match clauses with
  | [] -> raise Not_found (* Aucune clause unitaire trouvée *)
  | hd :: tl -> ( match hd with
  | [ a ] -> a (* Si une clause contient un seul littéral, on le retourne *)
  | _ -> unitaire tl) (* Sinon, on continue la recherche *)


(* VERSION PLUS OPTIMISER DE solveur_dpll_rec*)

(* unitaire_opt : retourne une option contenant un littéral unitaire ou None *)
let unitaire_opt clauses =
  try Some (unitaire clauses)
  with Not_found -> None  (* Si aucun littéral unitaire n'est trouvé, renvoie None *)

(* pur_opt : retourne une option contenant un littéral pur ou None *)
let pur_opt clauses =
  try Some (pur clauses)
  with Failure _ -> None  (* Si aucun littéral pur n'est trouvé, renvoie None *)

(* solveur_dpll_rec : int list list -> int list -> int list option *)
let rec solveur_dpll_rec clauses interpretation =
  (* l'ensemble vide de clauses est satisfiable *)
  if clauses = [] then Some interpretation
  else if (* la clause vide n'est jamais satisfiable *)
          List.mem [] clauses then None
  else
    (* branchement *)
    match unitaire_opt clauses with
    | Some unit -> (* Si un littéral unitaire est trouvé, on simplifie et continue avec ce littéral *)
        solveur_dpll_rec (simplifie unit clauses) (unit :: interpretation)
    | None -> (
        match pur_opt clauses with
        | Some p -> (* Si un littéral pur est trouvé, on simplifie et continue avec ce littéral *)
            solveur_dpll_rec (simplifie p clauses) (p :: interpretation)
        | None -> ( (* Sinon, on choisit un littéral arbitraire *)
            let l = List.hd (List.hd clauses) in
            let branche = (* On tente d'abord de résoudre avec l *)
              solveur_dpll_rec (simplifie l clauses) (l :: interpretation)
            in
            match branche with
            | None -> (* Si la première branche échoue, on tente avec -l *)
                solveur_dpll_rec (simplifie (-l) clauses) (-l :: interpretation)
            | _ -> branche
        )
    )

(* tests *)
(* ----------------------------------------------------------- *)
(* let () = print_modele (solveur_dpll_rec systeme []) *)
(* let () = print_modele (solveur_dpll_rec coloriage []) *)

 let () =
  let clauses = Dimacs.parse Sys.argv.(1) in
  print_modele (solveur_dpll_rec clauses [])
;; 
