type 'a auth =
  string

type 'a authenticated_computation =
  Kit.proof -> [`Ok of Kit.proof * 'a | `ProofFailure]

let return a =
  fun proof -> `Ok (proof, a)

let (>>=) c f =
  fun prfs ->
    match c prfs with
      | `ProofFailure -> `ProofFailure
      | `Ok (prfs',a) -> f a prfs'

module Authenticatable = struct
  type 'a evidence =
    { serialise   : 'a            -> Ezjsonm.value
    ; deserialise : Ezjsonm.value -> 'a option
    }

  let auth =
    let serialise h = `String h
    and deserialise = function
      | `String s -> Some s
      | _         -> None
    in
    { serialise; deserialise }

  let pair a_s b_s =
    let serialise (a,b) =
      `A [a_s.serialise a; b_s.serialise b]
    and deserialise = function
      | `A [x;y] ->
         (match a_s.deserialise x, b_s.deserialise y with
           | Some a, Some b -> Some (a,b)
           | _ -> None)
      | _ ->
         None
    in
    { serialise; deserialise }

  let sum a_s b_s =
    let serialise = function
      | `left a  -> `A [`String "left"; a_s.serialise a]
      | `right b -> `A [`String "right"; b_s.serialise b]
    and deserialise = function
      | `A [`String "left"; x] ->
         (match a_s.deserialise x with
           | Some a -> Some (`left a)
           | _ -> None)
      | `A [`String "right"; y] ->
         (match b_s.deserialise y with
           | Some b -> Some (`right b)
           | _ -> None)
      | _ ->
         None
    in
    { serialise; deserialise }

  let string =
    let serialise s = `String s
    and deserialise = function
      | `String s -> Some s
      | _         -> None
    in
    { serialise; deserialise }

  let int =
    let serialise i = `String (string_of_int i)
    and deserialise = function
      | `String i -> (try Some (int_of_string i) with Failure _ -> None)
      | _         -> None
    in
    { serialise; deserialise }

  let unit =
    let serialise () = `Null
    and deserialise = function
      | `Null -> Some ()
      | _     -> None
    in
    { serialise; deserialise }
end

open Authenticatable
  
let auth auth_evidence a =
  Kit.hash_json (auth_evidence.serialise a)

let unauth auth_evidence h =
  function
    | [] -> `ProofFailure
    | p::ps when Kit.hash_json p = h ->
       (match auth_evidence.deserialise p with
         | None   -> `ProofFailure
         | Some a -> `Ok (ps, a))
    | _ -> `ProofFailure
