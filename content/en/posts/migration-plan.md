---
title: "How to effortlessly migrate your code with this 8 step proven plan"
date: 2019-03-26T08:47:11+01:00
description: As time passes, new frameworks appear, older versions are put to rest and the tech environment is shifting and becoming better, faster and more reliable. What do you do?
draft: false
image: "images/migration-plan/feature.jpeg"
tags: ["migration", "refactor", "plan"]
author: Mihai Blebea
authorEmoji: 🤖
---

{{< featuredImage alt="featured image" >}}

Some say it cannot be done, or that it's even too scary to even attempt...

But migrating code should not be a taboo word in a developer's dictionary.

Any application is a living and breathing soul, that can get old with time.

As time passes, new frameworks appear, older versions are put to rest and the tech environment is always shifting and becoming better, faster and more reliable.

That means that your application may slowly be branded as... *legacy*.

This means that it's time for an update, it's time for the dreaded “migration”.

I have been reading a lot of articles lately and people tend to mix the concept of migration with refactoring.

That is why I wanted to write this article so I can share with you my 8 step plan for a flawless migration process.

But before jumping into that...

## What is the difference between migrating and refactoring?

Code migration is the movement of programming code from one system to another. On the other hand, refactoring is a disciplined technique for restructuring an existing body of code, altering its internal structure without changing its external behavior.

<img src="https://i.gifer.com/8mx.gif">

In this article we will cover the migration bit.

There are three distinct levels of code migration with increasing complexity, cost and risk.

The simple migration - involves updating dependencies or the language version. For example migrating from PHP 5.4 to 7.0 can be considered a simple migration. Trust me, it doesn't feel like a simple job at all when you start doing it...

The next step would be migrating to a completely different language. This is considered a more complex task as it involves changing the whole syntax of the code base.

The most difficult migration would be changing to a completely new platform or operating system.

In our case, migrating the Chip API in order to make it compatible with a new database version would be considered a complex migration.

But this doesn't make it an impossible task. Not by any means.

Even the most complex task can be achieved when you have the proper plan in place. I always like to say that if you don't have a good plan, then you are planning to fail.

Let's address the elephant in the room first. I don't consider myself an expert in migrating code, but I have completed a fair share in my developer career, so i can say that I learned a few tricks.

I always started every migration with a plan and improved it after each successful migration that I completed.

Every challenge is a good learning platform and migrating code brings some interesting problems that need to be solved.

## Before you set yourself to the challenge, here are a few issues that you need to consider:

**Data integrity** - If your migration involves data, then you need to make sure that no data will be lost in the process (goes without saying). Your database will need to be taken down when you decide to "press the switch" and complete the migration, so plan it ahead and don't lose any user data.

**Data security** - Changing from a known provider to different one can open the door for security exploits. You must make sure that the security of your data will be improved and not lowered by your migration. Keep you passwords and environment variables secure during the process.

**Clueless end users** - During the migration process your end users should not see any difference in the service provided. A good target would be to keep the users of your application clueless to the process taking place in the background.

**Minimal down time** - As part of your migration process, you will probably need to take your app down or put your API in a “teapot” state for a couple of hours until the switch needs to happen. Try to push changes as frequently as you can to production and leave as little code as possible to be migrated when going live.

**Migration does not equal refactoring** - Some developers can make the mistake of refactoring code during the migration process, thinking that they will improve the overall system. If that sounds like you, then you need to stop doing refactoring as this will bring a more complexity in your migration process. Try to focus on migrating the code over, even with the risk of copying some of the old system's bugs, make a note of all the bugs you encounter so you can fix them later as part of the post-migration tasks.

These are just some of the more important issues that you will have to deal with, but I am sure there are many more scenarios that you will encounter.

When working with legacy code, you never know what may be lurking beneath the calm look of the surface code...

<img src="https://i.pinimg.com/originals/31/37/44/3137449d3225422201697bdf7c73b861.gif">

Now that we talked about the problems, let's discuss the solution. The most important aspect of a migration process is the preparation or how I like to call it, "The Plan".

Let's imagine that you are called into your Project Owner's office, on a Monday morning, and given the task to migrate a legacy PHP 5.6 system to a newer PHP 7.4 platform in order to make it compatible with the newest MongoDB 4.4 database version.

This is somehow similar to what my squad was tasked over the last couple of months at Chip.

We had to move code from a legacy API to a newer version in order to keep it compatible with the newest MongoDB version that we ended up implementing.

We allowed ourselves around 2 months to complete the project and in the end we:

- Removed around 550k lines of code from the legacy system
- Sunset an entire public API
- Removed all the background tasks and processes from our legacy platform and moved them to the new one
- Removed 3 docker images from our repo
- Updated our configs to increase security and improved the CI/CD pipeline
- And prepared our platform for the next set of existing improvements that are planned in the near future (will keep you posted)

But none of these would have been possible without the 8 steps plan.

<img src="https://memegenerator.net/img/instances/82783501/ive-got-a-plan.jpg">

Let's break it down...

## 1. Prepare the ground

During the initial sprint (or sprints), try to get familiar as much as possible with the whole system architecture. If you need to migrate from platform A to platform B, then take your time and explore them. Take a closer look at what makes platform B a better home for your code.

Check if there are any dependencies or hidden risks.

After this initial step, you should be able to answer the question "Why do we need to migrate to the new platform?" with at least 3 unique benefits.

During this phase do some code exploration, and if time allows, put a software architecture diagram on a “piece of paper” to give you a better idea about the dependencies of your code.

If you are working in sprints, then it would be a good idea to align the first sprint with this exploration step.

## 2. Create a multi-disciplinary team

Migrating a legacy code is not a job for a single developer. Even if you are the next Robert C. Martin of the PHP world and have more than 10 years of experience under your belt, you will probably need to rely on a team to help you complete this task.

For a mobile application, you may require the help of an Android and an iOS developer and for a backend migration you may need the sharp mind of a platform engineer and at least two QA engineers.

Pick your team carefully as these are the people who will support you through the tough times for the next couple of weeks. Team chemistry is very important and sometimes it can make or break a migration process.

Here at Chip we are all about team-work and how we can improve the collaboration between our engineers.

## 3. Have a logging system in place

If you don't already have a way of logging events coming out of your system, then you need to put aside time to implement one before starting this journey. At Chip we use DataDog which is one of the best solutions for monitoring cloud based applications.

This step will be important in discovering critical parts of your application that needs to be migrated first, or dead code that can be removed. I am a big fan of using the condemned code technique, where you set logs around the code that you think may be not needed and keep an eye on the logs after a period of time to see if any were triggered.

You can also use the logs to discover bugs introduced by your migration and fix them as part of the post-migration tasks.

At Chip we rely heavily on our logs to discover issues happening in the code, but also to make data driven decisions, and plan future features and improvements.

## 4. Automated code tests are your best allies

Before even considering a migration or refactoring job, you need to have a good test coverage. If you plan to keep the same functionalities of the application while performing the migration, then you will need to lock down those functionalities by writing tests.

I am not talking just about unit tests, but also about functional and end to end tests. The more tests you write at the beginning of your project, the least you will have to worry about introducing unwanted behaviour in your application. Or keeping the wanted behaviour...

Consider starting writing higher level tests first as this will allow for a degree of flexibility when you consider changing the implementation of your code. If you are moving the code to a new platform, then there is no better feeling than running a simple command and getting the guarantee that your code still works as expected.

## 5. Decide on how often you need to deploy your code

Are you going to deploy code as frequently as possible or just have a long standing branch that can be pushed live when the migration process is completed?

From my experience, the best approach would be a combination of the two.

Of course your project may be different and this decision should be taken case by case, but most of the time you will encounter situations where some parts of the code can be deployed as soon as they are completed and some parts are dependent on the new platform.

For example in a migration to a newer database version, some models may not work with the new database out of the box and may require switching the persistence layer first, then update them. In this case a long standing branch may be a better solution for the code that cannot be deployed immediately.

This is exactly what we decided to do as part of our migration at Chip. We deployed the code that was compatible with the older and still in production MongoDB version, but we kept the code that required the new version in a long standing branch, to be released after the database upgrade.

## 6. Break the process into tasks

One issue that I encountered in my early career was dealing with tasks that were too big to handle and were blocking other team members from making progress.

Try to break your migration process into tasks that have a single clear objective. This will help you and the rest of the team to work individually and in parallel on the same codebase.

For example, if you receive a task titled "Complete the migration", I am 100% sure that this one needs to be broken into smaller ones. If your tasks are too broad in scope then you will eventually end up blocking the progress as others are waiting for your work to be deployed.

At Chip we use Jira as a software development tool to track our tickets and organize our sprints. This gives us clarity and helps us manage teams of developers with ease.

As a developer, it's always nice when you can clearly see what your tasks are for the entire sprint.

## 7. Create a Q.A. regression plan

Before doing the big leap of faith, you need to properly test your code and make sure it works in the same way as it used to work in the old platform.

The developers can test their own code, of course, but we all know how we sometimes skip the parts that may be broken and put more emphasis on the parts that we know they "work". You may be very happy that all your tests pass, but this is not enough for a big and complex application.

You need an outside person who hasn't worked on the initial code to try and break it and discover if there are any hidden issues.

To do this, you will need a regression test. A regression test can be completed by a skilled QA engineer before your new migrated application gets pushed into production.

At Chip we employ the help of an entire team of skilled QA engineers to make sure our code is bug-free before reaching the production environment. The team is split across mobile (front end) and backend QA engineers and we are always looking for the best talent out there to enhance it.

## 8. Press the red button

During our last migration at Chip, we had to bring our application down for a couple of hours, and have a team of engineers work during the late hours of Sunday evening to ensure the migration is completed successfully.

First we updated our legacy MongoDB to the latest version by using a scripted approach that we tested during the previous week over and over again.

Next, we deployed the updated code that was not compatible with the older database version and we did a "short" +2 hours session of testing behind closed doors to make sure everything works as expected and the code talks nicely with our new database.

We mitigated the risk of this failing by having a plan in place, just in case. 

We were prepared that if the migration would not be successful, we could easily revert to the older database version and complete the job in the next week.

<img src="https://i.gifer.com/5GNz.gif">

Fortunately this was not the case and the last step of the migration worked seamlessly so the entire public API was again exposed to the public.

We ended up doing a final round of testing the next week and finally concluded that the migration was a success.

At Chip, we are on a mission to build the best savings account in the world. 

Automated, intelligent, wealth-building all with an amazing UI for the mobile generation.

If you are a developer looking for your next opportunity or you are just looking for an intelligent way to save more money, then you have to [check out Chip](https://getchip.uk).

[![Chip](https://media.cdn.teamtailor.com/images/s3/teamtailor-production/gallery_picture-v1/image_uploads/39404b37-6e69-4e51-89c2-6ad11f8a98c9/original.jpeg)](https://getchip.uk "Check out Chip")