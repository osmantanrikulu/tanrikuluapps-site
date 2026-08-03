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
- **`www` ayrıca eklenmeli.** Pages'e yalnız kök alan adı eklenirse
  `www.tanrikuluapps.com` HİÇ ÇÖZÜLMEZ ("could not resolve host") —
  insanlar alışkanlıkla www yazar ve "site kapalı" sanır. Pages →
  Custom domains → `www...` eklenir (3 Ağu 2026'da yapıldı).
- **Kanonik adres `tanrikuluapps.com`.** www → kök yönlendirmesi
  Rules → **Page Rules** ile kuruldu (bu hesapta ayrı "Redirect Rules"
  maddesi görünmüyor): URL `www.tanrikuluapps.com/*` → Forwarding URL
  → **301** → `https://tanrikuluapps.com/$1`.
  `$1` ŞART: olmazsa www ile gelen herkes ana sayfaya düşer, afiş/QR'ın
  hedeflediği `/otoparkpro/get/` gibi alt sayfalar kaybolur.
  Doğrulama: `curl -s -o /dev/null -w "%{http_code} -> %{redirect_url}\n" https://www.tanrikuluapps.com/otoparkpro/get/`
- Proje adı: `tanrikuluapps-site`; custom domain: `tanrikuluapps.com`
  (Active). Yayın kontrolü: `curl -s https://tanrikuluapps.com | head`.

### Sayfa düzeni
| Yol | İşlev |
|---|---|
| `/` | Vitrin — uygulama kartları |
| `/verified/` | Supabase e-posta doğrulama sonrası "✓ doğrulandı" sayfası (tüm uygulamaların Auth Site URL'i buraya bakar) |
| `/<uygulama>/get/` | Cihaza göre App Store / Play yönlendirmesi (poster/QR hedefi) |
| `/t/#<token>` | WashPro müşteri canlı takip sayfası — Supabase `track_job(token)` RPC'sini publishable key ile çağırır (hesapsız/anon); 15 sn'de bir yenilenir |

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
- **Şablonlar nerede durur:** her uygulama kendi reposunda
  `docs/eposta-dogrulama-tr.html` + `docs/eposta-kurulum.md` (adım adım
  kontrol listesi). Yeni uygulamada OtoparkPro'nunkini kopyala, rengi ve
  adı değiştir. Şablon tablo düzeni + satır içi stille yazılır — e-posta
  istemcileri modern CSS'i desteklemez. Marka rengi: WashPro teal,
  OtoparkPro lacivert `#1E3A8A`.
- **Uygulama 27 dilde ama şablon tek dil:** en azından TR gövde + kısa
  EN alt not kullan; kullanıcı hangi dilden kaydolursa olsun maili anlar.
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

## APNs (Push) — takım geneli tek anahtar (3 Ağu 2026)

- **Team ID:** `Z4KVC9TB23` · **Key ID:** `QL62LG4AY6` · Ad: "WashPro APNs"
- Environment: Sandbox & Production; kısıtlamasız → **hem WashPro hem OtoparkPro** bu anahtarla push imzalar.
- `.p8` dosyası Osman'da (tek seferlik indirme). İçeriği ASLA sohbete/repoya yazılmaz;
  push sunucusu kurulurken doğrudan Supabase Edge Function secrets'a girilir
  (`supabase secrets set` veya Dashboard > Edge Functions > Secrets).
- App ID'lerde açık yetkiler: Sign In with Apple + Push Notifications
  (com.washpro.washpro ve com.otoparkpro.otoparkpro).
- Karar: push altyapısı KENDİ Edge Function'ımız (OneSignal yok); giriş: Apple native
  (signInWithIdToken, bundle ID yeter) + Google native (iOS OAuth client, tek GCP
  projesi "Tanrikulu Apps", uygulama başına ayrı iOS client ID).
- NOT: WashPro Xcode takımı J8628U9N29 (kişisel) → Z4KVC9TB23'e çevrildi (3 Ağu);
  farklı imza nedeniyle cihazda sil+kur gerekti.

## Google Sign-In — tek GCP projesi, uygulama basina iOS client (3 Agu 2026)

- GCP projesi: **Tanrikulu Apps** (`tanrikulu-apps`), Google Auth Platform yapilandirildi
  (External audience; App name "Tanrikulu Apps").
- iOS OAuth client ID'leri (GIZLI DEGIL, istemciye gomulur):
  - WashPro   `260820414956-72gfdned96aq1d945hi06m4eifj55uav.apps.googleusercontent.com`
  - OtoparkPro `260820414956-55cd3vac5vhmi3hdmc68h2u97i707h6b.apps.googleusercontent.com`
- iOS'ta Info.plist'e **ters cevrilmis** istemci kimligi URL semasi eklenir:
  `com.googleusercontent.apps.<client-id-onu>` (yoksa Google ekrani uygulamaya donemez).
- Uygulama tarafi: `google_sign_in` ^7 + `sign_in_with_apple` ^8 + `crypto`;
  Supabase'e `signInWithIdToken` ile id token gider (web yonlendirmesi YOK).
- Supabase Dashboard > Authentication > Providers:
  - **Apple**: yalnizca "Authorized Client IDs" alanina bundle ID yazilir
    (native akis; Services ID / secret key GEREKMEZ).
  - **Google**: "Authorized Client IDs" alanina iOS client ID yazilir;
    "Skip nonce check" ACIK olmali (google_sign_in nonce gondermez).
