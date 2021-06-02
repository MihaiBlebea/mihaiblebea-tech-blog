---
title: "My First Post"
date: 2022-03-26T08:47:11+01:00
description: So you managed to get past the technical take home exercise... Congrats! You deserve it. Now what's next?
draft: true
image: "images/banana-background.jpg"
---

{{< featuredImage alt="featured image" >}}

Go is so different then other languages you coded in...

And I am not even talking about the error handling.

No! This article is not about that.

In this article I am going to continue talking about structuring you Go based projects.

Continue? Yes, this is part of a series of articles that aims to promote good code structure.

- 

- (this one)

If you haven't read the first one, then open it in a different tab and go over it once you finish reading this one.

Now that we covered the housekeeping... Let's get to the interesting part.

As you may already noticed, Go structures code in **packages**.

Thse are units of encapsulated code that are focused on dealing with one and only one responsability.

You can compare packages with classes in the other OOP languages like PHP, Python and Java.

They can expose methods, structs, constants an all sorts of functionality to the outside world.

But in the same time, packages aim to encapsulate code and protect it from the global scope.

Go doesn't really put so much accent on files, so a package can contain any number of files.

All the files in a package are going to be considered as package content.

As long as all the files start with the `package yourpackage` declaration, you can thing of them as part of one single huge file.

This means that you have to avoid declaring the same function into multiple files, as Go will throw an error at compile tim saying that the function has already been declared.

This is just one of the quirks of Go and the one that I will show you how to take advantage of in this article.

The other important part to consider here is the `inferred interface` pattern of Go.

Basically to have a structure implment an intrface all you have to do is just implement the methods in the interface on your struct.

No need to declare the fact that your struct implements that interface.

This pattern opens the door to some nice encapsulation paterns.

Just to sumarize this before talking about the actual package structure:

- All code in Go is structured into packages

- Go does not care about the fils in a packace, at compile time it treats all the contents of the folder as one big file

- Interfaces in Go are inferred, so you don't ned to specify that a struct implements the interface as long as it implements all the methods

Let's consider a small demo project called `go-scrum-poker`.

First I am going to showcase the folder structure, than we are going to take it apart file by file and talk about the pattern.

```
|-- go-scrum-poker // root folder
    |-- user // user related code
        |-- api.ga
        |-- contracts.go
        |-- user.go
        |-- utils.go
        |-- user_test.go
    |-- poker // scrum poker related code
        |-- api.go
        |-- contracts.go
        |-- poker.go
        |-- poker_test.go
    |-- main.go // main entry file
    |-- go.sum
    |-- go.mod
```
We are going to assume that the main file exposes some sort of http server or terminal commands that will allow users to interact with the scrum poker.

You can already notice some patterns here.

We have two distinct packages, one is the `user`, which handles all the logic related to players of the scrum poker.

The second one is the `poker` itself, which needs no explanaition for what it does...

What we are trying to achieve here is perfect encapsulation of the `user` and `poker` packages.

Basically we should not be able to directly talk to, or use, methods or structs from the `user` package inside the `poker` package, except the ones that we allow explicitly.

### The user package

This contains 5 files:

- user.go it's where the actual magic happens, here we declare the `User` struct model plus a couple of setters and getters

```Go
package user

type user struct {
    id string
    username string
    role string
}

func user(username, role string) *User {
    return &User{
        id: uuid.NewV4().String(),
        username: username, 
        role: role,
    }
}

func (u *user) id() string {
    return u.id
}

func (u *user) username() string {
    return u.username
}

func (u *user) role() string {
    return u.role
}
```

Notice that the struct and all of the methods attached to it are lower cased. This means that none of them can be accessd from outside of the user package.

Of course this is an overkill keping in mind that we are just talking about some getters and setters, but this pattern really shines when we have a more complex package.

- utils.go just your average utils file that holds some helper functions

- contracts.go this is where we define interfaces for any dependencies that we require from other packages, you will see this in action in the `poker` folder

- api.go this file holds the methods that we want to expose from our package to the outside world

```Go
package user

type User struct {
    user
}

// New constructor function that returns a pointer to User
func New() *User {
    return user()
}

// Username getter for user's username
func (u *User) Username() string {
    return u.username()
}

// Role getter for user's role
func (u *User) Role() string {
    return u.role()
}
```
In this file we defined all th methods and structs that we plan to make accesible from the outside of our package.

We exposed the **New()** constructor function that returns a pointer to a User struct, the **Username()** and the **Role** getter methods on the **User** struct.

Notice that the **id** is not accesible from the outside of our `user` package, also we "forgot" to expose the methods to change the role and the username of the user.

This is by design, as we don't want those to be updated after they are set on the user.

Consider this as our way of making those immutable.

- user_test.go is a file that contains the tests for our package. We could also define a `api_test.go` for our api tests, but that seems like an overkill for our use case.

### The poker package

- contracts.go file creates interfaces for the dependencies that we will need in our `poker` package

```Go
package poker

type User interface {
    Username() string
}
```
Here we declared an interface for the User struct.

As we just care about the username here, we just require that specific method to be implemented.

We could also add the `Role()` method on the interface, but we are all equal in this scrum team so no need for "pulling rank".

- poker.go here we define the logic of our scrum poker

```Go
package poker

type service struct {
    users []User
    points []uint
}

func (u *User) register(users []User) {
    u.users = users
} 

func (u *User) vote(user User, points uint) error {
    if err := validateUser(u.users, user); err != nil {
        return err
    }

    if err := validatePoints(points); err != nil {
        return err
    }

    u.points = append(u.points, points)

    return nil
}

func (u *User) result() uint {

}

func validateUser(regUsers []User, user User) error {
    var found bool
    for _, regUser := range regUsers {
        if regUser.Username() == user.Username() {
            found = true
            break
        }
    }

    if found == false {
        return errors.New("User tried to vote without being registered")
    }

    return nil
}

func validatePoints(points uint) error {
    if isPerfectSquare(5*points*points + 4) || isPerfectSquare(5*points*points - 4) {
        return nil
    }

    return errors.New("Not a Fibonacci number")
}

func isPerfectSquare(value uint) bool {
    val := math.Sqrt(points)

    if val * val == points {
        return true
    }

    return false
}
```