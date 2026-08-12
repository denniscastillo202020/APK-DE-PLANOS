import re, os, shutil

shutil.copyfile("signing/release-keystore.jks", "android/app/release-keystore.jks")

with open("android/key.properties", "w") as f:
    f.write("storePassword=PlanosCastillo2026\n")
    f.write("keyPassword=PlanosCastillo2026\n")
    f.write("keyAlias=planoscastillo\n")
    f.write("storeFile=release-keystore.jks\n")

gradle_path = "android/app/build.gradle.kts"
if not os.path.exists(gradle_path):
    gradle_path = "android/app/build.gradle"

with open(gradle_path, "r") as f:
    contenido = f.read()

if "planoscastillo" not in contenido:
    if gradle_path.endswith(".kts"):
        bloque_carga = (
            'import java.util.Properties\n'
            'import java.io.FileInputStream\n\n'
        )
        bloque_signing = '''
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

'''
        contenido = bloque_carga + contenido
        contenido = contenido.replace("android {", bloque_signing + "android {", 1)
        contenido = re.sub(
            r"buildTypes\s*\{",
            'signingConfigs {\n'
            '        create("release") {\n'
            '            keyAlias = keystoreProperties["keyAlias"] as String\n'
            '            keyPassword = keystoreProperties["keyPassword"] as String\n'
            '            storeFile = file(keystoreProperties["storeFile"] as String)\n'
            '            storePassword = keystoreProperties["storePassword"] as String\n'
            '        }\n'
            '    }\n\n    buildTypes {',
            contenido, count=1,
        )
        contenido = re.sub(
            r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
            'signingConfig = signingConfigs.getByName("release")',
            contenido,
        )
    else:
        bloque_carga = (
            "def keystoreProperties = new Properties()\n"
            "def keystorePropertiesFile = rootProject.file('key.properties')\n"
            "if (keystorePropertiesFile.exists()) {\n"
            "    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n"
            "}\n\n"
        )
        contenido = bloque_carga + contenido
        contenido = re.sub(
            r"buildTypes\s*\{",
            "signingConfigs {\n"
            "        release {\n"
            "            keyAlias keystoreProperties['keyAlias']\n"
            "            keyPassword keystoreProperties['keyPassword']\n"
            "            storeFile file(keystoreProperties['storeFile'])\n"
            "            storePassword keystoreProperties['storePassword']\n"
            "        }\n"
            "    }\n\n    buildTypes {",
            contenido, count=1,
        )
        contenido = re.sub(
            r"signingConfig\s+signingConfigs\.debug",
            "signingConfig signingConfigs.release",
            contenido,
        )

    with open(gradle_path, "w") as f:
        f.write(contenido)

print("Firma configurada en", gradle_path)
