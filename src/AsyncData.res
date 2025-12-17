type t<'a> =
  | NotAsked
  | Loading
  | Done('a)

let getExn = x =>
  switch x {
  | Done(x) => x
  | NotAsked | Loading => throw(Not_found)
  }

let mapWithDefault = (x, default, f) =>
  switch x {
  | Done(x) => f(x)
  | Loading | NotAsked => default
  }

let map = (x, f) =>
  switch x {
  | Done(x) => Done(f(x))
  | Loading => Loading
  | NotAsked => NotAsked
  }

let flatMap = (x, f) =>
  switch x {
  | Done(x) => f(x)
  | Loading => Loading
  | NotAsked => NotAsked
  }

let getWithDefault = (x, default) =>
  switch x {
  | Done(x) => x
  | Loading | NotAsked => default
  }

let isLoading = x =>
  switch x {
  | Loading => true
  | Done(_) | NotAsked => false
  }

let isDone = x =>
  switch x {
  | Done(_) => true
  | NotAsked | Loading => false
  }

let isNotAsked = x =>
  switch x {
  | NotAsked => true
  | Loading | Done(_) => false
  }

let eq = (a, b, f) =>
  switch (a, b) {
  | (Done(a), Done(b)) => f(a, b)
  | (NotAsked, Done(_))
  | (NotAsked, Loading)
  | (Loading, NotAsked)
  | (Loading, Done(_))
  | (Done(_), NotAsked)
  | (Done(_), Loading) => false
  | (Loading, Loading)
  | (NotAsked, NotAsked) => true
  }

let cmp = (a, b, f) =>
  switch (a, b) {
  | (Done(a), Done(b)) => f(a, b)
  | (NotAsked, Done(_)) => -1
  | (NotAsked, Loading) => -1
  | (Loading, NotAsked) => 1
  | (Loading, Done(_)) => -1
  | (Done(_), NotAsked) => 1
  | (Done(_), Loading) => 1
  | (Loading, Loading)
  | (NotAsked, NotAsked) => 0
  }
