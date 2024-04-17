let env_with_default k v = Sys.getenv_opt k |> Option.value ~default:v
let http_port = env_with_default "HTTP_PORT" "8080" |> int_of_string
