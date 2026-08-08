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
- Plaka, tutar, müşteri verisi ASLA bu görünümden çıkmaz.
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
