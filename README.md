# tanrikuluapps.com

Tanrikulu Apps ürün ailesinin statik sitesi (Cloudflare Pages'te barınır;
her `git push` otomatik yayınlanır).

| Sayfa | İşlev |
|---|---|
| `/` | Vitrin: OtoparkPro + WashPro kartları |
| `/verified/` | Supabase e-posta doğrulama sonrası "✓ doğrulandı" sayfası (Auth Site URL buraya bakar) |
| `/washpro/get/` | Cihaza göre App Store / Play yönlendirmesi (poster QR hedefi) |
| `/otoparkpro/get/` | Aynısı, OtoparkPro için |

Mağaza linkleri yayımlanınca `get/index.html` dosyalarının başındaki
`APP_STORE` / `PLAY_STORE` sabitleri doldurulacak — boşken sayfa
"çok yakında" gösterir, dolunca otomatik yönlendirir.

Derleme adımı yok: Framework `None`, build command boş, output `/`.
