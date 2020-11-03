type t<'a> =
  | NotAsked
  | Loading
  | Done('a)

let getExn: t<'a> => 'a

let mapWithDefaultU: (t<'a>, 'b, (. 'a) => 'b) => 'b
let mapWithDefault: (t<'a>, 'b, 'a => 'b) => 'b

let mapU: (t<'a>, (. 'a) => 'b) => t<'b>
let map: (t<'a>, 'a => 'b) => t<'b>

let flatMapU: (t<'a>, (. 'a) => t<'b>) => t<'b>
let flatMap: (t<'a>, 'a => t<'b>) => t<'b>

let getWithDefault: (t<'a>, 'a) => 'a

let isLoading: t<'a> => bool
let isDone: t<'a> => bool
let isNotAsked: t<'a> => bool

let eqU: (t<'a>, t<'b>, (. 'a, 'b) => bool) => bool
let eq: (t<'a>, t<'b>, ('a, 'b) => bool) => bool

let cmpU: (t<'a>, t<'b>, (. 'a, 'b) => int) => int
let cmp: (t<'a>, t<'b>, ('a, 'b) => int) => int
