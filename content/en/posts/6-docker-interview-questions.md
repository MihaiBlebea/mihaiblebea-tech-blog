---
title: Get this 6 Docker interview questions right to master the tech interview
subtitle: Prove that you are the real deal
date: 2019-03-26T08:47:11+01:00
description: So you managed to get past the technical take home exercise... Congrats! You deserve it. Now what's next?
draft: false
image: images/banana-background.jpg
slug: best-docker-interview-questions
keywords: ["docker", "interview", "tech-interview"]
tags: ["docker", "interview", "tech-interview"]
author: Mihai Blebea
authorEmoji: 🤖
authorImage: images/mihai-profile.jpeg
---

{{< featuredImage alt="featured image" >}}

So you managed to get past the technical take home exercise...

Congrats! You deserve it.

*The next part of the interview will be a video call with two of our engineers to go over the test.*

*It will be a nice conversation with no right or wrong answers in which you will get the opportunity to showcase your past experience.*

*There will also be a couple of questions related to software architecture, your favourite stack, maybe some questions related to microservices and Docker containers.*

Oh wait...

Did you say Docker containers?

But I haven't really had much exposure to them in the past.

I usually just take pre-built images and run them locally. 

And there is also a dev-ops engineer that handles that in my company.

How can I possibly ACE this interview?

There is nothing to worry about.

Docker is one of those technologies that you can quickly pick up, but require a lot of time to master.

My advice is to go over the Docker documentation which is very comprehensive and easy to read.

Also their website is very well formatted and easy to navigate *(we all know how hard it is to go over badly written documentation)*.

In this article I will go over a couple of questions related to Docker that can sometimes come up in a tech interview.

And when I say "sometimes" what I mean is "almost everytime" haha.

A little tip, the question nr. 3 is one of my favourites and the one that I failed so badly in one of my past interviews.

So without further introduction, let's jump into the exciting part that probably peaked your interest in the first place.

## 1. "Can you walk me through the difference between `docker build` and `docker run` commands?"

This is one of the most simple questions.

If you ever used Docker before, you must have used both of those commands.

Docker build command is used to "build" images from a Dockerfile.

I like to think about the Dockerfile as the template for the containers. You can build lots of containers that are based on one single image.

Come to think about it, you could say that the Dockerfile resembles a class from the OOP world.

There are a couple of interesting flags that you can use with the `docker build` command:

- `--build-arg` to specify some external arguments for your build

- `--file` to point to the Dockerfile if it's not in the current build context

- `--no-cache` to force Docker to skip the old cache and always build every layer of your image from scratch

- `--rm` to remove intermediate containers needed in the build

- `--tag` to give a name and a tag to your image so it's easier to find and reference

I hope this all makes sense, let's go to the next command.

This command is used after your image has been built and tagged in the first step.

Now it's time to run your image as a container with `docker run`.

As a rule of thumb you need to at least specify an image to run which will be the last argument of the command.

Let's look at some examples:

- `docker run -p 8080:80 nginx:latest` - this will run nginx and expose it on port 8080. Notice how the container port is mapped to the host port.

- `docker run -v data -p 3307:3306 mariadb:latest` - this will start a MariaDB container listening on port 3307 with a volume in the `/data` folder

Of course, one advantage of container technology is that you can easily store and transport images from which to build the containers. If you already have an image pre-built in a repository you can just use the `run` command and specify it's name in the format `repository_name/image_name:tag`.

## 2. "What is the difference between docker **ARGs** and **ENVs**?"

This question is a step above the last one in terms of difficulty.

It basically builds on top of the previous question.

The simple answer is that both **ARGs** and **ENVs** are variables needed for the container to be built and run.

But while **ARGs** are just used at build-time and then dumped, the **ENVs** are used at container runtime.

You can test this yourself by using a simple `nginx` base image and build on top of it. 

- `touch Dockerfile && echo "FROM nginx \n\nENV BAR=false" > Dockerfile` to create the Dockerfile with a BAR env

- `docker build --build-arg FOO=true . -t repo/johndoe:latest` to build the image with a FOO argument

- `docker run -d --name my-nginx repo/johndoe:latest` to run the **repo/johndoe:latest** image

- `docker exec -it my-nginx bash -c "printenv | grep BAR="` to get the value of the BAR env

- `docker exec -it my-nginx bash -c "printenv | grep FOO="` you will not get any value as the FOO was just a build argument

Now that we talked about build-time and run-time, let's move to the actual Dockerfile itself.

The next one is one of my favourite interview questions.

## 3. What are the Docker layers and how can you take advantage of them to speed up you image builds?

As we talked before each container is baed on an image, and each image starts with a Dockerfile.

The Dockerfile contains the commands needed to build your image.

But at it's core, it always starts from a previous image...

```Dockerfile
FROM debian:stretch

ENV FOO=true

CMD ["./app", "start"]
```

Each of the commands in the example above represents an image layer.

Each of the layers can be considered an image on it's own.

To make your image builds faster, Docker uses a cache to store all of the previous steps.

So for example, if you run `docker run nginx` you will notice that it takes a couple of seconds to download the new image and go through all the layers.

The second time you run the same command it finishes almost instantly, that is because all the previous layers were cached and there is nothing to download from the internet.

One thing to keep in mind is that everytime you change one of those lines, you break the cache for the ones following it.

In the example above, if I change the **ENV** line to **false** I will break the cache for the **RUN** line.

The cost here is very small, but consider a big Dockerfile with multiple steps to build and tens of layers.

To speed up your builds, always try to put the things that change less often to the top of the file (if that is possible) and the ones changing more frequently, to the bottom.

## 4. Can you walk me through a potential security risk when building Docker images and how to mitigate it?

The answers here are numerous, but for the sake of this article, let's consider one that I saw happening a lot.

That is building an image with the root user.

When writing a Dockerfile you have the option to create a user to act as the "builder" of your image.

The same user will be used also at runtime.

If you don't specify any user in your Dockerfile, then the **root** user from your host will be used instead.

This means that every developer that has access to the container, also has root access to the host.

To mitigate this risk, just create a new user to act as the main "actor" in your Dockerfile.

## 5. How can I hide secrets that are needed during build time but not needed at runtime?

You may end up needing some arguments to be able to build your image. For example an application key, or a private key, etc.

By default, if you define them as ENV they will be available for the full lifetime of your container.

One way in which you can avoid this is by using **ARGs** instead.

If you read the previous answers, then you know that ARGs are not going to be persisted in the running container.

One other solution that you can use is the multi-step build.

Basically you can define two different steps for your image build:

- "build step", in which you compile your code and take advantage of those secrets needed at compile time.

- "run step", in which you get the artifact from the build step, run a couple of other commands, before starting the application

Each step is treated as a separate container, which means that the "build" step container is dumped after it's finished it's job, together with your secret keys.

## 6. How would you deal with fetching your application dependencies, which is a time consuming process, and at the same time keep you docker builds fast?

This is one tricky question.

As we talked before, each line of your Dockerfile is a separate layer which gets cached.

To build your application you probably have a package manager that needs to fetch the dependencies from the web before compiling and starting the application.

This can be considered one of the most time consuming tasks in your build process.

The best way to handle this would be to use the cache and skip this step once you had your initial build.

The issue here is that if you try to copy your files from your host to your container in one single layer, then everytime you change the application code, you end up breaking that cache.

For example, this command just copy all the files in your root folder: `COPY . .`

To get around this issue, use this strategy to copy the files from your host folder:

- First copy the dependency files and lock, for example: 

```Dockerfile
COPY composer.json .
COPY composer.lock .
```

- Next use the `RUN composer install` command to fetch your dependencies and bootstrap the autoloader

- Final step, just copy the remaining files in your host folder with `COPY . .`

The good news is that the layer copying your composer files will be cached, same as the composer install layer.

The last command will break the cache every time you change a file in your root folder, but that is oki, as the cost of copying the files is very small.

You may have noticed this pattern before, now you know why doing all the copy in one go is probably not the best approach if you also want to keep your builds fast.

## Final word

These are some of the questions that I encountered most frequently in tech interviews and some that I like to use too.

The tricky part is that, usually, the Docker questions may sound more complex then they really are.

Usually the answer is so easy that you end up scratching your head in disbelieve that it was so easy.

I hope you stumble upon this small article before your next tech interview and I wish you all the best and good luck in ACE-ing it.