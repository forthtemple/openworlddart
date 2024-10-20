part of jsm_controls;

class PointerLockControls with EventDispatcher {
  bool isLocked = false;

  // Set to constrain the pitch of the camera
  // Range is 0 to Math.PI radians
  double minPolarAngle = 0; // radians
  double maxPolarAngle = Math.PI; // radians

  double pointerSpeed = 1.0;

  late Camera camera;
  late PointerLockControls scope;

  late GlobalKey<DomLikeListenableState> listenableKey;
  DomLikeListenableState get domElement => listenableKey.currentState!;

  PointerLockControls(camera, listenableKey) : super() {
    this.camera = camera;

    this.listenableKey = listenableKey;

    scope = this;

    this.connect();
  }

  onMouseMove(event) {
//    print("onMouseMove event: ${event} isLocked ${scope.isLocked} ");
    if (scope.isLocked == false) return;

    var movementX =
        event.movementX ?? event.mozMovementX ?? event.webkitMovementX ?? 0;
    var movementY =
        event.movementY ?? event.mozMovementY ?? event.webkitMovementY ?? 0;

    _euler.setFromQuaternion(camera.quaternion);

    _euler.y -= movementX * 0.002 * scope.pointerSpeed;
    _euler.x -= movementY * 0.002 * scope.pointerSpeed;

    _euler.x = Math.max(_PI_2 - scope.maxPolarAngle,
        Math.min(_PI_2 - scope.minPolarAngle, _euler.x));

    camera.quaternion.setFromEuler(_euler);

    scope.dispatchEvent(_changeEvent);
  }

  onPointerlockChange() {
    if (scope.domElement.pointerLockElement == scope.domElement) {
      scope.dispatchEvent(_lockEvent);

      scope.isLocked = true;
    } else {
      scope.dispatchEvent(_unlockEvent);

      scope.isLocked = false;
    }
  }

  onPointerlockError() {
    print('THREE.PointerLockControls: Unable to use Pointer Lock API');
  }

  connect() {
    scope.domElement.addEventListener('mousemove', onMouseMove);
    scope.domElement.addEventListener('touchmove', onMouseMove);
    scope.domElement.addEventListener('pointerlockchange', onPointerlockChange);
    scope.domElement.addEventListener('pointerlockerror', onPointerlockError);
  }

  disconnect() {
    scope.domElement.removeEventListener('mousemove', onMouseMove);
    scope.domElement
        .removeEventListener('pointerlockchange', onPointerlockChange);
    scope.domElement
        .removeEventListener('pointerlockerror', onPointerlockError);
  }

  dispose() {
    this.disconnect();
  }

  getObject() {
    // retaining this method for backward compatibility

    return camera;
  }

  var direction = new Vector3(0, 0, -1);

  getDirection(v) {
    return v.copy(direction).applyQuaternion(camera.quaternion);
  }

  moveForward(distance) {
    // move forward parallel to the xz-plane
    // assumes camera.up is y-up

    _vector.setFromMatrixColumn(camera.matrix, 0);

    _vector.crossVectors(camera.up, _vector);

    camera.position.addScaledVector(_vector, distance);
  }

  moveRight(distance) {
    _vector.setFromMatrixColumn(camera.matrix, 0);

    camera.position.addScaledVector(_vector, distance);
  }

  lock() {
    this.isLocked = true;
    this.domElement.requestPointerLock();
  }

  unlock() {
    scope.domElement.exitPointerLock();
  }
}
