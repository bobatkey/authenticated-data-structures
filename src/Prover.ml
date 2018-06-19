type 'a auth = 'a * string

type 'a authenticated_computation =
  Kit.proof * 'a

let return a =
  ([], a)

let (>>=) (prf,a) f =
  let (prf',b) = f a in
  (prf @ prf', b)

module Authenticatable = struct
  type 'a evidence = 'a -> Ezjsonm.value

  let auth (a,h) =
    `String h

  let pair a_serialiser b_serialiser (a,b) =
    `A [a_serialiser a; b_serialiser b]

  let sum a_serialiser b_serialiser = function
    | `left a  -> `A [`String "left"; a_serialiser a]
    | `right b -> `A [`String "right"; b_serialiser b]

  let string s =
    `String s

  let int i =
    `String (string_of_int i)

  let unit () =
    `Null
end

let auth serialiser a =
  (a, Kit.hash_json (serialiser a))

let unauth serialiser (a, h) =
  ([serialiser a], a)

let get_hash (a,h) = h
