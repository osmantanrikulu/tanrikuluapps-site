# Tanrikulu Apps — Ortak Altyapı El Kitabı

> Bu dosya, Osman'ın tüm bağımsız uygulamalarının (OtoparkPro, WashPro ve
> sonrakiler) paylaştığı altyapıyı anlatır. Yeni bir uygulama oturumu bu
> dosyayı okuyarak alan adı, site, e-posta ve yayın düzenine hakim olur.
> Kurulum: 2 Ağu 2026. Güncel tutulmalı — altyapıda bir şey değişince
> burası da değişir.

## 1. Alan adı ve DNS

- **tanrikuluapps.com** — kayıt + DNS: **Cloudflare** (hesap:
  osmantanrikulu@gmail.com). Tüm uygulamaların ortak çatısı; uygulama
  başına ayrı domain ALINMAZ (bir ürün patlarsa pazarlama için sonradan
  eklenir, e-posta altyapısı taşınmaz).
- Yeni DNS kaydı gerektiğinde: Cloudflare → tanrikuluapps.com → DNS →
  Records. MX/TXT kayıtları "DNS only" kalır.

### ⚠️ Türkiye ağ tuzakları (bu Mac'te doğrulandı)
- `*.pages.dev` **Türkiye'de ISS seviyesinde engelli** (tüm zone sahte
  IP 213.14.227.50'ye çözülüyor). Kullanıcıya/dokümana asla pages.dev
  linki verme; her zaman `tanrikuluapps.com`.
- Dış DNS (1.1.1.1, 8.8.8.8) ve cloudflare-dns.com DoH bu ağda bloklu.
  Site testinde `dig` sahte IP döndürebilir; gerçek doğrulama = curl ile
  `https://tanrikuluapps.com/...` (200 mü?).

## 2. Web sitesi (Cloudflare Pages)

- Repo: **github.com/osmantanrikulu/tanrikuluapps-site** (public).
- Barındırma: **Cloudflare Pages**, Git bağlantılı — `main`'e her push
  otomatik yayınlanır (build yok: Framework None, output `/`).
- Proje adı: `tanrikuluapps-site`; custom domain: `tanrikuluapps.com`
  (Active). Yayın kontrolü: `curl -s https://tanrikuluapps.com | head`.

### Sayfa düzeni
| Yol | İşlev |
|---|---|
| `/` | Vitrin — uygulama kartları |
| `/verified/` | Supabase e-posta doğrulama sonrası "✓ doğrulandı" sayfası (tüm uygulamaların Auth Site URL'i buraya bakar) |
| `/<uygulama>/get/` | Cihaza göre App Store / Play yönlendirmesi (poster/QR hedefi) |

### Yeni uygulama eklerken
1. `index.html`'e kart ekle (mevcut kartları şablon al).
2. `/<uygulama>/get/index.html` oluştur (washpro'dakini kopyala; renk ve
   metni uyarla). Başındaki `APP_STORE` / `PLAY_STORE` sabitleri mağaza
   linkleri YAYIMLANINCA doldurulur — boşken sayfa "çok yakında" gösterir.
3. Commit + push → otomatik yayın.

## 3. E-posta (Resend + Supabase SMTP)

- **Resend** hesabı: osmantanrikulu (GitHub ile giriş). Domain
  `tanrikuluapps.com` **Verified** (EU/Ireland bölgesi). Ücretsiz plan:
  3.000 e-posta/ay, 100/gün.
- Gönderici deseni: her uygulama aynı domainden, kendi adıyla gönderir —
  `WashPro <no-reply@tanrikuluapps.com>`, `OtoparkPro <no-reply@...>`.
- **Her Supabase projesi kendi SMTP ayarını yapar** (Authentication →
  Emails → SMTP Settings): host `smtp.resend.com`, port `465`, kullanıcı
  `resend`, şifre = **o uygulama için üretilmiş ayrı Resend API anahtarı**
  (Resend → API Keys → Sending access, adlandırma: `supabase-<uygulama>`).
- **Anahtar disiplini:** API anahtarı SADECE Resend ekranından Supabase
  formuna gider — sohbete, repoya, dosyaya yazılmaz. Sohbete yapışan
  anahtar anında silinip yenilenir (2 Ağu'da bir kez yaşandı).
- Neden custom SMTP şart: Supabase yerleşik göndericisi saatte ~2-4 mail
  ile sınırlı ve markasız; ayrıca custom SMTP olmadan e-posta ŞABLONLARI
  düzenlenemiyor.
- SMTP açıldıktan sonra: Auth → Rate Limits'te saatlik e-posta sınırını
  yükselt; şablonları markala (WashPro'nun TR şablonu örnek alınabilir —
  teal kart, "E-postamı doğrula" düğmesi, TR+EN alt not).
- **Site URL** (Auth → URL Configuration): `https://tanrikuluapps.com/verified`
  — yoksa doğrulama sonrası kullanıcı bozuk localhost sayfası görür.

## 4. Supabase deseni

- Uygulama başına **AYRI proje** (bölge: Frankfurt/eu-central-1):
  - otoparkpro → `itjslckrcplrbjurwvtz`
  - washpro → `jlnxyqcjczqtbvviduof`
- Kurulum kuralları: "Automatically expose new tables" KAPALI; tablolar
  migration'daki açık grant'larla açılır; anon role hiçbir yetki yok;
  tenant + RLS izolasyonu; `current_tenant_id()` security definer.
- Rol modeli (her iki uygulamada da uygulandı): owner/manager/staff;
  yazma RLS'te role göre daralır; istemci Permissions sınıfı yalnız
  arayüzü sadeleştirir. Bilinmeyen rol = en dar yetki.
- Migration'lar repo içinde `supabase/migrations/` altında sıralı dosya;
  panelde SQL Editor'den elle çalıştırılıyor (CLI bağlanmadı).

## 5. Yayın (publish) kontrol listesi — uygulama mağazaya çıkarken

1. **Sürüm:** `pubspec.yaml` → `version: x.y.z+n` artır. iOS widget
   hedefi varsa `python3 tools/sync_ios_version.py` (ITMS-90473 önlemi).
2. **İkon/marka:** ikonlar kodla üretiliyor (`tools/icon/*.swift`,
   CoreGraphics; bu Mac'te rsvg/magick/PIL yok, Swift var) →
   `dart run flutter_launcher_icons`.
3. **Derleme:** `flutter build ipa` (arşiv `build/ios/archive/` içine
   düşer; Xcode Organizer görmez —
   `~/Library/Developer/Xcode/Archives/<tarih>/` altına kopyala).
   Android: `flutter build appbundle`.
4. **Mağaza linkleri çıkınca:** `tanrikuluapps-site` reposunda
   `/<uygulama>/get/index.html` içindeki `APP_STORE` / `PLAY_STORE`
   sabitlerini doldur, push'la.
5. **Mağaza metadata'sında** Destek/Pazarlama URL'i olarak
   `https://tanrikuluapps.com` (veya uygulama sayfası) kullan —
   github.io yerine. (İnceleme SÜRERKEN metadata'ya dokunma;
   sonraki sürümle değiştir.)
6. **RevenueCat:** uygulama başına ayrı proje/entitlement
   (`<uygulama>` entitlement, `<uygulama>_monthly` ürün); public API
   anahtarı `subscription_service.dart`'a gömülür (bu anahtar istemciye
   gömülmesi güvenli türdendir).
7. Yayın sonrası Osman "markette yayınladım" deyince sürüm
   patch+build otomatik artırılır (mevcut alışkanlık).

## 6. Simülatör/cihaz notları (bu Mac)

- ML Kit pod'ları simülatörde arm64 vermiyor → iOS 26 sim'leri (arm64-only)
  ÇALIŞMAZ; test **iOS 18 simülatöründe** (ör. iPhone 16 Pro) yapılır.
  Gerçek cihazda sorun yok. iOS minimum deployment: 15.5 (ML Kit şartı).
- İmza: "Apple Development: Osman Tanrikulu", team `J8628U9N29`;
  cihaza kurulum `flutter run --release -d <udid>` ile sorunsuz.
