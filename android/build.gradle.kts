plugins {
    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.android.application") version "8.7.3" apply false
    id("com.android.library")
    id("org.jetbrains.kotlin.android")

}

allprojects {
    repositories {
        maven { url = uri("https://maven.google.com") }
        google()
        google()
        mavenCentral()
    }

    configurations.all {
        resolutionStrategy {
            force("com.android.tools.build:gradle:8.7.3") // Update to match the classpath version
        }
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
android {
    namespace = "com.example.courier_application"
    compileSdk = 35
}

