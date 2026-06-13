import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.flutter.base.dev"
            resValue(type = "string", name = "app_name", value = "AppDev")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.flutter.base.stg"
            resValue(type = "string", name = "app_name", value = "AppStg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.flutter.base"
            resValue(type = "string", name = "app_name", value = "App")
        }
    }
}