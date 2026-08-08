# Mağaza Otomasyonu — App Store & Google Play

> **Kapsam: yalnızca Osman'ın KİŞİSEL uygulamaları** (OtoparkPro, WashPro
> ve sonrakiler; `osmantanrikulu@gmail.com` hesapları, Tanrikulu Apps
> çatısı). Gökçelik'in kurumsal uygulamalarıyla (GMobile, GMusteriPortal…)
> hiçbir ilgisi yoktur — o hesaplar ayrıdır, buradaki anahtarlar orada
> kullanılmaz.
>
> Kurulum: 5 Ağustos 2026, OtoparkPro 1.1.1 yayınlanırken.
> Güncel tutulmalı.

Mağaza metinlerini ve ekran görüntülerini 24-27 dilde elle girmek
uygulama başına yüzlerce kopyala-yapıştır demek; hem saatler sürüyor hem
bir harf kaydığında fark edilmiyor. İki mağazanın da API'si var, bu iş
tamamen otomatik yapılabiliyor.

---

## 1. Kimlik bilgileri — nerede duruyorlar

**Hiçbiri depoya girmez, sohbete yazılmaz.** Yalnızca dosya yolu
kullanılır.

| Ne | Nerede | Ne için |
|---|---|---|
| App Store Connect API anahtarı | `~/.appstoreconnect/private_keys/AuthKey_6CRLV6MMMK.p8` | ASC metin + görsel + build yükleme |
| ASC Key ID | `6CRLV6MMMK` | Gizli değil |
| ASC Issuer ID | `69a6de86-7a95-47e3-e053-5b8c7c11a4d1` | Gizli değil |
| Play servis hesabı | `~/.gcp/play-service-account.json` | Play metin + görsel + (istenirse) AAB |
| Play servis hesabı e-postası | `revenuecat-play@tanrikulu-apps.iam.gserviceaccount.com` | Gizli değil |

**ASC anahtarı hesap genelinde geçerlidir** — yeni bir uygulama için
yeniden üretmeye gerek yok, `--app-id` değiştirmek yeter.

**Play servis hesabı da öyle**, ama her yeni uygulama için Play
Console'da o uygulamaya erişim izni verilmesi gerekir:
Play Console → Kullanıcılar ve izinler → servis hesabını bul → uygulama
ekle. Gereken izinler: *Uygulama bilgilerini görüntüleme*, *Finansal
verileri görüntüleme*, *Siparişleri ve abonelikleri yönetme*,
**Mağazadaki varlığı yönetme** (metin ve görsel bunun altında).
Sürüm yayınlama izni bilerek VERİLMEDİ.

Ayrıca Google Cloud'da **Google Play Android Developer API** açık olmalı.

---

## 2. Araçlar

Hepsi OtoparkPro deposunda, `tools/` altında. Yeni uygulamaya kopyalanır,
paket adı ve app id değiştirilir.

| Araç | Ne yapar |
|---|---|
| `tools/asc_metadata.py` | ASC'ye ad, alt başlık, açıklama, anahtar kelime, tanıtım metni, yenilikler, destek/gizlilik adresi |
| `tools/asc_screenshots.py` | ASC'ye ekran görüntüsü |
| `tools/play_metadata.py` | Play'e başlık, kısa açıklama, tam açıklama |
| `tools/play_screenshots.py` | Play'e ekran görüntüsü |
| `store/screenshots/make_locales.py` | Görselleri dil dil üretir (başlık çevrilir, cihaz görüntüsü aynı kalır) |
| `store/screenshots/compose.swift` | Tek görseli çizer (CoreGraphics) |
| `tools/sync_ios_version.py` | Widget uzantısının sürümünü ana uygulamayla eşitler (ITMS-90473) |

Python ortamı:

```bash
python3 -m venv .venv-asc
.venv-asc/bin/pip install pyjwt cryptography google-auth requests pillow
```

Örnek çalıştırma:

```bash
.venv-asc/bin/python tools/asc_metadata.py \
  --key-id 6CRLV6MMMK \
  --issuer-id 69a6de86-7a95-47e3-e053-5b8c7c11a4d1 \
  --key ~/.appstoreconnect/private_keys/AuthKey_6CRLV6MMMK.p8 \
  --app-id <APP_ID> --version <SURUM> --only de --dry-run
```

**Her zaman önce `--only <bir dil> --dry-run`.** Sonucu mağazada gör,
doğruysa hepsini bas.

---

## 3. Bilinen tuzaklar

Hepsi 4-5 Ağustos 2026'da bizzat yaşandı.

### App Store

- **İki ayrı uç var, karıştırması kolay.** Ad ve alt başlık
  `appInfoLocalizations`'ta; açıklama, anahtar kelime, tanıtım metni ve
  yenilikler `appStoreVersionLocalizations`'ta.
- **Uygulamanın BİRDEN FAZLA `appInfo`'su olur.** Yayındaki kilitlidir
  (`state = READY_FOR_DISTRIBUTION`). Yanlışını seçersen ASC
  *"a relationship cannot be created in current state"* der ve sebebini
  söylemez. Düzenlenebilir olanı seç.
- **Yayındaki sürümün metinleri değiştirilemez.** Metinler ancak
  "Prepare for Submission" durumundaki bir sürüme yazılır.
- **Destek ve gizlilik adresi HER DİLDE ayrı ayrı zorunlu.** Türkçe'de
  dolu olması diğerlerini kurtarmıyor; eksikse gönderim engellenir
  (*"Support URL - This field is required"*).
- **Apple `az`, `fa`, `ur` dillerini mağaza dili olarak desteklemiyor.**
  Uygulama o dillerde çalışsa bile mağaza sayfası açılamıyor.
- **"Ready for Distribution" satışta olmak DEĞİLDİR.** Yeni uygulamada
  ülke seçimi kendiliğinden dolu gelmiyor; Pricing and Availability →
  Manage Availability'den ülkeler açıkça seçilmeli, yoksa uygulama
  onaylanır ama hiçbir yerde bulunamaz ve mağaza linki 404 verir.
- **Abonelikli gönderimde kalem sırası:** önce sürüm, sonra abonelik
  grubu, sonra abonelik. Sıra bozulursa ASC *"An unexpected error was
  encountered"* diyor.

### Play

- **En fazla 2:1 en-boy oranı.** App Store için üretilen 1284×2778
  (2.164:1) reddediliyor. Kırpma başlığı ya da telefonu kesiyor; ayrı ve
  daha kısa bir tuvale (1284×2568) yeniden çizmek doğru yol.
- **Yerel ayar kodları farklı:** İbranice `iw-IL`, Çince `zh-CN`,
  Portekizce `pt-BR`, Azerice `az-AZ`.
- **Play `az`, `fa`, `ur` dillerini DESTEKLİYOR** — Apple'da 24, Play'de
  27 dil.
- **Görseller ayrı adresten gider:** normal JSON ucundan değil,
  `/upload/…?uploadType=media` üzerinden ham bayt olarak.
- **Yeni görseller eskilerin ÜSTÜNE ekleniyor** ve Play en fazla 8 görsel
  alıyor; önce `deleteall` çağırmak gerekiyor.
- **Play "edit oturumu" mantığıyla çalışır:** commit edilmeyen oturum
  mağazada hiçbir şey değiştirmez. Hata olursa oturumu sil, yarım iş
  kalmasın.
- **Kısa açıklama (80 karakter) App Store'da karşılığı olmayan bir
  alandır.** Alt başlık 30, tanıtım metni 170 karakter; ikisi de uymuyor,
  ayrıca yazılmalı. Bu satır Play arama sonuçlarında görünür.
- **Uygulama kaydını API açamaz.** Ne Play ne ASC'de "yeni uygulama
  yarat" ucu var; ilk kayıt elle açılır, gerisi otomatiktir.

### Görsel üretimi

- **`qlmanage` SVG'yi KARE tuvale oturtuyor.** SVG + qlmanage yolu
  görselleri sessizce bozuyor (telefon büyüyüp taşıyor) ve API "başarılı"
  diyor. `compose.swift` (CoreGraphics) kullan.
- **`letter-spacing` Arapça'da harflerin birleşmesini bozuyor.** SVG
  yolunda yaşandı; CoreText'te sorun yok.
- **Başlık uzunluğu dile göre çok değişiyor** ("Otoparkın cebinde" →
  "Ihr Parkplatz in der Tasche"); punto otomatik küçülmeli.

---

## 4. Altın kural

**"Yüklendi" demek doğru yüklendi demek değil.** API `COMPLETE` dönüp
görselin bozuk olduğu, metnin eksik alanla kaydedildiği bir günü yaşadık.
Yükledikten sonra **mağazadan geri oku ve karşılaştır** — ölçü, sayı,
içerik. Sonucu ancak ondan sonra bildir.

---

## 5. Yeni uygulama açarken kontrol listesi

Elle yapılacaklar (API açamaz):

1. Play Console → Uygulama oluştur; App Store Connect → Bundle ID + yeni uygulama
2. Play'de servis hesabına o uygulama için izin ver
3. ASC'de fiyat (Free) ve **175 ülke** seç
4. Gizlilik politikası ve hesap silme sayfası adresleri
   (`tanrikuluapps.com/legal/…` altında ortak)

Sonrası otomatik: metinler, görseller, build yükleme, sürüm oluşturma.

Ayrıca bkz. [ALTYAPI.md](ALTYAPI.md) — alan adı, e-posta, site düzeni.

## TestFlight'a Xcode'suz yükleme (8 Ağu 2026'da çözüldü)

Oturum, kullanıcıya Organizer tıklatmadan TestFlight'a build basabilir.
Üç adım (OtoparkPro'da doğrulandı; WashPro da aynı yolu kullanır):

```bash
# 1) Arşiv (flutter'ın kendi IPA export'u düşebilir, sorun değil)
flutter build ipa   # build/ios/archive/Runner.xcarchive üretir

# 2) Export — KRİTİK: signingCertificate "Apple Distribution"
#    (anahtar zincirindeki YEREL sertifika; belirtilmezse xcodebuild
#    bulut yönetimli sertifikaya gider ve API anahtarlarında o izin
#    olmadığı için "Cloud signing permission error" düşer)
plutil -replace signingCertificate -string "Apple Distribution" eo.plist
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath out -exportOptionsPlist eo.plist -allowProvisioningUpdates \
  -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_<ID>.p8 \
  -authenticationKeyID <ID> -authenticationKeyIssuerID <ISSUER>

# 3) Yükle
xcrun altool --upload-app -f out/*.ipa -t ios \
  --apiKey <ID> --apiIssuer <ISSUER>
```

Notlar: eo.plist tabanı, daha önceki başarılı bir export'un
ExportOptions.plist'i (method app-store-connect, signingStyle
automatic). API anahtarı profil üretebilir (-allowProvisioningUpdates)
ama bulut sertifikası YÖNETEMEZ — yerel sertifika bu yüzden şart.
Sertifika süresi dolarsa (31 Tem 2027) Xcode'la bir kez yenilenir.
