open Test
open AsyncData

let intEqual = (~message=?, a: int, b: int) => assertion(~message?, (a, b) => a == b, a, b)
let boolEqual = (~message=?, a: bool, b: bool) => assertion(~message?, (a, b) => a == b, a, b)
let asyncDataEqual = (~message=?, a: AsyncData.t<'a>, b: AsyncData.t<'a>) =>
  assertion(~message?, (a, b) => AsyncData.eq(a, b, (a, b) => a == b), a, b)
let asyncDataArrayEqual = (~message=?, a: array<AsyncData.t<'a>>, b: array<AsyncData.t<'a>>) =>
  assertion(
    ~message?,
    (a, b) => Belt.Array.eq(a, b, (a, b) => AsyncData.eq(a, b, (a, b) => a == b)),
    a,
    b,
  )

test("AsyncData getExn", () => {
  throws(() => getExn(NotAsked))
  throws(() => getExn(Loading))
  doesNotThrow(() => {
    let _ = getExn(Done(1))
  })
})

test("AsyncData mapWithDefaultU", () => {
  intEqual(NotAsked->mapWithDefaultU(0, (. value) => value + 1), 0)
  intEqual(Loading->mapWithDefaultU(0, (. value) => value + 1), 0)
  intEqual(Done(1)->mapWithDefaultU(0, (. value) => value + 1), 2)
})

test("AsyncData mapWithDefault", () => {
  intEqual(NotAsked->mapWithDefault(0, value => value + 1), 0)
  intEqual(Loading->mapWithDefault(0, value => value + 1), 0)
  intEqual(Done(1)->mapWithDefault(0, value => value + 1), 2)
})

test("AsyncData mapU", () => {
  asyncDataEqual(NotAsked->mapU((. value) => value + 1), NotAsked)
  asyncDataEqual(Loading->mapU((. value) => value + 1), Loading)
  asyncDataEqual(Done(1)->mapU((. value) => value + 1), Done(2))
})

test("AsyncData map", () => {
  asyncDataEqual(NotAsked->map(value => value + 1), NotAsked)
  asyncDataEqual(Loading->map(value => value + 1), Loading)
  asyncDataEqual(Done(1)->map(value => value + 1), Done(2))
})

test("AsyncData flatMapU", () => {
  asyncDataEqual(NotAsked->flatMapU((. value) => Done(value + 1)), NotAsked)
  asyncDataEqual(Loading->flatMapU((. value) => Done(value + 1)), Loading)
  asyncDataEqual(Done(1)->flatMapU((. value) => Done(value + 1)), Done(2))
  asyncDataEqual(Done(1)->flatMapU((. _) => Loading), Loading)
  asyncDataEqual(Done(1)->flatMapU((. _) => NotAsked), NotAsked)
})

test("AsyncData flatMap", () => {
  asyncDataEqual(NotAsked->flatMap(value => Done(value + 1)), NotAsked)
  asyncDataEqual(Loading->flatMap(value => Done(value + 1)), Loading)
  asyncDataEqual(Done(1)->flatMap(value => Done(value + 1)), Done(2))
  asyncDataEqual(Done(1)->flatMap(_ => Loading), Loading)
  asyncDataEqual(Done(1)->flatMap(_ => NotAsked), NotAsked)
})

test("AsyncData getWithDefault", () => {
  intEqual(NotAsked->getWithDefault(1), 1)
  intEqual(Loading->getWithDefault(1), 1)
  intEqual(Done(2)->getWithDefault(1), 2)
})

test("AsyncData isLoading", () => {
  boolEqual(NotAsked->isLoading, false)
  boolEqual(Loading->isLoading, true)
  boolEqual(Done(2)->isLoading, false)
})

test("AsyncData isDone", () => {
  boolEqual(NotAsked->isDone, false)
  boolEqual(Loading->isDone, false)
  boolEqual(Done(2)->isDone, true)
})

test("AsyncData isNotAsked", () => {
  boolEqual(NotAsked->isNotAsked, true)
  boolEqual(Loading->isNotAsked, false)
  boolEqual(Done(2)->isNotAsked, false)
})

test("AsyncData eqU", () => {
  boolEqual(eqU(NotAsked, NotAsked, (. a, b) => a === b), true)
  boolEqual(eqU(Loading, Loading, (. a, b) => a === b), true)
  boolEqual(eqU(NotAsked, Loading, (. a, b) => a === b), false)
  boolEqual(eqU(Loading, NotAsked, (. a, b) => a === b), false)
  boolEqual(eqU(NotAsked, Done(1), (. a, b) => a === b), false)
  boolEqual(eqU(Loading, Done(1), (. a, b) => a === b), false)
  boolEqual(eqU(Done(1), NotAsked, (. a, b) => a === b), false)
  boolEqual(eqU(Done(1), Loading, (. a, b) => a === b), false)
  boolEqual(eqU(Done(1), Done(1), (. a, b) => a === b), true)
  boolEqual(eqU(Done(1), Done(2), (. a, b) => a === b), false)
  boolEqual(eqU(Done(2), Done(1), (. a, b) => a === b), false)
})

test("AsyncData eq", () => {
  boolEqual(eq(NotAsked, NotAsked, (a, b) => a === b), true)
  boolEqual(eq(Loading, Loading, (a, b) => a === b), true)
  boolEqual(eq(NotAsked, Loading, (a, b) => a === b), false)
  boolEqual(eq(Loading, NotAsked, (a, b) => a === b), false)
  boolEqual(eq(NotAsked, Done(1), (a, b) => a === b), false)
  boolEqual(eq(Loading, Done(1), (a, b) => a === b), false)
  boolEqual(eq(Done(1), NotAsked, (a, b) => a === b), false)
  boolEqual(eq(Done(1), Loading, (a, b) => a === b), false)
  boolEqual(eq(Done(1), Done(1), (a, b) => a === b), true)
  boolEqual(eq(Done(1), Done(2), (a, b) => a === b), false)
  boolEqual(eq(Done(2), Done(1), (a, b) => a === b), false)
})

test("AsyncData cmpU", () => {
  open Belt
  asyncDataArrayEqual(
    [Done(2), NotAsked, Loading, Loading, Done(1), NotAsked]->SortArray.stableSortBy((a, b) =>
      cmpU(a, b, (. a, b) => b > a ? -1 : 1)
    ),
    [NotAsked, NotAsked, Loading, Loading, Done(1), Done(2)],
  )
})

test("AsyncData cmp", () => {
  open Belt
  asyncDataArrayEqual(
    [Done(2), NotAsked, Loading, Loading, Done(1), NotAsked]->SortArray.stableSortBy((a, b) =>
      cmp(a, b, (a, b) => b > a ? -1 : 1)
    ),
    [NotAsked, NotAsked, Loading, Loading, Done(1), Done(2)],
  )
})
