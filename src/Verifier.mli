include Kit.S
  with type 'a authenticated_computation =
         Kit.proof -> [ `Ok of Kit.proof * 'a | `ProofFailure ]
   and type 'a auth = string
