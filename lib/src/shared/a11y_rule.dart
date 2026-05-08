import 'package:analyzer/dart/ast/ast.dart';

abstract class A11yRule {
  String get name;

  String get message;

  String get correctionMessage;

  void checkInstanceCreation(
    InstanceCreationExpression node,
    void Function(AstNode) report,
  ) {}

  void checkMethodInvocation(
    MethodInvocation node,
    void Function(AstNode) report,
  ) {}
}
