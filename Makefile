.PHONY: help run-app run-web build-app build-web clean-app clean-web

help:
	@echo "Perintah yang tersedia:"
	@echo "  make run-app    - Menjalankan aplikasi admin (Flutter) di mode debug"
	@echo "  make run-web    - Menjalankan website buyer (Next.js) di mode dev"
	@echo "  make build-app  - Membuat release APK untuk aplikasi admin"
	@echo "  make build-web     - Membuat production build untuk website buyer"
	@echo "  make clean-app     - Membersihkan cache dan dependencies aplikasi admin"
	@echo "  make clean-web     - Membersihkan dependencies website buyer"
	@echo "  make fingerprint-app - Generate SHA-1 dan SHA-256 untuk Firebase"

run-app:
	cd admin && flutter run

run-web:
	cd buyer && pnpm dev

build-app:
	cd admin && flutter build apk --release
	@echo "APK admin berhasil dibuat di: admin/build/app/outputs/flutter-apk/app-release.apk"

build-web:
	cd buyer && pnpm build
	@echo "Production build website buyer selesai."

clean-app:
	cd admin && flutter clean && flutter pub get

clean-web:
	cd buyer && pnpm store prune && pnpm install

fingerprint-app:
	cd admin/android && ./gradlew signingReport
