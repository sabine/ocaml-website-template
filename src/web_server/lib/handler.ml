open Global.Import

let http_or_404 opt f =
  Option.fold ~none:(Dream.html ~code:404 "Not Found!") ~some:f opt

(* short-circuiting 404 error operator *)
let ( let</>? ) opt = http_or_404 opt
let home _req = Dream.html (Templates.home ())

let paginate ~req ~n items =
  let items_per_page = n in
  let page =
    Dream.query req "p" |> Option.map int_of_string |> Option.value ~default:1
  in
  let number_of_pages =
    int_of_float
      (Float.ceil
         (float_of_int (List.length items) /. float_of_int items_per_page))
  in
  let current_items =
    let skip = items_per_page * (page - 1) in
    items |> List.drop skip |> List.take items_per_page
  in
  (page, number_of_pages, current_items)

let blog req =
  let page, number_of_pages, current_items =
    paginate ~req ~n:10 Data.Blog.all
  in
  Dream.html (Templates.blog ~page ~pages_number:number_of_pages current_items)

let blog_post req =
  let slug = Dream.param req "id" in
  let</>? blog = Data.Blog.get_by_slug slug in
  Dream.html (Templates.blog_post blog)

let jobs _req =
  let jobs = Data.Job.all in
  Dream.html (Templates.jobs jobs)
