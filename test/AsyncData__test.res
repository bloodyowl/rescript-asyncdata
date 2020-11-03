open TestFramework
open AsyncData

describe("AsyncData", ({test}) => {
  test("getExn", ({expect}) => {
    expect.value(
      try getExn(NotAsked) catch {
      | _ => Not_found
      },
    ).toEqual(Not_found)
    expect.value(
      try getExn(Loading) catch {
      | _ => Not_found
      },
    ).toEqual(Not_found)
    expect.value(getExn(Done(1))).toEqual(1)
  })

  test("mapWithDefaultU", ({expect}) => {
    expect.int(NotAsked->mapWithDefaultU(0, (. value) => value + 1)).toBe(0)
    expect.int(Loading->mapWithDefaultU(0, (. value) => value + 1)).toBe(0)
    expect.int(Done(1)->mapWithDefaultU(0, (. value) => value + 1)).toBe(2)
  })

  test("mapWithDefault", ({expect}) => {
    expect.int(NotAsked->mapWithDefault(0, value => value + 1)).toBe(0)
    expect.int(Loading->mapWithDefault(0, value => value + 1)).toBe(0)
    expect.int(Done(1)->mapWithDefault(0, value => value + 1)).toBe(2)
  })

  test("mapU", ({expect}) => {
    expect.value(NotAsked->mapU((. value) => value + 1)).toEqual(NotAsked)
    expect.value(Loading->mapU((. value) => value + 1)).toEqual(Loading)
    expect.value(Done(1)->mapU((. value) => value + 1)).toEqual(Done(2))
  })

  test("map", ({expect}) => {
    expect.value(NotAsked->map(value => value + 1)).toEqual(NotAsked)
    expect.value(Loading->map(value => value + 1)).toEqual(Loading)
    expect.value(Done(1)->map(value => value + 1)).toEqual(Done(2))
  })

  test("flatMapU", ({expect}) => {
    expect.value(NotAsked->flatMapU((. value) => Done(value + 1))).toEqual(NotAsked)
    expect.value(Loading->flatMapU((. value) => Done(value + 1))).toEqual(Loading)
    expect.value(Done(1)->flatMapU((. value) => Done(value + 1))).toEqual(Done(2))
    expect.value(Done(1)->flatMapU((. _) => Loading)).toEqual(Loading)
    expect.value(Done(1)->flatMapU((. _) => NotAsked)).toEqual(NotAsked)
  })

  test("flatMap", ({expect}) => {
    expect.value(NotAsked->flatMap(value => Done(value + 1))).toEqual(NotAsked)
    expect.value(Loading->flatMap(value => Done(value + 1))).toEqual(Loading)
    expect.value(Done(1)->flatMap(value => Done(value + 1))).toEqual(Done(2))
    expect.value(Done(1)->flatMap(_ => Loading)).toEqual(Loading)
    expect.value(Done(1)->flatMap(_ => NotAsked)).toEqual(NotAsked)
  })

  test("getWithDefault", ({expect}) => {
    expect.value(NotAsked->getWithDefault(1)).toEqual(1)
    expect.value(Loading->getWithDefault(1)).toEqual(1)
    expect.value(Done(2)->getWithDefault(1)).toEqual(2)
  })

  test("isLoading", ({expect}) => {
    expect.value(NotAsked->isLoading).toEqual(false)
    expect.value(Loading->isLoading).toEqual(true)
    expect.value(Done(2)->isLoading).toEqual(false)
  })

  test("isDone", ({expect}) => {
    expect.value(NotAsked->isDone).toEqual(false)
    expect.value(Loading->isDone).toEqual(false)
    expect.value(Done(2)->isDone).toEqual(true)
  })

  test("isNotAsked", ({expect}) => {
    expect.value(NotAsked->isNotAsked).toEqual(true)
    expect.value(Loading->isNotAsked).toEqual(false)
    expect.value(Done(2)->isNotAsked).toEqual(false)
  })

  test("eqU", ({expect}) => {
    expect.value(eqU(NotAsked, NotAsked, (. a, b) => a === b)).toEqual(true)
    expect.value(eqU(Loading, Loading, (. a, b) => a === b)).toEqual(true)
    expect.value(eqU(NotAsked, Loading, (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Loading, NotAsked, (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(NotAsked, Done(1), (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Loading, Done(1), (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Done(1), NotAsked, (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Done(1), Loading, (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Done(1), Done(1), (. a, b) => a === b)).toEqual(true)
    expect.value(eqU(Done(1), Done(2), (. a, b) => a === b)).toEqual(false)
    expect.value(eqU(Done(2), Done(1), (. a, b) => a === b)).toEqual(false)
  })

  test("eq", ({expect}) => {
    expect.value(eq(NotAsked, NotAsked, (a, b) => a === b)).toEqual(true)
    expect.value(eq(Loading, Loading, (a, b) => a === b)).toEqual(true)
    expect.value(eq(NotAsked, Loading, (a, b) => a === b)).toEqual(false)
    expect.value(eq(Loading, NotAsked, (a, b) => a === b)).toEqual(false)
    expect.value(eq(NotAsked, Done(1), (a, b) => a === b)).toEqual(false)
    expect.value(eq(Loading, Done(1), (a, b) => a === b)).toEqual(false)
    expect.value(eq(Done(1), NotAsked, (a, b) => a === b)).toEqual(false)
    expect.value(eq(Done(1), Loading, (a, b) => a === b)).toEqual(false)
    expect.value(eq(Done(1), Done(1), (a, b) => a === b)).toEqual(true)
    expect.value(eq(Done(1), Done(2), (a, b) => a === b)).toEqual(false)
    expect.value(eq(Done(2), Done(1), (a, b) => a === b)).toEqual(false)
  })

  test("cmpU", ({expect}) => {
    open Belt
    expect.value(
      [Done(2), NotAsked, Loading, Loading, Done(1), NotAsked]->SortArray.stableSortBy((a, b) =>
        cmpU(a, b, (. a, b) => b > a ? -1 : 1)
      ),
    ).toEqual([NotAsked, NotAsked, Loading, Loading, Done(1), Done(2)])
  })

  test("cmp", ({expect}) => {
    open Belt
    expect.value(
      [Done(2), NotAsked, Loading, Loading, Done(1), NotAsked]->SortArray.stableSortBy((a, b) =>
        cmp(a, b, (a, b) => b > a ? -1 : 1)
      ),
    ).toEqual([NotAsked, NotAsked, Loading, Loading, Done(1), Done(2)])
  })
})
