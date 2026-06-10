import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor")

    productFlavors {
        create("dev") {
            dimension = "flavor"
            applicationId = "com.flutter.base.dev"
            resValue(type = "string", name = "app_name", value = "MyApp Dev")
        }
        create("stg") {
            dimension = "flavor"
            applicationId = "com.flutter.base.stg"
            resValue(type = "string", name = "app_name", value = "MyApp Stg")
        }
        create("prod") {
            dimension = "flavor"
            applicationId = "com.flutter.base"
            resValue(type = "string", name = "app_name", value = "MyApp")
        }
    }
}
