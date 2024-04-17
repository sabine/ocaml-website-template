exception Decode_error of string

module String = struct
  include Stdlib.String
  module Map = Map.Make (Stdlib.String)

  let contains_s s1 s2 =
    try
      let len = String.length s2 in
      for i = 0 to String.length s1 - len do
        if String.sub s1 i len = s2 then raise Exit
      done;
      false
    with Exit -> true

  (* ripped off stringext, itself ripping it off from one of dbuenzli's libs *)
  let cut s ~on =
    let sep_max = length on - 1 in
    if sep_max < 0 then invalid_arg "Stringext.cut: empty separator"
    else
      let s_max = length s - 1 in
      if s_max < 0 then None
      else
        let k = ref 0 in
        let i = ref 0 in
        (* We run from the start of [s] to end with [i] trying to match the
           first character of [on] in [s]. If this matches, we verify that the
           whole [on] is matched using [k]. If it doesn't match we continue to
           look for [on] with [i]. If it matches we exit the loop and extract a
           substring from the start of [s] to the position before the [on] we
           found and another from the position after the [on] we found to end of
           string. If [i] is such that no separator can be found we exit the
           loop and return the no match case. *)
        try
          while !i + sep_max <= s_max do
            (* Check remaining [on] chars match, access to unsafe s (!i + !k) is
               guaranteed by loop invariant. *)
            if unsafe_get s !i <> unsafe_get on 0 then incr i
            else (
              k := 1;
              while
                !k <= sep_max && unsafe_get s (!i + !k) = unsafe_get on !k
              do
                incr k
              done;
              if !k <= sep_max then (* no match *) incr i else raise Exit)
          done;
          None (* no match in the whole string. *)
        with Exit ->
          (* i is at the beginning of the separator *)
          let left_end = !i - 1 in
          let right_start = !i + sep_max + 1 in
          Some
            (sub s 0 (left_end + 1), sub s right_start (s_max - right_start + 1))
end

module Result = struct
  include Stdlib.Result

  let const_error e _ = Error e
  let apply f = Result.fold ~ok:Result.map ~error:const_error f
  let get_ok ~error = fold ~ok:Fun.id ~error:(fun e -> raise (error e))
  let sequential_or f g x = fold (f x) ~ok ~error:(Fun.const (g x))
end

let ( let* ) = Result.bind
let ( <@> ) = Result.apply

let extract_metadata_body path s =
  let err =
    `Msg
      (Printf.sprintf "expected metadata at the top of the file %s. Got %s" path
         s)
  in
  let cut =
    let sep = "---\n" in
    let win_sep = "---\r\n" in
    let cut on s = Option.to_result ~none:err (String.cut ~on s) in
    Result.sequential_or (cut sep) (cut win_sep)
  in
  let* pre, post = cut s in
  let* () = if pre = "" then Ok () else Error err in
  let* yaml, body = cut post in
  let* yaml = Yaml.of_string yaml in
  Ok (yaml, body)

let root_dir = Fpath.(v (Sys.getcwd ()) // v "data")

let read_file filepath =
  let filepath = Fpath.(root_dir // filepath) in
  Bos.OS.File.read filepath
  |> Result.map (fun r -> Some r)
  |> Result.map_error (fun (`Msg msg) -> failwith msg)
  |> Result.value ~default:None

let read_from_dir glob =
  let file_pattern =
    Fpath.v (String.split_on_char '*' glob |> String.concat "$(f)")
  in
  let results =
    Bos.OS.Path.matches Fpath.(root_dir // file_pattern)
    |> Result.get_ok ~error:(fun (`Msg msg) -> failwith msg)
    |> List.filter_map (fun x ->
           read_file x
           |> Option.map (fun y ->
                  ( x |> Fpath.rem_prefix root_dir |> Option.get
                    |> Fpath.to_string,
                    y )))
  in
  if List.length results = 0 then
    failwith
      ("Did not find any files matching " ^ glob
     ^ "! All data folders need to be listed as dependencies of the \
        corresponding ood-gen command in src/ocamlorg_data/dune");
  results

let map_files f glob =
  let f (path, data) =
    let* metadata = extract_metadata_body path data in
    Result.map_error
      (function `Msg err -> `Msg (path ^ ": " ^ err))
      (f (path, metadata))
  in
  read_from_dir glob
  |> List.fold_left (fun u x -> Ok List.cons <@> f x <@> u) (Ok [])
  |> Result.map List.rev
  |> Result.get_ok ~error:(fun (`Msg msg) -> Decode_error msg)

let slugify value =
  value
  |> Str.global_replace (Str.regexp " ") "-"
  |> String.lowercase_ascii
  |> Str.global_replace (Str.regexp "[^a-z0-9\\-]") ""

let yaml_file filepath_str =
  let filepath =
    filepath_str |> Fpath.of_string
    |> Result.get_ok ~error:(fun (`Msg m) -> Invalid_argument m)
  in
  let file_opt = read_file filepath in
  let* file = Option.to_result ~none:(`Msg "file not found") file_opt in
  Yaml.of_string file

let yaml_sequence_file ?key of_yaml filepath_str =
  let filepath =
    filepath_str |> Fpath.of_string
    |> Result.get_ok ~error:(fun (`Msg m) -> Invalid_argument m)
  in
  let key_default = filepath |> Fpath.rem_ext |> Fpath.basename in
  let key = Option.value ~default:key_default key in
  (let* yaml = yaml_file filepath_str in
   let* opt = Yaml.Util.find key yaml in
   let* found = Option.to_result ~none:(`Msg (key ^ ", key not found")) opt in
   let* list =
     (function `A u -> Ok u | _ -> Error (`Msg "expecting a sequence")) found
   in
   List.fold_left (fun u x -> Ok List.cons <@> of_yaml x <@> u) (Ok []) list)
  |> Result.map_error (function `Msg err ->
         `Msg ((filepath |> Fpath.to_string) ^ ": " ^ err))
  |> Result.get_ok ~error:(fun (`Msg msg) -> Decode_error msg)

let of_yaml of_string error = function
  | `String s -> of_string s
  | _ -> Error (`Msg error)

let where fpath = function `Msg err -> `Msg (fpath ^ ": " ^ err)
