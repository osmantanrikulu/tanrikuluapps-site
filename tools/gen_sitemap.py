#!/usr/bin/env python3
"""sitemap.xml ureticisi.

lastmod her URL'nin dayandigi dosyanin son git commit tarihinden gelir;
sayfa guncellenip push'laninca bu script yeniden calistirilir (elle tarih
tutulmaz). Dil varyantlarinin HER BIRI tam hreflang setini tasir
(uluslararasi SEO standardi: grup uyeleri birbirini karsilikli gosterir).
Kullanim: python3 tools/gen_sitemap.py  (repo kokunde calistir)
"""
import subprocess

LANGS = ['tr','en','de','fr','es','it','pt','nl','ru','uk','pl','cs','ro',
         'el','sv','az','ar','fa','he','ur','hi','id','vi','th','ja','ko','zh']
BASE = 'https://tanrikuluapps.com'


def lastmod(*files):
    best = ''
    for f in files:
        try:
            d = subprocess.check_output(
                ['git', 'log', '-1', '--format=%cs', '--', f], text=True).strip()
            best = max(best, d)
        except Exception:
            pass
    return best


def url(loc, lm, priority, changefreq, hreflang=False):
    lines = [f'  <url>', f'    <loc>{loc}</loc>']
    if hreflang:
        for l in LANGS:
            href = BASE + '/' if l == 'tr' else f'{BASE}/?lang={l}'
            lines.append(
                f'    <xhtml:link rel="alternate" hreflang="{l}" href="{href}"/>')
        lines.append(
            f'    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE}/"/>')
    if lm:
        lines.append(f'    <lastmod>{lm}</lastmod>')
    lines += [f'    <changefreq>{changefreq}</changefreq>',
              f'    <priority>{priority}</priority>', '  </url>']
    return '\n'.join(lines)


home_lm = lastmod('index.html', 'i18n.js')
urls = [url(f'{BASE}/', home_lm, '1.0', 'weekly', hreflang=True)]
for l in LANGS:
    if l == 'tr':
        continue
    urls.append(url(f'{BASE}/?lang={l}', home_lm, '0.6', 'weekly', hreflang=True))
urls.append(url(f'{BASE}/washpro/get/', lastmod('washpro/get/index.html'),
                '0.9', 'monthly'))
urls.append(url(f'{BASE}/otoparkpro/get/', lastmod('otoparkpro/get/index.html'),
                '0.9', 'monthly'))
urls.append(url(f'{BASE}/washpro/poster/', lastmod('washpro/poster/index.html'),
                '0.5', 'monthly'))
urls.append(url(f'{BASE}/legal/gizlilik/', lastmod('legal/gizlilik/index.html'),
                '0.2', 'yearly'))
urls.append(url(f'{BASE}/legal/kullanim/', lastmod('legal/kullanim/index.html'),
                '0.2', 'yearly'))

open('sitemap.xml', 'w').write(
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"\n'
    '        xmlns:xhtml="http://www.w3.org/1999/xhtml">\n'
    + '\n'.join(urls) + '\n</urlset>\n')
print(f'sitemap.xml: {len(urls)} URL, home lastmod={home_lm}')
