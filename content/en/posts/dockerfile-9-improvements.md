---
title: "My First Post"
date: 2019-03-26T08:47:11+01:00
description: So you managed to get past the technical take home exercise... Congrats! You deserve it. Now what's next?
draft: true
image: "images/banana-background.jpg"
author: Mihai Blebea
authorEmoji: 🤖
authorImage: images/mihai-profile.jpeg
---

{{< featuredImage alt="featured image" >}}

What do you know about containers?

They are used to transport products manufactured in China to be sold in Europe...

Not that kind of containers!

I am talking about Docker containers.

To be completely honest the description above is not 100% wrong.

When talking about software container we are talking mainly about transporting "software" and encapsulating the runtime of the application.

Think about Darwin's theory of evolution: 

*"Charles Darwin's theory of evolution states that evolution happens by natural selection. Individuals in a species show variation in physical characteristics. This variation is because of differences in their genes that appear as adaptation to their environment."* - Wikipedia

Biology aside, the applications that we developers build are affected by the environment too.

But the software does not adapt to the environment, it just dies - or throws a nicely formattted error.

If you build an application locally using a global library installed on your laptop, but forget to install set library on the production sever, then you will be "greeted" by a nice 500 error when trying to showcase your work.

Only if you could take the same libraries and dependencies that you have on your laptop, move them to the production server with ease, and reproduce the same environment that you have on your laptop...

Something like a container that encapsulates your application together with your dependencies.

You see where this is going.

*"Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries and configuration files."* - Wikipedia

In this article I am going to show you some of the **quirks and features** of the Docker container, then I am going to take it for a **drive** and give it a *Mihai score*.

But before we do that, let's talk a bit about hwo containers work behind the scenes.

Containers work in the same way as virtual machines, but instead of copying the whole OS and all the kernels, it re-uses the Linux operating system. This way the Docker images are kept light (just a couple of MB, compared to GB).

All you need is a Container Engine to run containers on a server.

But Docker is not the only Contaner Engine out there. Because of it's popularity the brand became synonim with the product, like Xerox or ... other products that took the brand name.

There are also containers running on CRI-O, CoreOS rkt or Apache Mesos.

Like an object is based on a class, so does a container which is based on an image.

The image specifies the dependencies to be installed in the container, the environment varialbes needed, the operating system version and the commands needed to start your application.

The container, which is based on the image, repreent just the runtime in which your application runs.

So there are a couple of steps to running your application in a container:

- Create an image or take one of the shelf (See Dockerhub)

- Build a container from the image

- Run the container

Before jumping head on into the main part of this article, let's talk about container layers.

Each instruction that you specify in a Docker file represent a different layer.

A layer is basically an image on itself.

To make building a container faster, Docker caches your individual layers so it doesn't need to recreate them everytime.

When you change a line in your Dockerfile, the container engine takes note of that and recreates all the other layers starting from the one that you modified.

To make building your images faster and take advantage of the caching, you need to put the layers that change less often to the top of the file, and the ones that change frequently to the bottom.

I hope this makes sense, we will explore this further in the next sections...

## Avoid updating all dependencies

Updating your dependencies is a good thing, as updates help fix security issues and improves speed and resiliance. 

In the same time, you must strive to get replicable builds of your Docker containers. This means that everytime you build a container you should expect to get the same stable result.

Your application may work just fine on your local environment, but may not be compatible with a latest release of a particular library.

Updating every dependency prevents your Dockerfile from creating consistent, immutable builds.

Nowadays you always notice this group of commands in almost every Dockerfile:

```Dockerfile
RUN apt-get update
RUN apt-get install git make ...
``` 

This is turn mean that your Dockerfile is not replicable anymore.

Another potential risk of adding the above to your Dockerfile is that the update and install commands are executed on separate layers.

This means that the `RUN apt-get update` may get cached and skipped when you build your container from the image.

Try and install and update only those libraries that your application requires and always make it a point to update packages to a known version.

## Don't COPY everything in one place

This is a tricky one because as a newly adopter of container technology you have to get used to a suit of new commands like `RUN`, `ADD`, `COPY`, `ENTRYPOINT`, `ARG`, `ENV`, `FROM`, etc.

So when you think about the need to copy your local files into the container you may think that the best way of doing this is by running `COPY . .`.

I've seen this pattern a lot and it's not very clear why it could be a potential risk to your buid speed.

Let's break it down... The COPY command simply replicates the files you have on your host, inside your container.

The first dot is representing the host path, while the second one is the path inside the Docker container.

So `COPY . .` simply means copy everything from host to the container.

This command is usually followed by the line `RUN composer install` or `RUN npm install` which uses the PHP or Node js package manager to fetch the libraries that your application needs.

The issue here is that if we make any change to our application code, then we will have to break the cache starting from this line onwards.

This will drasticly affect the speed of our builds, cost more resources if you are depending on a third party provider to build and test your application or even block other developers from deploying their changes.

A better practice is to split the `COPY` command like so:

```Dockerfile
COPY ./composer.json .
COPY ./composer.lock .

RUN composer install

COPY . .
```

What we did here is copy the `composer.json` & `composer.lock` which are needed to install the dependencies.

Next we run the command to fetch the packages from the web.

And last we copied all the remaining files in our host folder.

As you know, the fetching of dependencies can be a lenghty task, which will be cached by Docker.

This way you will not need to rerun the same time consumming command everytime you change your code.

## Sometimes latest doesn't mean "greatest"

Using the `FROM redis:latest` or `FROM alpine:latest` is not always the best practice when talking about Docker.

What this means is that you get the latest tag from the specified image. But latest doesn't always means the greatest, as sudden changes in internal libraries can break your entire application without warnings.

This one goes hand in hand with the first improvement from our list.

As a rule of thumb, always try to stay in control of the versions that you use in your Dockerfile.

Instead, you can specify the tag like so `FROM redis:6.0-alpine`. 

This way you will never get caught by surprise, but always keep in mind to regulary update your base images to stay up to date.

## Build first, use later

I've seen this a few times...

Let's say you want to bootstrap your application with a `CMD` (command) at the end of your Dockerfile, but in the same time, you also need to migrate the database.

So what do you do then? 

One idea would be to just use a `RUN ./application migrate` command before the final `CMD ["./application", "start"]`.

What can possibly go wrong?

In this case, the issue is that you assume that the database container is built first, or it's already running when you try to run the migration.

But that may not always be the case, and in most cases it's not even close.

Leaning on external containers and third party providers, will not speed up yur build process, actually it may have the opposite effect, making your Dockerfile slower.

Try to separate the build phase from the commands that are better suited to be run at runtime, as in, when your container is already up and the state of the database is already known.

Also consider this...

What will happen if you even want to change your database from MariaDB to MongoDB? You may need to change the migration command, and also update your Dockerfile.

## Don't EXPOSE everything too early

The `EXPOSE` command is used to expose a port of your container to the outside world. 

For example, you may need to run `EXPOSE 8080` to make your application public to the host.

Of course you could also specify the port mapping in your `docker run -p 80:80 my_image` command to bind the ports at runtime.

This command is quite inexpensive so it's not worth breaking the cache by declaring it at the top of your Dockerfile.

As it's not usually needed until the end of your build, it's worth adding this one at the very end of your file. Maybe just before the `CMD` line.

Same goes for the `ENV` commands that bind environment variables.

If you don't need them in your application build phase, then leave them last in your Dockerfile to improve the overall speed of your build.

If you really need some of those variables at the start of the build, like for example `ENV GO_VERSION 1.16` then don't feel bad for splitting them in two separate parts.

Something on the lines of:

```Dockerfile
ENV GO_VERSION=1.16

# Building your app here

ENV HTTP_PORT=8080
ENV DATABASE_USER=admin
ENV DATABASE_PASSWORD=pass

# Only require the env variable before you actually need it
EXPOSE ${HTTP_PORT}
```

## ARGuments vs ENVironment variables

Arguments are not the same as environment variables?

They may seem to have similar roles, but they are definitely not treated equally by Docker.

ENVs are set to work with your application runtime, when the container is running.

On the other hand, ARGs are just meant to be used during th build phase of your Dockerfile.

While the first are not changeble during the build phase of your container, the latter can be overriden from your coommand line.

This makes them great options when you need to set a default variable inside your container, for example `ARG MIX_ENV=prod`, but also have the option to change it based on your container use `docker build --build-arg MIX_ENV=dev .`.

The `MIX_ENV` will not persist in your Docker container runtime, instead it will e used just to build your container.

You can also decide to pass an `ARG` value to an `ENV` if you consider you will need it at runtime, like so:

```Dockerfile
#Watch out for name conflicts
ARG MIX_ENV=prod
ENV MIX=${MIX_ENV}
```

## Don't run everything as root

I can't stress this enought...

By default, Docker containers run as root. That root user is the same root user of the host machine, with UID 0. 

If a hacker with bad intentions gets a hold of your vulnerable container, he can:

- they can copy sensitive files from the host to the container and access them

- remote command execution

- if some sensitive root-owned file is mounted to the container, they can access it from the container as they’re root

To avoid security risks, set a different user inside your Dockerfil to build your container.

All of these risks can be mitigated by simply adding this line to your Dockerfile:

```Dockerfile
# the user nam is specified before the :
# the user group is represented by the anme after the :
# Ex: user_name:user_group
USER nobody:nobody
```
Starting from this line, all the other commands will run with the privileges of the user you just created.

Want to override the user and run the container as root, then try this:

- `docker run --rm -d --user root my_image:latest`

If you ever need to execute something in your running container, you can always act as root user with this command:

- `docker exec -it --user root container_name /bin/sh`

Notice that we specified the user with the argument `--user root`.

You can experiment with this by running the `whoami` command inside the container once it is up and running.

## Don't declare VOLUMEs in your Dockerfile

As a rule of thumb you should not assume anything related to the host that the container is running, when building your Dockerfile.

For example, one risky assumption is that the file or folder that you need will be there on the host.

How can you declare a volume inside your Dockerfile?

By simply adding this command: `VOLUME /volume_folder`.

AS you noticed, there is no mention of the host folder, the folder above is just the one inside the container.

This is because by default it's not possible to create a folder on host when building the image.

That is reserved for when you run your container.

Let's look at a simple example:

```Dockerfile
# ...

# Declare a /data volume on your host
VOLUME /data

# Put the string inside a file that is saved in the volume
RUN echo "This file is important..." > /data/important_file.txt

# Try to read the file
CMD ["cat", "/data/important_file.txt"]
```

This above Dockerfile will fail as the file you are looking for will not be found inside the `/data` folder on your host.

```bash
docker run volume-in-build
cat: can't open '/data/myfile.txt': No such file or directory
```

Instead do this:

```Dockerfile
# ...

# Put the string inside a file that is saved in the volume
RUN echo "This file is important..." > /important_file.txt

# Try to read the file
CMD ["cat", "/important_file.txt"]
```

## Use multiple stages for building and runnig your application {#custom-id}
