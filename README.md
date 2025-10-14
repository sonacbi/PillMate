# PillMate

flutter create --project-name pillmate .
# flutter 프로젝트 생성시 '소문자, 숫자, 밑줄'만 이름에 사용 가능(dart 정책)

flutter doctor
flutter run
# 초기 세팅 완료

keytool -genkey -v -keystore C:\Users\User03\git\PillMate\key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pillmate-key
# Android 앱 서명용 KeyStore 생성 (릴리즈용)

CN=dajeong jeong, OU=Development Team, O="Korea Polytechnics, Campus of Gwangju, Department of AI Convergence", L=Gwangju, ST=Buckgu, C=KR
# 생성자 정보

# android/key.properties
storePassword=mypassword
keyPassword=mypassword
keyAlias=pillmate-key
storeFile=C:\\Users\\User03\\git\\PillMate\\key.jks

# 설정 추가 (위의 파일 읽게) android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream
....

# 릴리즈 apk 빌드
flutter clean
flutter pub get
flutter build apk --release

# USB + ADB
폰에서 개발자 모드 + USB 디버깅 켜기

# 터미널에서
adb install build/app/outputs/flutter-apk/app-release.apk

# 이미 설치됐다면
adb install -r build/app/outputs/flutter-apk/app-release.apk
