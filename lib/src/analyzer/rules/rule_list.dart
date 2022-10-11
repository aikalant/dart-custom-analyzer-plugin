import '../rule/rule.dart';
import 'no_bare_strings/no_bare_strings.dart';
import 'no_material_cupertino_imports/no_material_cupertino_imports.dart';

final rules = <Rule>[
  NoMaterialCupertinoImportsRule(),
  NoBareStrings(),
  //Add more rules here
];
