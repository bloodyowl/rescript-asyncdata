open TestFramework
open AsyncData
open ReactTestUtils
open Belt

module UseAsyncData = {
  @react.component
  let make = (~step=0) => {
    let (data, setData) = ReactAsyncData.useAsyncData()

    React.useEffect1(() => {
      switch step {
      | 0 => ()
      | 1 => setData(Loading)
      | 2 => setData(Done(1))
      | _ => ()
      }
      None
    }, [step])

    <div>
      {React.string(
        switch data {
        | NotAsked => "NotAsked"
        | Loading => "Loading"
        | Done(value) => `Done(${Js.Json.stringifyAny(value)->Option.getWithDefault("")})`
        },
      )}
    </div>
  }
}

module UseAsyncReloadData = {
  @react.component
  let make = (~step=0, ~merge=?) => {
    let (data, setData) = ReactAsyncData.useAsyncReloadData(~merge?, ())

    React.useEffect1(() => {
      switch step {
      | 0 => ()
      | 1 => setData(Loading)
      | 2 => setData(Done(1))
      | 3 => setData(Loading)
      | 4 => setData(Done(2))
      | _ => ()
      }
      None
    }, [step])

    <div>
      <div className="current">
        {React.string(
          switch data.current {
          | NotAsked => "NotAsked"
          | Loading => "Loading"
          | Done(value) => `Done(${Js.Json.stringifyAny(value)->Option.getWithDefault("")})`
          },
        )}
      </div>
      <div className="next">
        {React.string(
          switch data.next {
          | NotAsked => "NotAsked"
          | Loading => "Loading"
          | Done(value) => `Done(${Js.Json.stringifyAny(value)->Option.getWithDefault("")})`
          },
        )}
      </div>
    </div>
  }
}

module UseAsyncPaginatedData = {
  @react.component
  let make = (~step=0, ~merge) => {
    let (data, setData) = ReactAsyncData.useAsyncPaginatedData(~merge, ())

    React.useEffect1(() => {
      switch step {
      | 0 => ()
      | 1 => setData(Loading)
      | 2 => setData(Done([1, 2, 3]))
      | 3 => setData(Loading)
      | 4 => setData(Done([4, 5, 6]))
      | _ => ()
      }
      None
    }, [step])

    <div>
      <div className="current">
        {React.string(
          switch data.current {
          | NotAsked => "NotAsked"
          | Loading => "Loading"
          | Done(value) => `Done(${Js.Json.stringifyAny(value)->Option.getWithDefault("")})`
          },
        )}
      </div>
      <div className="next">
        {React.string(
          switch data.next {
          | NotAsked => "NotAsked"
          | Loading => "Loading"
          | Done(value) => `Done(${Js.Json.stringifyAny(value)->Option.getWithDefault("")})`
          },
        )}
      </div>
    </div>
  }
}

describe("AsyncData", ({test, beforeEach, afterEach}) => {
  let container = ref(None)

  beforeEach(prepareContainer(container))
  afterEach(cleanupContainer(container))

  test("useAsyncData", ({expect}) => {
    let container = getContainer(container)

    act(() => {
      ReactDOMRe.render(<UseAsyncData />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent("div", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncData step=1 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent("div", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncData step=2 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent("div", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
  })

  test("useAsyncReloadData", ({expect}) => {
    let container = getContainer(container)

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=1 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=2 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=3 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=4 />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(2)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done(2)")
    expect.bool(value->Option.isSome).toBeTrue()
  })

  test("useAsyncReloadData with merge", ({expect}) => {
    let container = getContainer(container)
    let merge = (a, _b) => a
    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=1 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=2 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=3 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncReloadData step=4 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done(2)")
    expect.bool(value->Option.isSome).toBeTrue()
  })

  test("useAsyncPaginatedData", ({expect}) => {
    let container = getContainer(container)
    let merge = Array.concat
    act(() => {
      ReactDOMRe.render(<UseAsyncPaginatedData merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "NotAsked")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncPaginatedData step=1 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncPaginatedData step=2 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done([1,2,3])")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done([1,2,3])")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncPaginatedData step=3 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done([1,2,3])")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
    expect.bool(value->Option.isSome).toBeTrue()

    act(() => {
      ReactDOMRe.render(<UseAsyncPaginatedData step=4 merge />, container)
    })

    let value = container->DOM.findBySelectorAndTextContent(".current", "Done([1,2,3,4,5,6])")
    expect.bool(value->Option.isSome).toBeTrue()
    let value = container->DOM.findBySelectorAndTextContent(".next", "Done([4,5,6])")
    expect.bool(value->Option.isSome).toBeTrue()
  })
})
