# AsyncData

> A ReScript variant type to represent async data

## Installation

Run the following in your console:

```console
$ yarn add rescript-asyncdata
```

Then add `rescript-asyncdata` to your `bsconfig.json`'s `bs-dependencies`:

```diff
 {
   "bs-dependencies": [
+    "rescript-asyncdata"
   ]
 }
```

## Basics

**AsyncData** provides a variant type that helps you represent the state of an async request. The type consists of three tags:

- `NotAsked`: the request hasn't started yet
- `Loading`: the request has been initialised and we're waiting for a response
- `Done('a)`: the request has finished with `'a`

## Representing success & failure states

ReScript provides a `result<'ok, 'error>` type to represent an operation success.

You can combine `AsyncData.t` and `result` to represent a possible request failure state:

```reason
type userFromServer = AsyncData.t<result<User.t, exn>>
```

> Note that you can use your own error type in place of `exn`

Then, you can pattern match:

```reason
switch userFromServer {
| NotAsked => React.null
| Loading => <LoadingIndicator />
| Done(Error(error)) => <ErrorIndicator error />
| Done(Ok(user)) => <UserCard user />
}
```

## Representing reload

You can combine multiple `AsyncData.t` to represent more complex loading styles:

```reason
type reloadableUserFromServer = {
  userFromServer: userFromServer,
  userFromServerReload: userFromServer,
}

let initialState = {
  userFromServer: NotAsked,
  userFromServerReload: NotAsked
}

let firstLoad = {
  userFromServer: Loading,
  userFromServerReload: NotAsked
}

let firstLoadDone = {
  userFromServer: Done(Ok(user)),
  userFromServerReload: NotAsked
}

let reload = {
  userFromServer: Done(Ok(user)),
  userFromServerReload: Loading
}

// If you just want to replace the previous state
let reloadDone = {
  userFromServer: Done(Ok(newUser)),
  userFromServerReload: NotAsked
}

// If you want to compare/show a diff
let reloadDone = {
  userFromServer: Done(Ok(user)),
  userFromServerReload: Done(Ok(newUser))
}
```

## Utility functions

This package contains a few utility functions to manipulate `AsyncData.t`:

- `getExn`: Extract the `Done('a)` payload or throw
- `getWithDefault`: Extract the `Done('a)` payload or return a default value
- `mapWithDefault`: Extract and map the `Done('a)` payload or return a default value
- `map`: Map the `Done('a)` payload
- `flatMap`: Map the `Done('a)` payload with a callback that returns a `AsyncData.t`
- `isLoading`
- `isNotAsked`
- `isDone`
- `cmp`: For sorting
- `eq`: For comparison

## React hooks

This library provides a `ReactAsyncData` module that contains some usefull hooks:

### useAsyncData

Simple async data

```reason
let (data, setData) = useAsyncData() // NotAsked
setData(Loading) // Loading
setData(Done(1)) // Done(1)
```

### useAsyncReloadData

Simple async data with support for reload.

Return a record containing:
- `current`: after initial load, guaranteed to keep a `Done` state
- `next`: the reload request

```reason
let (data, setData) = useAsyncReloadData() // {current: NotAsked, next: NotAsked}
setData(Loading) // {current: Loading, next: Loading}
setData(Done(1)) // {current: Done(1), next: Done(1)}
setData(Loading) // {current: Done(1), next: Loading}
setData(Done(2)) // {current: Done(2), next: Done(2)}
```

Takes an optional `merge` to define how to set `current` when receiving a new `Done(x)` .
That can be useful if you want to compare the original and newly received data.

```
let (data, setData) = useAsyncReloadData(~merge=(a, _b) => a) // {current: NotAsked, next: NotAsked}
setData(Loading) // {current: Loading, next: Loading}
setData(Done(1)) // {current: Done(1), next: Done(1)}
setData(Loading) // {current: Done(1), next: Loading}
setData(Done(2)) // {current: Done(1), next: Done(2)}
```

### useAsyncPaginatedData

Simple async data with support for pagination

Return a record containing:
- `current`: after initial load, guaranteed to keep a `Done` state containing the aggregated data
- `next`: the next page request

```reason
let (data, setData) = useAsyncPaginatedData(~merge=Array.concat) // {current: NotAsked, next: NotAsked}
setData(Loading) // {current: Loading, next: Loading}
setData(Done([1, 2, 3])) // {current: Done([1, 2, 3]), next: Done([1, 2, 3])}
setData(Loading) // {current: Done([1, 2, 3]), next: Loading}
setData(Done([4, 5, 6])) // {current: Done([1, 2, 3, 4, 5, 6]), next: Done([4, 5, 6])}
```

## Aknowledgments

This is heavily inspired by Elm's [krisajenkins/remotedata](https://github.com/krisajenkins/remotedata)
