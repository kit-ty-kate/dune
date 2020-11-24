This exercises the difference in behavior when creating archives introduced in
ocaml 4.12.

In 4.11 - .a are always created
In 4.12 - they are omitted if there are no modules or stubs

A single test case is in test.ml

  $ ./test.exe unwrapped_empty <<EOF
  > (library
  >  (public_name foo)
  >  (wrapped false)
  >  (modules ()))
  > EOF
  -> creating dune-project
  # build the library and see if .a is present
  -> creating dune
  % dune build --root . @install
  % ls _build/install/default/lib/foo/*.a
  _build/install/default/lib/foo/foo.a
  
  # create a dummy executable to test
  -> creating dune
  -> creating b.ml
  
  # make sure that this library is usable locally
  % dune exec ./exe/b.exe
  exe working
  
  # make sure that this library is usable externally
  % rm -rf lib
  % OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 ./exe/b.exe
  exe working
  
  $ ./test.exe wrapped_empty <<EOF
  > (library
  >  (public_name foo)
  >  (wrapped true)
  >  (modules ()))
  > EOF
  -> creating dune-project
  # build the library and see if .a is present
  -> creating dune
  % dune build --root . @install
  % ls _build/install/default/lib/foo/*.a
  _build/install/default/lib/foo/foo.a
  
  # create a dummy executable to test
  -> creating dune
  -> creating b.ml
  
  # make sure that this library is usable locally
  % dune exec ./exe/b.exe
  exe working
  
  # make sure that this library is usable externally
  % rm -rf lib
  % OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 ./exe/b.exe
  exe working
  
  $ ./test.exe unwrapped_empty_with_stubs --stub baz <<EOF
  > (library
  >  (public_name foo)
  >  (wrapped false)
  >  (foreign_stubs (language c) (names baz)))
  > EOF
  -> creating dune-project
  # build the library and see if .a is present
  -> creating dune
  -> creating baz.c
  % dune build --root . @install
  % ls _build/install/default/lib/foo/*.a
  _build/install/default/lib/foo/foo.a
  _build/install/default/lib/foo/libfoo_stubs.a
  
  # create a dummy executable to test
  -> creating dune
  -> creating b.ml
  
  # make sure that this library is usable locally
  % dune exec ./exe/b.exe
  exe working
  
  # make sure that this library is usable externally
  % rm -rf lib
  % OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 ./exe/b.exe
  exe working
  
