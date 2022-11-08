import '../rule/rule.dart';
import 'no_bare_strings/no_bare_strings.dart';
import 'no_material_cupertino_imports/no_material_cupertino_imports.dart';

export 'no_bare_strings/no_bare_strings.dart';
export 'no_material_cupertino_imports/no_material_cupertino_imports.dart';

/// List of all custom analyzer rules.
final rules = <Rule>[
  NoMaterialCupertinoImportsRule(),
  NoBareStrings(),
  // Add more rules here
];
