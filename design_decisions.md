# Design decisions

## How the app works in high-level

### Report generation

1. Server has asset table, which has the symbols and names of the assets to be queried through API.
2. Server queries the API for the assets, and generates a price table each 6 hours, and stores these
   price tables.
3. When client becomes online, it fetches the price tables it missed from the server.
4. Then, client creates snapshots for each 6 hours it missed (it can do so, since it has the price
   tables now).
    - say client was offline for 30 hours. when it is back online again, it will fetch the last 5
      price tables,
    - and there were no new transactions, since the client was offline,
    - it will create 5 snapshots, using the current assets and 5 price tables.
5. report will be generated on the client-side by utilizing the snapshots,

### Storing Transactions and Snapshots

1. Server does not store client's snapshots.
2. Server only stores transactions, which can be processed on the client side to generate snapshots
   if needed.
3. When client records new transactions, it also sends them to server, and server stores them.
4. Client does not store transaction, because it does not need to. It is already storing snapshots,
   and transactions are only needed to generate snapshots.
5. If client somehow loses snapshots (it could be that client switches to a new device, or offloads
   the app), client will simply query the server for fetching the transactions, and build the
   snapshots that it is currently missing.

## Data

### Crypto asset data format differences

- We will treat crypto assets differently
    - stock and forex market have unique symbols, that's not the case for crypto
    - for crypto, we need unique identifiers. In our case, they are coingecko ID's
    - we display the symbol `BTC` to the user, but we query the API with `bitcoin`
    - this mapping will be stored in `assets` document under `server` collection
    - client will fetch this information from server
    - when client is displaying the name of the asset to the user, it will use the symbol (`BTC`)
    - all the communication between server-client will be done with the coingeckoID (`bitcoin`)
    - mapping one to another, is the responsibility of the client, because:
        - client has enough information to perform this mapping
        - and also, server does not need SYMBOL for api queries

## Server-Side

### Server responsibilities

- We cannot rely on client device's availability. So, the following should be done by the server:
    - having an asset table that will be used to query the api's for price tables
    - fetching price tables regularly
    - storing the transaction log for each client
        - since this will be an ever-growing data, we will be rotating yearly (firebase's limit is
          1MB per doc)
- The data will be exposed to clients (for both read/write) only via cloud functions
    - cloud functions are not subject to firestore rules, since they are run in a trusted server
    - restricting every file in database for client access (for both read/write) is our approach

## Client-side

### Client responsibilities

- fetching asset table from server, and storing it in local storage for the future
- fetching price tables from server, and storing them in local storage for the future
- sending a copy of the transactions (after compressing them) to the server, so that server can back
  up the
  client's history
- generating snapshots from the transactions
- generating reports from the snapshots
- knowing when will server have updates ready.
    - in fact, server could notify the client on when will the next update be available,
    - but that would require extra communication between server and client
    - and, I want to minimize the costs for:
        - firebase cloud function invocations
        - server side computation
    - so, although it is bringing some coupling, I've chosen to go with burdening the client instead

### Asset deletion

- deletion is not allowed for assets that are present in snapshots, since that would complicate a
  lot of things
    - when the user clicks on delete button, we will only make the amount 0
    - the assets with `0 amount`, are hidden in the most of the UI for simplicity and minimalism
- if the asset is not present in any snapshots (say, it has been added accidentally just 2 seconds
  ago), deletion will actually delete it instead of making the amount 0

### New Asset Addition

- we could disallow adding a new asset, if to be added asset is already present in the typeMap
  and categoryMap
- however, in this case, user will be confused. They will get `asset already exists` error, yet the
  asset might be hidden in UI
    - consider assets with 0 amount (hidden ones)
- that's why, we allow adding a new asset, even if it exists. Asset addition works in the following
  way:
    - if asset does not exist, simply add it
    - if asset does exist:
        - add the given amount to the previous amount
        - compare the old category of the existing asset with the given new category
            - if they are different, move the asset from old category to new one

### AssetType and Category design

- We are allowing custom categories, so we can't get away with a single map that only consists
  of `assetType` -> (`assetId`, `assetData`)
- we can somehow stick `category` information to the value part of `assetType` map, but then queries
  related to `category` would be inefficient:
    - fetching all the assets under a specific category would require traversing the whole map. This
      is very inefficient
    - `category` related queries happening a lot in the application (category pages, report
      generation)
- we can't have only a single `categoryMap`, and store the `assetType` information in the value part
  as well:
    - due to, `assetType` related queries also happen frequently (price update for each day, etc.)
- solution is, to have 2 separate maps: `categoryMap` and `assetTypeMap`:
    - to reduce duplication:
        - `assetData` will only be stored in `assetTypeMap`
        - `categoryMap` will only store a tuple of (AssetType, AssetID)
        - `assetTypeMap` will store an inner mapping, where key is: `AssetID`, and value is `Asset`
            - where `Asset` is a struct, with fields: `amount`, `price`, `category`
    - this way, we can efficiently query `AssetID`s based on both `category` and `assetType`
    - also, we can retrieve the `category` or `assetType` information from both maps
- another solution might be using doubleMap (map with 2 keys), feel free to open a PR about that if
  you feel adventurous!

### Transaction compressing

- say, the user bought 0.5 eth, and after 2 seconds, he sold 0.5 eth (effectively, he did nothing),
  then he pressed `save all` in the edit assets page
- when `save all` button is triggered, client will compress all the transactions (merge the
  transactions for the same asset under one), and send them to server like that
- in fact, server should compress them a second time (because, the user might buy 0.5 eth,
  hit `save all`, then sold 0.5 eth, and hit `save all` again in succession). But server is not
  doing that, the reasons are:
    - server needs to look at the previous transactions for that (and worst case, because of the
      rotation, server needs to parse 2 document's content)
    - this means, 2 additional read cost per each transaction submit to the server by the client
      side
    - also, this means extra CPU usage cost for the server
    - the benefit is very minimal, doesn't worth the extra cost (both server costs, and developer
      costs)
    - client will have an additional logic to compensate
    - the additional cost to client is only more cpu usage, and happens only when client fetches
      transactions from the server (which should happen only once per fresh device)

## Not-features:

- Adding retroactive transactions should not be possible. Because they introduce the following
  complexities:
    - if there isn't any snapshot for that date, have to create the snapshot, and add that asset
        - now, when are doing comparison based on dates, what will happen to other snapshots where
          this asset might be missing?
    - if there is already a snapshot with the given asset, should we accept this manual addition?
      Maybe user made a mistake, and it will override the actual/correct data.
    - the API needs to change as well
    - not a common use case, and this can be opening a can of worms. So, better to avoid it
