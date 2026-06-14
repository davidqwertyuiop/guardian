import 'countries_part1.dart';
import 'countries_part2.dart';

export 'countries_part1.dart' show CountryInfo;

const List<CountryInfo> countries = [
  ...countriesPart1,
  ...countriesPart2,
];
