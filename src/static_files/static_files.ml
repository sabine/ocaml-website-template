let of_url_path = File.of_url_path

module Open_search = struct
  let manifest = "/opensearch.xml"
end

module Media = struct
  let url_root = "/media"
  let digest = Media.hash
  let read = Media.read

  let url filepath =
    let digest = Option.map Dream.to_base64url (Media.hash filepath) in
    if digest = None then
      raise
        (Invalid_argument
           (Fmt.str "'%s' is rendered via Media.url, but it is not an media!"
              filepath));
    url_root ^ File.to_url_path ?digest filepath
end

module Asset = struct
  let digest = Asset.hash
  let read = Asset.read

  (* given the path of a file from `assets.ml`: 1. looks up the file's digest in
     and 2. returns the corresponding digest URL for use in templates *)
  let url filepath =
    let digest = Option.map Dream.to_base64url (Asset.hash filepath) in
    if digest = None then
      raise
        (Invalid_argument
           (Fmt.str "'%s' is rendered via Asset.url, but it is not an asset!"
              filepath));
    File.to_url_path ?digest filepath
end
