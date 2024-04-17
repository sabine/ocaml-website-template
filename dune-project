(lang dune 3.6)

(name ocaml-website-template)

(source
 (github sabine/ocaml-website-template))

(license ISC)

(generate_opam_files true)

(package
 (name ocaml-website-template)
 (synopsis "Website Starter Template made from the Official OCaml website")
 (description
  "")
 (depends
  (ocaml
   (>= 4.14.0))
  dune
  bos
  crunch
  mirage-kv-mem
  dream-accept
  dream-encoding
  fpath
  fmt
  timedesc
  (cmarkit
   (>= 0.2.0))
  tailwindcss
  (hilite
   (>= 0.4.0))
  ppx_deriving_yaml
  ppx_show
  ppx_stable
  ptime
  (cmdliner
   (>= 1.1.0))
  ))
