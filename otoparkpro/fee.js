// OtoparkPro tarife motoru — lib/domain/fee_calculator.dart'in JS esi.
// Kurallar birebir: grace, "bu dakikaya kadar toplam fiyat" kademeleri,
// gunluk tavan, cok gunlu konaklama. Degisiklik IKI yerde birden yapilir.
function otoparkFeeKurus(minutes, tariff) {
  if (!tariff) return null;
  const grace = tariff.grace_minutes || 0;
  const brackets = (tariff.brackets || []).slice();
  if (minutes <= grace) return 0;
  if (!brackets.length) return 0;

  brackets.sort((a, b) => {
    if (a.up_to_minutes == null) return 1;
    if (b.up_to_minutes == null) return -1;
    return a.up_to_minutes - b.up_to_minutes;
  });

  const bracketPrice = (mins) => {
    for (const b of brackets) {
      if (b.up_to_minutes == null || mins <= b.up_to_minutes)
        return b.price_kurus;
    }
    return brackets[brackets.length - 1].price_kurus;
  };

  const cap = tariff.daily_cap_kurus;
  const DAY = 24 * 60;

  if (minutes <= DAY) {
    const p = bracketPrice(minutes);
    return cap != null && p > cap ? cap : p;
  }
  const fullDays = Math.floor(minutes / DAY);
  const rem = minutes % DAY;
  const dayPrice = cap != null ? cap : bracketPrice(DAY);
  let total = fullDays * dayPrice;
  if (rem > 0) {
    const rp = bracketPrice(rem);
    total += cap != null && rp > cap ? cap : rp;
  }
  return total;
}

function kurusToTl(kurus) {
  return '₺' + (kurus / 100).toLocaleString('tr-TR',
      {minimumFractionDigits: 2, maximumFractionDigits: 2});
}
