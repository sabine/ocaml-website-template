module Job : sig
  type t = {
    title : string;
    link : string;
    locations : string list;
    publication_date : string option;
    company : string;
    company_logo : string;
  }

  val all : t list
end

module Blog : sig
  type t = {
    title : string;
    slug : string;
    description : string;
    date : string;
    tags : string list;
    body_html : string;
    authors : string list;
  }

  val all : t list
  val get_by_slug : string -> t option
end
