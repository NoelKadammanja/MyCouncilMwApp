// Root build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
}

// All projects use these repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Customize root build directory
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Customize subproject build directories
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Ensure evaluation order for Android app module
    project.evaluationDependsOn(":app")
}

// Clean task for root project
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}