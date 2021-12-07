---
title: "How to use a github template repo to remove Golang boilerplate code"
date: 2021-09-10T08:47:11+01:00
description: Bootstrap you Go application and add extra entry points in the same time shoul not be so complicated. Let's explore this pattern.
draft: false
image: "images/go-project-structure/feature.jpeg"
tags: ["go", "project structure", "template repo", "github"]
---

{{< featuredImage alt="featured image" >}}

He probabily thought that I am nuts...

Looking back over the past year, I remember an interview I did for a well known payment processing company, let's call it company C.

I was tasked with building this payment API which is composed from a couple of Go packages.

My interviewer was surprised why I chose to not add the interface in the same package as the service which was implementing it.

My http handler package had an interface for the payment service which was part of a different package.

But let's break this down...

Go offers implicit interfaces so you don't need to specify the interface which a struct implements. if it sounds like a duck, looks like a duck and behaves like a duck... then it's probabily a duck.

So I used my interface to specify which methods my http handler package needs to work with, regardles of the implementation of that service. Makes sense... at least for me.

If I would have kept the interface in the payment package, I would have been forced to create a dependency between the handler and the payment packages.

My method would have looked like this:

```go
package handler

import {
	pay "github.com/MihaiBlebea/.../.../payments"
}

func doSomeHandlingWork(paymentService pay.PaymentService) {
	// logic in here
}
```
In this case `pay.PaymentService` would be the interface that I pass as param to this function.

As you can see, I need to import the package and refer the interface...

Not ideal.

But if you think about it, in service I just need an interface that has a couple of methods that I actually need. So it makes sense to be included in the `handler` package.

```go
package handler

type PaymentService interface {
	GetAllPayments() []payment
	MakePayment(sum int, currency string) (bool, error)
}

func doSomeHandlingWork(paymentService PaymentService) {
	// logic in here
}
```
You can see how this is a much more decoupled implementation.


```
|-- src
	|-- user
		|-- services
			|-- auth.go
			|-- report.go
		|-- adaptors
			|-- telegram.go // interface for telegram service
			|-- email.go // interface for email service
		|-- models
			|-- user.go
			|-- password.go // value object
			|-- activity.go // model
		|-- handlers
			|-- login.go
			|-- logout.go
			|-- register.go
		|-- repos
			|-- user_repo.go
			|-- activity_repo.go
|-- http
|-- cmd
|-- main.go
|-- .env
|-- .env.example
|-- Dockerfile
|-- docker-compose.yaml
|-- .dockerignore
|-- .gitignore
```

![overview-folder-structure](/assets/overview-folder-structure.png)
