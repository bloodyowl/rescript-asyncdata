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
    let (user, setUser) = ReactAsyncData.useAsyncData()

    React.useEffect1(() => {
      setUser(Loading)
      User.get(id, user => {
        setUser(Done(user))
      })->Option.map((func, ()) => {
        setUser(NotAsked)
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

module AsyncWithReload = {
  @react.component
  let make = (~id) => {
    let (reloadableUser, setUser) = ReactAsyncData.useAsyncReloadData()
    let (reloadCount, setReloadCount) = React.useState(() => 0)

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

module AsyncWithPagination = {
  let merge = (a, b) => {
    switch (a, b) {
    | (Ok(a), Ok(b)) => Ok(Array.concat(a, b))
    | _ => a
    }
  }

  @react.component
  let make = () => {
    let (users, setUsers) = ReactAsyncData.useAsyncPaginatedData(~merge, ())
    let (page, setPage) = React.useState(() => 1)

    React.useEffect1(() => {
      setUsers(Loading)
      User.getPage(page, users => {
        setUsers(Done(users))
      })->Option.map((func, ()) => {
        setUsers(NotAsked)
        func()
      })
    }, [page])

    <div>
      {switch users.current {
      | NotAsked => React.null
      | Loading => "Loading ..."->React.string
      | Done(Error(_)) => "Error"->React.string
      | Done(Ok(items)) =>
        let list = items->Array.map(user => {
          <li key=user.id> {user.username->React.string} </li>
        })->React.array
        <>
          <ul> {list} </ul>
          {users.next->AsyncData.isLoading ? "Loading next page"->React.string : React.null}
          <button disabled={users.next->AsyncData.isLoading} onClick={_ => setPage(x => x + 1)}>
            {"Load next page"->React.string}
          </button>
        </>
      }}
    </div>
  }
}

module App = {
  @react.component
  let make = () => {
    <div> <Async id="1" /> <br /> <AsyncWithReload id="2" /> <br /> <AsyncWithPagination /> </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<App />, root)
| None => ()
}
