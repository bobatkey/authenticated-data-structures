module type S = sig

  (* Authenticated data. *)
  type 'a auth

  (* The authenticated computation monad. *)
  type 'a authenticated_computation

  (* Monad structure *)
  val return : 'a -> 'a authenticated_computation

  val (>>=) :
    'a authenticated_computation ->
    ('a -> 'b authenticated_computation) ->
    'b authenticated_computation

  (* Authenticatable data types *)
  module Authenticatable : sig
    type 'a evidence
    val auth   : 'a auth evidence
    val pair   : 'a evidence -> 'b evidence -> ('a * 'b) evidence
    val sum    :
      'a evidence -> 'b evidence -> [`left of 'a | `right of 'b] evidence
    val string : string evidence
    val int    : int evidence
    val unit   : unit evidence
  end

  (* auth/unauth wrapping *)
  val auth   : 'a Authenticatable.evidence -> 'a -> 'a auth

  val unauth : 'a Authenticatable.evidence -> 'a auth -> 'a authenticated_computation
  
end

type proof = Ezjsonm.value list

let hash_json =
  let h = Cryptokit.Hash.sha1 () in
  fun json -> Cryptokit.hash_string h (Ezjsonm.to_string (`A [json]))
