# Generic Authenticated Data Structures

An implementation in OCaml of Miller et al's [Authenticated Data
Structures,
Generically](http://www.cs.umd.edu/~mwh/papers/gpads.pdf). See the
blog post [Authenticated Data Structures, as a Library, for
Free!](https://bentnib.org/posts/2016-04-12-authenticated-data-structures-as-a-library.html) for more information.

To compile it, you'll need OCaml (tested with version 4.05.0), `opam`,
`jbuilder`/`dune`. You'll need to install the
prerequisites `ezjsonm` and `cryptokit`:

    opam install ezjsonm cryptokit

To play with it interactively, we need to install the nice OCaml
REPL `utop`:

    opam install utop

Then to compile the example, Merkle trees, and load it into `utop` do:

    jbuilder utop test
    
Example interaction:

```ocaml
(* create a tree *)
# let tree =
    Merkle.Prover.(make_branch
                     (make_branch (make_leaf "a") (make_leaf "b"))
                     (make_branch (make_leaf "c") (make_leaf "d")));;
val tree : Merkle.Prover.tree = <abstr>

(* get the hash code of the root *)
# let code = Authentikit.Prover.get_hash tree;;
val code : string = ".z\129w\199J\224\\\254\220\bo\246W\158\243S\029\177\190"

(* run a query on the server side, get a proof and a result *)
# let proof, result = Merkle.Prover.retrieve [`L;`L] tree;;
val proof : Authentikit.Kit.proof = [<abstr>; <abstr>; <abstr>]
val result : string option = Some "a"

(* verify the proof on the client side *)
# Merkle.Verifier.retrieve [`L;`L] code proof;;
- : [ `Ok of Authentikit.Kit.proof * string option | `ProofFailure ] = `Ok ([], Some "a")

(* Let's make another tree and try to trick the verifier *)
# let other_tree =
    Merkle.Prover.(make_branch
                     (make_branch (make_leaf "A") (make_leaf "B"))
                     (make_branch (make_leaf "C") (make_leaf "D")));;
val other_tree : Merkle.Prover.tree = <abstr>

(* Run a query on this tree *)
# let proof, result = Merkle.Prover.retrieve [`L;`L] other_tree;;
val proof : Authentikit.Kit.proof = [<abstr>; <abstr>; <abstr>]
val result : string option = Some "A"

(* Now verifying this proof against the code for the original tree fails: *)
# Merkle.Verifier.retrieve [`L;`L] code proof;;
- : [ `Ok of Authentikit.Kit.proof * string option | `ProofFailure ] = `ProofFailure
```


## Structure of the code

The code from the blog post has been split up. The `src` directory
holds the core library `Authentikit`. There are three modules:

- `Authentikit.Kit` contains the interface `S` and the definition of `proof`s and
  a hashing function used by provers and verifiers.
  
- `Authentikit.Prover` implements the prover / server side of the authenticated
  data structure implementation.
  
- `Authentikit.Verifier` implements the verifier / client side of the
  authenticated data structure implementation.
  
The `test` directory holds an example use of the library: Merkle
trees in `merkle.ml`.

## See Also

- [An implementation of the same idea in Haskell](https://github.com/adjoint-io/auth-adt)
