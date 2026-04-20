Before you start, we would like to congratulate you on reaching that stage of our hiring process; it's already a significant achievement!

This is a technical exercise where we want to see the best of you. This exercise is limited to 2 days in total, so don't rush it and take the time you need within that limit. Keep in mind, we recommend favoring quality over quantity.

## :bulb: Note on AI
We see AI as a catalyst for our success - not a shortcut, but a way to think sharp and raise the bar. We actively encourage you to use it. What we care about is how you use it.

Come to your presentation ready to walk us through:
- What you used AI for - and what you chose not to;
- How you prompted it - bring concrete examples;
- How you challenged it - where you pushed back, iterated, or discarded its output.

# How to submit your work
Use this GitHub repository to push your code.

First, clone this repository locally:
```script
$ git clone https://github.com/ios-qonto/REPOSITORY_NAME
```

By default, Github provides a `/main` branch. Please create a `/feature` branch to complete your exercise. Feel free to follow your own git-flow logic while developing, but please open a pull request from the `/feature` to the `/main` branch once you completed this exercise. 

We will then use this pull request to review your code.

**Note :** Adding a short video of your application on the description of the pull request will help us to review your work.

# Part 1 - Let's make an application!

Context - Qonto mobile developers strive to build applications where complex actions are made simple, fast and transparent for our users.

Build an application that fetches data from this API - [Transactions API](https://us-central1-qonto-staging.cloudfunctions.net/transactions) - and displays a list of Transactions. 
Start by reading the API documentation [here](https://qonto.notion.site/Public-Documentation-API-get-Transactions-34131ee4c69680d48790f31fd7d66e0f). Your application should fetch multiple pages of Transactions from that API and display a list of Transactions showing at least the `counterpartyName` and `amount` on one line, and the `settledAt` and `status` below. Following pages should be fetched when users scroll the list. Finally, while offline, previously loaded Transactions should still be accessible from the list. We recommend you implement this based on a classic database solution like Core Data or Realm.


## Code guidelines

Feel free to use any third-party libraries you'd need.
We favour quality over quantity, so here are a few things you should keep in mind:

- your project should follow a well-known design pattern (MVVM, Clean architecture, MVP, etc...)
- your code should contain some developers' good practices (SOLID, KISS, DRY, etc...)
- cover some classes with tests (no need to cover everything)
- favor technologies you master rather than new, fancy ones

# Part 2 - Present your work

Context - Qonto engineers are active during our conception phases (Value Engineering, DiveIns) where they are required to write down their ideas, plan their work and engage in technical discussion with peers. 

Your next interview will be the Skills Test debrief where we will ask you to present your work and justify your choices. To prepare for this interview, it's expected that you take the time to create a new Markdown file (.md) on your pull request and on this document to answer the following questions:

- give us your context at the time you did this skills test. Were you stressed/relaxed, under some constraints?
- present your work; explain its architecture, main components and how they interact with each other. Feel free to include diagrams as appropriate. Hand-drawn is fine.
- explain where you applied some developers' good practices: design pattern, SOLID, KISS, DRY principles, etc...
- explain your development strategy:
    - if you favored some functionalities or layers
    - your commits strategy
- explain if your code is future-proof (scalable, robust to changes, etc...)

Please answer in 🇺🇸  English.

# Retro

We would much appreciate if you could quickly answer the following:

1. How much time did you spend answering those questions?
    - [ ]  Less than 3h
    - [ ]  3h to 4h
    - [ ]  4h to 5h
    - [ ]  5h to 6h
    - [ ]  More than 6h (your time: _________)
2. How proud are you of your work? (Feel free to explain why)
    - [ ]  Very proud
    - [ ]  Fairly proud
    - [ ]  Good enough
    - [ ]  Somehow disappointed
3. Is there anything missing that you think would be relevant to ask to candidates in the context of Skills Test?

# Well done!

Thank you for your time; if you have any questions, don't hesitate to contact us. We will quickly review your code and get back to you.

The Qonto iOS team
