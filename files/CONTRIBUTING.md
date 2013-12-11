# Test-Driven Development Workflow

## Step 1:  Create feature branch...

Always create a feature branch off of a freshly updated version of master.
Use the thegarage-gitx `start` command to simplify the process.

```
$ git start my-feature-branch
```

### Git Branching Protips&trade;
* Ensure branch stays up-to-date with latest changes merged into master (ex: `$ git update`)
* Use a descriptive branch name to help other developers (ex: fix-login-screen, api-refactor, payment-reconcile, etc)
* Follow [best practices](http://robots.thoughtbot.com/post/48933156625/5-useful-tips-for-a-better-commit-message) for git commit messages to communicate your changes.
* Only write the **minimal** amount of code necessary to accomplish the given task.
* Changes that are not directly related to the current feature should be cherry-picked into their own branch and merged separately than the current changeset.


## Step 2: Implement the requested change...
Use Test Driven Development to ensure that the feature has proper code coverage

**RED** - Write tests for the desired behavior...

**GREEN** - Write just enough code to get the tests to pass...

**REFACTOR** - Cleanup for clarity and DRY-ness...

### Testing Protips&trade;
* Every line of code should have associated unit tests.  If it's not tested, it's probably broken and you just don't know it yet...
* Follow [BetterSpecs.org](http://betterspecs.org/) as reference for building readable and maintainable unit tests.


## Step 3: Review changes with team members...
Submit pull request...Discuss...
Use the thegarage-gitx `reviewrequest` command to automate the process.

```
$ git reviewrequest
```

### Pull Request Protips&trade;
* Describe high level overview of the branch in pull request description.  Include links to relevant resources.
* Record **artifacts** created by this feature (ex: screenshots of UI changes, screencasts of UX changes, logs from database migrations, etc)
* Document **follow-up** items/tasks that need to be addressed post-release

### Questions to ask...
* Is there a simpler way to accomplish the task at hand?
* Are we solving the problems of today and not over engineering for the problems of tomorrow?


## Step 4: Sign-off and release

* Pull requests must be signed off by team leads before release (preferrably via :shipit: emoji)
* Smoketest all changes locally
* (optional) Smoketest changes in staging environment (via `git integrate staging`)
* Ensure that build is green (local build + travis-ci and/or deploy to staging environment)

Use thegarage-gitx `release` command to automate the process.

```
$ git release
```

## Step 5: Profit?
