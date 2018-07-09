## Jenkins Pipeline

### What is Jenkins Pipeline
Jenkins pipeline is a suite of plugins which supports implementing and integrating `continuous integration and delivery`
pipeline into Jenkins.

A CI/CD pipeline is an automated expression of your process for getting features of software from version control right
through to the end users. Every change in your software (commited in source control) goes through a complex process on
its way being released. This process involves building software in a reliable and repeatable manner, as well as progressing
the built software through multiple stages of testing and deployment.

The definition of Jenkins pipeline is written into a text file (Jenkinsfile) which in turn can be commited to a project's
source control repo. This is the foundation of `Pipeline as code`, treating the pipeline as part of the application to be 
versioned and reviewed like any other code.

### Jenkinsfile benefits:
Creating a Jenkinsfile and committing it to source control provides a number of immediate benefits:
* Automatically creates a pipeline build process for all the branches and PRs.
* Code review/iteration on the pipeline
* Audit trial for the pipeline
* Single source of truth for the pipeline. No more misconfigurations and blames.

### Declarative vs Scripted
A Jenkinsfile can be written using two types of syntax: Declarative and scripted. They are constructed fundamentally differently. Declarative is a more recent feature of Jenkins pipeline which:
* Provide richer syntactical features
* Designed to make writing and reading pipeline code easier

### Why pipeline
Jenkisn is fundamentally an automation engine
