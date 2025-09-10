allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Gunakan path absolut untuk menghindari masalah spasi di path
val newBuildDir: Directory = layout.buildDirectory.dir("C:/FlutterBuild/Gerobaks_Build/android").get()
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
