# countries_part1.dart

* **File Path:** `apps/mobile/lib/core/constants/countries_part1.dart`
* **Type:** `DART`

---

```dart
class CountryInfo {
  final String name;
  final String flag;
  final String code;
  final String dialCode;

  const CountryInfo({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });
}

const List<CountryInfo> countriesPart1 = [
  CountryInfo(name: 'Afghanistan', flag: '🇦🇫', code: 'AF', dialCode: '+93'),
  CountryInfo(name: 'Albania', flag: '🇦🇱', code: 'AL', dialCode: '+355'),
  CountryInfo(name: 'Algeria', flag: '🇩🇿', code: 'DZ', dialCode: '+213'),
  CountryInfo(name: 'Andorra', flag: '🇦🇩', code: 'AD', dialCode: '+376'),
  CountryInfo(name: 'Angola', flag: '🇦🇴', code: 'AO', dialCode: '+244'),
  CountryInfo(name: 'Anguilla', flag: '🇦🇮', code: 'AI', dialCode: '+1'),
  CountryInfo(
    name: 'Antigua & Barbuda',
    flag: '🇦🇬',
    code: 'AG',
    dialCode: '+1',
  ),
  CountryInfo(name: 'Argentina', flag: '🇦🇷', code: 'AR', dialCode: '+54'),
  CountryInfo(name: 'Armenia', flag: '🇦🇲', code: 'AM', dialCode: '+374'),
  CountryInfo(name: 'Australia', flag: '🇦🇺', code: 'AU', dialCode: '+61'),
  CountryInfo(name: 'Austria', flag: '🇦🇹', code: 'AT', dialCode: '+43'),
  CountryInfo(name: 'Azerbaijan', flag: '🇦🇿', code: 'AZ', dialCode: '+994'),
  CountryInfo(name: 'Bahamas', flag: '🇧🇸', code: 'BS', dialCode: '+1'),
  CountryInfo(name: 'Bahrain', flag: '🇧🇭', code: 'BH', dialCode: '+973'),
  CountryInfo(name: 'Bangladesh', flag: '🇧🇩', code: 'BD', dialCode: '+880'),
  CountryInfo(name: 'Barbados', flag: '🇧🇧', code: 'BB', dialCode: '+1'),
  CountryInfo(name: 'Belarus', flag: '🇧🇾', code: 'BY', dialCode: '+375'),
  CountryInfo(name: 'Belgium', flag: '🇧🇪', code: 'BE', dialCode: '+32'),
  CountryInfo(name: 'Belize', flag: '🇧🇿', code: 'BZ', dialCode: '+501'),
  CountryInfo(name: 'Benin', flag: '🇧🇯', code: 'BJ', dialCode: '+229'),
  CountryInfo(name: 'Bermuda', flag: '🇧🇲', code: 'BM', dialCode: '+1'),
  CountryInfo(name: 'Bhutan', flag: '🇧🇹', code: 'BT', dialCode: '+975'),
  CountryInfo(name: 'Bolivia', flag: '🇧🇴', code: 'BO', dialCode: '+591'),
  CountryInfo(
    name: 'Bosnia & Herzegovina',
    flag: '🇧🇦',
    code: 'BA',
    dialCode: '+387',
  ),
  CountryInfo(name: 'Botswana', flag: '🇧🇼', code: 'BW', dialCode: '+267'),
  CountryInfo(name: 'Brazil', flag: '🇧🇷', code: 'BR', dialCode: '+55'),
  CountryInfo(name: 'Brunei', flag: '🇧🇳', code: 'BN', dialCode: '+673'),
  CountryInfo(name: 'Bulgaria', flag: '🇧🇬', code: 'BG', dialCode: '+359'),
  CountryInfo(name: 'Burkina Faso', flag: '🇧🇫', code: 'BF', dialCode: '+226'),
  CountryInfo(name: 'Burundi', flag: '🇧🇮', code: 'BI', dialCode: '+257'),
  CountryInfo(name: 'Cambodia', flag: '🇰🇭', code: 'KH', dialCode: '+855'),
  CountryInfo(name: 'Cameroon', flag: '🇨🇲', code: 'CM', dialCode: '+237'),
  CountryInfo(name: 'Canada', flag: '🇨🇦', code: 'CA', dialCode: '+1'),
  CountryInfo(name: 'Cape Verde', flag: '🇨🇻', code: 'CV', dialCode: '+238'),
  CountryInfo(name: 'Cayman Islands', flag: '🇰🇾', code: 'KY', dialCode: '+1'),
  CountryInfo(name: 'Chad', flag: '🇹🇩', code: 'TD', dialCode: '+235'),
  CountryInfo(name: 'Chile', flag: '🇨🇱', code: 'CL', dialCode: '+56'),
  CountryInfo(name: 'China', flag: '🇨🇳', code: 'CN', dialCode: '+86'),
  CountryInfo(name: 'Colombia', flag: '🇨🇴', code: 'CO', dialCode: '+57'),
  CountryInfo(name: 'Comoros', flag: '🇰🇲', code: 'KM', dialCode: '+269'),
  CountryInfo(name: 'Congo', flag: '🇨🇬', code: 'CG', dialCode: '+242'),
  CountryInfo(name: 'Costa Rica', flag: '🇨🇷', code: 'CR', dialCode: '+506'),
  CountryInfo(name: 'Croatia', flag: '🇭🇷', code: 'HR', dialCode: '+385'),
  CountryInfo(name: 'Cuba', flag: '🇨🇺', code: 'CU', dialCode: '+53'),
  CountryInfo(name: 'Cyprus', flag: '🇨🇾', code: 'CY', dialCode: '+357'),
  CountryInfo(
    name: 'Czech Republic',
    flag: '🇨🇿',
    code: 'CZ',
    dialCode: '+420',
  ),
  CountryInfo(name: 'Denmark', flag: '🇩🇰', code: 'DK', dialCode: '+45'),
  CountryInfo(name: 'Djibouti', flag: '🇩🇯', code: 'DJ', dialCode: '+253'),
  CountryInfo(name: 'Dominica', flag: '🇩🇲', code: 'DM', dialCode: '+1'),
  CountryInfo(
    name: 'Dominican Republic',
    flag: '🇩🇴',
    code: 'DO',
    dialCode: '+1',
  ),
  CountryInfo(name: 'Ecuador', flag: '🇪🇨', code: 'EC', dialCode: '+593'),
  CountryInfo(name: 'Egypt', flag: '🇪🇬', code: 'EG', dialCode: '+20'),
  CountryInfo(name: 'El Salvador', flag: '🇸🇻', code: 'SV', dialCode: '+503'),
  CountryInfo(
    name: 'Equatorial Guinea',
    flag: '🇬🇶',
    code: 'GQ',
    dialCode: '+240',
  ),
  CountryInfo(name: 'Eritrea', flag: '🇪🇷', code: 'ER', dialCode: '+291'),
  CountryInfo(name: 'Estonia', flag: '🇪🇪', code: 'EE', dialCode: '+372'),
  CountryInfo(name: 'Ethiopia', flag: '🇪🇹', code: 'ET', dialCode: '+251'),
  CountryInfo(name: 'Fiji', flag: '🇫🇯', code: 'FJ', dialCode: '+679'),
  CountryInfo(name: 'Finland', flag: '🇫🇮', code: 'FI', dialCode: '+358'),
  CountryInfo(name: 'France', flag: '🇫🇷', code: 'FR', dialCode: '+33'),
  CountryInfo(name: 'Gabon', flag: '🇬🇦', code: 'GA', dialCode: '+241'),
  CountryInfo(name: 'Gambia', flag: '🇬🇲', code: 'GM', dialCode: '+220'),
  CountryInfo(name: 'Georgia', flag: '🇬🇪', code: 'GE', dialCode: '+995'),
  CountryInfo(name: 'Germany', flag: '🇩🇪', code: 'DE', dialCode: '+49'),
  CountryInfo(name: 'Ghana', flag: '🇬🇭', code: 'GH', dialCode: '+233'),
  CountryInfo(name: 'Gibraltar', flag: '🇬🇮', code: 'GI', dialCode: '+350'),
  CountryInfo(name: 'Greece', flag: '🇬🇷', code: 'GR', dialCode: '+30'),
  CountryInfo(name: 'Greenland', flag: '🇬🇱', code: 'GL', dialCode: '+299'),
  CountryInfo(name: 'Grenada', flag: '🇬🇩', code: 'GD', dialCode: '+1'),
  CountryInfo(name: 'Guatemala', flag: '🇬🇹', code: 'GT', dialCode: '+502'),
  CountryInfo(name: 'Guinea', flag: '🇬🇳', code: 'GN', dialCode: '+224'),
  CountryInfo(name: 'Guyana', flag: '🇬🇾', code: 'GY', dialCode: '+592'),
  CountryInfo(name: 'Haiti', flag: '🇭🇹', code: 'HT', dialCode: '+509'),
  CountryInfo(name: 'Honduras', flag: '🇭🇳', code: 'HN', dialCode: '+504'),
  CountryInfo(name: 'Hong Kong', flag: '🇭🇰', code: 'HK', dialCode: '+852'),
  CountryInfo(name: 'Hungary', flag: '🇭🇺', code: 'HU', dialCode: '+36'),
];

```
