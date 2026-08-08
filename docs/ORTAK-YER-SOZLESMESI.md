# Ortak "Halka Açık Yer" Sözleşmesi (taslak v1 — 8 Ağu 2026)

Amaç: OtoparkPro ve WashPro'nun (ileride lastikçi vb.) müşteri tarafına
açtığı işletme verisini TEK biçime oturtmak. Bu sözleşme üç şeyi besler:

1. **Birleşik müşteri haritası** — iki dikeyin noktaları tek haritada
   (önce mevcut nearby ekranlarına çapraz katman, sonra ayrı uygulama).
2. **Vitrin panoları** — kulübe/dükkân TV'leri (OtoparkPro'da canlı).
3. **Makbuz/takip sayfaları** — oturum bazlı müşteri sayfaları.

## Kaynaklar (bugün)

| Alan | OtoparkPro (`public_lot_board` / `public_parking_lots`) | WashPro (kendi public view'u) |
|---|---|---|
| id | uuid (şube) | uuid |
| type | *(sabit)* `parking` | *(sabit)* `wash` |
| name | şube adı | dükkân adı |
| business_name | işletme adı | işletme adı |
| lat / lng | var (haritaya açık onaylılar) | var |
| capacity | araç kapasitesi | — |
| occupied / queue | içerideki araç | sıradaki araç |
| tariff / services | kademeli tarife (jsonb) | hizmet listesi (jsonb) |
| last_activity_at | var | var |

## Sözleşme (hedef biçim)

Her dikey kendi projesinde şu görünümü sunar: `public_places_v1`

```
id uuid, type text, name text, business_name text,
lat double, lng double,
capacity int null,          -- null = tanımsız
busy int,                   -- içerideki/sıradaki
detail jsonb,               -- dikeye özel: tarife | hizmetler
last_activity_at timestamptz
```

Kurallar:
- Yalnız işletmenin **açık onay** verdiği yerler (is_public) listelenir.
- Plaka, MÜŞTERİ İŞLEM tutarı ve müşteri verisi ASLA çıkmaz; `detail`
  içindeki fiyat listesi/tarife halka açık tabela bilgisidir ve çıkar
  (WashPro şerhi 2 — bu ayrım bilinçli).
- `detail` dikeye özeldir; harita katmanı onu yorumlamak zorunda değildir
  (gösterirse gösterir).
- Tüketici (harita/pano) iki projeye ayrı istek atar ve `type` ile
  birleştirir — projeler arası kopyalama YOK, her veri sahibinde kalır.

## Uygulama sırası

1. OtoparkPro: `public_places_v1` = mevcut board görünümünün yeniden
   adlandırılmış hali (+type sabiti). WashPro: aynısı kendi tarafında.
2. Çapraz katman testi: WashPro nearby ekranına `type=parking` pinleri
   (gri/ikincil), OtoparkPro sürücü listesine `type=wash` satırları.
3. Yoğunluk eşiği (şehirde 20-30 nokta) aşılınca: ayrı markalı müşteri
   uygulaması, iki ucu da okur.

Durum: taslak — iki oturum (otopark + yıkama) onaylayınca migration'lar
yazılır. İlgili görev: OtoparkPro #34.

## WashPro oturumunun görüşü (8 Ağu gece) — ONAY + 3 şerh

Biçim ve kurallar WashPro'ya oturuyor (id=şube uuid'si, name=şube,
business_name=tenant — 0008 dersiyle uyumlu: listede TENANT adı esas).
`busy` = aktif iş sayısı zaten nearby'da canlı dönüyor. Şerhler:

1. **Onay kapsamı:** İşletme "Haritada görün" onayını KENDİ
   uygulamasının haritası için verdi. Çapraz katman (adım 2) yayına
   alınırken iki uygulamada da anahtar metni "Tanrikulu Apps müşteri
   haritalarında görün" gibi genişletilmeli; mevcut onaylar için tek
   seferlik bilgilendirme yeterli, yeniden onay şart değil (veri zaten
   halka açık kapsamda).
2. **"Tutar" sözcüğü:** Kural "plaka, tutar, müşteri verisi asla" derken
   kastedilen MÜŞTERİ İŞLEM tutarları; `detail` içindeki fiyat listesi
   /tarife halka açık bilgidir ve çıkabilir. Metne bu ayrım not düşülsün
   ki ileride fiyat listesi yanlışlıkla budanmasın.
3. **Erişim mekanizması serbest kalsın:** WashPro tarafında bu sözleşme
   bir VIEW değil, mevcut kalıpla security-definer RPC olarak sunulacak
   (anon'a tablo/görünüm grant'ı yok — nearby_businesses ile aynı
   disiplin). Sözleşme "biçim" sözleşmesidir; her proje kendi erişim
   tarzını korur.

WashPro uygulama işi: `public_places_v1(lat, lng)` RPC'si + nearby
ekranına `type=parking` gri ikincil pin katmanı (WashPro görev #45,
8 Ağu gece BAŞLADI).

## Uç noktalar (uygulama detayı — tüketici oturum için)

**WashPro (CANLI — 0024 uygulandı, 8 Ağu gece anon REST'ten doğrulandı;
örnek dönüş: Tanrıkulu Yıkama/Merkez, busy=3, hizmet listesi dolu.
NOT: tekrar koşulursa 42P13 verir — zararsız, fonksiyon zaten doğru):**
- Proje: `https://jlnxyqcjczqtbvviduof.supabase.co`
- Anahtar (publishable): `sb_publishable_h5ZwQrTIoDnBZ6V4YBC0NA_59g2PvOh`
- Erişim: RPC — `POST /rest/v1/rpc/public_places_v1` gövde `{"lat":.., "lng":..}`
  (görünüm DEĞİL; anon'a tablo/görünüm grantı yok, nearby ile aynı disiplin)
- Dönen satır: `{id, type:'wash', name(şube), business_name(tenant),
  lat, lng, capacity:null, busy(kuyruk+işlemde), detail:[{name,
  price_kurus, duration_min}], last_activity_at}`
- Bbox: lat ±1°, lng ±1.5°; en yakın 50.
- DİKKAT: `detail[].name` tohum hizmetlerde i18n ANAHTARI olabilir
  ('exterior', 'interiorExterior'…) — gösterilecekse çevrilmeli ya da
  ham bırakılmalı; WashPro içi çeviri tablosu `serviceName()` (Dart).

**OtoparkPro (CANLI — 0013 uygulandı, 8 Ağu gece anon REST'ten doğrulandı;
örnek dönüş: Tanrıkulu Otopark/Merkez, busy=6, capacity=40, tarife dolu):**
- Proje: `https://itjslckrcplrbjurwvtz.supabase.co`
- Anahtar (publishable): `sb_publishable_xBlCzeWSSb2Np9pToL-y7w_9L6SRLLj`
- Erişim: RPC — `POST /rest/v1/rpc/public_places_v1` gövde
  `{"lat":.., "lng":..}` — **WashPro ile birebir aynı imza**; tüketici
  iki uca aynı kodla bağlanır. (public_lot_board view'ü pano için ayrı
  yaşamaya devam eder, harita katmanı ONU KULLANMAZ.)
- Dönen: jsonb dizi `{id, type:'parking', name(şube),
  business_name(tenant), lat, lng, capacity, busy(içerideki araç),
  detail:{grace_minutes, daily_cap_kurus, brackets:[{up_to_minutes,
  price_kurus}]}, last_activity_at}` — mesafe sıralı.
- Bbox: lat ±1°, lng ±1.5°; en yakın 50 (WashPro ile aynı).
- DİKKAT: `detail` yıkamadaki gibi hizmet listesi DEĞİL, tarife
  nesnesi — tüketici `type`'a göre yorumlar (sözleşme kuralı).
