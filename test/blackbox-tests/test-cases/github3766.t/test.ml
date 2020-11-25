open! Stdune

let mli_only = ref false

let stub = ref None

let name = ref ""

let () =
  let anon s = name := s in
  let set_stub s = stub := Some s in
  let args =
    [ ("--stub", Arg.String set_stub, "C stub")
    ; ("--mli-only", Arg.Set mli_only, "mli only")
    ]
  in
  Arg.parse (Arg.align args) anon "./test.exe <name> [--stub]"

let stub = !stub

let mli_only = !mli_only

let name = !name

let stanza = Io.read_all stdin

let cwd () = Path.external_ (Path.External.cwd ())

let chdir dir = Unix.chdir (Path.to_absolute_filename dir)

let prefix = "test.exe."

let suffix = "." ^ name

let file name c =
  let path = Path.relative (cwd ()) name in
  printfn "-> creating %s" name;
  Io.write_file path c

let descr s f =
  printfn "# %s" s;
  f ();
  print_endline ""

let sh =
  let path = Env.path Env.initial in
  Option.value_exn (Bin.which ~path "sh")

let in_dir name f =
  let cwd = cwd () in
  let dir = Path.relative cwd name in
  Path.mkdir_p dir;
  chdir dir;
  Exn.protect ~f ~finally:(fun () -> chdir cwd)

let cmd s =
  let script = Temp.create File ~prefix ~suffix in
  Io.write_file script s;
  print_endline ("% " ^ s);
  let pid =
    let prog = Path.to_absolute_filename sh in
    Spawn.spawn ~stderr:Unix.stdout ~stdout:Unix.stdout ~prog
      ~argv:[ prog; Path.to_absolute_filename script ]
      ()
  in
  let pid', code = Unix.wait () in
  assert (Pid.equal pid (Pid.of_int pid'));
  match code with
  | WEXITED 0 -> ()
  | WEXITED n -> printfn "[%d]" n
  | _ -> ()

let () =
  in_dir name (fun () ->
      file "dune-project" {|(lang dune 2.8)
(package
 (name foo))
|};
      descr "build the library and see if .a is present" (fun () ->
          in_dir "lib" (fun () ->
              file "dune" stanza;
              Option.iter stub ~f:(fun name ->
                  file (name ^ ".c") "void foo() {}");
              if mli_only then file (name ^ ".mli") "type x = unit");
          cmd "dune build --root . @install";
          cmd "ls _build/install/default/lib/foo/*.a");

      descr "create a dummy executable to test" (fun () ->
          in_dir "exe" (fun () ->
              file "dune"
                {|
(executable
 (name b)
 (link_flags -linkall)
 (libraries foo))
|};
              file "b.ml" "print_endline \"exe working\""));

      descr "make sure that this library is usable locally" (fun () ->
          cmd "dune exec ./exe/b.exe");

      descr "make sure that this library is usable externally" (fun () ->
          cmd "rm -rf lib";
          cmd
            "OCAMLPATH=_build/install/default/lib dune exec --build-dir=_b2 \
             ./exe/b.exe"))
