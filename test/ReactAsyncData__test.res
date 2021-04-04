open Test
open AsyncData
open ReactTestUtils
open Belt

@bs.val external window: {..} = "window"
@bs.send external remove: Dom.element => unit = "remove"

let createContainer = () => {
  let containerElement: Dom.element = window["document"]["createElement"]("div")
  let _ = window["document"]["body"]["appendChild"](containerElement)
  containerElement
}

let cleanupContainer = container => {
  ReactDOM.unmountComponentAtNode(container)
  remove(container)
}

let testWithReact = testWith(~setup=createContainer, ~teardown=cleanupContainer)

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

let isTrue = (~message=?, a: bool) => assertion(~message?, (a, b) => a == b, a, true)

testWithReact("useAsyncData", container => {
  act(() => {
    ReactDOM.render(<UseAsyncData />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent("div", "NotAsked")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncData step=1 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent("div", "Loading")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncData step=2 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent("div", "Done(1)")
  isTrue(value->Option.isSome)
})

testWithReact("useAsyncReloadData", container => {
  act(() => {
    ReactDOM.render(<UseAsyncReloadData />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "NotAsked")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "NotAsked")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=1 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Loading")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=2 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Done(1)")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=3 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=4 />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(2)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Done(2)")
  isTrue(value->Option.isSome)
})

testWithReact("useAsyncReloadData with merge", container => {
  let merge = (a, _b) => a
  act(() => {
    ReactDOM.render(<UseAsyncReloadData merge />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "NotAsked")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "NotAsked")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=1 merge />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Loading")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=2 merge />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Done(1)")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=3 merge />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Loading")
  isTrue(value->Option.isSome)

  act(() => {
    ReactDOM.render(<UseAsyncReloadData step=4 merge />, container)
  })

  let value = container->DOM.findBySelectorAndTextContent(".current", "Done(1)")
  isTrue(value->Option.isSome)
  let value = container->DOM.findBySelectorAndTextContent(".next", "Done(2)")
  isTrue(value->Option.isSome)
})
