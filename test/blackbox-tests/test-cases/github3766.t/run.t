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
  

  $ ./test.exe mli_only_no_stubs --mli-only <<EOF
  > (library
  >  (public_name foo)
  >  (modules_without_implementation foo))
  > EOF
  -> creating dune-project
  # build the library and see if .a is present
  -> creating dune
  -> creating mli_only_no_stubs.mli
  % dune build --root . @install
  File "lib/dune", line 3, characters 33-36:
  3 |  (modules_without_implementation foo))
                                       ^^^
  Error: Module Foo doesn't exist.
  [1]
  % ls _build/install/default/lib/foo/*.a
  ls: _build/install/default/lib/foo/*.a: No such file or directory
  [1]
  
  # create a dummy executable to test
  -> creating dune
  -> creating b.ml
  
  # make sure that this library is usable locally
  % dune exec ./exe/b.exe
  File "lib/dune", line 3, characters 33-36:
  3 |  (modules_without_implementation foo))
                                       ^^^
  Error: Module Foo doesn't exist.
  [1]
  
  # make sure that this library is usable externally
  % rm -rf lib
  % OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 ./exe/b.exe
  File "exe/dune", line 5, characters 12-15:
  5 |  (libraries foo))
                  ^^^
  Error: Library "foo" not found.
  Hint: try:
    dune external-lib-deps --missing --build-dir _b2 ./exe/b.exe
  [1]
  

  $ ./test.exe mli_only_no_stubs --mli-only --stub baz <<EOF
  > (library
  >  (public_name foo)
  >  (foreign_stubs (language c) (names baz))
  >  (modules_without_implementation foo))
  > EOF
  -> creating dune-project
  # build the library and see if .a is present
  -> creating dune
  -> creating baz.c
  -> creating mli_only_no_stubs.mli
  % dune build --root . @install
  File "lib/dune", line 4, characters 33-36:
  4 |  (modules_without_implementation foo))
                                       ^^^
  Error: Module Foo doesn't exist.
  [1]
  % ls _build/install/default/lib/foo/*.a
  ls: _build/install/default/lib/foo/*.a: No such file or directory
  [1]
  
  # create a dummy executable to test
  -> creating dune
  -> creating b.ml
  
  # make sure that this library is usable locally
  % dune exec ./exe/b.exe
  File "lib/dune", line 4, characters 33-36:
  4 |  (modules_without_implementation foo))
                                       ^^^
  Error: Module Foo doesn't exist.
  [1]
  
  # make sure that this library is usable externally
  % rm -rf lib
  % OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 ./exe/b.exe
  File "exe/dune", line 5, characters 12-15:
  5 |  (libraries foo))
                  ^^^
  Error: Library "foo" not found.
  Hint: try:
    dune external-lib-deps --missing --build-dir _b2 ./exe/b.exe
  [1]
  
