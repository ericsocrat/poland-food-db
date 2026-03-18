// ─── GS1 prefix → country-of-registration hint ─────────────────────────────
// Reference: https://www.gs1.org/standards/id-keys/company-prefix
// NOTE: GS1 prefix indicates where the barcode was *registered*, not where the
// product was manufactured. Imported products often carry their origin-country prefix.

interface Gs1CountryHint {
  code: string;
  name: string;
}

/**
 * GS1 prefix ranges mapped to country codes and names.
 * Each entry is [startPrefix, endPrefix, countryCode, countryName].
 * Ranges are inclusive on both ends. Prefixes are compared as 3-digit strings.
 */
const GS1_RANGES: readonly [string, string, string, string][] = [
  ["000", "019", "US", "United States"],
  ["020", "029", "US", "United States"],
  ["030", "039", "US", "United States"],
  ["060", "099", "US", "United States"],
  ["100", "139", "US", "United States"],
  ["300", "379", "FR", "France"],
  ["380", "380", "BG", "Bulgaria"],
  ["383", "383", "SI", "Slovenia"],
  ["385", "385", "HR", "Croatia"],
  ["387", "387", "BA", "Bosnia and Herzegovina"],
  ["389", "389", "ME", "Montenegro"],
  ["400", "440", "DE", "Germany"],
  ["450", "459", "JP", "Japan"],
  ["460", "469", "RU", "Russia"],
  ["470", "470", "KG", "Kyrgyzstan"],
  ["471", "471", "TW", "Taiwan"],
  ["474", "474", "EE", "Estonia"],
  ["475", "475", "LV", "Latvia"],
  ["476", "476", "AZ", "Azerbaijan"],
  ["477", "477", "LT", "Lithuania"],
  ["478", "478", "UZ", "Uzbekistan"],
  ["480", "480", "PH", "Philippines"],
  ["481", "481", "BY", "Belarus"],
  ["482", "482", "UA", "Ukraine"],
  ["484", "484", "MD", "Moldova"],
  ["485", "485", "AM", "Armenia"],
  ["486", "486", "GE", "Georgia"],
  ["487", "487", "KZ", "Kazakhstan"],
  ["488", "488", "TJ", "Tajikistan"],
  ["489", "489", "HK", "Hong Kong"],
  ["490", "499", "JP", "Japan"],
  ["500", "509", "GB", "United Kingdom"],
  ["520", "521", "GR", "Greece"],
  ["528", "528", "LB", "Lebanon"],
  ["529", "529", "CY", "Cyprus"],
  ["530", "530", "AL", "Albania"],
  ["531", "531", "MK", "North Macedonia"],
  ["535", "535", "MT", "Malta"],
  ["539", "539", "IE", "Ireland"],
  ["540", "549", "BE", "Belgium / Luxembourg"],
  ["560", "560", "PT", "Portugal"],
  ["569", "569", "IS", "Iceland"],
  ["570", "579", "DK", "Denmark"],
  ["590", "590", "PL", "Poland"],
  ["594", "594", "RO", "Romania"],
  ["599", "599", "HU", "Hungary"],
  ["600", "601", "ZA", "South Africa"],
  ["608", "608", "BH", "Bahrain"],
  ["609", "609", "MU", "Mauritius"],
  ["611", "611", "MA", "Morocco"],
  ["613", "613", "DZ", "Algeria"],
  ["615", "615", "NG", "Nigeria"],
  ["616", "616", "KE", "Kenya"],
  ["618", "618", "CI", "Ivory Coast"],
  ["619", "619", "TN", "Tunisia"],
  ["620", "620", "TZ", "Tanzania"],
  ["621", "621", "SY", "Syria"],
  ["622", "622", "EG", "Egypt"],
  ["624", "624", "LY", "Libya"],
  ["625", "625", "JO", "Jordan"],
  ["626", "626", "IR", "Iran"],
  ["627", "627", "KW", "Kuwait"],
  ["628", "628", "SA", "Saudi Arabia"],
  ["629", "629", "AE", "United Arab Emirates"],
  ["640", "649", "FI", "Finland"],
  ["690", "699", "CN", "China"],
  ["700", "709", "NO", "Norway"],
  ["729", "729", "IL", "Israel"],
  ["730", "739", "SE", "Sweden"],
  ["740", "740", "GT", "Guatemala"],
  ["741", "741", "SV", "El Salvador"],
  ["742", "742", "HN", "Honduras"],
  ["743", "743", "NI", "Nicaragua"],
  ["744", "744", "CR", "Costa Rica"],
  ["745", "745", "PA", "Panama"],
  ["746", "746", "DO", "Dominican Republic"],
  ["750", "750", "MX", "Mexico"],
  ["754", "755", "CA", "Canada"],
  ["759", "759", "VE", "Venezuela"],
  ["760", "769", "CH", "Switzerland"],
  ["770", "771", "CO", "Colombia"],
  ["773", "773", "UY", "Uruguay"],
  ["775", "775", "PE", "Peru"],
  ["777", "777", "BO", "Bolivia"],
  ["778", "779", "AR", "Argentina"],
  ["780", "780", "CL", "Chile"],
  ["784", "784", "PY", "Paraguay"],
  ["786", "786", "EC", "Ecuador"],
  ["789", "790", "BR", "Brazil"],
  ["800", "839", "IT", "Italy"],
  ["840", "849", "ES", "Spain"],
  ["850", "850", "CU", "Cuba"],
  ["858", "858", "SK", "Slovakia"],
  ["859", "859", "CZ", "Czech Republic"],
  ["860", "860", "RS", "Serbia"],
  ["865", "865", "MN", "Mongolia"],
  ["867", "867", "KP", "North Korea"],
  ["868", "869", "TR", "Turkey"],
  ["870", "879", "NL", "Netherlands"],
  ["880", "880", "KR", "South Korea"],
  ["884", "884", "KH", "Cambodia"],
  ["885", "885", "TH", "Thailand"],
  ["888", "888", "SG", "Singapore"],
  ["890", "890", "IN", "India"],
  ["893", "893", "VN", "Vietnam"],
  ["896", "896", "PK", "Pakistan"],
  ["899", "899", "ID", "Indonesia"],
  ["900", "919", "AT", "Austria"],
  ["930", "939", "AU", "Australia"],
  ["940", "949", "NZ", "New Zealand"],
  ["955", "955", "MY", "Malaysia"],
];

/**
 * Extract a GS1 country-of-registration hint from an EAN-13 barcode prefix.
 * Returns null for EAN-8 codes (no reliable country mapping) or unrecognised prefixes.
 */
export function gs1CountryHint(ean: string): Gs1CountryHint | null {
  if (ean.length !== 13 && ean.length !== 12) return null;

  const prefix = ean.slice(0, 3);

  for (const [start, end, code, name] of GS1_RANGES) {
    if (prefix >= start && prefix <= end) {
      return { code, name };
    }
  }

  return null;
}
