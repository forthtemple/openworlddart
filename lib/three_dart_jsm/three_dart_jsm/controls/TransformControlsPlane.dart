part of jsm_controls;

class TransformControlsPlane extends Mesh {
  bool isTransformControlsPlane = true;
  String type = "TransformControlsPlane";

  Camera? camera;
  var object = null;
  bool enabled = true;
  String? axis = null;
  var mode = "translate";
  var space = "world";
  var size = 1;
  bool dragging = false;
  bool showX = true;
  bool showY = true;
  bool showZ = true;

  // var worldPosition = new Vector3();
  // var worldPositionStart = new Vector3();
  // var worldQuaternion = new Quaternion();
  // var worldQuaternionStart = new Quaternion();
  // var cameraPosition = new Vector3();
  // var cameraQuaternion = new Quaternion();
  // var pointStart = new Vector3();
  // var pointEnd = new Vector3();
  // var rotationAxis = new Vector3();
  // num rotationAngle = 0;
  // var eye = new Vector3();

  get eye {
    return controls.eye;
  }

  get cameraPosition {
    return controls.cameraPosition;
  }

  get cameraQuaternion {
    return controls.cameraQuaternion;
  }

  get worldPosition {
    return controls.worldPosition;
  }

  get rotationAngle {
    return controls.rotationAngle;
  }

  get rotationSnap {
    return controls.rotationSnap;
  }

  get translationSnap {
    return controls.translationSnap;
  }

  get scaleSnap {
    return controls.scaleSnap;
  }

  get worldPositionStart {
    return controls.worldPositionStart;
  }

  get worldQuaternion {
    return controls.worldQuaternion;
  }

  get worldQuaternionStart {
    return controls.worldQuaternionStart;
  }

  get pointStart {
    return controls.pointStart;
  }

  get pointEnd {
    return controls.pointEnd;
  }

  get rotationAxis {
    return controls.rotationAxis;
  }

  late TransformControls controls;

  TransformControlsPlane.create(geometry, material)
      : super(geometry, material) {}

  factory TransformControlsPlane(controls) {
    var geometry = PlaneGeometry(100000, 100000, 2, 2);
    var material = MeshBasicMaterial({
      "visible": false,
      "wireframe": true,
      "side": DoubleSide,
      "transparent": true,
      "opacity": 0.1,
      "toneMapped": false
    });

    var tcp = TransformControlsPlane.create(geometry, material);

    tcp.controls = controls;

    return tcp;
  }

  updateMatrixWorld([bool force = false]) {
    var space = this.space;

    this.position.copy(this.worldPosition);

    if (this.mode == 'scale')
      space = 'local'; // scale always oriented to local rotation

    _v1.copy(_unitX).applyQuaternion(
        space == 'local' ? this.worldQuaternion : _identityQuaternion);
    _v2.copy(_unitY).applyQuaternion(
        space == 'local' ? this.worldQuaternion : _identityQuaternion);
    _v3.copy(_unitZ).applyQuaternion(
        space == 'local' ? this.worldQuaternion : _identityQuaternion);

    // Align the plane for current transform mode, axis and space.

    _alignVector.copy(_v2);

    switch (this.mode) {
      case 'translate':
      case 'scale':
        switch (this.axis) {
          case 'X':
            _alignVector.copy(this.eye).cross(_v1);
            _dirVector.copy(_v1).cross(_alignVector);
            break;
          case 'Y':
            _alignVector.copy(this.eye).cross(_v2);
            _dirVector.copy(_v2).cross(_alignVector);
            break;
          case 'Z':
            _alignVector.copy(this.eye).cross(_v3);
            _dirVector.copy(_v3).cross(_alignVector);
            break;
          case 'XY':
            _dirVector.copy(_v3);
            break;
          case 'YZ':
            _dirVector.copy(_v1);
            break;
          case 'XZ':
            _alignVector.copy(_v3);
            _dirVector.copy(_v2);
            break;
          case 'XYZ':
          case 'E':
            _dirVector.set(0, 0, 0);
            break;
        }

        break;
      case 'rotate':
      default:
        // special case for rotate
        _dirVector.set(0, 0, 0);
    }

    if (_dirVector.length() == 0) {
      // If in rotate mode, make the plane parallel to camera
      this.quaternion.copy(this.cameraQuaternion);
    } else {
      _tempMatrix.lookAt(_tempVector.set(0, 0, 0), _dirVector, _alignVector);

      this.quaternion.setFromRotationMatrix(_tempMatrix);
    }

    super.updateMatrixWorld(force);
  }
}
