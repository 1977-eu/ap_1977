
class CountryService {
  static final Map<String, String> _countryFlags = {
    'Brasil': '🇧🇷',
    'Portugal': '🇵🇹',
    'Angola': '🇦🇴',
    'Moçambique': '🇲🇿',
    'Cabo Verde': '🇨🇻',
    'Guiné-Bissau': '🇬🇼',
    'São Tomé e Príncipe': '🇸🇹',
    'Espanha': '🇪🇸',
    'França': '🇫🇷',
    'Itália': '🇮🇹',
    'Alemanha': '🇩🇪',
    'Reino Unido': '🇬🇧',
    'Irlanda': '🇮🇪',
    'Holanda': '🇳🇱',
    'Bélgica': '🇧🇪',
    'Suíça': '🇨🇭',
    'Áustria': '🇦🇹',
    'Polônia': '🇵🇱',
    'Romênia': '🇷🇴',
    'Ucrânia': '🇺🇦',
  };

  // Mapa para converter códigos antigos para nomes completos
  static final Map<String, String> _legacyCodes = {
    'PT': 'Portugal',
    'BR': 'Brasil',
    'AO': 'Angola',
    'MZ': 'Moçambique',
    'CV': 'Cabo Verde',
    'GW': 'Guiné-Bissau',
    'ST': 'São Tomé e Príncipe',
    'ES': 'Espanha',
    'FR': 'França',
    'IT': 'Itália',
    'DE': 'Alemanha',
    'GB': 'Reino Unido',
    'IE': 'Irlanda',
    'NL': 'Holanda',
    'BE': 'Bélgica',
    'CH': 'Suíça',
    'AT': 'Áustria',
    'PL': 'Polônia',
    'RO': 'Romênia',
    'UA': 'Ucrânia',
  };

  static List<String> get countries => _countryFlags.keys.toList()..sort();

  static String? getFlagEmoji(String country) => _countryFlags[country];

  // Método para converter código antigo para nome completo
  static String convertLegacyCode(String code) {
    return _legacyCodes[code] ?? code;
  }
}
