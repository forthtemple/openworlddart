part of jsm_controls;

// This set of controls performs orbiting, dollying (zooming), and panning.
// Unlike TrackballControls, it maintains the "up" direction object.up (+Y by default).
//
//    Orbit - left mouse / touch: one-finger move
//    Zoom - middle mouse, or mousewheel / touch: two-finger spread or squish
//    Pan - right mouse, or left mouse + ctrl/meta/shiftKey, or arrow keys / touch: two-finger move

class STATE {
  static const int NONE = -1;
  static const int ROTATE = 0;
  static const int DOLLY = 1;
  static const int ZOOM = 1;
  static const int PAN = 2;
  static const int TOUCH_ROTATE = 3;
  static const int TOUCH_PAN = 4;
  static const int TOUCH_ZOOM_PAN = 4;
  static const int TOUCH_DOLLY_PAN = 5;
  static const int TOUCH_DOLLY_ROTATE = 6;
}

// The four arrow keys
class keys {
  static const String LEFT = 'ArrowLeft';
  static const String UP = 'ArrowUp';
  static const String RIGHT = 'ArrowRight';
  static const String BOTTOM = 'ArrowDown';
}

class OrbitControls with EventDispatcher {
  late OrbitControls scope;
  late Camera object;

  late GlobalKey<DomLikeListenableState> listenableKey;
  DomLikeListenableState get domElement => listenableKey.currentState!;

  // API
  late bool enabled;
  late Vector3 target;
  late Vector3 target0;
  late Vector3 position0;
  late double zoom0;

  late double minDistance;
  late double maxDistance;

  late double minZoom;
  late double maxZoom;

  late double minPolarAngle;
  late double maxPolarAngle;

  late double minAzimuthAngle;
  late double maxAzimuthAngle;

  late bool enableDamping;
  late double dampingFactor;

  late bool enableZoom;
  late double zoomSpeed;

  late bool enableRotate;
  late double rotateSpeed;

  late bool enablePan;
  late double panSpeed;
  late bool screenSpacePanning;
  late double keyPanSpeed;

  late bool autoRotate;
  late double autoRotateSpeed;

  late bool enableKeys;

  late Map<String, dynamic> mouseButtons;
  late Map<String, dynamic> touches;

  var changeEvent = Event({"type": 'change'});
  var startEvent = Event({"type": 'start'});
  var endEvent = Event({"type": 'end'});

  var state = STATE.NONE;

  var EPS = 0.000001;

  // current position in spherical coordinates
  var spherical = new Spherical();
  var sphericalDelta = new Spherical();

  num scale = 1;
  var panOffset = new Vector3();
  var zoomChanged = false;

  var rotateStart = new Vector2(0, 0);
  var rotateEnd = new Vector2(null, null);
  var rotateDelta = new Vector2(null, null);

  var panStart = new Vector2(null, null);
  var panEnd = new Vector2(null, null);
  var panDelta = new Vector2(null, null);

  var dollyStart = new Vector2(null, null);
  var dollyEnd = new Vector2(null, null);
  var dollyDelta = new Vector2(null, null);

  var Infinity = Math.Infinity;

  List pointers = [];
  Map<int, Vector2> pointerPositions = {};

  var lastPosition = new Vector3();
  var lastQuaternion = new Quaternion();

  var twoPI = 2 * Math.PI;

  late Quaternion quat;
  late Quaternion quatInverse;

  OrbitControls(Camera object, GlobalKey<DomLikeListenableState> listenableKey)
      : super() {
    scope = this;

    this.object = object;
    this.listenableKey = listenableKey;
    // this.domElement = domElement;
    // this.domElement.style.touchAction = 'none'; // disable touch scroll

    // Set to false to disable this control
    this.enabled = true;

    // "target" sets the location of focus, where the object orbits around
    this.target = new Vector3();

    // How far you can dolly in and out ( PerspectiveCamera only )
    this.minDistance = 0;
    this.maxDistance = Infinity;

    // How far you can zoom in and out ( OrthographicCamera only )
    this.minZoom = 0;
    this.maxZoom = Infinity;

    // How far you can orbit vertically, upper and lower limits.
    // Range is 0 to Math.PI radians.
    this.minPolarAngle = 0; // radians
    this.maxPolarAngle = Math.PI; // radians

    // How far you can orbit horizontally, upper and lower limits.
    // If set, the interval [ min, max ] must be a sub-interval of [ - 2 PI, 2 PI ], with ( max - min < 2 PI )
    this.minAzimuthAngle = -Infinity; // radians
    this.maxAzimuthAngle = Infinity; // radians

    // Set to true to enable damping (inertia)
    // If damping is enabled, you must call controls.update() in your animation loop
    this.enableDamping = false;
    this.dampingFactor = 0.05;

    // This option actually enables dollying in and out; left as "zoom" for backwards compatibility.
    // Set to false to disable zooming
    this.enableZoom = true;
    this.zoomSpeed = 1.0;

    // Set to false to disable rotating
    this.enableRotate = true;
    this.rotateSpeed = 1.0;

    // Set to false to disable panning
    this.enablePan = true;
    this.panSpeed = 1.0;
    this.screenSpacePanning =
        true; // if false, pan orthogonal to world-space direction camera.up
    this.keyPanSpeed = 7.0; // pixels moved per arrow key push

    // Set to true to automatically rotate around the target
    // If auto-rotate is enabled, you must call controls.update() in your animation loop
    this.autoRotate = false;
    this.autoRotateSpeed = 2.0; // 30 seconds per orbit when fps is 60

    // Mouse buttons
    this.mouseButtons = {
      'LEFT': MOUSE.ROTATE,
      'MIDDLE': MOUSE.DOLLY,
      'RIGHT': MOUSE.PAN
    };

    // Touch fingers
    this.touches = {'ONE': TOUCH.ROTATE, 'TWO': TOUCH.DOLLY_PAN};

    // for reset
    this.target0 = this.target.clone();
    this.position0 = this.object.position.clone();
    this.zoom0 = this.object.zoom;

    // the target DOM element for key events
    // this._domElementKeyEvents = null;

    scope.domElement.addEventListener('contextmenu', onContextMenu);

    scope.domElement.addEventListener('pointerdown', onPointerDown);
    scope.domElement.addEventListener('pointercancel', onPointerCancel);
    scope.domElement.addEventListener('wheel', onMouseWheel);

    // force an update at start

    // so camera.up is the orbit axis
    quat = new Quaternion().setFromUnitVectors(object.up, new Vector3(0, 1, 0));
    quatInverse = quat.clone().invert();

    this.update();
  }

  getPolarAngle() {
    return spherical.phi;
  }

  getAzimuthalAngle() {
    return spherical.theta;
  }

  getDistance() {
    return this.object.position.distanceTo(this.target);
  }

  listenToKeyEvents(domElement) {
    domElement.addEventListener('keydown', onKeyDown);
    // this._domElementKeyEvents = domElement;
  }

  saveState() {
    scope.target0.copy(scope.target);
    scope.position0.copy(scope.object.position);
    scope.zoom0 = scope.object.zoom;
  }

  reset() {
    scope.target.copy(scope.target0);
    scope.object.position.copy(scope.position0);
    scope.object.zoom = scope.zoom0;

    scope.object.updateProjectionMatrix();
    scope.dispatchEvent(_changeEvent);

    scope.update();

    state = STATE.NONE;
  }

  // this method is exposed, but perhaps it would be better if we can make it private...

  var offset = new Vector3();

  update() {
    var position = scope.object.position;
    offset.copy(position).sub(scope.target);

    // rotate offset to "y-axis-is-up" space
    offset.applyQuaternion(quat);

    // angle from z-axis around y-axis
    spherical.setFromVector3(offset);

    if (scope.autoRotate && state == STATE.NONE) {
      rotateLeft(getAutoRotationAngle());
    }

    if (scope.enableDamping) {
      spherical.theta += sphericalDelta.theta * scope.dampingFactor;
      spherical.phi += sphericalDelta.phi * scope.dampingFactor;
    } else {
      spherical.theta += sphericalDelta.theta;
      spherical.phi += sphericalDelta.phi;
    }

    // restrict theta to be between desired limits

    var min = scope.minAzimuthAngle;
    var max = scope.maxAzimuthAngle;

    if (isFinite(min) && isFinite(max)) {
      if (min < -Math.PI)
        min += twoPI;
      else if (min > Math.PI) min -= twoPI;

      if (max < -Math.PI)
        max += twoPI;
      else if (max > Math.PI) max -= twoPI;

      if (min <= max) {
        spherical.theta = Math.max(min, Math.min(max, spherical.theta));
      } else {
        spherical.theta = (spherical.theta > (min + max) / 2)
            ? Math.max(min, spherical.theta)
            : Math.min(max, spherical.theta);
      }
    }

    // restrict phi to be between desired limits
    spherical.phi = Math.max(
        scope.minPolarAngle, Math.min(scope.maxPolarAngle, spherical.phi));

    spherical.makeSafe();

    spherical.radius *= scale;

    // restrict radius to be between desired limits
    spherical.radius = Math.max(
        scope.minDistance, Math.min(scope.maxDistance, spherical.radius));

    // move target to panned location

    if (scope.enableDamping == true) {
      scope.target.addScaledVector(panOffset, scope.dampingFactor);
    } else {
      scope.target.add(panOffset);
    }

    offset.setFromSpherical(spherical);

    // rotate offset back to "camera-up-vector-is-up" space
    offset.applyQuaternion(quatInverse);
    position.copy(scope.target).add(offset);

    scope.object.lookAt(scope.target);

    if (scope.enableDamping == true) {
      sphericalDelta.theta *= (1 - scope.dampingFactor);
      sphericalDelta.phi *= (1 - scope.dampingFactor);

      panOffset.multiplyScalar(1 - scope.dampingFactor);
    } else {
      sphericalDelta.set(0, 0, 0);

      panOffset.set(0, 0, 0);
    }

    scale = 1;

    // update condition is:
    // min(camera displacement, camera rotation in radians)^2 > EPS
    // using small-angle approximation cos(x/2) = 1 - x^2 / 8

    if (zoomChanged ||
        lastPosition.distanceToSquared(scope.object.position) > EPS ||
        8 * (1 - lastQuaternion.dot(scope.object.quaternion)) > EPS) {
      scope.dispatchEvent(_changeEvent);

      lastPosition.copy(scope.object.position);
      lastQuaternion.copy(scope.object.quaternion);
      zoomChanged = false;

      return true;
    }

    return false;
  }

  dispose() {
    scope.domElement.removeEventListener('contextmenu', onContextMenu);

    scope.domElement.removeEventListener('pointerdown', onPointerDown);
    scope.domElement.removeEventListener('pointercancel', onPointerCancel);
    scope.domElement.removeEventListener('wheel', onMouseWheel);

    scope.domElement.removeEventListener('pointermove', onPointerMove);
    scope.domElement.removeEventListener('pointerup', onPointerUp);

    // if ( scope._domElementKeyEvents != null ) {

    //   scope._domElementKeyEvents.removeEventListener( 'keydown', onKeyDown );

    // }

    //scope.dispatchEvent( { type: 'dispose' } ); // should this be added here?
  }

  getAutoRotationAngle() {
    return 2 * Math.PI / 60 / 60 * scope.autoRotateSpeed;
  }

  getZoomScale() {
    return Math.pow(0.95, scope.zoomSpeed);
  }

  rotateLeft(angle) {
    sphericalDelta.theta -= angle;
  }

  rotateUp(angle) {
    sphericalDelta.phi -= angle;
  }

  var v = new Vector3();

  panLeft(distance, objectMatrix) {
    v.setFromMatrixColumn(objectMatrix, 0); // get X column of objectMatrix
    v.multiplyScalar(-distance);

    panOffset.add(v);
  }

  panUp(distance, objectMatrix) {
    if (scope.screenSpacePanning == true) {
      v.setFromMatrixColumn(objectMatrix, 1);
    } else {
      v.setFromMatrixColumn(objectMatrix, 0);
      v.crossVectors(scope.object.up, v);
    }

    v.multiplyScalar(distance);

    panOffset.add(v);
  }

  // deltaX and deltaY are in pixels; right and down are positive
  pan(deltaX, deltaY) {
    var element = scope.domElement;

    if (scope.object is PerspectiveCamera) {
      // perspective
      var position = scope.object.position;
      offset.copy(position).sub(scope.target);
      var targetDistance = offset.length();

      // half of the fov is center to top of screen
      targetDistance *= Math.tan((scope.object.fov / 2) * Math.PI / 180.0);

      // we use only clientHeight here so aspect ratio does not distort speed
      panLeft(2 * deltaX * targetDistance / element.clientHeight,
          scope.object.matrix);
      panUp(2 * deltaY * targetDistance / element.clientHeight,
          scope.object.matrix);
    } else if (scope.object is OrthographicCamera) {
      // orthographic
      panLeft(
          deltaX *
              (scope.object.right - scope.object.left) /
              scope.object.zoom /
              element.clientWidth,
          scope.object.matrix);
      panUp(
          deltaY *
              (scope.object.top - scope.object.bottom) /
              scope.object.zoom /
              element.clientHeight,
          scope.object.matrix);
    } else {
      // camera neither orthographic nor perspective
      print(
          'WARNING: OrbitControls.js encountered an unknown camera type - pan disabled.');
      scope.enablePan = false;
    }
  }

  dollyOut(dollyScale) {
    if (scope.object is PerspectiveCamera) {
      scale /= dollyScale;
    } else if (scope.object is OrthographicCamera) {
      scope.object.zoom = Math.max(scope.minZoom,
          Math.min(scope.maxZoom, scope.object.zoom * dollyScale));
      scope.object.updateProjectionMatrix();
      zoomChanged = true;
    } else {
      print(
          'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.');
      scope.enableZoom = false;
    }
  }

  dollyIn(dollyScale) {
    if (scope.object is PerspectiveCamera) {
      scale *= dollyScale;
    } else if (scope.object is OrthographicCamera) {
      scope.object.zoom = Math.max(scope.minZoom,
          Math.min(scope.maxZoom, scope.object.zoom / dollyScale));
      scope.object.updateProjectionMatrix();
      zoomChanged = true;
    } else {
      print(
          'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.');
      scope.enableZoom = false;
    }
  }

  //
  // event callbacks - update the object state
  //

  handleMouseDownRotate(event) {
    rotateStart.set(event.clientX, event.clientY);
  }

  handleMouseDownDolly(event) {
    dollyStart.set(event.clientX, event.clientY);
  }

  handleMouseDownPan(event) {
    panStart.set(event.clientX, event.clientY);
  }

  handleMouseMoveRotate(event) {
    rotateEnd.set(event.clientX, event.clientY);

    rotateDelta
        .subVectors(rotateEnd, rotateStart)
        .multiplyScalar(scope.rotateSpeed);

    var element = scope.domElement;

    rotateLeft(
        2 * Math.PI * rotateDelta.x / element.clientHeight); // yes, height

    rotateUp(2 * Math.PI * rotateDelta.y / element.clientHeight);

    rotateStart.copy(rotateEnd);

    scope.update();
  }

  handleMouseMoveDolly(event) {
    dollyEnd.set(event.clientX, event.clientY);

    dollyDelta.subVectors(dollyEnd, dollyStart);

    if (dollyDelta.y > 0) {
      dollyOut(getZoomScale());
    } else if (dollyDelta.y < 0) {
      dollyIn(getZoomScale());
    }

    dollyStart.copy(dollyEnd);

    scope.update();
  }

  handleMouseMovePan(event) {
    panEnd.set(event.clientX, event.clientY);

    panDelta.subVectors(panEnd, panStart).multiplyScalar(scope.panSpeed);

    pan(panDelta.x, panDelta.y);

    panStart.copy(panEnd);

    scope.update();
  }

  handleMouseWheel(event) {
    if (event.deltaY < 0) {
      dollyIn(getZoomScale());
    } else if (event.deltaY > 0) {
      dollyOut(getZoomScale());
    }

    scope.update();
  }

  handleKeyDown(event) {
    var needsUpdate = false;

    switch (event.code) {
      case keys.UP:
        pan(0, scope.keyPanSpeed);
        needsUpdate = true;
        break;

      case keys.BOTTOM:
        pan(0, -scope.keyPanSpeed);
        needsUpdate = true;
        break;

      case keys.LEFT:
        pan(scope.keyPanSpeed, 0);
        needsUpdate = true;
        break;

      case keys.RIGHT:
        pan(-scope.keyPanSpeed, 0);
        needsUpdate = true;
        break;
    }

    if (needsUpdate) {
      // prevent the browser from scrolling on cursor keys
      event.preventDefault();

      scope.update();
    }
  }

  handleTouchStartRotate() {
    if (pointers.length == 1) {
      rotateStart.set(pointers[0].pageX, pointers[0].pageY);
    } else {
      var x = 0.5 * (pointers[0].pageX + pointers[1].pageX);
      var y = 0.5 * (pointers[0].pageY + pointers[1].pageY);

      rotateStart.set(x, y);
    }
  }

  handleTouchStartPan() {
    if (pointers.length == 1) {
      panStart.set(pointers[0].pageX, pointers[0].pageY);
    } else {
      var x = 0.5 * (pointers[0].pageX + pointers[1].pageX);
      var y = 0.5 * (pointers[0].pageY + pointers[1].pageY);

      panStart.set(x, y);
    }
  }

  handleTouchStartDolly() {
    var dx = pointers[0].pageX - pointers[1].pageX;
    var dy = pointers[0].pageY - pointers[1].pageY;

    var distance = Math.sqrt(dx * dx + dy * dy);

    dollyStart.set(0, distance);
  }

  handleTouchStartDollyPan() {
    if (scope.enableZoom) handleTouchStartDolly();

    if (scope.enablePan) handleTouchStartPan();
  }

  handleTouchStartDollyRotate() {
    if (scope.enableZoom) handleTouchStartDolly();

    if (scope.enableRotate) handleTouchStartRotate();
  }

  handleTouchMoveRotate(event) {
    if (pointers.length == 1) {
      rotateEnd.set(event.pageX, event.pageY);
    } else {
      var position = getSecondPointerPosition(event);

      var x = 0.5 * (event.pageX + position.x);
      var y = 0.5 * (event.pageY + position.y);

      rotateEnd.set(x, y);
    }

    rotateDelta
        .subVectors(rotateEnd, rotateStart)
        .multiplyScalar(scope.rotateSpeed);

    var element = scope.domElement;

    rotateLeft(
        2 * Math.PI * rotateDelta.x / element.clientHeight); // yes, height

    rotateUp(2 * Math.PI * rotateDelta.y / element.clientHeight);

    rotateStart.copy(rotateEnd);
  }

  handleTouchMovePan(event) {
    if (pointers.length == 1) {
      panEnd.set(event.pageX, event.pageY);
    } else {
      var position = getSecondPointerPosition(event);

      var x = 0.5 * (event.pageX + position.x);
      var y = 0.5 * (event.pageY + position.y);

      panEnd.set(x, y);
    }

    panDelta.subVectors(panEnd, panStart).multiplyScalar(scope.panSpeed);

    pan(panDelta.x, panDelta.y);

    panStart.copy(panEnd);
  }

  handleTouchMoveDolly(event) {
    var position = getSecondPointerPosition(event);

    print("handleTouchMoveDolly event.pageX: ${event.pageX} position.x: ${position.x} ");
    print("handleTouchMoveDolly event.pageY: ${event.pageY} position.y: ${position.y} ");

    var dx = event.pageX - position.x;
    var dy = event.pageY - position.y;

    var distance = Math.sqrt(dx * dx + dy * dy);

    dollyEnd.set(0, distance);

    dollyDelta.set(0, Math.pow(dollyEnd.y / dollyStart.y, scope.zoomSpeed).toDouble());

    dollyOut(dollyDelta.y);

    dollyStart.copy(dollyEnd);
  }

  handleTouchMoveDollyPan(event) {
    if (scope.enableZoom) handleTouchMoveDolly(event);

    if (scope.enablePan) handleTouchMovePan(event);
  }

  handleTouchMoveDollyRotate(event) {
    if (scope.enableZoom) handleTouchMoveDolly(event);

    if (scope.enableRotate) handleTouchMoveRotate(event);
  }

  //
  // event handlers - FSM: listen for events and reset state
  //

  onPointerDown(event) {
    if (scope.enabled == false) return;

    if (pointers.length == 0) {
      scope.domElement.setPointerCapture(event.pointerId);

      scope.domElement.addEventListener('pointermove', onPointerMove);
      scope.domElement.addEventListener('pointerup', onPointerUp);
    }

    addPointer(event);

    if (event.pointerType == 'touch') {
      onTouchStart(event);
    } else {
      onMouseDown(event);
    }
  }

  onPointerMove(event) {
    if (scope.enabled == false) return;

    if (event.pointerType == 'touch') {
      onTouchMove(event);
    } else {
      onMouseMove(event);
    }
  }

  onPointerUp(event) {
    removePointer(event);

    if (pointers.length == 0) {
      scope.domElement.releasePointerCapture(event.pointerId);

      scope.domElement.removeEventListener('pointermove', onPointerMove);
      scope.domElement.removeEventListener('pointerup', onPointerUp);
    }

    scope.dispatchEvent(_endEvent);

    state = STATE.NONE;
  }

  onPointerCancel(event) {
    removePointer(event);
  }

  onMouseDown(event) {
    var mouseAction;

    switch (event.button) {
      case 0:
        mouseAction = scope.mouseButtons['LEFT'];
        break;

      case 1:
        mouseAction = scope.mouseButtons['MIDDLE'];
        break;

      case 2:
        mouseAction = scope.mouseButtons['RIGHT'];
        break;

      default:
        mouseAction = -1;
    }

    switch (mouseAction) {
      case MOUSE.DOLLY:
        if (scope.enableZoom == false) return;

        handleMouseDownDolly(event);

        state = STATE.DOLLY;

        break;

      case MOUSE.ROTATE:
        if (event.ctrlKey || event.metaKey || event.shiftKey) {
          if (scope.enablePan == false) return;

          handleMouseDownPan(event);

          state = STATE.PAN;
        } else {
          if (scope.enableRotate == false) return;

          handleMouseDownRotate(event);

          state = STATE.ROTATE;
        }

        break;

      case MOUSE.PAN:
        if (event.ctrlKey || event.metaKey || event.shiftKey) {
          if (scope.enableRotate == false) return;

          handleMouseDownRotate(event);

          state = STATE.ROTATE;
        } else {
          if (scope.enablePan == false) return;

          handleMouseDownPan(event);

          state = STATE.PAN;
        }

        break;

      default:
        state = STATE.NONE;
    }

    if (state != STATE.NONE) {
      scope.dispatchEvent(_startEvent);
    }
  }

  onMouseMove(event) {
    if (scope.enabled == false) return;

    switch (state) {
      case STATE.ROTATE:
        if (scope.enableRotate == false) return;

        handleMouseMoveRotate(event);

        break;

      case STATE.DOLLY:
        if (scope.enableZoom == false) return;

        handleMouseMoveDolly(event);

        break;

      case STATE.PAN:
        if (scope.enablePan == false) return;

        handleMouseMovePan(event);

        break;
    }
  }

  onMouseWheel(event) {
    if (scope.enabled == false ||
        scope.enableZoom == false ||
        state != STATE.NONE) return;

    event.preventDefault();

    scope.dispatchEvent(_startEvent);

    handleMouseWheel(event);

    scope.dispatchEvent(_endEvent);
  }

  onKeyDown(event) {
    if (scope.enabled == false || scope.enablePan == false) return;

    handleKeyDown(event);
  }

  onTouchStart(event) {
    trackPointer(event);

    switch (pointers.length) {
      case 1:
        switch (scope.touches['ONE']) {
          case TOUCH.ROTATE:
            if (scope.enableRotate == false) return;

            handleTouchStartRotate();

            state = STATE.TOUCH_ROTATE;

            break;

          case TOUCH.PAN:
            if (scope.enablePan == false) return;

            handleTouchStartPan();

            state = STATE.TOUCH_PAN;

            break;

          default:
            state = STATE.NONE;
        }

        break;

      case 2:
        switch (scope.touches['TWO']) {
          case TOUCH.DOLLY_PAN:
            if (scope.enableZoom == false && scope.enablePan == false) return;

            handleTouchStartDollyPan();

            state = STATE.TOUCH_DOLLY_PAN;

            break;

          case TOUCH.DOLLY_ROTATE:
            if (scope.enableZoom == false && scope.enableRotate == false)
              return;

            handleTouchStartDollyRotate();

            state = STATE.TOUCH_DOLLY_ROTATE;

            break;

          default:
            state = STATE.NONE;
        }

        break;

      default:
        state = STATE.NONE;
    }

    if (state != STATE.NONE) {
      scope.dispatchEvent(_startEvent);
    }
  }

  onTouchMove(event) {
    trackPointer(event);

    switch (state) {
      case STATE.TOUCH_ROTATE:
        if (scope.enableRotate == false) return;

        handleTouchMoveRotate(event);

        scope.update();

        break;

      case STATE.TOUCH_PAN:
        if (scope.enablePan == false) return;

        handleTouchMovePan(event);

        scope.update();

        break;

      case STATE.TOUCH_DOLLY_PAN:
        if (scope.enableZoom == false && scope.enablePan == false) return;

        handleTouchMoveDollyPan(event);

        scope.update();

        break;

      case STATE.TOUCH_DOLLY_ROTATE:
        if (scope.enableZoom == false && scope.enableRotate == false) return;

        handleTouchMoveDollyRotate(event);

        scope.update();

        break;

      default:
        state = STATE.NONE;
    }
  }

  onContextMenu(event) {
    if (scope.enabled == false) return;

    event.preventDefault();
  }

  addPointer(event) {
    pointers.add(event);
  }

  removePointer(event) {
    pointerPositions.remove(event.pointerId);

    for (var i = 0; i < pointers.length; i++) {
      if (pointers[i].pointerId == event.pointerId) {
        pointers.splice(i, 1);
        return;
      }
    }
  }

  trackPointer(event) {
    var position = pointerPositions[event.pointerId];

    if (position == null) {
      position = new Vector2();
      pointerPositions[event.pointerId] = position;
    }

    position.set(event.pageX, event.pageY);
  }

  getSecondPointerPosition(event) {
    var pointer =
        (event.pointerId == pointers[0].pointerId) ? pointers[1] : pointers[0];

    return pointerPositions[pointer.pointerId];
  }
}

// This set of controls performs orbiting, dollying (zooming), and panning.
// Unlike TrackballControls, it maintains the "up" direction object.up (+Y by default).
// This is very similar to OrbitControls, another set of touch behavior
//
//    Orbit - right mouse, or left mouse + ctrl/meta/shiftKey / touch: two-finger rotate
//    Zoom - middle mouse, or mousewheel / touch: two-finger spread or squish
//    Pan - left mouse, or arrow keys / touch: one-finger move

class MapControls extends OrbitControls {
  MapControls(object, domElement) : super(object, domElement) {
    this.screenSpacePanning =
        false; // pan orthogonal to world-space direction camera.up

    this.mouseButtons['LEFT'] = MOUSE.PAN;
    this.mouseButtons['RIGHT'] = MOUSE.ROTATE;

    this.touches['ONE'] = TOUCH.PAN;
    this.touches['TWO'] = TOUCH.DOLLY_ROTATE;
  }
}
