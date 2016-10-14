/**
 * This Jenkins DSL Creates the following jenkins jobs and nested pipeline views:
 * 1. service build job (service-build)
 * 2. service release (service-release)
 * 3. service deploy (service-deploy)
 * 4. service system-test (service-system-test)
 */
import groovy.json.JsonSlurper

// Load package versions
Properties versions = new Properties()
versions.load(streamFileFromWorkspace('microservice-dsls/config/versions.dsl'))

// Load urls
Properties urls = new Properties()
urls.load(streamFileFromWorkspace('microservice-dsls/config/urls.dsl'))

// Define LinkedHashMap multiPut function, this allows you to
// append multiple values to the same key
LinkedHashMap.metaClass.multiPut << { key, value ->
    delegate[key] = delegate[key] ?: []; delegate[key] += value
}

def release_down_streams = [:]   // Release job down streams mapping
def release_artifacts = [:]      // Release job artifacts dir mapping
def slurper = new JsonSlurper()
def service_lists = []           // List hold each microservice project (include sub proj)
def service_map = [:]
def view_group = "Microservice Pipeline"

// Load microservices definition
def service_objects = slurper.parseText(readFileFromWorkspace('microservice-dsls/config/services.dsl'))
// Create jenkins job for every microservice
service_objects.each { name, data ->
    // Aggregate each service into ArrayList
    for (item in data) {
        service_lists.add(item)
    }
}

service_lists.each {
    // Add each service into map, this is for nestedView later
    service_map[it.name] = it

    // Creating master build, release and piranha deploy jobs
    println "Create master branch builder job for ${it.parent_name}-service"
    createMasterBuildJob(it.parent_name, it, versions, urls)
    println "Create release job for ${it.parent_name}-service"
    // Eliminate weird jenkins duplicate entries
    createReleaseJob(it.parent_name, versions, urls)
    println "Create deploy job for ${it.name}-service"
    createDeployJob(it.parent_name, it, versions)
}

def microservicesByGroup = service_map.groupBy({view_group})

/** Create nested build nested pipeline view
 *  nestedView() has to take a parameter, and give a non-empty name will
 * create an empty pipeline view, this could be a bug
 */
nestedView('a') {
    columns {
        status()
        weather()
    }
    views {
        microservicesByGroup.each { group, services ->
            nestedView("${group}") {
                columns {
                    status()
                    weather()
                }
                views {
                    def innerNestedView = delegate
                    def created_views = []
                    services.each { name, data ->
                        if (!created_views.contains(data.parent_name)) {
                            innerNestedView.buildPipelineView("${data.parent_name}") {
                                selectedJob("${data.parent_name}-build")
                                triggerOnlyLatestJob(false)
                                alwaysAllowManualTrigger(true)
                                showPipelineParameters(true)
                                showPipelineParametersInHeaders(true)
                                showPipelineDefinitionHeader(true)
                                startsWithParameters(true)
                                displayedBuilds(10)
                            }
                        }
                        created_views.add(data.parent_name)
                    }
                }
            }
        }
    }
}

/**
 * Create master branch builder jenkins job
 */
def createMasterBuildJob(name, data, versions, urls) {
    mavenJob("${name}-build") {
        triggers {
            scm('H/2 * * * *')
        }

        scm {
            git {
                remote {
                    url("git@github.com:tonylixu/jenkins-dsl.git")
                }
                branch('origin/master')
                createTag(false)
                configure { node ->
                    // Exclude build from jenkins user
                    node / 'extensions' << 'hudson.plugins.git.extensions.impl.UserExclusion' {
                        excludedUsers 'Jenkins'
                    }
                }
            }
        }

        mavenInstallation("${versions.'maven'}")
        goals('-Pint clean verify')
        rootPOM('pom.xml')

        configure { proj ->

            // Set strategy
            props = proj / 'properties' / 'jenkins.model.BuildDiscarderProperty'
            props << ('strategy' {
                daysToKeep('-1')
                numToKeep('10')
                artifactDaysToKeep('-1')
            })

            // Set project URL
            props = proj / 'properties'
            props << ('com.coravy.hudson.plugins.github.GithubProjectProperty'(plugin="${versions.'github'}") {
                projectUrl("${urls.'company'}/${name}/")
            })

            // Run post steps only if build succeeds
            props = proj / 'runPostStepsIfResult'
            props << ('completeBuild' {
                'true'
            })

            // Set publisher
            def publishers = proj / 'publishers'

            // Set slack notifications
            publishers << ('jenkins.plugins.slack.SlackNotifier'(plugin="${versions.'slack'}") {
                startNotification('false')
                notifySuccess('false')
                notifyAborted('true')
                notifyNotBuilt('true')
                notifyUnstable('true')
                notifyFailure('true')
                notifyBackToNormal('true')
            })

            publishers << ('hudson.tasks.BuildTrigger' {
                childProjects("${name}-release")
            })
            publishers = proj / 'publishers' / 'hudson.tasks.BuildTrigger' / 'threshold'
            publishers.appendNode('name', 'SUCCESS')
            publishers.appendNode('ordinal', '0')
            publishers.appendNode('color', 'BLUE')
            publishers.appendNode('completeBuild', 'true')
        }
    }
}

/**
 * Create microservice release job
 */
def createReleaseJob(name, versions, urls) {
    mavenJob("${name}-release") {
        scm {
            git("git@github.com:tonylixu/jenkins-dsl.git", 'master')
        }

        // Define maven settings
        mavenInstallation("${versions.'maven'}")
        goals('--batch-mode jgitflow:release-start jgitflow:release-finish -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -DskipTests -Pbuild-system-test-rpm')

        configure { proj ->

            // Set strategy
            props = proj / 'properties' / 'jenkins.model.BuildDiscarderProperty'
            props << ('strategy' {
                daysToKeep('-1')
                numToKeep('30')
                artifactDaysToKeep('-1')
                artifactNumToKeep('10')
            })

            // Set project URL
            props = proj / 'properties'
            props << ('com.coravy.hudson.plugins.github.GithubProjectProperty'(plugin="${versions.'github'}") {
                projectUrl("${urls.'company'}/${name}/")
            })

            // Set prebuilders
            def prebuilders = proj / 'prebuilders'
            prebuilders << ('org.jenkinsci.plugins.managedscripts.ScriptBuildStep' (plugin='managed-scripts@1.2.1') {
                buildStepId('org.jenkinsci.plugins.managedscripts.ScriptConfig1445013207596')
            })

            // Set postbuilders
            def postbuilders = proj / 'postbuilders'
            postbuilders << ('hudson.tasks.Shell' {
                command('git push origin master --follow-tags \n' +
                        'git push origin release --follow-tags')
            })

            // Run post steps only if build succeeds
            props = proj / 'runPostStepsIfResult'
            props << ('completeBuild' {
                'true'
            })

            // Set publisher
            def publishers = proj / 'publishers'

            // Set slack notifications
            publishers << ('jenkins.plugins.slack.SlackNotifier'(plugin="${versions.'slack'}") {
                startNotification('false')
                notifySuccess('false')
                notifyAborted('true')
                notifyNotBuilt('true')
                notifyUnstable('true')
                notifyFailure('true')
                notifyBackToNormal('true')
            })

            publishers << ('hudson.tasks.ArtifactArchiver' {
                artifacts(artifacts_dirs.join(","))
            })
        }
    }
}

/**
 * Create deploy jenkins job
 */
def createDeployJob(name, data, versions) {
    mavenJob("${data.name}-deploy") {
        scm {
          git {
                remote {
                    url("git@github.com:tonylixu/jenkins-dsl.git")
                    branch('*/release')
                    credentials('xxxx-xxxxx-xxxxxxx-xxxxxxxxxxxxxxxxxxx')
                }
            }
        }

        triggers {
            upstream("${name}-release", 'SUCCESS')
        }

        // Define maven settings
        mavenInstallation("${versions.'maven'}")
        goals('clean verify -DskipTests microservice:deploy')
        rootPOM("${data.service_directory}/pom.xml")

        configure { proj ->

            // Set publisher
            def publishers = proj / 'publishers'

            // Set slack notifications
            publishers << ('jenkins.plugins.slack.SlackNotifier'(plugin="${versions.'slack'}") {
                startNotification('false')
                notifySuccess('false')
                notifyAborted('true')
                notifyNotBuilt('true')
                notifyUnstable('true')
                notifyFailure('true')
                notifyBackToNormal('true')
            })

            publishers << ('hudson.tasks.BuildTrigger' {
                childProjects("${data.name}-system-tests")
            })
            publishers = proj / 'publishers' / 'hudson.tasks.BuildTrigger' / 'threshold'
            publishers.appendNode('name', 'SUCCESS')
            publishers.appendNode('ordinal', '0')
            publishers.appendNode('color', 'BLUE')
            publishers.appendNode('completeBuild', 'true')
        }
    }
}
