allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Defensive compileSdk floor for plugin subprojects. A plugin that pins an
// old compileSdk (flutter_displaymode 0.6.0 pinned android-33) silently broke
// the APK/AAB jobs the day AndroidX transitives started requiring 34+ — with
// no change in this repo, because CI tracks the stable Flutter channel. Any
// plugin still below the app's compileSdk is lifted to it here, so a stale
// dependency can never take the store pipeline down again.
subprojects {
    fun liftCompileSdk(p: Project) {
        p.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            val declared = compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
            if (declared != null && declared < 36) compileSdkVersion(36)
        }
    }
    // The evaluationDependsOn(":app") block above forces :app to evaluate
    // while these subprojects blocks are still registering, so :app reaches
    // here already evaluated — afterEvaluate would throw on it. Run the lift
    // immediately for anything already evaluated (a no-op for :app, which
    // declares 36) and defer it for the plugin subprojects.
    if (state.executed) {
        liftCompileSdk(project)
    } else {
        afterEvaluate { liftCompileSdk(this) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
