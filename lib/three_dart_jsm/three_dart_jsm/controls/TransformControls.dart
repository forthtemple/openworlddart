part of jsm_controls;

var _tempVector = new Vector3();
var _tempVector2 = new Vector3();
var _tempQuaternion = new Quaternion();
var _unit = {
  "X": new Vector3(1, 0, 0),
  "Y": new Vector3(0, 1, 0),
  "Z": new Vector3(0, 0, 1)
};

var _mouseDownEvent = Event({"type": 'mouseDown'});
var _mouseUpEvent = Event({"type": 'mouseUp', "mode": null});
var _objectChangeEvent = Event({"type": 'objectChange'});

Pointer? _pointer0;

class TransformControls extends Object3D {
  bool isTransformControls = true;

  late dynamic domKey;
  dynamic domElement;

  late TransformControlsGizmo _gizmo;
  late TransformControlsPlane _plane;

  dynamic scope;

  Camera? _camera;
  get camera {
    return _camera;
  }

  set camera(value) {
    if (value != _camera) {
      _camera = value;
      _plane.camera = value;
      _gizmo.camera = value;

      scope.dispatchEvent(Event({"type": 'camera-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Object3D? _object = null;
  get object {
    return _object;
  }

  set object(value) {
    if (value != _object) {
      _object = value;
      _plane.object = value;
      _gizmo.object = value;

      scope.dispatchEvent(Event({"type": 'object-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  bool _enabled = true;
  get enabled {
    return _enabled;
  }

  set enabled(value) {
    if (value != _enabled) {
      _enabled = value;
      _plane.enabled = value;
      _gizmo.enabled = value;

      scope.dispatchEvent(Event({"type": 'enabled-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  String? _axis = null;
  get axis {
    return _axis;
  }

  set axis(value) {
    if (value != _axis) {
      _axis = value;
      _plane.axis = value;
      _gizmo.axis = value;

      scope.dispatchEvent(Event({"type": 'axis-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  var _mode = "translate";
  get mode {
    return _mode;
  }

  set mode(value) {
    if (value != _mode) {
      _mode = value;
      _plane.mode = value;
      _gizmo.mode = value;

      scope.dispatchEvent(Event({"type": 'mode-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  var _translationSnap = null;
  get translationSnap {
    return _translationSnap;
  }

  set translationSnap(value) {
    if (value != _translationSnap) {
      _translationSnap = value;

      scope.dispatchEvent(
          Event({"type": 'translationSnap-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  num? _rotationSnap = null;
  get rotationSnap {
    return _rotationSnap;
  }

  set rotationSnap(value) {
    if (value != _rotationSnap) {
      _rotationSnap = value;

      scope.dispatchEvent(
          Event({"type": 'rotationSnap-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  num? _scaleSnap = null;
  get scaleSnap {
    return _scaleSnap;
  }

  set scaleSnap(value) {
    if (value != _scaleSnap) {
      _scaleSnap = value;

      scope.dispatchEvent(Event({"type": 'scaleSnap-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  var _space = "world";
  get space {
    return _space;
  }

  set space(value) {
    if (value != _space) {
      _space = value;
      _plane.space = value;
      _gizmo.space = value;

      scope.dispatchEvent(Event({"type": 'space-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  var _size = 1;
  get size {
    return _size;
  }

  set size(value) {
    if (value != _size) {
      _size = value;
      _plane.size = value;
      _gizmo.size = value;

      scope.dispatchEvent(Event({"type": 'size-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  bool _dragging = false;
  get dragging {
    return _dragging;
  }

  set dragging(value) {
    if (value != _dragging) {
      _dragging = value;
      _plane.dragging = value;
      _gizmo.dragging = value;

      scope.dispatchEvent(Event({"type": 'dragging-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  bool _showX = true;
  get showX {
    return _showX;
  }

  set showX(value) {
    if (value != _showX) {
      _showX = value;
      _plane.showX = value;
      _gizmo.showX = value;

      scope.dispatchEvent(Event({"type": 'showX-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  bool _showY = true;
  get showY {
    return _showY;
  }

  set showY(value) {
    if (value != _showY) {
      _showY = value;
      _plane.showY = value;
      _gizmo.showY = value;

      scope.dispatchEvent(Event({"type": 'showY-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  bool _showZ = true;
  get showZ {
    return _showZ;
  }

  set showZ(value) {
    if (value != _showZ) {
      _showZ = value;
      _plane.showZ = value;
      _gizmo.showZ = value;

      scope.dispatchEvent(Event({"type": 'showZ-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  // Reusable utility variables

  // var worldPosition = new Vector3();
  // var worldPositionStart = new Vector3();
  // var worldQuaternion = new Quaternion();
  // var worldQuaternionStart = new Quaternion();
  // var cameraPosition = new Vector3();
  // var cameraQuaternion = new Quaternion();
  // var pointStart = new Vector3();
  // var pointEnd = new Vector3();
  // var rotationAxis = new Vector3();
  // var rotationAngle = 0;
  // var eye = new Vector3();

  Vector3 _worldPosition = Vector3();
  get worldPosition {
    return _worldPosition;
  }

  set worldPosition(value) {
    if (value != _worldPosition) {
      _worldPosition = value;
      // _plane.worldPosition = value;
      // _gizmo.worldPosition = value;

      scope.dispatchEvent(
          Event({"type": 'worldPosition-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _worldPositionStart = Vector3();
  get worldPositionStart {
    return _worldPositionStart;
  }

  set worldPositionStart(value) {
    if (value != _worldPositionStart) {
      _worldPositionStart = value;
      // _plane.worldPositionStart = value;
      // _gizmo.worldPositionStart = value;

      scope.dispatchEvent(
          Event({"type": 'worldPositionStart-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Quaternion _worldQuaternion = Quaternion();
  get worldQuaternion {
    return _worldQuaternion;
  }

  set worldQuaternion(value) {
    if (value != _worldQuaternion) {
      _worldQuaternion = value;
      // _plane.worldQuaternion = value;
      // _gizmo.worldQuaternion = value;

      scope.dispatchEvent(
          Event({"type": 'worldQuaternion-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Quaternion _worldQuaternionStart = Quaternion();
  get worldQuaternionStart {
    return _worldQuaternionStart;
  }

  set worldQuaternionStart(value) {
    if (value != _worldQuaternionStart) {
      _worldQuaternionStart = value;
      // _plane.worldQuaternionStart = value;
      // _gizmo.worldQuaternionStart = value;

      scope.dispatchEvent(
          Event({"type": 'worldQuaternionStart-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _cameraPosition = Vector3();
  get cameraPosition {
    return _cameraPosition;
  }

  set cameraPosition(value) {
    if (value != _cameraPosition) {
      _cameraPosition = value;
      // _plane.cameraPosition = value;
      // _gizmo.cameraPosition = value;

      scope.dispatchEvent(
          Event({"type": 'cameraPosition-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Quaternion _cameraQuaternion = Quaternion();
  get cameraQuaternion {
    return _cameraQuaternion;
  }

  set cameraQuaternion(value) {
    if (value != _cameraQuaternion) {
      _cameraQuaternion = value;
      // _plane.cameraQuaternion = value;
      // _gizmo.cameraQuaternion = value;

      scope.dispatchEvent(
          Event({"type": 'cameraQuaternion-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _pointStart = Vector3();
  get pointStart {
    return _pointStart;
  }

  set pointStart(value) {
    if (value != _pointStart) {
      _pointStart = value;
      // _plane.pointStart = value;
      // _gizmo.pointStart = value;

      scope
          .dispatchEvent(Event({"type": 'pointStart-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _pointEnd = Vector3();
  get pointEnd {
    return _pointEnd;
  }

  set pointEnd(value) {
    if (value != _pointEnd) {
      _pointEnd = value;
      // _plane.pointEnd = value;
      // _gizmo.pointEnd = value;

      scope.dispatchEvent(Event({"type": 'pointEnd-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _rotationAxis = Vector3();
  get rotationAxis {
    return _rotationAxis;
  }

  set rotationAxis(value) {
    if (value != _rotationAxis) {
      _rotationAxis = value;
      // _plane.rotationAxis = value;
      // _gizmo.rotationAxis = value;

      scope.dispatchEvent(
          Event({"type": 'rotationAxis-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  num _rotationAngle = 0;
  get rotationAngle {
    return _rotationAngle;
  }

  set rotationAngle(value) {
    if (value != _rotationAngle) {
      _rotationAngle = value;
      // _plane.rotationAngle = value;
      // _gizmo.rotationAngle = value;

      scope.dispatchEvent(
          Event({"type": 'rotationAngle-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  Vector3 _eye = Vector3();
  get eye {
    return _eye;
  }

  set eye(value) {
    if (value != _eye) {
      _eye = value;
      // _plane.eye = value;
      // _gizmo.eye = value;

      scope.dispatchEvent(Event({"type": 'eye-changed', "value": value}));
      scope.dispatchEvent(_changeEvent);
    }
  }

  var _offset = new Vector3();
  var _startNorm = new Vector3();
  var _endNorm = new Vector3();
  var _cameraScale = new Vector3();

  var _parentPosition = new Vector3();
  var _parentQuaternion = new Quaternion();
  var _parentQuaternionInv = new Quaternion();
  var _parentScale = new Vector3();

  var _worldScaleStart = new Vector3();
  var _worldQuaternionInv = new Quaternion();
  var _worldScale = new Vector3();

  var _positionStart = new Vector3();
  var _quaternionStart = new Quaternion();
  var _scaleStart = new Vector3();

  TransformControls(camera, domKey) : super() {
    scope = this;

    this.visible = false;
    this.domKey = domKey;
    this.domElement = domKey.currentState;
    // this.domElement.style.touchAction = 'none'; // disable touch scroll

    _gizmo = TransformControlsGizmo(this);
    _gizmo.name = "TransformControlsGizmo";

    _plane = TransformControlsPlane(this);
    _plane.name = "TransformControlsPlane";

    this.camera = camera;

    this.add(_gizmo);
    this.add(_plane);

    this.domElement.addEventListener('pointerdown', this._onPointerDown, false);
    this
        .domElement
        .addEventListener('pointermove', this._onPointerHover, false);
    this.domElement.addEventListener('pointerup', this._onPointerUp, false);
  }

  // updateMatrixWorld  updates key transformation variables
  updateMatrixWorld([bool force = false]) {
    if (this.object != null) {
      this.object.updateMatrixWorld(force);

      if (this.object.parent == null) {
        print(
            'TransformControls: The attached 3D object must be a part of the scene graph.');
      } else {
        this.object.parent.matrixWorld.decompose(
            this._parentPosition, this._parentQuaternion, this._parentScale);
      }

      this.object.matrixWorld.decompose(
          this.worldPosition, this.worldQuaternion, this._worldScale);

      this._parentQuaternionInv.copy(this._parentQuaternion).invert();
      this._worldQuaternionInv.copy(this.worldQuaternion).invert();
    }

    this.camera.updateMatrixWorld(force);

    this
        .camera
        .matrixWorld
        .decompose(this.cameraPosition, this.cameraQuaternion, _cameraScale);

    this.eye.copy(this.cameraPosition).sub(this.worldPosition).normalize();

    super.updateMatrixWorld(force);
  }

  pointerHover(Pointer pointer) {
    if (this.object == null || this.dragging == true) return;

    _raycaster.setFromCamera(Vector2(pointer.x, pointer.y), this.camera);

    var intersect = intersectObjectWithRay(
        this._gizmo.picker[this.mode], _raycaster, false);

    if (intersect != null && intersect != false) {
      this.axis = intersect.object.name;
    } else {
      this.axis = null;
    }
  }

  pointerDown(Pointer pointer) {
    _pointer0 = pointer;


    if (this.object == null || this.dragging == true || pointer.button != 1)
      return;

    if (this.axis != null) {
      _raycaster.setFromCamera(Vector2(pointer.x, pointer.y), this.camera);

      var planeIntersect =
          intersectObjectWithRay(this._plane, _raycaster, true);

      if (planeIntersect != null && planeIntersect != false) {
        this.object.updateMatrixWorld(false);
        this.object.parent.updateMatrixWorld(false);

        this._positionStart.copy(this.object.position);
        this._quaternionStart.copy(this.object.quaternion);
        this._scaleStart.copy(this.object.scale);

        this.object.matrixWorld.decompose(this.worldPositionStart,
            this.worldQuaternionStart, this._worldScaleStart);

        this.pointStart.copy(planeIntersect.point).sub(this.worldPositionStart);
      }

      this.dragging = true;
      _mouseDownEvent.mode = this.mode;
      this.dispatchEvent(_mouseDownEvent);
    }
  }

  pointerMove(Pointer pointer) {
    // TODO if not when change axis will cause object position change. why???
    if (pointer.x == _pointer0?.x &&
        pointer.y == _pointer0?.y &&
        pointer.button == _pointer0?.button) {
      return;
    }
    _pointer0 = pointer;

    var axis = this.axis;
    var mode = this.mode;
    var object = this.object;
    var space = this.space;

    if (mode == 'scale') {
      space = 'local';
    } else if (axis == 'E' || axis == 'XYZE' || axis == 'XYZ') {
      space = 'world';
    }

    if (object == null ||
        axis == null ||
        this.dragging == false ||
        pointer.button != 1) return;

    _raycaster.setFromCamera(Vector2(pointer.x, pointer.y), this.camera);

    var planeIntersect = intersectObjectWithRay(this._plane, _raycaster, true);

    if (planeIntersect == null || planeIntersect == false) return;

    this.pointEnd.copy(planeIntersect.point).sub(this.worldPositionStart);

    if (mode == 'translate') {
      // Apply translate

      this._offset.copy(this.pointEnd).sub(this.pointStart);

      if (space == 'local' && axis != 'XYZ') {
        this._offset.applyQuaternion(this._worldQuaternionInv);
      }

      if (axis.indexOf('X') == -1) this._offset.x = 0;
      if (axis.indexOf('Y') == -1) this._offset.y = 0;
      if (axis.indexOf('Z') == -1) this._offset.z = 0;

      if (space == 'local' && axis != 'XYZ') {
        this
            ._offset
            .applyQuaternion(this._quaternionStart)
            .divide(this._parentScale);
      } else {
        this
            ._offset
            .applyQuaternion(this._parentQuaternionInv)
            .divide(this._parentScale);
      }

      object.position.copy(this._offset).add(this._positionStart);

      // Apply translation snap

      if (this.translationSnap != null) {
        if (space == 'local') {
          object.position.applyQuaternion(
              _tempQuaternion.copy(this._quaternionStart).invert());

          if (axis.indexOf('X') != -1) {
            object.position.x =
                Math.round(object.position.x / this.translationSnap) *
                    this.translationSnap;
          }

          if (axis.indexOf('Y') != -1) {
            object.position.y =
                Math.round(object.position.y / this.translationSnap) *
                    this.translationSnap;
          }

          if (axis.indexOf('Z') != -1) {
            object.position.z =
                Math.round(object.position.z / this.translationSnap) *
                    this.translationSnap;
          }

          object.position.applyQuaternion(this._quaternionStart);
        }

        if (space == 'world') {
          if (object.parent != null) {
            var _vec =
                _tempVector.setFromMatrixPosition(object.parent.matrixWorld);
            object.position.add(
                _tempVector.setFromMatrixPosition(object.parent.matrixWorld));
          }

          if (axis.indexOf('X') != -1) {
            object.position.x =
                Math.round(object.position.x / this.translationSnap) *
                    this.translationSnap;
          }

          if (axis.indexOf('Y') != -1) {
            object.position.y =
                Math.round(object.position.y / this.translationSnap) *
                    this.translationSnap;
          }

          if (axis.indexOf('Z') != -1) {
            object.position.z =
                Math.round(object.position.z / this.translationSnap) *
                    this.translationSnap;
          }

          if (object.parent != null) {
            object.position.sub(
                _tempVector.setFromMatrixPosition(object.parent.matrixWorld));
          }
        }
      }
    } else if (mode == 'scale') {
      if (axis.indexOf('XYZ') != -1) {
        var d = this.pointEnd.length() / this.pointStart.length();

        if (this.pointEnd.dot(this.pointStart) < 0) d *= -1;

        _tempVector2.set(d, d, d);
      } else {
        _tempVector.copy(this.pointStart);
        _tempVector2.copy(this.pointEnd);

        _tempVector.applyQuaternion(this._worldQuaternionInv);
        _tempVector2.applyQuaternion(this._worldQuaternionInv);

        _tempVector2.divide(_tempVector);

        if (axis.indexOf('X') == -1) {
          _tempVector2.x = 1;
        }

        if (axis.indexOf('Y') == -1) {
          _tempVector2.y = 1;
        }

        if (axis.indexOf('Z') == -1) {
          _tempVector2.z = 1;
        }
      }

      // Apply scale

      object.scale.copy(this._scaleStart).multiply(_tempVector2);

      if (this.scaleSnap != null) {
        if (axis.indexOf('X') != -1) {
          var _x = Math.round(object.scale.x / this.scaleSnap) * this.scaleSnap;

          object.scale.x = _x != 0 ? _x : this.scaleSnap;
        }

        if (axis.indexOf('Y') != -1) {
          var _y = Math.round(object.scale.y / this.scaleSnap) * this.scaleSnap;

          object.scale.y = _y != 0 ? _y : this.scaleSnap;
        }

        if (axis.indexOf('Z') != -1) {
          var _z = Math.round(object.scale.z / this.scaleSnap) * this.scaleSnap;

          object.scale.z = _z != 0 ? _z : this.scaleSnap;
        }
      }
    } else if (mode == 'rotate') {
      this._offset.copy(this.pointEnd).sub(this.pointStart);

      var ROTATION_SPEED = 20 /
          this.worldPosition.distanceTo(
              _tempVector.setFromMatrixPosition(this.camera.matrixWorld));

      if (axis == 'E') {
        this.rotationAxis.copy(this.eye);
        this.rotationAngle = this.pointEnd.angleTo(this.pointStart);

        this._startNorm.copy(this.pointStart).normalize();
        this._endNorm.copy(this.pointEnd).normalize();

        this.rotationAngle *=
            (this._endNorm.cross(this._startNorm).dot(this.eye) < 0 ? 1 : -1);
      } else if (axis == 'XYZE') {
        this.rotationAxis.copy(this._offset).cross(this.eye).normalize();
        this.rotationAngle = this
                ._offset
                .dot(_tempVector.copy(this.rotationAxis).cross(this.eye)) *
            ROTATION_SPEED;
      } else if (axis == 'X' || axis == 'Y' || axis == 'Z') {
        this.rotationAxis.copy(_unit[axis]);

        _tempVector.copy(_unit[axis]);

        if (space == 'local') {
          _tempVector.applyQuaternion(this.worldQuaternion);
        }

        this.rotationAngle =
            this._offset.dot(_tempVector.cross(this.eye).normalize()) *
                ROTATION_SPEED;
      }

      // Apply rotation snap

      if (this.rotationSnap != null)
        this.rotationAngle =
            Math.round(this.rotationAngle / this.rotationSnap) *
                this.rotationSnap;

      // Apply rotate
      if (space == 'local' && axis != 'E' && axis != 'XYZE') {
        object.quaternion.copy(this._quaternionStart);
        object.quaternion
            .multiply(_tempQuaternion.setFromAxisAngle(
                this.rotationAxis, this.rotationAngle))
            .normalize();
      } else {
        this.rotationAxis.applyQuaternion(this._parentQuaternionInv);
        object.quaternion.copy(_tempQuaternion.setFromAxisAngle(
            this.rotationAxis, this.rotationAngle));
        object.quaternion.multiply(this._quaternionStart).normalize();
      }
    }

    this.dispatchEvent(_changeEvent);
    this.dispatchEvent(_objectChangeEvent);
  }

  pointerUp(Pointer pointer) {
    if (pointer.button != 0) return;

    if (this.dragging && (this.axis != null)) {
      _mouseUpEvent.mode = this.mode;
      this.dispatchEvent(_mouseUpEvent);
    }

    this.dragging = false;
    this.axis = null;
  }

  dispose() {
    this.domElement.removeEventListener('pointerdown', this._onPointerDown);
    this.domElement.removeEventListener('pointermove', this._onPointerHover);
    this.domElement.removeEventListener('pointermove', this._onPointerMove);
    this.domElement.removeEventListener('pointerup', this._onPointerUp);

    this.traverse((child) {
      if (child.geometry) child.geometry.dispose();
      if (child.material) child.material.dispose();
    });
  }

  // Set current object
  attach(object) {
    this.object = object;
    this.visible = true;

    return this;
  }

  // Detatch from object
  detach() {
    this.object = null;
    this.visible = false;
    this.axis = null;

    return this;
  }

  getRaycaster() {
    return _raycaster;
  }

  // TODO: deprecate

  getMode() {
    return this.mode;
  }

  setMode(mode) {
    this.mode = mode;
  }

  setTranslationSnap(translationSnap) {
    this.translationSnap = translationSnap;
  }

  setRotationSnap(rotationSnap) {
    this.rotationSnap = rotationSnap;
  }

  setScaleSnap(scaleSnap) {
    this.scaleSnap = scaleSnap;
  }

  setSize(size) {
    this.size = size;
  }

  setSpace(space) {
    this.space = space;
  }

  update() {
    print(
        'THREE.TransformControls: update function has no more functionality and therefore has been deprecated.');
  }

  // mouse / touch event handlers
  _getPointer(event) {
    return getPointer(event);
  }

  _onPointerDown(event) {
    return onPointerDown(event);
  }

  _onPointerHover(event) {
    return onPointerHover(event);
  }

  _onPointerMove(event) {
    return onPointerMove(event);
  }

  _onPointerUp(event) {
    return onPointerUp(event);
  }

  getPointer(event) {
    final RenderBox renderBox = domKey.currentContext!.findRenderObject();
    final size = renderBox.size;
    var rect = size;
    int left = 0;
    int top = 0;

    var _x = (event.clientX - left) / rect.width * 2 - 1;
    var _y = -(event.clientY - top) / rect.height * 2 + 1;
    var _button = event.button;

    return Pointer(_x, _y, _button);
  }

  onPointerHover(event) {
    if (!this.enabled) return;

    switch (event.pointerType) {
      case 'mouse':
      case 'pen':
        this.pointerHover(this._getPointer(event));
        break;
    }
  }

  onPointerDown(event) {
    if (!this.enabled) return;

    // this.domElement.setPointerCapture( event.pointerId );

    this.domElement.addEventListener('pointermove', this._onPointerMove);

    this.pointerHover(this._getPointer(event));
    this.pointerDown(this._getPointer(event));
  }

  onPointerMove(event) {
    if (!this.enabled) return;

    this.pointerMove(this._getPointer(event));
  }

  onPointerUp(event) {
    if (!this.enabled) return;

    // this.domElement.releasePointerCapture( event.pointerId );

    this.domElement.removeEventListener('pointermove', this._onPointerMove);

    this.pointerUp(this._getPointer(event));
  }

  intersectObjectWithRay(object, raycaster, includeInvisible) {
    var allIntersections = raycaster.intersectObject(object, true, null);

    for (var i = 0; i < allIntersections.length; i++) {
      if (allIntersections[i].object.visible || includeInvisible) {
        return allIntersections[i];
      }
    }

    return false;
  }
}

class Pointer {
  late double x;
  late double y;
  late int button;
  Pointer(double x, double y, int button) {
    this.x = x;
    this.y = y;
    this.button = button;
  }

  toJSON() {
    return {"x": x, "y": y, "button": button};
  }
}
