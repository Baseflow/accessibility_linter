import 'package:analyzer/dart/ast/ast.dart';

class RuleSpec {
  final String name;

  final String message;

  final String correctionMessage;

  final void Function(
    InstanceCreationExpression node,
    void Function(AstNode) report,
  )? onInstanceCreation;

  final void Function(
    MethodInvocation node,
    void Function(AstNode) report,
  )? onMethodInvocation;

  const RuleSpec({
    required this.name,
    required this.message,
    required this.correctionMessage,
    this.onInstanceCreation,
    this.onMethodInvocation,
  });
}
