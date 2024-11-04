import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

class Camera {
  Camera({
    Vector3? position,
    Vector3? target,
    Vector3? up,
    this.fov = 60.0,
    this.near = 0.1,
    this.far = 1000,
    this.zoom = 1.0,
    this.viewportWidth = 100.0,
    this.viewportHeight = 100.0,
  }) {
    if (position != null) position.copyInto(this.position);
    if (target != null) target.copyInto(this.target);
    if (up != null) up.copyInto(this.up);
  }

  final Vector3 position = Vector3(0.0, 0.0, -10.0);
  final Vector3 target = Vector3(0.0, 0.0, 0.0);
  final Vector3 up = Vector3(0.0, 1.0, 0.0);
  double fov;
  double near;
  double far;
  double zoom;
  double viewportWidth;
  double viewportHeight;

  double get aspectRatio => viewportWidth / viewportHeight;

  Matrix4 get lookAtMatrix {
    return makeViewMatrix(position, target, up);
  }

  void rotateZAsix(double angle) {
    angle = angle / 180 * math.pi;
    var forward = (target - position);
    forward = forward.normalized();
    Quaternion q = Quaternion.axisAngle(forward, angle);

    var ret = q.rotate(up);
    ret = ret.normalized();
    up.setValues(ret.x, ret.y, ret.z);
  }

  void rotateYAsix(double angle) {
    angle = angle / 180 * math.pi;
    var forward = (target - position);
    var value = forward.length;
    forward = forward.normalized();
    var right = up.cross(forward).normalized();
    Quaternion q = Quaternion.axisAngle(right, angle);

    var ret = q.rotate(forward);
    var newTarget = position + ret * value;
    target.setValues(newTarget.x, newTarget.y, newTarget.z);

    var newUp = q.rotate(up);
    up.setValues(newUp.x, newUp.y, newUp.z);
  }

  void goVertical(double distance) {
    Vector3 vec = up * distance;
    Vector3 newPos = position + vec;
    position.setValues(newPos.x, newPos.y, newPos.z);

    var newTarget = target + vec;
    target.setValues(newTarget.x, newTarget.y, newTarget.z);
  }

  void goHorizontal(double distance) {
    Vector3 forward = (target - position).normalized();
    Vector3 vec = forward.cross(up).normalized() * distance;
    Vector3 newPos = position + vec;
    position.setValues(newPos.x, newPos.y, newPos.z);

    var newTarget = target + vec;
    target.setValues(newTarget.x, newTarget.y, newTarget.z);
  }

  void go(double distance) {
    Vector3 vec = (target - position).normalized();
    Vector3 newPos = position + vec * distance;
    position.setValues(newPos.x, newPos.y, newPos.z);

    var newTarget = target + vec * distance;
    target.setValues(newTarget.x, newTarget.y, newTarget.z);
  }

  void rotate(double angle) {
    angle = angle / 180 * math.pi;
    Quaternion q = Quaternion.axisAngle(up, angle);
    var vec = target - position;
    var ret = q.rotate(vec);
    ret += position;
    target.setValues(ret.x, ret.y, ret.z);
  }

  Matrix4 get projectionMatrix {
    final double top = near * math.tan(radians(fov) / 2.0) / zoom;
    final double bottom = -top;
    final double right = top * aspectRatio;
    final double left = -right;
    return makeFrustumMatrix(left, right, bottom, top, near, far);
  }

  void trackBall(Vector2 from, Vector2 to, [double sensitivity = 1.0]) {
    final double x = -(to.x - from.x) * sensitivity / (viewportWidth * 0.5);
    final double y = (to.y - from.y) * sensitivity / (viewportHeight * 0.5);

    rotateYAsix(y);
    rotate(x);
  }

  void trackBallDeprecated(Vector2 from, Vector2 to,
      [double sensitivity = 1.0]) {
    final double x = -(to.x - from.x) * sensitivity / (viewportWidth * 0.5);
    final double y = (to.y - from.y) * sensitivity / (viewportHeight * 0.5);
    Vector2 delta = Vector2(x, y);
    Vector3 moveDirection = Vector3(delta.x, delta.y, 0);
    final double angle = moveDirection.length;
    if (angle > 0) {
      Vector3 eye = position - target;
      Vector3 eyeDirection = eye.normalized();
      Vector3 upDirection = up.normalized();
      Vector3 sidewaysDirection = upDirection.cross(eyeDirection).normalized();
      upDirection.scale(delta.y);
      sidewaysDirection.scale(delta.x);
      moveDirection = upDirection + sidewaysDirection;
      Vector3 axis = moveDirection.cross(eye).normalized();
      Quaternion q = Quaternion.axisAngle(axis, angle);
      q.rotate(position);
      q.rotate(up);
    }
  }
}
