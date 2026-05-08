import 'package:analyzer/dart/ast/visitor.dart';

import 'violation.dart';

abstract class A11yChecker extends RecursiveAstVisitor<void> {
  final List<Violation> violations = [];
}
