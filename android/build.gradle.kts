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

subprojects {
    fun configureNamespaceIfMissing() {
        val androidExt = extensions.findByName("android") ?: return

        try {
            val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
            val currentNamespace = getNamespace?.invoke(androidExt) as? String
            if (!currentNamespace.isNullOrBlank()) return

            val manifestFile = file("src/main/AndroidManifest.xml")
            if (!manifestFile.exists()) return

            val manifestText = manifestFile.readText()
            val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestText)
            val packageName = packageMatch?.groupValues?.getOrNull(1)

            if (!packageName.isNullOrBlank()) {
                val setNamespace = androidExt.javaClass.methods.firstOrNull {
                    it.name == "setNamespace" && it.parameterTypes.size == 1
                }
                setNamespace?.invoke(androidExt, packageName)
            }
        } catch (_: Exception) {
            // Keep build resilient when a subproject does not expose Android namespace APIs.
        }
    }

    if (state.executed) {
        configureNamespaceIfMissing()
    } else {
        afterEvaluate {
            configureNamespaceIfMissing()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
