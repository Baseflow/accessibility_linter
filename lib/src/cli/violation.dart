import 'package:analyzer/dart/ast/ast.dart';

class Violation {
  final AstNode node;
  final String ruleName;
  final String message;

  const Violation(this.node, this.ruleName, this.message);
}
