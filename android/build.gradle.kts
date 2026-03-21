@Suppress("DSL_SCOPE_VIOLATION") // fix: suppress known scope violation warning in allprojects block
plugins.withId("com.android.application").apply {
    repositories {
        google()
        mavenCentral()
    }
}

// Correct buildDir relocation for root and subprojects
@Suppress("DSL_SCOPE_VIOLATION") // fix: suppress known scope violation warning in subprojects block
subprojects {
    // Set custom build directory path
    buildDir = file("${rootProject.rootDir}/../build/${project.name}")
    // Make sure subprojects depend on ":app" evaluation
    evaluationDependsOn(":app")
}

@Suppress("DSL_SCOPE_VIOLATION") // fix: suppress known scope violation warning in tasks block
tasks.register<Delete>("clean") {
    // Delete root build directory, which now contains all subproject build outputs
    delete(file("${rootProject.rootDir}/../build"))
}
