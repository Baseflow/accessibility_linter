import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/orientation_lock_check.dart';

/// CLI checker for the `orientation_lock` rule.
class OrientationLockChecker extends A11yChecker {
  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    checkOrientationLock(
      node,
      (n) => violations.add(Violation(
        n,
        'orientation_lock',
        'Locking device orientation is an accessibility issue and should be avoided.',
      )),
    );
  }
}
