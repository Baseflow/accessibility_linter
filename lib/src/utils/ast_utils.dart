import 'package:analyzer/dart/ast/ast.dart';

String constructorTypeName(InstanceCreationExpression node) =>
    node.constructorName.type.name.lexeme;

NamedExpression? getNamedArg(InstanceCreationExpression node, String argName) {
  for (final arg in node.argumentList.arguments) {
    if (arg is NamedExpression && arg.name.label.name == argName) return arg;
  }
  return null;
}

bool hasNamedNonNull(InstanceCreationExpression node, String argName) {
  final arg = getNamedArg(node, argName);
  return arg != null && arg.expression is! NullLiteral;
}

bool isWrappedWith(AstNode node, String widgetName) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression &&
        constructorTypeName(current) == widgetName) {
      return true;
    }
    current = current.parent;
  }
  return false;
}

bool isWrappedWithAny(AstNode node, Set<String> widgetNames) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression &&
        widgetNames.contains(constructorTypeName(current))) {
      return true;
    }
    current = current.parent;
  }
  return false;
}
