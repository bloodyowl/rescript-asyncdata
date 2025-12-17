type t<'a> =
  | NotAsked
  | Loading
  | Done('a)

let getExn: t<'a> => 'a

let mapWithDefault: (t<'a>, 'b, 'a => 'b) => 'b

let map: (t<'a>, 'a => 'b) => t<'b>

let flatMap: (t<'a>, 'a => t<'b>) => t<'b>

let getWithDefault: (t<'a>, 'a) => 'a

let isLoading: t<'a> => bool
let isDone: t<'a> => bool
let isNotAsked: t<'a> => bool

let eq: (t<'a>, t<'b>, ('a, 'b) => bool) => bool

let cmp: (t<'a>, t<'b>, ('a, 'b) => int) => int
