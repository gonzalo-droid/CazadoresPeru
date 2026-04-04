allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Patch for Flutter plugins that don't declare a namespace (e.g. isar_flutter_libs 3.x)
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val androidExtension = extensions.getByType<com.android.build.gradle.BaseExtension>()
            if (androidExtension.namespace == null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val pkg = groovy.xml.XmlParser().parse(manifestFile).attribute("package")?.toString()
                    if (pkg != null) {
                        androidExtension.namespace = pkg
                    }
                }
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
