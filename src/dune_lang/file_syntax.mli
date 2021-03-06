open Stdune

type t = Jbuild | Dune

val equal : t -> t -> bool

val hash : t -> int

val of_basename : string -> t option

val to_dyn : t -> Dyn.t
