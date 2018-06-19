include Kit.S
  with type 'a authenticated_computation = Kit.proof * 'a

val get_hash : 'a auth -> string

