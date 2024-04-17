module Job = struct
  include Job
end

module Blog = struct
  include Blog

  let get_by_slug slug = List.find_opt (fun x -> String.equal slug x.slug) all
end
