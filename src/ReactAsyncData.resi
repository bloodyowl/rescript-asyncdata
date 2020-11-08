let useAsyncData: unit => (AsyncData.t<'a>, AsyncData.t<'a> => unit)

type reloadable<'a> = {
  current: AsyncData.t<'a>,
  next: AsyncData.t<'a>,
}

let useAsyncReloadData: (
  ~merge: ('a, 'a) => 'a=?,
  unit,
) => (reloadable<'a>, AsyncData.t<'a> => unit)
