# Liberate your data: Move from an RDBMS to MongoDB to leverage Search and GraphQL for Mobile

Reduce the time it takes to modernize your applications by freeing the data trapped in your relational database and migrating to the next-gen fully transactional DB of MongoDB Atlas. Powering it with advanced lucene-based search, enable API consumption via fully-managed GraphQL, and expose to mobile and edge consumers via the Realm mobile DB and SDK’s. 

![Demo Architecture](./img/demo-components.jpg)

## Prerequisites
* MongoDB Atlas Cluster
   - [Sign up for Atlas](https://www.mongodb.com/cloud/atlas/signup)
* Docker Desktop 4+
   - Install Docker Desktop: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* MongoDB Relational Migrator (see here for [Info](https://www.mongodb.com/products/relational-migrator)).
   - Install a release: [Migrator Releases](https://github.com/mongodb-ets/migrator/releases)
* Postman 
	- Install Postman from here: [Postman](https://www.postman.com/downloads/)
* XCode with Swift
	- Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12#:~:text=View%20in-,Mac,-App%20Store) using App Store - see here for details on the SDK [Swift](https://developer.apple.com/swift/) 


## Steps
### Clone the Github Repo
1. Run the following command

   `git clone https://github.com/mongodb-developer/liberate-data.git`
   
2. Go to the repo folder

   `cd liberate-data`
   
### Create a PostgreSQL instance in Docker
1. Build the docker image by: 
	
	`docker build -t liberate-data-postgres .`
2. Launch a docker container for the Postgres instance by:
   
   `docker run -d --name my-postgres -p "5432:5432" -e POSTGRES_PASSWORD=password --rm liberate-data-postgres -c wal_level=logical`
   
3. Validate the Northwind schema by running this command:

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
the output should look this...

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

#### Configure a MongoDB Atlas Cluster
1. Login to Atlas: [Login](https://account.mongodb.com/account/login)
2. Create an Atlas Project named `Liberate Data` 
3. Create an Atlas M10 cluster named `production`.
4. Create a db user named `demo` with `readWriteAnyDatabase` permissions.
5. Add your IP to the Access List
6. Create Atlas cluster named `production`.
7. Get your cluster connection string.

#### Migrate the local DB to Atlas with MongoDB Relational Migrator

1. Start the Mongodb Relational Migrator app - or click to reconnect [Migrator](http://127.0.0.1:8278/)
2. Click `Import project file` and select the project file: `./relational-migrator/liberate-data.relmig`
3. Inspect the Relational and MDB diagrams. Notice how the `Orders` collection uses the [Subset](https://www.mongodb.com/blog/post/building-with-patterns-the-subset-pattern) schema design pattern to store most frequently accessed data together.
4. The destination Orders collection should look like this:
![Orders collection mapping](./img/orders_mappings.jpg)
5. Perform the database migration
	- Start a Data Migration Job by clicking on the other top tab along side Mapping
	- Click on `Create sync job`
	- Connect to your Source DB (postgres)
		- Postgres Credentials: Username = `postgres` / Password = `password`
	- Connect to your Destination DB (Mongodb)
		- enter the Mongodb Connection string (use northwind db)
		- Like: `mongodb+srv://demo:demo@production.3sov9.mongodb.net/northwind?retryWrites=true&w=majority`
   - Click Start 
6. When this job is complete, validate the outcome in the MongoDB cluster
	- In the Atlas UI, ensure all the collections were migrated. 
	- Inspect the `orders` collection. 
	- A subset of the data from orderDetails, product, customer & employee should be nested.

#### Configure MongoDB Atlas Search
1. In the Atlas UI, create a default search index with dynamic mappings on the `orders` and `categories` collections. 
	- See [search-indexes.json](./atlas/search-indexes.json) for their definition.

#### Setup the MongoDB Atlas App Services
1. Import the Atlas Application [production-app](./app-services/) into the Atlas project.
2. <b>Linked Data Sources</b>: Inspect that the `production` cluster is linked as the data source.
3. <b>Rules</b>: The `orders` collection should have the `readAndWriteAll` role. All other collections should have the `readAll` role. 
4. <b>Schema</b>: Ensure the schema for all collections is defined. The schema for the `orders` collection should define required fields as below in addition to their bson types:
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
5. <b>Authentication</b>: Two authentication providers should be enabled: `email/password` and `API Keys`. An API key named `demo` should be (re)created by you.
6. <b>Device Sync</b>: Flexible device sync should be enabled, set to the linked atlas cluster and the northwind database.
7. <b>GraphQL</b>: All entity types should be defined along with a custom resolver named `searchOrders`, which itself is linked to an Atlas Function named `funcSearchOrders`.

#### Use Postman to connect to the Atlas Cluster to run a Search Query
1. With Postman, import the [liberate-data - GraphQL](./postman/liberate-data%20-%20GraphQL.postman_collection.json) postman collection.
2. In the collection variables, enter the `api_key` and `atlas_app_id` values. Obtain the GraphQL API endpoint from the GraphQL section in Atlas App Services and set in the `graphql_api` variable.
![Postman variable](./img/postman-variables.jpg)
3. Execute the 1st POST operation `Auth: Get Bearer & Access Token` to authenticate and obtain tokens.
4. Execute all other operations in any order. Feel free to change query values.
5. The `Search: Orders by search string` operation uses a custom resolver which in turn executes an Atlas Search pipeline. This pipeline is implemented in the `funcSearchOrders` function and performs a fuzzy text search on the `orders` collection, plus a union (`$unionWith`) and join (`$lookup`) to the `categories` collection, thus performing a text search on orders and categories.

#### Swift mobile app with Realm SDK
1. With Xcode, open the swift app under the [app-swift](./app-swift/) folder. 
2. Open the Realm object and replace the `appId` and  `appUrl`. Compile and run.
![Swift Realm config](./img/swift-app-config.jpg)
3. In the mobile app, register with a new user via an email and password. 
4. Browse orders. For the purpose of this demo, all users have access to all orders.

#### Atlas Device Sync
1. Modify an order using the mobile app.
2. Open the same Order document in Atlas or Compass and notice the changes. Now modify the same order and the changes will be reflected on the mobile app. Atlas Device Sync works.
3. Finally, run the `Mutation: Change a Sales Order` GraphQL operation in postman. Change the Order ID and any fields in the order body. The changes should reflect in the mobile app.