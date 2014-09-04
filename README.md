# Example Neo4j Application [![Build Status](https://travis-ci.org/pivotal-cf/cf-neo4j-example-app.svg)](https://travis-ci.org/pivotal-cf/cf-neo4j-example-app)

This simple application illustrates the use of the Pivotal Neo4j data service in a Ruby application running on Pivotal Cloud Foundry.

## Installation

#### Push the Example Application

The example application comes with a Cloud Foundry `manifest.yml` file, which provides all of the defaults necessary for an easy `cf push`.

```
$ cf push
Using manifest file cf-neo4j-example-app-app/manifest.yml

Creating app neo4j-example-app in org testing / space testing as me...
OK

Using route neo4j-example-app.example.com
Binding neo4j-example-app.example.com to neo4j-example-app...
OK

Uploading neo4j-example-app...
Uploading from: cf-neo4j-example-app
...
Showing health and status for app neo4j-example-app in org testing / space testing as me...
OK

requested state: started
instances: 0/1
usage: 256M x 1 instances
urls: neo4j-example-app.10.244.0.34.xip.io

     state     since                    cpu    memory          disk
#0   running   2014-04-10 01:42:43 PM   0.0%   75.5M of 256M   0 of 1G
```

If you now curl the application, you'll see that the application has detected that it's not bound to a neo4j instance.

```
$ curl http://neo4j-example-app.example.com/

      You must bind a Neo4j service instance to this application.

      You can run the following commands to create an instance and bind to it:

    $ cf create-service p-neo4j development neo4j
    $ cf bind-service neo4j-example-app neo4j
    $ cf push
```

#### Create a Neo4j service instance

Find your Neo4j service via `cf marketplace`.

```
$ cf marketplace
Getting services from marketplace in org testing / space testing as me...
OK

service       plans         description
neo4j         development   Neo4j service
```

Our service is called `neo4j`.  To create an instance of this service, use:

```
$ cf create-service neo4j development my_neo4j_instance
```

#### Bind the Instance

Now, simply bind the neo4j instance to our application.

```
$ cf bind-service neo4j-example-app my_neo4j_instance
$ cf push
```

## Usage

You can now read and write records by GETting and POSTing to `/nodes`.  In the example below, we create a node named `foo` with a value of `bar`, and retrieve the value back from `foo`.

```
$ curl -X POST http://neo4j-example-app.example.com/nodes -d '{"foo":"bar"}'
{"id":1}
$ curl http://neo4j-example-app.example.com/nodes/1
{"attributes":{"foo":"bar"}}
```

Of course, be sure to replace `example.com` with the actual domain of your Pivotal Cloud Foundry installation.

## Testing

Integration tests require an instance of Neo4j running on localhost and port 7474.

```
$ brew install neo4j
$ neo4j start
```
