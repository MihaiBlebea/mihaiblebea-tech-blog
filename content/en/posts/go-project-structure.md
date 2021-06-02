---
title: "How to structure your next GO project using multiple terminal commands"
date: 2019-03-26T08:47:11+01:00
description: Bootstrap you Go application and add extra entry points in the same time shoul not be so complicated. Let's explore this pattern.
draft: false
image: "images/go-project-structure/feature.jpeg"
tags: ["go", "project structure", "terminal"]
author: Mihai Blebea
authorEmoji: 🤖
authorImage: images/mihai-profile.jpeg
---

{{< featuredImage alt="featured image" >}}

This should be an easy one, but...

I see some Go developers asking the question:

*"How should I structure my Go project?"*

There are 2 answers to this question:

- **The easy answer:** Just structure your project in a way that makes sense for you.

- **The more complex answer:** Structuring your Go application is harder that may seem at the first glance..

Both are valid answers so the question deserves a bit of attention.

First approach is quite a limited one.

Of course you should structure your codebase depending on the size, scope and overall complexity of the project.

If you are new to Go and coming from a language like *PHP*, *Python* or *Javascript*, then you are probabily used to coding in an OOP way.

This means that you will structure your project in layers (Models, Views and Controllers) - MVP, or why not, in Application, Domain and Infrastructure using the **Hexagonal Architecture**.

But if you do any of those you will discover that Go is not such a flexible language to code in, and you may end up fighting against the current.

Let's explore...

## What you should know about Golang?

> Go is a strong typed, compiled and OOP language. Well... sort of.

There are structs that resemble classes, and functions attached to structs that may seem like methods.

There are also infered interfaces, that we will cover in another article...

But the main unit of encapsulation in Go is the "package", not the struct.

This means that each folder in Go represents a package, which provides encapsulation from the other packages and the main global scope.

So folders have an important role in Go. More so then in other languages...

For example, if you have a `models` folder, then your package will be also called models and you may have a hard time trying to align the other packages in relation to this one.

Now that we saw what the problem is, let's explore some solutions...

## Bootstrap your application inside the main file

Starting with the main entry point in you application, the `main.go` file should be used to bootstrap your other dependencies and packages.

A `normal` main file could look like this:

```go
package main

import (
// Import your packages in here
)

func main() {
    r := repo.New()

    sl := slack.New()

    s := server.NewHTTPServer(r, sl)

    err := s.HandleConnections()
    if err != nil {
        log.Fatal(err)
    }
}
```

You notice that we imported all our packages and dependencies at the top of the main file.

Then we instantiated out services, both slack and repo packages exposing a constructor method that returns a service which encapsulates other dependencies and methods.

Nothing wrong with this approach.

But what happens when you have more then a few dependencies?

Then you will be stuck with a bloated main file that tries to do too much at once.

One issue with this approach is that you may need to have two concurrent threads:

- one exposing an http server 

- the other one running a background worker that sends slack messages based on entries in the database

This means that you need to work out a way to run the worker and the server in separate goroutines.

In this case your main file can look something like this:

```go
package main

import (
// Import your packages in here
)

func main() {
    r := repo.New()

    sl := slack.New()

    // Run worker in this routine
    // Worker requires the repo service and the slack service to be able to send messages
    go func(r &repo.Service, sl &slack.Service) {
        // Trigger an infinite loop to check repo every 10 seconds for new messages
        for {
            w := worker.New(r, sl)
            
            err := w.CheckMessagesToSend()
            if err != nil {
                log.Fatal(err)
            }

            time.Sleep(time.Second * 10)
        }
    }(r, sl)

    s := server.NewHTTPServer(r, sl)

    err := s.HandleConnections()
    if err != nil {
        log.Fatal(err)
    }
}
```
We created a new go routine that get's triggered in our main file. It runs an infinite loop that checks our repo every 10 seconds for new messages to be sent and implements some logic on those.

If the worker encounters an error, then it crushes the goroutine.

Hmm... do we really want this to happen?

Why would we want to bundle the worker and the server in the same application?

## Going down the microservice rabbit hole

One solution could be to split those two in separate applications that can be run in parallel.

We could encapsulate those in two docker containers that talk with the same database.

This means that we would be implementing a microservice architecture, and that brings some other problems that we need to take care of.

If you work in a bigger company, with more then one team of developer, then it probabily makes sense to go down that rabbit hole.

But if this is your side project or you are the only developer in a small company, then microservices would bring more pain then benefits.

> Just keep in mind that microservices are not a silver bullet.

By chosing the microservices it means that you will have to duplicate your models (structs), repos and some of the logic.

<img src="https://149363654.v2.pressablecdn.com/wp-content/uploads/2014/02/surprise.gif" />

This can be a pain when you try to update some of that logic in 2 or 3 places in the same time...

Let's look at the middle ground.

## Using multiple commands to start applications using the same codebase

We will start by creating a `cmd` folder that will house different cli commands that we can use to start our application.

I like to use a package called `cobra` that you can find more about by checking their [documentation here](https://github.com/spf13/cobra).

Our folder structure will look something like this:

```
|-- go-project // root folder
    |-- cmd
        |-- root.ga
        |-- worker.go
        |-- server.go
        |-- admin.go
    |-- slack // slack package
        |-- api.go
        |-- logic.go
    |-- repo // repo package
        |-- api.go
        |-- logic.go
        |-- model.go
    |-- main.go
    |-- go.sum
    |-- go.mod
```
Notice that we have 4 commands in our `cmd` folder:

- root - is the main command, mostly used to help or documentation for the others
- worker - bootstraps our background worker
- server - runs and exposes our http server
- admin - runs the admin section of our project, can be an api or some html templates

In this case, the `worker` command in `worker.go` would look something like this:

```go
package cmd

import (
// Import packages here
)

func init() {
    // Bootstrap your worker command into the root command
	rootCmd.AddCommand(workerCmd)
}

var workerCmd = &cobra.Command{
	Use:   "worker",
	Short: "Worker does the work.",
	Long:  "Does what every worker likes to do in the background.",
	RunE: func(cmd *cobra.Command, args []string) error {
        fmt.Println("Worker started")

        r := repo.New()

        sl := slack.New()

        w := worker.New(r, sl)

		for {
            fmt.Println("Worker checking messages")
            err := w.CheckMessagesToSend()
            if err != nil {
                return err
            }

            time.Sleep(time.Second * 10)
        }

		return nil
	},
}
```
Same can be implemented for server and admin commands.

Notice how every command starts a different process which handles a part of the application.

This means that we can run those in individual docker containers.

If one command crushes, this will not bring down the house.

For example, if the worker crushes, your users will still be able to use the server or the admin sections of your app.

This is a nice compromise between microservices and monolith applications.

Let's see how the Dockerfile could look for our `worker` command:

```yaml
FROM golang:1.15-alpine AS build_base

RUN apk add --no-cache git

# Set the Current Working Directory inside the container
WORKDIR /tmp/app

# We want to populate the module cache based on the go.{mod,sum} files.
COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

# Unit tests
RUN CGO_ENABLED=0 go test -v

# Build the Go app
RUN go build -o ./out/go-project .

# Start fresh from a smaller image
FROM alpine:3.9

RUN apk add ca-certificates

WORKDIR /app

# Create a new user for your container
USER nobody:nobody

COPY --from=build_base --chown=nobody:nobody /tmp/app/out/go-project /app/go-project

# Set the envs for the db connection
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_HOST=${MYSQL_HOST}
ENV MYSQL_PORT=${MYSQL_PORT}
ENV SLACK_WEBHOOK=${SLACK_WEBHOOK}

# Run the binary program produced by `go install`
CMD ["./go-project", "worker"]
```
You can choose to have different Dockerfiles for each of your individual commands, or beter yet, have one single dockerfile (as you are compiling the same codebase anyways) and just override the main `CMD` when running the containers.

For example:

```bash
# Run your worker docker container
docker run -d --rm --name worker --entrypoint="./go-project worker" serbanblebea/go-project:0.1

# Run your http server container
docker run -d --rm -p 8081:8081 --name server --entrypoint="./go-project server" serbanblebea/go-project:0.1

# Run your admin section container
docker run -d --rm -p 8082:8082 --name admin --entrypoint="./go-project admin" serbanblebea/go-project:0.1
```

Or you can put all three into a `docker-compose.yaml` file together with your database and start them all at once.

<img src="https://thumbs.gfycat.com/TangibleBreakableFrillneckedlizard-size_restricted.gif" />

We just touched the top of the iceberg with this article, as there are many more benefits of the command structure.

For example, you could also run short lifecycle commands, like migrating your database or manual trigger of a slack message.

You can do this by connecting to one of the running docker containers and executing this with `./go-project <your-command>` or you could spin up a docker container that has one single entrypoint and can be removed after the process finished.

Please let me know in the comments section if you can think of any benefits or drawbacks of using this approach.

I find this to be a nice compromise between complexity and ease of use.

Of course there are also some drawbacks with this one too, for example all your different containers will fetch data from the same database...

For now, I found that this works well for me and my projects, but in the future and with a growing codebase, there is always scope for improvement.

Let me know in the comments section below if you find any edge cases with this approach and how would you improve it.