open Belt

// The following module is just a mock for an API
module User = {
  type t = {
    id: string,
    username: string,
    fetchedAt: float,
  }
  type error
  let get = (id: string, cb: result<t, error> => unit) => {
    Js.Console.log(`get(${id}): init`)
    let timeoutId = Js.Global.setTimeout(() => {
      Js.Console.log(`get(${id}): receive`)
      let payload = {id: id, username: `User${id}`, fetchedAt: Js.Date.now()}
      cb(Ok(payload))
    }, 1_000)
    Some(
      () => {
        Js.Console.log(`get(${id}): cancel`)
        Js.Global.clearTimeout(timeoutId)
      },
    )
  }
  let getPage = (page: int, cb: result<array<t>, error> => unit) => {
    Js.Console.log(`getPage(${page->Int.toString}): init`)
    let timeoutId = Js.Global.setTimeout(() => {
      Js.Console.log(`getPage(${page->Int.toString}): receive`)
      let payload = Array.range(0, 9)->Array.map(index => {
        let id = ((page - 1) * 10 + index)->Int.toString
        {
          id: id,
          username: `User${id}`,
          fetchedAt: Js.Date.now(),
        }
      })
      cb(Ok(payload))
    }, 1_000)
    Some(
      () => {
        Js.Console.log(`getPage(${page->Int.toString}): cancel`)
        Js.Global.clearTimeout(timeoutId)
      },
    )
  }
}

module Async = {
  @react.component
  let make = (~id) => {
    let (user, setUser) = React.useState(() => AsyncData.NotAsked)

    React.useEffect1(() => {
      setUser(_ => Loading)
      User.get(id, user => {
        setUser(_ => Done(user))
      })->Option.map((func, ()) => {
        setUser(_ => NotAsked)
        func()
      })
    }, [id])

    <div>
      {switch user {
      | NotAsked => React.null
      | Loading => "Loading ..."->React.string
      | Done(Error(_)) => "Error"->React.string
      | Done(Ok(user)) => user.username->React.string
      }}
    </div>
  }
}

type reload<'a> = {current: AsyncData.t<'a>, next: AsyncData.t<'a>}

module AsyncWithReload = {
  @react.component
  let make = (~id) => {
    let (reloadableUser, setUser) = React.useState(() => {current: NotAsked, next: NotAsked})
    let (reloadCount, setReloadCount) = React.useState(() => 0)

    let setUser = React.useCallback0((next: AsyncData.t<result<User.t, User.error>>) => {
      setUser(state => {
        current: switch (state.current, next) {
        | (Done(_), Done(next)) => Done(next)
        | (NotAsked | Loading, next) => next
        | _ => state.current
        },
        next: next,
      })
    })

    React.useEffect2(() => {
      if mod(reloadCount, 2) == 0 {
        let userRollback = reloadableUser.next
        setUser(Loading)
        User.get(id, user => {
          setUser(Done(user))
        })->Option.map((func, ()) => {
          setUser(userRollback)
          func()
        })
      } else {
        None
      }
    }, (id, reloadCount))

    <div>
      {switch reloadableUser.current {
      | NotAsked => React.null
      | Loading => "Loading ..."->React.string
      | Done(Error(_)) => "Error"->React.string
      | Done(Ok(user)) => <>
          {user.username->React.string}
          <small> {user.fetchedAt->React.float} </small>
          {reloadableUser.next->AsyncData.isLoading ? "Reloading ..."->React.string : React.null}
          <button onClick={_ => setReloadCount(x => x + 1)}> {"Reload"->React.string} </button>
        </>
      }}
    </div>
  }
}

module App = {
  @react.component
  let make = () => {
    <div> <Async id="1" /> <br /> <AsyncWithReload id="2" /> </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<App />, root)
| None => ()
}
