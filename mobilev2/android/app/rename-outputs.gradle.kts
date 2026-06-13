import java.text.Normalizer
import com.android.build.api.variant.ApplicationAndroidComponentsExtension
import com.android.build.gradle.AppExtension
import com.android.build.api.variant.FilterConfiguration

// =========================================================
//  HELPER - Chuyển tên project thành tên file an toàn (ASCII)
//  VD: "sports_booking_mobile" → "sports-booking-mobile"
// =========================================================
fun String.toSafeFileName(): String {
    val normalized = Normalizer.normalize(this, Normalizer.Form.NFD)
    return normalized
        .replace(Regex("[\\p{InCombiningDiacriticalMarks}]"), "")
        .replace("Đ", "D").replace("đ", "d")
        .replace(Regex("[^a-zA-Z0-9\\s_-]"), "")
        .trim()
        .replace(Regex("[\\s_]+"), "-")
        .lowercase()
}

// =========================================================
//  Lấy extensions thủ công (apply from script không có
//  type-safe accessors). Cần androidComponentsExt cho onVariants.
//  androidExt giữ lại để dùng cho default versionName/versionCode
//  ở AAB rename (lúc đó variant APIs đã không còn).
// =========================================================
val androidExt = project.extensions.getByType<AppExtension>()
val androidComponentsExt = project.extensions.getByType<ApplicationAndroidComponentsExtension>()

// =========================================================
//  PER-FLAVOR APP NAME - Đọc từ flavorizr.gradle.kts
//
//  Nguồn ưu tiên:
//   1. resValue "app_name" của flavor (set trong flavorizr productFlavors).
//      ⚠️ resValues chỉ available ở EXECUTION phase. Ở config phase trả null.
//   2. Parse trực tiếp file flavorizr.gradle.kts (regex) — luôn work, kể cả
//      configuration phase. Đây là fallback chính.
//   3. Cuối cùng: ghép rootProject.name + flavor literal.
//
//  Slugify kết quả bằng toSafeFileName() ngay tại call site.
// =========================================================
val flavorizrFile = project.file("flavorizr.gradle.kts")

fun flavorAppName(flavor: String): String {
    // 1. Try resValue (execution phase only)
    val raw = androidExt.productFlavors.findByName(flavor)
        ?.resValues?.get("string/app_name")?.value
    if (raw != null) return raw

    // 2. Parse flavorizr.gradle.kts trực tiếp
    if (flavorizrFile.exists()) {
        val content = flavorizrFile.readText()
        val regex = Regex(
            """create\("$flavor"\)\s*\{[^}]*?app_name[^)]*?value\s*=\s*"([^"]+)"""",
            RegexOption.DOT_MATCHES_ALL
        )
        regex.find(content)?.groupValues?.get(1)?.let { return it }
    }

    // 3. Fallback cuối: project slug + flavor
    return "${rootProject.name}-$flavor"
}

// =========================================================
//  GIT SHA - Lấy 1 lần ở config time (SHA không đổi trong 1 build).
//  Dùng ProcessBuilder thay vì providers.exec để né caveats của
//  configuration cache. Fail thì rơi về "nogit" cho an toàn.
// =========================================================
val gitSha7: String = try {
    val proc = ProcessBuilder("git", "rev-parse", "--short=7", "HEAD")
        .directory(rootProject.projectDir.parentFile) // mobilev2/ (gradle ở mobilev2/android/)
        .redirectErrorStream(true)
        .start()
    proc.waitFor()
    proc.inputStream.bufferedReader().readText().trim().ifEmpty { "nogit" }
} catch (_: Exception) {
    "nogit"
}

// =========================================================
//  HELPER - Bản prod release đẩy lên store thì bỏ SHA cho gọn,
//  vì store không cần traceability commit (đã có versionCode).
//  Các build khác (debug/profile, dev/stg) thì giữ SHA để dev
//  biết artifact build từ commit nào.
// =========================================================
fun isStoreRelease(flavor: String, buildType: String): Boolean =
    flavor == "prod" && buildType == "release"

// =========================================================
//  HELPER - Format timestamp YYYY-MM-DD_HHhMM. ISO date prefix
//  giữ sortable trong `ls -la`, separator '_' + 'h' để dễ đọc.
//  Phải gọi LAZY trong provider để phản ánh đúng thời điểm build,
//  không phải lúc gradle config init.
// =========================================================
fun currentTimestamp(): String =
    java.time.LocalDateTime.now()
        .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd_HH'h'mm"))

// =========================================================
//  RENAME APK
//  Format: <flavorAppName>-<buildType>[-<abi>]-v<versionName>+<versionCode>-<YYYY-MM-DD>_<HHhMM>[-<sha7>].apk
//  <flavorAppName> đọc từ flavorizr resValue "app_name" → toSafeFileName().
// =========================================================
androidComponentsExt.onVariants { variant ->
    variant.outputs.forEach { output ->
        val flavor = variant.flavorName ?: "noflavor"
        val buildType = variant.buildType ?: "release"
        val versionName = variant.outputs.first().versionName.orNull ?: "1.0.0"
        val versionCode = variant.outputs.first().versionCode.orNull ?: 1
        val appName = flavorAppName(flavor).toSafeFileName()

        // Nếu build có split-per-abi thì identifier sẽ là arm64-v8a/armeabi-v7a/x86_64.
        // "universal" tức là APK gộp → không cần suffix abi.
        val abiFilter = output.filters.find {
            it.filterType == FilterConfiguration.FilterType.ABI
        }?.identifier
        val abi = if (abiFilter != null && abiFilter != "universal") "-${abiFilter}" else ""

        val shaSuffix = if (isStoreRelease(flavor, buildType)) "" else "-${gitSha7}"

        // outputFileName là Property<String>. Dùng provider để timestamp lazy
        // (lấy thời điểm task chạy chứ không phải lúc gradle configure).
        (output as com.android.build.api.variant.impl.VariantOutputImpl)
            .outputFileName.set(
                project.provider {
                    val ts = currentTimestamp()
                    "${appName}-${buildType}${abi}-v${versionName}+${versionCode}-${ts}${shaSuffix}.apk"
                }
            )
    }
}

// =========================================================
//  RENAME AAB
//  Format: <flavorAppName>-<buildType>-v<versionName>+<versionCode>-<YYYY-MM-DD>_<HHhMM>[-<sha7>].aab
//  (bundle không có ABI split nên không có suffix abi)
// =========================================================
tasks.register("renameAab") {
    doLast {
        val bundleDir = file("${layout.buildDirectory.get()}/outputs/bundle")
        if (!bundleDir.exists()) return@doLast

        bundleDir.walkBottomUp().filter { it.extension == "aab" }.forEach { aabFile ->
            // Chỉ xử lý file gốc của Flutter (app-<flavor>-<buildType>.aab).
            // Bỏ qua nếu đã được đổi tên theo format mới (đã có "-v" trong tên).
            if (aabFile.name.contains("-v")) return@forEach

            val parentName = aabFile.parentFile.name
            val flavor = when {
                parentName.contains("Dev", ignoreCase = true) -> "dev"
                parentName.contains("Stg", ignoreCase = true) -> "stg"
                parentName.contains("Prod", ignoreCase = true) -> "prod"
                else -> return@forEach
            }
            val buildType = when {
                parentName.contains("Release", ignoreCase = true) -> "release"
                parentName.contains("Debug", ignoreCase = true) -> "debug"
                parentName.contains("Profile", ignoreCase = true) -> "profile"
                else -> "release"
            }

            val versionName = androidExt.defaultConfig.versionName ?: "1.0.0"
            val versionCode = androidExt.defaultConfig.versionCode ?: 1
            val appName = flavorAppName(flavor).toSafeFileName()
            val shaSuffix = if (isStoreRelease(flavor, buildType)) "" else "-${gitSha7}"
            val ts = currentTimestamp()

            val newName = "${appName}-${buildType}-v${versionName}+${versionCode}-${ts}${shaSuffix}.aab"
            val newFile = File(aabFile.parentFile, newName)

            if (aabFile.absolutePath == newFile.absolutePath) return@forEach

            if (aabFile.renameTo(newFile)) {
                println("✅ AAB renamed → $newName")
            }
            // Nếu thất bại (file bị lock, hoặc finalizedBy chạy lại) thì im lặng
            // để khỏi gây hiểu lầm trong log build.
        }
    }
}

// Auto-run renameAab after bundle tasks
tasks.whenTaskAdded {
    if (name.startsWith("bundle") && name.endsWith("Release")) {
        finalizedBy("renameAab")
    }
}
