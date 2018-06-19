module type Merkle =
  functor (A : Authentikit.Kit.S) -> sig
    open A
    
    type path = [`L | `R] list
    type tree = [`left of string | `right of tree * tree ] A.auth

    val make_leaf   : string -> tree
    val make_branch : tree -> tree -> tree
    val retrieve    : path -> tree -> string option authenticated_computation
    val update      : path -> string -> tree -> tree option authenticated_computation
  end

module Merkle : Merkle =
  functor (A : Authentikit.Kit.S) -> struct
    open A

    type path = [`L|`R] list
    type tree = [`left of string | `right of tree * tree ] A.auth

    let tree : [`left of string | `right of tree * tree] Authenticatable.evidence =
      Authenticatable.(sum string (pair auth auth))

    let make_leaf s =
      auth tree (`left s)

    let make_branch l r =
      auth tree (`right (l,r))

    let rec retrieve path t =
      unauth tree t >>= fun t ->
      match path, t with
        | [],       `left s      -> return (Some s)
        | `L::path, `right (l,r) -> retrieve path l
        | `R::path, `right (l,r) -> retrieve path r
        | _,        _            -> return None

    let rec update path v t =
      unauth tree t >>= fun t ->
      match path, t with
        | [],       `left _      -> return (Some (make_leaf v))
        | `L::path, `right (l,r) ->
           (update path v l >>= function
             | None    -> return None
             | Some l' -> return (Some (make_branch l' r)))
        | `R::path, `right (l,r) ->
         (update path v r >>= function
           | None    -> return None
           | Some r' -> return (Some (make_branch l r')))
      | _ ->
         return None
  end

module Prover = Merkle (Authentikit.Prover)
module Verifier = Merkle (Authentikit.Verifier)
