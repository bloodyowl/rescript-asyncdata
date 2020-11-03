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

let defaultMerge = (_a, b) => b

let useAsyncReloadData = (~merge=defaultMerge, ()) => {
  let (data, setData) = React.useState(() => {current: NotAsked, next: NotAsked})

  let setData = React.useCallback1(next => {
    setData(state => {
      current: switch (state.current, next) {
      | (Done(current), Done(next)) => Done(merge(current, next))
      | (NotAsked | Loading, next) => next
      | _ => state.current
      },
      next: next,
    })
  }, [merge])

  (data, setData)
}

let useAsyncPaginatedData = (~merge, ()) => {
  useAsyncReloadData(~merge, ())
}
