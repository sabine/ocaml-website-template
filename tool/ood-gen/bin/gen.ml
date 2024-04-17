open Cmdliner

let term_templates =
  [ ("job", Ood_gen.Job.template); ("blog", Ood_gen.Blog.template) ]

let cmds =
  Cmd.group (Cmd.info "ood-gen" ~version:"%%VERSION%%")
  @@ List.map
       (fun (term, template) ->
         Cmd.v (Cmd.info term)
           Term.(const (fun () -> print_endline (template ())) $ const ()))
       term_templates

let () =
  Printexc.record_backtrace true;
  exit (Cmd.eval cmds)
