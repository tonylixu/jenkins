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
Jenkisn is fundamentally an automation engine which support a number of automation patterns. Pipeline adds a set of powerful
tools onto Jenkins supporting use cases that span from simple CI to comprehensive CD pipeline. By modeling a series of related tasks, users can take advantage of the many features of Pipeline:
* Code : Pipeline is implemented in code and checked into source control, giving teams the ability to edit, review and iterate upon their delivery pipeline.
* Durable: Pipeline can survive both planned and unplanned restarts of Jenkins.
* Pausable: Pipeline can optionally stop and wait for human input or approval before continue.
* Versatile: Pipeline supports complex real world CD requirements
* Extensible: Pipeline plugin supports custom extensions to its DSL and mutiple options for integration with other plugins.

### Pipeline concepts
* Pipeline: A user defined model of CD pipeline. A pipeline code defines your entire build process, which typically includes checkout, building, testing and deploying stages.
```groovy
# Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any 
    stages {
        stage('Build') { 
            steps {
                // 
            }
        }
        stage('Test') { 
            steps {
                // 
            }
        }
        stage('Deploy') { 
            steps {
                // 
            }
        }
    }
}
```
* Stage: Defines a conceptually distinct subset of tasks performed through the entire pipeline. For exmaple, "Build", "Test" and "Deploy".
* Step: A single task. Fundmentally, a task tells Jenkins what to do at a paticular point of time.

### Pipeline Example
```groovy
pipeline { # Pipeline block
    agent any 
    stages {  # Subset of tasks
        stage('Build') { 
            steps { # A single task
                sh 'make' 
            }
        }
        stage('Test'){
            steps {
                sh 'make check'
                junit 'reports/**/*.xml' 
            }
        }
        stage('Deploy') {
            steps {
                sh 'make publish'
            }
        }
    }
}
```
