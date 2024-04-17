open Global

let asset_loader =
  Static.loader
    ~read:(fun _root path -> Static_files.Asset.read path |> Lwt.return)
    ~digest:(fun _root path ->
      Option.map Dream.to_base64url (Static_files.Asset.digest path))
    ~not_cached:[ "robots.txt"; "/robots.txt" ]

let media_loader =
  Static.loader
    ~read:(fun _root path -> Static_files.Media.read path |> Lwt.return)
    ~digest:(fun _root path ->
      Option.map Dream.to_base64url @@ Static_files.Media.digest path)

let page_routes =
  Dream.scope ""
    [ Dream_encoding.compress ]
    [
      Dream.get Url.home Handler.home;
      Dream.get Url.blog Handler.blog;
      Dream.get (Url.blog_post ":id") Handler.blog_post;
      Dream.get Url.jobs Handler.jobs;
    ]

let router =
  Dream.router
    [
      page_routes;
      Dream.scope ""
        [ Dream_encoding.compress ]
        [ Dream.get "/media/**" (Dream.static ~loader:media_loader "") ];
      Dream.scope ""
        [ Dream_encoding.compress ]
        [ Dream.get "/**" (Dream.static ~loader:asset_loader "") ];
    ]
