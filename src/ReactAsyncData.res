open AsyncData

let useAsyncData = () => {
  let (data, setData) = React.useState(() => NotAsked)
  let setData = React.useCallback0(nextData => setData(_ => nextData))
  (data, setData)
}

type reloadable<'a> = {
  current: t<'a>,
  next: t<'a>,
}

let useAsyncReloadData = (~merge=(_a, b) => b, ()) => {
  let (data, setData) = React.useState(() => {current: NotAsked, next: NotAsked})

  let setData = React.useCallback0(next => {
    setData(state => {
      current: switch (state.current, next) {
      | (Done(current), Done(next)) => Done(merge(current, next))
      | (NotAsked | Loading, next) => next
      | _ => state.current
      },
      next: next,
    })
  })

  (data, setData)
}

let useAsyncPaginatedData = (~merge, ()) => {
  useAsyncReloadData(~merge, ())
}
