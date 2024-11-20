# Notice: Repository Deprecation
This repository is deprecated and no longer actively maintained. It contains outdated code examples or practices that do not align with current MongoDB best practices. While the repository remains accessible for reference purposes, we strongly discourage its use in production environments.
Users should be aware that this repository will not receive any further updates, bug fixes, or security patches. This code may expose you to security vulnerabilities, compatibility issues with current MongoDB versions, and potential performance problems. Any implementation based on this repository is at the user's own risk.
For up-to-date resources, please refer to the [MongoDB Developer Center](https://mongodb.com/developer).

# Liberate your data: From RDBMS to Vector Search, GraphQL & Mobile ... in minutes!

Reduce the time it takes to modernize your applications by freeing the data trapped in your relational database and migrating to the next-gen fully transactional DB of MongoDB Atlas.

Power it with advanced vector and textual search, enable consumption via a fully-managed GraphQL API, and expose data to mobile and edge consumers via the Realm mobile DB and SDKs.

![Demo Architecture](./img/demo-components.jpg)

Watch a walkthrough of this demo here 
[![walkthrough](https://img.youtube.com/vi/OZZJ5RJKtCU/default.jpg)](https://www.youtube.com/watch?v=OZZJ5RJKtCU)

## Prerequisites

* A target DB environment - MongoDB Atlas Cluster
  - [Sign up for Atlas](https://www.mongodb.com/cloud/atlas/signup)
* A source DB environment - PostGreSQL
  - Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* The new MongoDB Relational Migrator - see [Info](https://www.mongodb.com/products/relational-migrator) for details.
  - Install a [Migrator Release](https://www.mongodb.com/products/relational-migrator)
* An OpenAI Account with an API Key generated
  - Consult the [OpenAI API reference](https://platform.openai.com/docs/api-reference)  
* A tool to generate API calls - Postman
  - Install [Postman](https://www.postman.com/downloads/)
* Upfront setup of the [Production Atlas App](./app-services/production-app/) is required as this contains triggers to automatically embed data as it is being migrated into the Atlas cluster.   
* A mobile application coding environment - Xcode with Swift
  - Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12#:~:text=View%20in-,Mac,-App%20Store) using App Store - see here for details on the how to download the SDK [Swift](https://developer.apple.com/swift/)
* Download and install the realm-cli by running:
  * ```npm install -g mongodb-realm-cli```


## Steps to Show the Migration and Mobile Deployment
### Clone the Github Repo
Clone the repo and change to the Repo directory

* ```git clone https://github.com/mongodb-developer/liberate-data.git && cd liberate-data```

### Create a PostgreSQL instance in Docker
* Build the image:

    ```
    docker build -t liberate-data-postgres .
    ```
* Launch a docker container for the Postgres instance by:

    ```
    docker run -d --name my-postgres -p "5432:5432" -e POSTGRES_PASSWORD=password --rm liberate-data-postgres -c wal_level=logical
    ```
* Validate the Northwind schema by running this command:

   ```shell
   docker exec -i my-postgres psql -U postgres <<EOF
   WITH tbl AS
   (SELECT table_schema, TABLE_NAME
   FROM information_schema.tables
   WHERE TABLE_NAME not like 'pg_%'
   AND table_schema in ('northwind'))
   SELECT table_schema, TABLE_NAME,
   (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, TABLE_NAME), FALSE, TRUE, '')))[1]::text::int AS rows_n
   FROM tbl
   ORDER BY rows_n DESC;
   \q
   EOF

   ```

The output should look like this...

```shell

------------------------------------------------
 table_schema |       table_name       | rows_n 
--------------+------------------------+--------
 northwind    | order_details          |   2155
 northwind    | orders                 |    830
 northwind    | customers              |     91
 northwind    | products               |     77
 northwind    | territories            |     53
 northwind    | us_states              |     51
 northwind    | employee_territories   |     49
 northwind    | suppliers              |     29
 northwind    | employees              |      9
 northwind    | categories             |      8
 northwind    | shippers               |      6
 northwind    | region                 |      4
 northwind    | customer_customer_demo |      0
 northwind    | customer_demographics  |      0

```

### Build a MongoDB Atlas Cluster
We build a small Atlas cluster to serve as the target DB and then as the back-end for the mobile app.

* Login to MongoDB Atlas: [Login](https://account.mongodb.com/account/login)
* Create an Atlas Project named `Liberate Data`
* Create a single region Atlas M10 cluster named `production` at version 6.0+. *do not use another name*
* Create a db user named `demo` with `readWriteAnyDatabase` permissions.
* Add your IP (or 0.0.0.0.0) to the Access List
* Get your cluster connection string.

### MongoDB Relational Migrator
In this segment, the PostgreSQL DB will be migrated to the MongoDB cluster.

* Start the Mongodb Relational Migrator app - or click to reconnect [Migrator](http://127.0.0.1:8278/)
* Click `Import project file` and select the project file: `./relational-migrator/liberate-data.relmig`
* Inspect the Relational and MDB diagrams. Notice how the `orders` collection uses the [Extended Reference](https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern) schema design pattern to store most frequently accessed data together.
* The destination `orders` collection should look like this:
  * ![Orders collection mapping](./img/orders_mappings.jpg)
* Perform the database migration
  - Start a Data Migration Job by clicking on the other top tab along side Mapping
  - Click on `Create sync job`
  - Connect to your Source DB (postgres)
    - Postgres Credentials: Username = `postgres` / Password = `password`
  - Connect to your Destination DB (Mongodb)
    - enter the Mongodb Connection string (use northwind db)
    - Like: `mongodb+srv://demo:demo@production.3sov9.mongodb.net/northwind?retryWrites=true&w=majority`
  - Click Start
* When this job is complete, validate the outcome in the MongoDB cluster
  - In the Atlas UI, ensure all the collections were migrated.
  - Inspect the `orders` collection. The most frequently accessed data from `orderDetails`, `product`, `customer` & `employee` should be nested.

### Enable MongoDB Atlas Search
These steps build Search indexes on the `orders` and `categories` collection enable one to run queries via Atlas Search.

* Create a default search index with dynamic mappings on the `orders` collection.
  ![orders index](./img/orders-index.gif)
* Create a default search index with dynamic mappings on the `categories` collection.
  ![categories index](./img/categories-index.gif)
* See [search-indexes.json](./atlas/search-indexes.json) for index definitions.


### Configure MongoDB Data Services
Now we careate a public/private key pair that will be used to authenticate the realm-cli.

* Create an API Key Pair. Save these values for deployment in the [production-app](./app-services/) in the next section.
* Description: `Liberate Data`
* Project Permissions: `Project Owner`
  ![Create Key Pair](./img/create-keypair.gif)
* Save Key Pair to Terminal variables
```
export PUB_KEY=<REPLACEME>
export PRIV_KEY=<REPLACEME>
```
![Save Vars](./img/save-vars.gif)

### Setup MongoDB Atlas App Services
In this section, you will deploy an Atlas Application [production-app](./app-services/) from your local machine to Atlas. [production-app](./app-services/) contains all the preconfigured <b>Linked Data Sources</b>, <b>Rules</b>, <b>Schema</b>, <b>Device Sync</b>, <b>GraphQL</b>, <b>Functions</b> and <b>Custom Resolvers</b> you will need to complete this demo.

* In a terminal shell, authenticate to the realm-cli by running this:
    ```
    realm-cli login --api-key $PUB_KEY --private-api-key $PRIV_KEY
    ```            
  * If prompted with `This action will terminate blah blah blah`, just proceed with `y`
  * When you see `Successfully logged in`, chances are you're successfully logged in.
* Deploy the production-app from the root of this repo project.
  * NOTE: If your cluster is not named `production` this command will fail. Either create a new cluster named `production`, or update the `config.clusterName` in the [config.json](./app-services/production-app/data_sources/mongodb-atlas/config.json)

  * Then run this:
    ```
    realm-cli push --local app-services/production-app
    ```
* Accept all the default prompts. The following message indicates success:

    ```
    Creating draft
    Pushing changes
    Deploying draft
    Deployment complete
    Successfully pushed app up: production
    ```
#### Configure the App Service
Now finalize the application setup by creating an application API key which will be used in the next steps.
* In the browser for your MongoDB Cluster, click on the App Services Tab.
* Click on the Production App item.
* Grab the App Id value - should be something like: production-app-*xxxxx*
* Now, go to Authentication from the left panel
* Click on the `EDIT` button for the API Keys row and `Click create API Key` - capturing this value too.
* Now click on GraphQL from the left panel and capture GraphQL Endpoint value.
  ![App services key](./img/app-svc-key.gif)
* Add your OpenAI API Key in the `openAI_secret` in the `Values` section  

#### Validate the App Service Deployment
Walk through the following steps to show that the app service is configured properly.

* <b>Linked Data Sources</b>: Inspect that the `production` cluster is linked as the data source.
* <b>Rules</b>: The `orders` collection should have the `readAndWriteAll` role. All other collections should have the `readAll` role.
* <b>Schema</b>: Ensure the schema for all collections is defined. The schema for the `orders` collection should define required fields as below in addition to their bson types:
```
{
  "title": "order",
  "required": [
    "_id",
    "customerId",
    "employeeId",
    "freight",
    "orderDate",
    "shipAddress",
    "shipCity",
    "shipCountry",
    "shipName",
    "shipPostalCode",
    "shipRegion",
    "shipVia",
    "shippedDate"
  ],
  ...
}
```
* <b>Authentication</b>: Two authentication providers should be enabled: `email/password` and `API Keys`. The API key named `demo` was created by you.
* <b>Device Sync</b>: Flexible device sync should be enabled, set to the linked atlas cluster and the northwind database.
* <b>GraphQL</b>: All entity types should be defined along with two custom resolvers named `searchOrders` and `vectorSearchOrders` which are linked to the Atlas Functions named `funcSearchOrders` and `funcVectorSearchOrders` respectively.

### Use Postman for API testing
This step will allow one to run queries via GraphQL. This will show that the API is working as expected.

* Startup the **Postman** app and import the collection file: ``postman/liberate-data - GraphQL.postman_collection.json```

* In **My Workspace**, Click **Collections** in left panel.
* Click on the "Liberate data!" heading and then in the middle panel, click on Variables.
* Then enter the three variable `api_key`,`atlas_app_id`, and `graphql_api` - using the values previous gathered in the CURRENT VALUE column.
  * Note: Obtain the GraphQL API (`graphql_api`) endpoint value from the GraphQL section in Atlas App Services.
    * See this diagram from an example: ![Postman variable](./img/postman-variables.jpg)

* Click Save
* Execute the 1st POST operation `Auth: Get Bearer & Access Token` to authenticate and obtain tokens by hitting the blue Send button.
* If successful, copy/save the value of the output `access_token` - without the quotes - to be used in the other queries.

* Now, execute any of the other operations after inserting the `access_token` value in the **Authorization** tab. Feel free to change query values.

* The `Vector Search: Semantic search on Orders` operation uses a custom resolver which in turn executes an Atlas Vector Search pipeline. This pipeline is implemented in the `funcVectorSearchOrders` function and performs a real-time embedding of the search string against OpenAI and performs a vector search.

* The `Search: Orders by search string` operation uses a custom resolver which in turn executes an Atlas Search pipeline. This pipeline is implemented in the `funcSearchOrders` function and performs a fuzzy text search on the `orders` collection, plus a union (`$unionWith`) and join (`$lookup`) to the `categories` collection, thus performing a text search on orders and categories.

### Swift mobile app with Realm SDK

This segment shows a mobile app built with MongoDB Realm for an Apple iPhone communicating with a MongoDB Atlas database.

* Start up **Xcode**
* Open the the Swift app called `App.xcodeproj` under the [app-swift](./app-swift/) folder.
* In the App section, open the Realm object and replace the `appId` and  `appUrl`. Compile and run.
  * The `appId` was captured earlier.
  * The `appUrl` is found on the browser by by clicking on tApp Services `production-app` and copying the URL up to the `/dashboard` ending.
  * ![Swift Realm config](./img/swift-app-config.jpg)
* In the mobile app, register with a new user via an email and password.
* Browse orders. For the purpose of this demo, all users have access to all orders.

### Atlas Device Sync

In this final segment, one can show Atlas Device Sync. This shows changes in data are propagated from Mobile App to Atlas Cluster (or the reverse) **immediately**.

* Modify an order using the mobile app.
* Open the same Order document in Atlas or Compass and notice the changes. Now modify the same order and the changes will be reflected on the mobile app. Atlas Device Sync works.
* Finally, run the `Mutation: Change a Sales Order` GraphQL operation in postman. Change the Order ID and any fields in the order body. The changes should reflect in the mobile app.
