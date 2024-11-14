part of jsm_controls;

//trackball state
class STATE2 {
  static const int IDLE = 0;
  static const int ROTATE = 1;
  static const int PAN = 2;
  static const int SCALE = 3;
  static const int FOV = 4;
  static const int FOCUS = 5;
  static const int ZROTATE = 6;
  static const int TOUCH_MULTI = 7;
  static const int ANIMATION_FOCUS = 8;
  static const int ANIMATION_ROTATE = 9;
}

class INPUT {
  static const int NONE = 0;
  static const int ONE_FINGER = 1;
  static const int ONE_FINGER_SWITCHED = 2;
  static const int TWO_FINGER = 3;
  static const int MULT_FINGER = 4;
  static const int CURSOR = 5;
}

//cursor center coordinates
Vector2 _center = Vector2(0, 0);

//transformation matrices for gizmos and camera
var _transformation = {'camera': new Matrix4(), 'gizmos': new Matrix4()};

var _gizmoMatrixStateTemp = new Matrix4();
var _cameraMatrixStateTemp = new Matrix4();
var _scalePointTemp = new Vector3();

/**
 *
 * @param {Camera} camera Virtual camera used in the scene
 * @param {HTMLElement} domElement Renderer's dom element
 * @param {Scene} scene The scene to be rendered
 */
class ArcballControls with EventDispatcher {
  Vector3 target = new Vector3();
  var _currentTarget = new Vector3();
  var radiusFactor = 0.67;

  var mouseActions = [];
  var _mouseOp = null;

  //global vectors and matrices that are used in some operations to avoid creating new objects every time (e.g. every time cursor moves)
  var _v2_1 = new Vector2();
  var _v3_1 = new Vector3();
  var _v3_2 = new Vector3();

  var _m4_1 = new Matrix4();
  var _m4_2 = new Matrix4();

  var _quat = new Quaternion();

  //transformation matrices
  var _translationMatrix = new Matrix4(); //matrix for translation operation
  var _rotationMatrix = new Matrix4(); //matrix for rotation operation
  var _scaleMatrix = new Matrix4(); //matrix for scaling operation

  var _rotationAxis = new Vector3(); //axis for rotate operation

  //camera state
  var _cameraMatrixState = new Matrix4();
  var _cameraProjectionState = new Matrix4();

  num _fovState = 1;
  var _upState = new Vector3();
  double _zoomState = 1;
  num _nearPos = 0;
  num _farPos = 0;

  var _gizmoMatrixState = new Matrix4();

  //initial values
  var _up0 = new Vector3();
  double _zoom0 = 1;
  num _fov0 = 0;
  num _initialNear = 0;
  num _nearPos0 = 0;
  num _initialFar = 0;
  num _farPos0 = 0;
  var _cameraMatrixState0 = new Matrix4();
  var _gizmoMatrixState0 = new Matrix4();

  //pointers array
  var _button = -1;
  var _touchStart = [];
  var _touchCurrent = [];
  var _input = INPUT.NONE;

  //two fingers touch interaction
  var _switchSensibility =
      32; //minimum movement to be performed to fire single pan start after the second finger has been released
  var _startFingerDistance = 0; //distance between two fingers
  var _currentFingerDistance = 0;
  var _startFingerRotation = 0; //amount of rotation performed with two fingers
  var _currentFingerRotation = 0;

  //double tap
  var _devPxRatio = 0;
  var _downValid = true;
  var _nclicks = 0;
  var _downEvents = [];
  var _downStart = 0; //pointerDown time
  var _clickStart = 0; //first click time
  var _maxDownTime = 250;
  var _maxInterval = 300;
  var _posThreshold = 24;
  var _movementThreshold = 24;

  //cursor positions
  var _currentCursorPosition = new Vector3();
  var _startCursorPosition = new Vector3();

  //grid
  var _grid = null; //grid to be visualized during pan operation
  var _gridPosition = new Vector3();

  //gizmos
  var _gizmos = new Group();
  var _curvePts = 128;

  //animations
  var _timeStart = -1; //initial time
  dynamic _animationId = -1;

  //focus animation
  var focusAnimationTime = 500; //duration of focus animation in ms

  //rotate animation
  var _timePrev = 0; //time at which previous rotate operation has been detected
  var _timeCurrent =
      0; //time at which current rotate operation has been detected
  num _anglePrev = 0; //angle of previous rotation
  num _angleCurrent = 0; //angle of current rotation
  var _cursorPosPrev =
      new Vector3(); //cursor position when previous rotate operation has been detected
  var _cursorPosCurr =
      new Vector3(); //cursor position when current rotate operation has been detected
  double _wPrev = 0; //angular velocity of the previous rotate operation
  double _wCurr = 0; //angular velocity of the current rotate operation

  //parameters
  var adjustNearFar = false;
  var scaleFactor = 1.1; //zoom/distance multiplier
  var dampingFactor = 25;
  var wMax = 20; //maximum angular velocity allowed
  var enableAnimations = true; //if animations should be performed
  var enableGrid = false; //if grid should be showed during pan operation
  var cursorZoom = false; //if wheel zoom should be cursor centered
  double minFov = 5;
  double maxFov = 90;

  var enabled = true;
  var enablePan = true;
  var enableRotate = true;
  var enableZoom = true;
  var enableGizmos = true;

  double minDistance = 0;
  double maxDistance = Infinity;
  double minZoom = 0;
  double maxZoom = Infinity;

  //trackball parameters
  double _tbRadius = 1;

  late OrbitControls scope;
  late Camera camera;

  late GlobalKey<DomLikeListenableState> listenableKey;
  DomLikeListenableState get domElement => listenableKey.currentState!;

  Scene? scene;
  dynamic _state;

  ArcballControls(camera, listenableKey, [scene = null, devicePixelRatio = 1.0])
      : super() {
    this.camera = camera;
    this.listenableKey = listenableKey;
    this.scene = scene;

    //FSA
    this._state = STATE2.IDLE;

    this.setCamera(camera);

    if (this.scene != null) {
      this.scene!.add(this._gizmos);
    }

    // this.domElement.style.touchAction = 'none';
    this._devPxRatio = devicePixelRatio;

    this.initializeMouseActions();

    this.domElement.addEventListener('contextmenu', this.onContextMenu);
    this.domElement.addEventListener('wheel', this.onWheel);
    this.domElement.addEventListener('pointerdown', this.onPointerDown);
    this.domElement.addEventListener('pointercancel', this.onPointerCancel);

    // window.addEventListener( 'resize', this.onWindowResize );
  }

  //listeners

  onWindowResize() {
    var scale =
        (this._gizmos.scale.x + this._gizmos.scale.y + this._gizmos.scale.z) /
            3;
    this._tbRadius = this.calculateTbRadius(this.camera);

    var newRadius = this._tbRadius / scale;
    var curve = new EllipseCurve(0, 0, newRadius, newRadius);
    var points = curve.getPoints(this._curvePts);
    var curveGeometry = new BufferGeometry().setFromPoints(points);

    for (var gizmo in this._gizmos.children) {
      // this._gizmos.children[ gizmo ].geometry = curveGeometry;
      gizmo.geometry = curveGeometry;
    }

    this.dispatchEvent(_changeEvent);
  }

  onContextMenu(event) {
    if (!this.enabled) {
      return;
    }

    for (var i = 0; i < this.mouseActions.length; i++) {
      if (this.mouseActions[i]['mouse'] == 2) {
        //prevent only if button 2 is actually used
        event.preventDefault();
        break;
      }
    }
  }

  onPointerCancel() {
    this._touchStart.splice(0, this._touchStart.length);
    this._touchCurrent.splice(0, this._touchCurrent.length);
    this._input = INPUT.NONE;
  }

  onPointerDown(event) {
    if (event.button == 0 && event.isPrimary) {
      this._downValid = true;
      this._downEvents.add(event);
      this._downStart = DateTime.now().millisecondsSinceEpoch;
    } else {
      this._downValid = false;
    }

    if (event.pointerType == 'touch' && this._input != INPUT.CURSOR) {
      this._touchStart.add(event);
      this._touchCurrent.add(event);

      switch (this._input) {
        case INPUT.NONE:

          //singleStart
          this._input = INPUT.ONE_FINGER;
          this.onSinglePanStart(event, 'ROTATE');

          domElement.addEventListener('pointermove', this.onPointerMove);
          domElement.addEventListener('pointerup', this.onPointerUp);

          break;

        case INPUT.ONE_FINGER:
        case INPUT.ONE_FINGER_SWITCHED:

          //doubleStart
          this._input = INPUT.TWO_FINGER;

          this.onRotateStart();
          this.onPinchStart();
          this.onDoublePanStart();

          break;

        case INPUT.TWO_FINGER:

          //multipleStart
          this._input = INPUT.MULT_FINGER;
          this.onTriplePanStart(event);
          break;
      }
    } else if (event.pointerType != 'touch' && this._input == INPUT.NONE) {
      var modifier = null;

      if (event.ctrlKey || event.metaKey) {
        modifier = 'CTRL';
      } else if (event.shiftKey) {
        modifier = 'SHIFT';
      }

      this._mouseOp = this.getOpFromAction(event.button, modifier);

      if (this._mouseOp != null) {
        domElement.addEventListener('pointermove', this.onPointerMove);
        domElement.addEventListener('pointerup', this.onPointerUp);

        //singleStart
        this._input = INPUT.CURSOR;
        this._button = event.button;
        this.onSinglePanStart(event, this._mouseOp);
      }
    }
  }

  onPointerMove(event) {
    if (event.pointerType == 'touch' && this._input != INPUT.CURSOR) {
      switch (this._input) {
        case INPUT.ONE_FINGER:

          //singleMove
          this.updateTouchEvent(event);

          this.onSinglePanMove(event, STATE2.ROTATE);
          break;

        case INPUT.ONE_FINGER_SWITCHED:
          var movement =
              this.calculatePointersDistance(this._touchCurrent[0], event) *
                  this._devPxRatio;

          if (movement >= this._switchSensibility) {
            //singleMove
            this._input = INPUT.ONE_FINGER;
            this.updateTouchEvent(event);

            this.onSinglePanStart(event, 'ROTATE');
            break;
          }

          break;

        case INPUT.TWO_FINGER:

          //rotate/pan/pinchMove
          this.updateTouchEvent(event);

          this.onRotateMove();
          this.onPinchMove();
          this.onDoublePanMove();

          break;

        case INPUT.MULT_FINGER:

          //multMove
          this.updateTouchEvent(event);

          this.onTriplePanMove(event);
          break;
      }
    } else if (event.pointerType != 'touch' && this._input == INPUT.CURSOR) {
      var modifier = null;

      if (event.ctrlKey || event.metaKey) {
        modifier = 'CTRL';
      } else if (event.shiftKey) {
        modifier = 'SHIFT';
      }

      var mouseOpState = this.getOpStateFromAction(this._button, modifier);

      if (mouseOpState != null) {
        this.onSinglePanMove(event, mouseOpState);
      }
    }

    //checkDistance
    if (this._downValid) {
      var movement = this.calculatePointersDistance(
              this._downEvents[this._downEvents.length - 1], event) *
          this._devPxRatio;
      if (movement > this._movementThreshold) {
        this._downValid = false;
      }
    }
  }

  onPointerUp(event) {
    if (event.pointerType == 'touch' && this._input != INPUT.CURSOR) {
      var nTouch = this._touchCurrent.length;

      for (var i = 0; i < nTouch; i++) {
        if (this._touchCurrent[i].pointerId == event.pointerId) {
          this._touchCurrent.splice(i, 1);
          this._touchStart.splice(i, 1);
          break;
        }
      }

      switch (this._input) {
        case INPUT.ONE_FINGER:
        case INPUT.ONE_FINGER_SWITCHED:

          //singleEnd
          domElement.removeEventListener('pointermove', this.onPointerMove);
          domElement.removeEventListener('pointerup', this.onPointerUp);

          this._input = INPUT.NONE;
          this.onSinglePanEnd();

          break;

        case INPUT.TWO_FINGER:

          //doubleEnd
          this.onDoublePanEnd(event);
          this.onPinchEnd(event);
          this.onRotateEnd(event);

          //switching to singleStart
          this._input = INPUT.ONE_FINGER_SWITCHED;

          break;

        case INPUT.MULT_FINGER:
          if (this._touchCurrent.length == 0) {
            domElement.removeEventListener('pointermove', this.onPointerMove);
            domElement.removeEventListener('pointerup', this.onPointerUp);

            //multCancel
            this._input = INPUT.NONE;
            this.onTriplePanEnd();
          }

          break;
      }
    } else if (event.pointerType != 'touch' && this._input == INPUT.CURSOR) {
      domElement.removeEventListener('pointermove', this.onPointerMove);
      domElement.removeEventListener('pointerup', this.onPointerUp);

      this._input = INPUT.NONE;
      this.onSinglePanEnd();
      this._button = -1;
    }

    if (event.isPrimary) {
      if (this._downValid) {
        var downTime = event.timeStamp -
            this._downEvents[this._downEvents.length - 1].timeStamp;

        if (downTime <= this._maxDownTime) {
          if (this._nclicks == 0) {
            //first valid click detected
            this._nclicks = 1;
            this._clickStart = DateTime.now().millisecondsSinceEpoch;
          } else {
            var clickInterval = event.timeStamp - this._clickStart;
            var movement = this.calculatePointersDistance(
                    this._downEvents[1], this._downEvents[0]) *
                this._devPxRatio;

            if (clickInterval <= this._maxInterval &&
                movement <= this._posThreshold) {
              //second valid click detected
              //fire double tap and reset values
              this._nclicks = 0;
              this._downEvents.splice(0, this._downEvents.length);
              this.onDoubleTap(event);
            } else {
              //new 'first click'
              this._nclicks = 1;
              this._downEvents.removeAt(0);
              this._clickStart = DateTime.now().millisecondsSinceEpoch;
            }
          }
        } else {
          this._downValid = false;
          this._nclicks = 0;
          this._downEvents.splice(0, this._downEvents.length);
        }
      } else {
        this._nclicks = 0;
        this._downEvents.splice(0, this._downEvents.length);
      }
    }
  }

  onWheel(event) {
    if (this.enabled && this.enableZoom) {
      var modifier = null;

      if (event.ctrlKey || event.metaKey) {
        modifier = 'CTRL';
      } else if (event.shiftKey) {
        modifier = 'SHIFT';
      }

      var mouseOp = this.getOpFromAction('WHEEL', modifier);

      if (mouseOp != null) {
        event.preventDefault();
        this.dispatchEvent(_startEvent);

        var notchDeltaY = 125; //distance of one notch of mouse wheel
        var sgn = event.deltaY / notchDeltaY;

        double size = 1;

        if (sgn > 0) {
          size = 1 / this.scaleFactor;
        } else if (sgn < 0) {
          size = this.scaleFactor;
        }

        switch (mouseOp) {
          case 'ZOOM':
            this.updateTbState(STATE2.SCALE, true);

            if (sgn > 0) {
              size = 1 / (Math.pow(this.scaleFactor, sgn));
            } else if (sgn < 0) {
              size = Math.pow(this.scaleFactor, -sgn) + 0.0;
            }

            if (this.cursorZoom && this.enablePan) {
              var scalePoint;

              if (this.camera is OrthographicCamera) {
                scalePoint = this
                    .unprojectOnTbPlane(this.camera, event.clientX,
                        event.clientY, this.domElement)
                    .applyQuaternion(this.camera.quaternion)
                    .multiplyScalar(1 / this.camera.zoom)
                    .add(this._gizmos.position);
              } else if (this.camera is PerspectiveCamera) {
                scalePoint = this
                    .unprojectOnTbPlane(this.camera, event.clientX,
                        event.clientY, this.domElement)
                    .applyQuaternion(this.camera.quaternion)
                    .add(this._gizmos.position);
              }

              this.applyTransformMatrix(this.scale(size, scalePoint));
            } else {
              this.applyTransformMatrix(
                  this.scale(size, this._gizmos.position));
            }

            if (this._grid != null) {
              this.disposeGrid();
              this.drawGrid();
            }

            this.updateTbState(STATE2.IDLE, false);

            this.dispatchEvent(_changeEvent);
            this.dispatchEvent(_endEvent);

            break;

          case 'FOV':
            if (this.camera is PerspectiveCamera) {
              this.updateTbState(STATE2.FOV, true);

              //Vertigo effect

              //	  fov / 2
              //		|\
              //		| \
              //		|  \
              //	x	|	\
              //		| 	 \
              //		| 	  \
              //		| _ _ _\
              //			y

              //check for iOs shift shortcut
              if (event.deltaX != 0) {
                sgn = event.deltaX / notchDeltaY;

                size = 1;

                if (sgn > 0) {
                  size = 1 / (Math.pow(this.scaleFactor, sgn));
                } else if (sgn < 0) {
                  size = Math.pow(this.scaleFactor, -sgn) + 0.0;
                }
              }

              this._v3_1.setFromMatrixPosition(this._cameraMatrixState);
              var x = this._v3_1.distanceTo(this._gizmos.position);
              var xNew = x /
                  size; //distance between camera and gizmos if scale(size, scalepoint) would be performed

              //check min and max distance
              xNew = MathUtils.clamp(xNew, this.minDistance, this.maxDistance);

              var y = x * Math.tan(MathUtils.DEG2RAD * this.camera.fov * 0.5);

              //calculate new fov
              var newFov = MathUtils.RAD2DEG * (Math.atan(y / xNew) * 2);

              //check min and max fov
              if (newFov > this.maxFov) {
                newFov = this.maxFov;
              } else if (newFov < this.minFov) {
                newFov = this.minFov;
              }

              var newDistance = y / Math.tan(MathUtils.DEG2RAD * (newFov / 2));
              size = x / newDistance;

              this.setFov(newFov);
              this.applyTransformMatrix(
                  this.scale(size, this._gizmos.position, false));
            }

            if (this._grid != null) {
              this.disposeGrid();
              this.drawGrid();
            }

            this.updateTbState(STATE2.IDLE, false);

            this.dispatchEvent(_changeEvent);
            this.dispatchEvent(_endEvent);

            break;
        }
      }
    }
  }

  onSinglePanStart(event, operation) {
    if (this.enabled) {
      this.dispatchEvent(_startEvent);

      this.setCenter(event.clientX, event.clientY);

      switch (operation) {
        case 'PAN':
          if (!this.enablePan) {
            return;
          }

          if (this._animationId != -1) {
            cancelAnimationFrame(this._animationId);
            this._animationId = -1;
            this._timeStart = -1;

            this.activateGizmos(false);
            this.dispatchEvent(_changeEvent);
          }

          this.updateTbState(STATE2.PAN, true);
          this._startCursorPosition.copy(this.unprojectOnTbPlane(
              this.camera, _center.x, _center.y, this.domElement));
          if (this.enableGrid) {
            this.drawGrid();
            this.dispatchEvent(_changeEvent);
          }

          break;

        case 'ROTATE':
          if (!this.enableRotate) {
            return;
          }

          if (this._animationId != -1) {
            cancelAnimationFrame(this._animationId);
            this._animationId = -1;
            this._timeStart = -1;
          }

          this.updateTbState(STATE2.ROTATE, true);
          this._startCursorPosition.copy(this.unprojectOnTbSurface(this.camera,
              _center.x, _center.y, this.listenableKey, this._tbRadius));
          this.activateGizmos(true);
          if (this.enableAnimations) {
            this._timePrev =
                this._timeCurrent = DateTime.now().millisecondsSinceEpoch;
            this._angleCurrent = this._anglePrev = 0;
            this._cursorPosPrev.copy(this._startCursorPosition);
            this._cursorPosCurr.copy(this._cursorPosPrev);
            this._wCurr = 0;
            this._wPrev = this._wCurr;
          }

          this.dispatchEvent(_changeEvent);
          break;

        case 'FOV':
          if (this.camera is! PerspectiveCamera || !this.enableZoom) {
            return;
          }

          if (this._animationId != -1) {
            cancelAnimationFrame(this._animationId);
            this._animationId = -1;
            this._timeStart = -1;

            this.activateGizmos(false);
            this.dispatchEvent(_changeEvent);
          }

          this.updateTbState(STATE2.FOV, true);
          this._startCursorPosition.setY(
              this.getCursorNDC(_center.x, _center.y, this.domElement).y * 0.5);
          this._currentCursorPosition.copy(this._startCursorPosition);
          break;

        case 'ZOOM':
          if (!this.enableZoom) {
            return;
          }

          if (this._animationId != -1) {
            cancelAnimationFrame(this._animationId);
            this._animationId = -1;
            this._timeStart = -1;

            this.activateGizmos(false);
            this.dispatchEvent(_changeEvent);
          }

          this.updateTbState(STATE2.SCALE, true);
          this._startCursorPosition.setY(
              this.getCursorNDC(_center.x, _center.y, this.domElement).y * 0.5);
          this._currentCursorPosition.copy(this._startCursorPosition);
          break;
      }
    }
  }

  onSinglePanMove(event, opState) {
    if (this.enabled) {
      var restart = opState != this._state;
      this.setCenter(event.clientX, event.clientY);

      switch (opState) {
        case STATE2.PAN:
          if (this.enablePan) {
            if (restart) {
              //switch to pan operation

              this.dispatchEvent(_endEvent);
              this.dispatchEvent(_startEvent);

              this.updateTbState(opState, true);
              this._startCursorPosition.copy(this.unprojectOnTbPlane(
                  this.camera, _center.x, _center.y, this.domElement));
              if (this.enableGrid) {
                this.drawGrid();
              }

              this.activateGizmos(false);
            } else {
              //continue with pan operation
              this._currentCursorPosition.copy(this.unprojectOnTbPlane(
                  this.camera, _center.x, _center.y, this.domElement));
              this.applyTransformMatrix(this
                  .pan(this._startCursorPosition, this._currentCursorPosition));
            }
          }

          break;

        case STATE2.ROTATE:
          if (this.enableRotate) {
            if (restart) {
              //switch to rotate operation

              this.dispatchEvent(_endEvent);
              this.dispatchEvent(_startEvent);

              this.updateTbState(opState, true);
              this._startCursorPosition.copy(this.unprojectOnTbSurface(
                  this.camera,
                  _center.x,
                  _center.y,
                  this.listenableKey,
                  this._tbRadius));

              if (this.enableGrid) {
                this.disposeGrid();
              }

              this.activateGizmos(true);
            } else {
              //continue with rotate operation
              this._currentCursorPosition.copy(this.unprojectOnTbSurface(
                  this.camera,
                  _center.x,
                  _center.y,
                  this.listenableKey,
                  this._tbRadius));

              var distance = this
                  ._startCursorPosition
                  .distanceTo(this._currentCursorPosition);
              var angle = this
                  ._startCursorPosition
                  .angleTo(this._currentCursorPosition);
              var amount = Math.max(
                  distance / this._tbRadius, angle); //effective rotation angle

              this.applyTransformMatrix(this.rotate(
                  this.calculateRotationAxis(
                      this._startCursorPosition, this._currentCursorPosition),
                  amount));

              if (this.enableAnimations) {
                this._timePrev = this._timeCurrent;
                this._timeCurrent = DateTime.now().millisecondsSinceEpoch;
                this._anglePrev = this._angleCurrent;
                this._angleCurrent = amount;
                this._cursorPosPrev.copy(this._cursorPosCurr);
                this._cursorPosCurr.copy(this._currentCursorPosition);
                this._wPrev = this._wCurr;
                this._wCurr = this.calculateAngularSpeed(this._anglePrev,
                    this._angleCurrent, this._timePrev, this._timeCurrent);
              }
            }
          }

          break;

        case STATE2.SCALE:
          if (this.enableZoom) {
            if (restart) {
              //switch to zoom operation

              this.dispatchEvent(_endEvent);
              this.dispatchEvent(_startEvent);

              this.updateTbState(opState, true);
              this._startCursorPosition.setY(
                  this.getCursorNDC(_center.x, _center.y, this.domElement).y *
                      0.5);
              this._currentCursorPosition.copy(this._startCursorPosition);

              if (this.enableGrid) {
                this.disposeGrid();
              }

              this.activateGizmos(false);
            } else {
              //continue with zoom operation
              var screenNotches =
                  8; //how many wheel notches corresponds to a full screen pan
              this._currentCursorPosition.setY(
                  this.getCursorNDC(_center.x, _center.y, this.domElement).y *
                      0.5);

              var movement =
                  this._currentCursorPosition.y - this._startCursorPosition.y;

              num size = 1;

              if (movement < 0) {
                size =
                    1 / (Math.pow(this.scaleFactor, -movement * screenNotches));
              } else if (movement > 0) {
                size = Math.pow(this.scaleFactor, movement * screenNotches);
              }

              this.applyTransformMatrix(
                  this.scale(size, this._gizmos.position));
            }
          }

          break;

        case STATE2.FOV:
          if (this.enableZoom && this.camera is PerspectiveCamera) {
            if (restart) {
              //switch to fov operation

              this.dispatchEvent(_endEvent);
              this.dispatchEvent(_startEvent);

              this.updateTbState(opState, true);
              this._startCursorPosition.setY(
                  this.getCursorNDC(_center.x, _center.y, this.domElement).y *
                      0.5);
              this._currentCursorPosition.copy(this._startCursorPosition);

              if (this.enableGrid) {
                this.disposeGrid();
              }

              this.activateGizmos(false);
            } else {
              //continue with fov operation
              var screenNotches =
                  8; //how many wheel notches corresponds to a full screen pan
              this._currentCursorPosition.setY(
                  this.getCursorNDC(_center.x, _center.y, this.domElement).y *
                      0.5);

              var movement =
                  this._currentCursorPosition.y - this._startCursorPosition.y;

              num size = 1;

              if (movement < 0) {
                size =
                    1 / (Math.pow(this.scaleFactor, -movement * screenNotches));
              } else if (movement > 0) {
                size = Math.pow(this.scaleFactor, movement * screenNotches);
              }

              this._v3_1.setFromMatrixPosition(this._cameraMatrixState);
              var x = this._v3_1.distanceTo(this._gizmos.position);
              var xNew = x /
                  size; //distance between camera and gizmos if scale(size, scalepoint) would be performed

              //check min and max distance
              xNew = MathUtils.clamp(xNew, this.minDistance, this.maxDistance);

              var y = x * Math.tan(MathUtils.DEG2RAD * this._fovState * 0.5);

              //calculate new fov
              var newFov = MathUtils.RAD2DEG * (Math.atan(y / xNew) * 2);

              //check min and max fov
              newFov = MathUtils.clamp(newFov, this.minFov, this.maxFov);

              var newDistance = y / Math.tan(MathUtils.DEG2RAD * (newFov / 2));
              size = x / newDistance;
              this._v3_2.setFromMatrixPosition(this._gizmoMatrixState);

              this.setFov(newFov);
              this.applyTransformMatrix(this.scale(size, this._v3_2, false));

              //adjusting distance
              _offset
                  .copy(this._gizmos.position)
                  .sub(this.camera.position)
                  .normalize()
                  .multiplyScalar(newDistance / x);
              this._m4_1.makeTranslation(_offset.x, _offset.y, _offset.z);
            }
          }

          break;
      }

      this.dispatchEvent(_changeEvent);
    }
  }

  onSinglePanEnd() {
    if (this._state == STATE2.ROTATE) {
      if (!this.enableRotate) {
        return;
      }

      if (this.enableAnimations) {
        //perform rotation animation
        var deltaTime =
            (DateTime.now().millisecondsSinceEpoch - this._timeCurrent);
        if (deltaTime < 120) {
          var w = Math.abs((this._wPrev + this._wCurr) / 2);

          var self = this;
          this._animationId = requestAnimationFrame((t) {
            self.updateTbState(STATE2.ANIMATION_ROTATE, true);
            var rotationAxis = self.calculateRotationAxis(
                self._cursorPosPrev, self._cursorPosCurr);

            self.onRotationAnim(t, rotationAxis, Math.min(w, self.wMax));
          });
        } else {
          //cursor has been standing still for over 120 ms since last movement
          this.updateTbState(STATE2.IDLE, false);
          this.activateGizmos(false);
          this.dispatchEvent(_changeEvent);
        }
      } else {
        this.updateTbState(STATE2.IDLE, false);
        this.activateGizmos(false);
        this.dispatchEvent(_changeEvent);
      }
    } else if (this._state == STATE2.PAN || this._state == STATE2.IDLE) {
      this.updateTbState(STATE2.IDLE, false);

      if (this.enableGrid) {
        this.disposeGrid();
      }

      this.activateGizmos(false);
      this.dispatchEvent(_changeEvent);
    }

    this.dispatchEvent(_endEvent);
  }

  onDoubleTap(event) {
    if (this.enabled && this.enablePan && this.scene != null) {
      this.dispatchEvent(_startEvent);

      this.setCenter(event.clientX, event.clientY);
      var hitP = this.unprojectOnObj(
          this.getCursorNDC(_center.x, _center.y, this.domElement),
          this.camera);

      if (hitP != null && this.enableAnimations) {
        var self = this;
        if (this._animationId != -1) {
          cancelAnimationFrame(this._animationId);
        }

        this._timeStart = -1;
        this._animationId = requestAnimationFrame((t) {
          self.updateTbState(STATE2.ANIMATION_FOCUS, true);
          self.onFocusAnim(
              t, hitP, self._cameraMatrixState, self._gizmoMatrixState);
        });
      } else if (hitP != null && !this.enableAnimations) {
        this.updateTbState(STATE2.FOCUS, true);
        this.focus(hitP, this.scaleFactor);
        this.updateTbState(STATE2.IDLE, false);
        this.dispatchEvent(_changeEvent);
      }
    }

    this.dispatchEvent(_endEvent);
  }

  onDoublePanStart() {
    if (this.enabled && this.enablePan) {
      this.dispatchEvent(_startEvent);

      this.updateTbState(STATE2.PAN, true);

      this.setCenter(
          (this._touchCurrent[0].clientX + this._touchCurrent[1].clientX) / 2,
          (this._touchCurrent[0].clientY + this._touchCurrent[1].clientY) / 2);
      this._startCursorPosition.copy(this.unprojectOnTbPlane(
          this.camera, _center.x, _center.y, this.domElement, true));
      this._currentCursorPosition.copy(this._startCursorPosition);

      this.activateGizmos(false);
    }
  }

  onDoublePanMove() {
    if (this.enabled && this.enablePan) {
      this.setCenter(
          (this._touchCurrent[0].clientX + this._touchCurrent[1].clientX) / 2,
          (this._touchCurrent[0].clientY + this._touchCurrent[1].clientY) / 2);

      if (this._state != STATE2.PAN) {
        this.updateTbState(STATE2.PAN, true);
        this._startCursorPosition.copy(this._currentCursorPosition);
      }

      this._currentCursorPosition.copy(this.unprojectOnTbPlane(
          this.camera, _center.x, _center.y, this.domElement, true));
      this.applyTransformMatrix(this
          .pan(this._startCursorPosition, this._currentCursorPosition, true));
      this.dispatchEvent(_changeEvent);
    }
  }

  onDoublePanEnd(event) {
    this.updateTbState(STATE2.IDLE, false);
    this.dispatchEvent(_endEvent);
  }

  onRotateStart() {
    if (this.enabled && this.enableRotate) {
      this.dispatchEvent(_startEvent);

      this.updateTbState(STATE2.ZROTATE, true);

      //this._startFingerRotation = event.rotation;

      this._startFingerRotation =
          this.getAngle(this._touchCurrent[1], this._touchCurrent[0]) +
              this.getAngle(this._touchStart[1], this._touchStart[0]);
      this._currentFingerRotation = this._startFingerRotation;

      this.camera.getWorldDirection(this._rotationAxis); //rotation axis

      if (!this.enablePan && !this.enableZoom) {
        this.activateGizmos(true);
      }
    }
  }

  onRotateMove() {
    if (this.enabled && this.enableRotate) {
      this.setCenter(
          (this._touchCurrent[0].clientX + this._touchCurrent[1].clientX) / 2,
          (this._touchCurrent[0].clientY + this._touchCurrent[1].clientY) / 2);
      var rotationPoint;

      if (this._state != STATE2.ZROTATE) {
        this.updateTbState(STATE2.ZROTATE, true);
        this._startFingerRotation = this._currentFingerRotation;
      }

      //this._currentFingerRotation = event.rotation;
      this._currentFingerRotation =
          this.getAngle(this._touchCurrent[1], this._touchCurrent[0]) +
              this.getAngle(this._touchStart[1], this._touchStart[0]);

      if (!this.enablePan) {
        rotationPoint =
            new Vector3().setFromMatrixPosition(this._gizmoMatrixState);
      } else {
        this._v3_2.setFromMatrixPosition(this._gizmoMatrixState);
        rotationPoint = this
            .unprojectOnTbPlane(
                this.camera, _center.x, _center.y, this.domElement)
            .applyQuaternion(this.camera.quaternion)
            .multiplyScalar(1 / this.camera.zoom)
            .add(this._v3_2);
      }

      var amount = MathUtils.DEG2RAD *
          (this._startFingerRotation - this._currentFingerRotation);

      this.applyTransformMatrix(this.zRotate(rotationPoint, amount));
      this.dispatchEvent(_changeEvent);
    }
  }

  onRotateEnd(event) {
    this.updateTbState(STATE2.IDLE, false);
    this.activateGizmos(false);
    this.dispatchEvent(_endEvent);
  }

  onPinchStart() {
    if (this.enabled && this.enableZoom) {
      this.dispatchEvent(_startEvent);
      this.updateTbState(STATE2.SCALE, true);

      this._startFingerDistance = this.calculatePointersDistance(
          this._touchCurrent[0], this._touchCurrent[1]);
      this._currentFingerDistance = this._startFingerDistance;

      this.activateGizmos(false);
    }
  }

  onPinchMove() {
    if (this.enabled && this.enableZoom) {
      this.setCenter(
          (this._touchCurrent[0].clientX + this._touchCurrent[1].clientX) / 2,
          (this._touchCurrent[0].clientY + this._touchCurrent[1].clientY) / 2);
      var minDistance = 12; //minimum distance between fingers (in css pixels)

      if (this._state != STATE2.SCALE) {
        this._startFingerDistance = this._currentFingerDistance;
        this.updateTbState(STATE2.SCALE, true);
      }

      this._currentFingerDistance = Math.max(
          this.calculatePointersDistance(
              this._touchCurrent[0], this._touchCurrent[1]),
          minDistance * this._devPxRatio);
      var amount = this._currentFingerDistance / this._startFingerDistance;

      var scalePoint;

      if (!this.enablePan) {
        scalePoint = this._gizmos.position;
      } else {
        if (this.camera is OrthographicCamera) {
          scalePoint = this
              .unprojectOnTbPlane(
                  this.camera, _center.x, _center.y, this.domElement)
              .applyQuaternion(this.camera.quaternion)
              .multiplyScalar(1 / this.camera.zoom)
              .add(this._gizmos.position);
        } else if (this.camera is PerspectiveCamera) {
          scalePoint = this
              .unprojectOnTbPlane(
                  this.camera, _center.x, _center.y, this.domElement)
              .applyQuaternion(this.camera.quaternion)
              .add(this._gizmos.position);
        }
      }

      this.applyTransformMatrix(this.scale(amount, scalePoint));
      this.dispatchEvent(_changeEvent);
    }
  }

  onPinchEnd(event) {
    this.updateTbState(STATE2.IDLE, false);
    this.dispatchEvent(_endEvent);
  }

  onTriplePanStart(event) {
    if (this.enabled && this.enableZoom) {
      this.dispatchEvent(_startEvent);

      this.updateTbState(STATE2.SCALE, true);

      //var center = event.center;
      num clientX = 0;
      num clientY = 0;
      var nFingers = this._touchCurrent.length;

      for (var i = 0; i < nFingers; i++) {
        clientX += this._touchCurrent[i]!.clientX;
        clientY += this._touchCurrent[i]!.clientY;
      }

      this.setCenter(clientX / nFingers, clientY / nFingers);

      this._startCursorPosition.setY(
          this.getCursorNDC(_center.x, _center.y, this.domElement).y * 0.5);
      this._currentCursorPosition.copy(this._startCursorPosition);
    }
  }

  onTriplePanMove(event) {
    if (this.enabled && this.enableZoom) {
      //	  fov / 2
      //		|\
      //		| \
      //		|  \
      //	x	|	\
      //		| 	 \
      //		| 	  \
      //		| _ _ _\
      //			y

      //var center = event.center;
      num clientX = 0;
      num clientY = 0;
      var nFingers = this._touchCurrent.length;

      for (var i = 0; i < nFingers; i++) {
        clientX += this._touchCurrent[i].clientX;
        clientY += this._touchCurrent[i].clientY;
      }

      this.setCenter(clientX / nFingers, clientY / nFingers);

      var screenNotches =
          8; //how many wheel notches corresponds to a full screen pan
      this._currentCursorPosition.setY(
          this.getCursorNDC(_center.x, _center.y, this.domElement).y * 0.5);

      var movement =
          this._currentCursorPosition.y - this._startCursorPosition.y;

      num size = 1;

      if (movement < 0) {
        size = 1 / (Math.pow(this.scaleFactor, -movement * screenNotches));
      } else if (movement > 0) {
        size = Math.pow(this.scaleFactor, movement * screenNotches);
      }

      this._v3_1.setFromMatrixPosition(this._cameraMatrixState);
      var x = this._v3_1.distanceTo(this._gizmos.position);
      var xNew = x /
          size; //distance between camera and gizmos if scale(size, scalepoint) would be performed

      //check min and max distance
      xNew = MathUtils.clamp(xNew, this.minDistance, this.maxDistance);

      var y = x * Math.tan(MathUtils.DEG2RAD * this._fovState * 0.5);

      //calculate new fov
      var newFov = MathUtils.RAD2DEG * (Math.atan(y / xNew) * 2);

      //check min and max fov
      newFov = MathUtils.clamp(newFov, this.minFov, this.maxFov);

      var newDistance = y / Math.tan(MathUtils.DEG2RAD * (newFov / 2));
      size = x / newDistance;
      this._v3_2.setFromMatrixPosition(this._gizmoMatrixState);

      this.setFov(newFov);
      this.applyTransformMatrix(this.scale(size, this._v3_2, false));

      //adjusting distance
      _offset
          .copy(this._gizmos.position)
          .sub(this.camera.position)
          .normalize()
          .multiplyScalar(newDistance / x);
      this._m4_1.makeTranslation(_offset.x, _offset.y, _offset.z);

      this.dispatchEvent(_changeEvent);
    }
  }

  onTriplePanEnd() {
    this.updateTbState(STATE2.IDLE, false);
    this.dispatchEvent(_endEvent);
    //this.dispatchEvent( _changeEvent );
  }

  /**
	 * Set _center's x/y coordinates
	 * @param {Number} clientX
	 * @param {Number} clientY
	 */
  setCenter(clientX, clientY) {
    _center.x = clientX;
    _center.y = clientY;
  }

  /**
	 * Set default mouse actions
	 */
  initializeMouseActions() {
    this.setMouseAction('PAN', 0, 'CTRL');
    this.setMouseAction('PAN', 2);

    this.setMouseAction('ROTATE', 0);

    this.setMouseAction('ZOOM', 'WHEEL');
    this.setMouseAction('ZOOM', 1);

    this.setMouseAction('FOV', 'WHEEL', 'SHIFT');
    this.setMouseAction('FOV', 1, 'SHIFT');
  }

  /**
	 * Compare two mouse actions
	 * @param {Object} action1
	 * @param {Object} action2
	 * @returns {Boolean} True if action1 and action 2 are the same mouse action, false otherwise
	 */
  compareMouseAction(action1, action2) {
    if (action1['operation'] == action2['operation']) {
      if (action1['mouse'] == action2['mouse'] &&
          action1['key'] == action2['key']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /**
	 * Set a new mouse action by specifying the operation to be performed and a mouse/key combination. In case of conflict, replaces the existing one
	 * @param {String} operation The operation to be performed ('PAN', 'ROTATE', 'ZOOM', 'FOV)
	 * @param {*} mouse A mouse button (0, 1, 2) or 'WHEEL' for wheel notches
	 * @param {*} key The keyboard modifier ('CTRL', 'SHIFT') or null if key is not needed
	 * @returns {Boolean} True if the mouse action has been successfully added, false otherwise
	 */
  setMouseAction(operation, mouse, [key = null]) {
    var operationInput = ['PAN', 'ROTATE', 'ZOOM', 'FOV'];
    var mouseInput = ['0', '1', '2', 'WHEEL'];
    var keyInput = ['CTRL', 'SHIFT', null];
    var state;

    if (!operationInput.contains(operation) ||
        !mouseInput.contains(mouse.toString()) ||
        !keyInput.contains(key)) {
      //invalid parameters
      return false;
    }

    if (mouse == 'WHEEL') {
      if (operation != 'ZOOM' && operation != 'FOV') {
        //cannot associate 2D operation to 1D input
        return false;
      }
    }

    switch (operation) {
      case 'PAN':
        state = STATE2.PAN;
        break;

      case 'ROTATE':
        state = STATE2.ROTATE;
        break;

      case 'ZOOM':
        state = STATE2.SCALE;
        break;

      case 'FOV':
        state = STATE2.FOV;
        break;
    }

    var action = {
      'operation': operation,
      'mouse': mouse,
      'key': key,
      'state': state
    };

    for (var i = 0; i < this.mouseActions.length; i++) {
      if (this.mouseActions[i]['mouse'] == action['mouse'] &&
          this.mouseActions[i]['key'] == action['key']) {
        this.mouseActions.splice(i, 1, action);
        return true;
      }
    }

    this.mouseActions.add(action);
    return true;
  }

  /**
	 * Remove a mouse action by specifying its mouse/key combination
	 * @param {*} mouse A mouse button (0, 1, 2) or 'WHEEL' for wheel notches
	 * @param {*} key The keyboard modifier ('CTRL', 'SHIFT') or null if key is not needed
	 * @returns {Boolean} True if the operation has been succesfully removed, false otherwise
	 */
  unsetMouseAction(mouse, [key = null]) {
    for (var i = 0; i < this.mouseActions.length; i++) {
      if (this.mouseActions[i]['mouse'] == mouse &&
          this.mouseActions[i]['key'] == key) {
        this.mouseActions.splice(i, 1);
        return true;
      }
    }

    return false;
  }

  /**
	 * Return the operation associated to a mouse/keyboard combination
	 * @param {*} mouse A mouse button (0, 1, 2) or 'WHEEL' for wheel notches
	 * @param {*} key The keyboard modifier ('CTRL', 'SHIFT') or null if key is not needed
	 * @returns The operation if it has been found, null otherwise
	 */
  getOpFromAction(mouse, key) {
    var action;

    for (var i = 0; i < this.mouseActions.length; i++) {
      action = this.mouseActions[i];
      if (action['mouse'] == mouse && action['key'] == key) {
        return action['operation'];
      }
    }

    if (key != null) {
      for (var i = 0; i < this.mouseActions.length; i++) {
        action = this.mouseActions[i];
        if (action['mouse'] == mouse && action['key'] == null) {
          return action['operation'];
        }
      }
    }

    return null;
  }

  /**
	 * Get the operation associated to mouse and key combination and returns the corresponding FSA state
	 * @param {Number} mouse Mouse button
	 * @param {String} key Keyboard modifier
	 * @returns The FSA state obtained from the operation associated to mouse/keyboard combination
	 */
  getOpStateFromAction(mouse, key) {
    var action;

    for (var i = 0; i < this.mouseActions.length; i++) {
      action = this.mouseActions[i];
      if (action['mouse'] == mouse && action['key'] == key) {
        return action['state'];
      }
    }

    if (key != null) {
      for (var i = 0; i < this.mouseActions.length; i++) {
        action = this.mouseActions[i];
        if (action['mouse'] == mouse && action['key'] == null) {
          return action['state'];
        }
      }
    }

    return null;
  }

  /**
	 * Calculate the angle between two pointers
	 * @param {PointerEvent} p1
	 * @param {PointerEvent} p2
	 * @returns {Number} The angle between two pointers in degrees
	 */
  getAngle(p1, p2) {
    return Math.atan2(p2.clientY - p1.clientY, p2.clientX - p1.clientX) *
        180 /
        Math.PI;
  }

  /**
	 * Update a PointerEvent inside current pointerevents array
	 * @param {PointerEvent} event
	 */
  updateTouchEvent(event) {
    for (var i = 0; i < this._touchCurrent.length; i++) {
      if (this._touchCurrent[i].pointerId == event.pointerId) {
        this._touchCurrent.splice(i, 1, event);
        break;
      }
    }
  }

  /**
	 * Apply a transformation matrix, to the camera and gizmos
	 * @param {Object} transformation Object containing matrices to apply to camera and gizmos
	 */
  applyTransformMatrix(transformation) {
    if (transformation['camera'] != null) {
      this
          ._m4_1
          .copy(this._cameraMatrixState)
          .premultiply(transformation['camera']);
      this._m4_1.decompose(
          this.camera.position, this.camera.quaternion, this.camera.scale);
      this.camera.updateMatrix();

      //update camera up vector
      if (this._state == STATE2.ROTATE ||
          this._state == STATE2.ZROTATE ||
          this._state == STATE2.ANIMATION_ROTATE) {
        this
            .camera
            .up
            .copy(this._upState)
            .applyQuaternion(this.camera.quaternion);
      }
    }

    if (transformation['gizmos'] != null) {
      this
          ._m4_1
          .copy(this._gizmoMatrixState)
          .premultiply(transformation['gizmos']);
      this._m4_1.decompose(
          this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);
      this._gizmos.updateMatrix();
    }

    if (this._state == STATE2.SCALE ||
        this._state == STATE2.FOCUS ||
        this._state == STATE2.ANIMATION_FOCUS) {
      this._tbRadius = this.calculateTbRadius(this.camera);

      if (this.adjustNearFar) {
        var cameraDistance =
            this.camera.position.distanceTo(this._gizmos.position);

        var bb = new Box3();
        bb.setFromObject(this._gizmos);
        var sphere = new Sphere();
        bb.getBoundingSphere(sphere);

        var adjustedNearPosition =
            Math.max(this._nearPos0, sphere.radius + sphere.center.length());
        var regularNearPosition = cameraDistance - this._initialNear;

        var minNearPos = Math.min(adjustedNearPosition, regularNearPosition);
        this.camera.near = cameraDistance - minNearPos;

        var adjustedFarPosition =
            Math.min(this._farPos0, -sphere.radius + sphere.center.length());
        var regularFarPosition = cameraDistance - this._initialFar;

        var minFarPos = Math.min(adjustedFarPosition, regularFarPosition);
        this.camera.far = cameraDistance - minFarPos;

        this.camera.updateProjectionMatrix();
      } else {
        var update = false;

        if (this.camera.near != this._initialNear) {
          this.camera.near = this._initialNear;
          update = true;
        }

        if (this.camera.far != this._initialFar) {
          this.camera.far = this._initialFar;
          update = true;
        }

        if (update) {
          this.camera.updateProjectionMatrix();
        }
      }
    }
  }

  /**
	 * Calculate the angular speed
	 * @param {Number} p0 Position at t0
	 * @param {Number} p1 Position at t1
	 * @param {Number} t0 Initial time in milliseconds
	 * @param {Number} t1 Ending time in milliseconds
	 */
  calculateAngularSpeed(p0, p1, t0, t1) {
    var s = p1 - p0;
    var t = (t1 - t0) / 1000;
    if (t == 0) {
      return 0;
    }

    return s / t;
  }

  /**
	 * Calculate the distance between two pointers
	 * @param {PointerEvent} p0 The first pointer
	 * @param {PointerEvent} p1 The second pointer
	 * @returns {number} The distance between the two pointers
	 */
  calculatePointersDistance(p0, p1) {
    return Math.sqrt(Math.pow(p1.clientX - p0.clientX, 2) +
        Math.pow(p1.clientY - p0.clientY, 2));
  }

  /**
	 * Calculate the rotation axis as the vector perpendicular between two vectors
	 * @param {Vector3} vec1 The first vector
	 * @param {Vector3} vec2 The second vector
	 * @returns {Vector3} The normalized rotation axis
	 */
  calculateRotationAxis(vec1, vec2) {
    this._rotationMatrix.extractRotation(this._cameraMatrixState);
    this._quat.setFromRotationMatrix(this._rotationMatrix);

    this._rotationAxis.crossVectors(vec1, vec2).applyQuaternion(this._quat);
    return this._rotationAxis.normalize().clone();
  }

  /**
	 * Calculate the trackball radius so that gizmo's diamater will be 2/3 of the minimum side of the camera frustum
	 * @param {Camera} camera
	 * @returns {Number} The trackball radius
	 */
  calculateTbRadius(Camera camera) {
    var distance = camera.position.distanceTo(this._gizmos.position);

    if (camera is PerspectiveCamera) {
      var halfFovV =
          MathUtils.DEG2RAD * camera.fov * 0.5; //vertical fov/2 in radians
      var halfFovH = Math.atan(
          (camera.aspect) * Math.tan(halfFovV)); //horizontal fov/2 in radians
      return Math.tan(Math.min(halfFovV, halfFovH)) *
          distance *
          this.radiusFactor;
    } else if (camera is OrthographicCamera) {
      return Math.min(camera.top, camera.right) * this.radiusFactor;
    }
  }

  /**
	 * Focus operation consist of positioning the point of interest in front of the camera and a slightly zoom in
	 * @param {Vector3} point The point of interest
	 * @param {Number} size Scale factor
	 * @param {Number} amount Amount of operation to be completed (used for focus animations, default is complete full operation)
	 */
  focus(point, size, [amount = 1]) {
    //move center of camera (along with gizmos) towards point of interest
    _offset.copy(point).sub(this._gizmos.position).multiplyScalar(amount);
    this._translationMatrix.makeTranslation(_offset.x, _offset.y, _offset.z);

    _gizmoMatrixStateTemp.copy(this._gizmoMatrixState);
    this._gizmoMatrixState.premultiply(this._translationMatrix);
    this._gizmoMatrixState.decompose(
        this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);

    _cameraMatrixStateTemp.copy(this._cameraMatrixState);
    this._cameraMatrixState.premultiply(this._translationMatrix);
    this._cameraMatrixState.decompose(
        this.camera.position, this.camera.quaternion, this.camera.scale);

    //apply zoom
    if (this.enableZoom) {
      this.applyTransformMatrix(this.scale(size, this._gizmos.position));
    }

    this._gizmoMatrixState.copy(_gizmoMatrixStateTemp);
    this._cameraMatrixState.copy(_cameraMatrixStateTemp);
  }

  /**
	 * Draw a grid and add it to the scene
	 */
  drawGrid() {
    if (this.scene != null) {
      var color = 0x888888;
      var multiplier = 3;
      var size, divisions, maxLength, tick;

      if (this.camera is OrthographicCamera) {
        var width = this.camera.right - this.camera.left;
        var height = this.camera.bottom - this.camera.top;

        maxLength = Math.max(width, height);
        tick = maxLength / 20;

        size = maxLength / this.camera.zoom * multiplier;
        divisions = size / tick * this.camera.zoom;
      } else if (this.camera is PerspectiveCamera) {
        var distance = this.camera.position.distanceTo(this._gizmos.position);
        var halfFovV = MathUtils.DEG2RAD * this.camera.fov * 0.5;
        var halfFovH = Math.atan((this.camera.aspect) * Math.tan(halfFovV));

        maxLength = Math.tan(Math.max(halfFovV, halfFovH)) * distance * 2;
        tick = maxLength / 20;

        size = maxLength * multiplier;
        divisions = size / tick;
      }

      if (this._grid == null) {
        this._grid = new GridHelper(size, divisions, color, color);
        this._grid.position.copy(this._gizmos.position);
        this._gridPosition.copy(this._grid.position);
        this._grid.quaternion.copy(this.camera.quaternion);
        this._grid.rotateX(Math.PI * 0.5);

        this.scene!.add(this._grid);
      }
    }
  }

  /**
	 * Remove all listeners, stop animations and clean scene
	 */
  dispose() {
    if (this._animationId != -1) {
      cancelAnimationFrame(this._animationId);
    }

    this.domElement.removeEventListener('pointerdown', this.onPointerDown);
    this.domElement.removeEventListener('pointercancel', this.onPointerCancel);
    this.domElement.removeEventListener('wheel', this.onWheel);
    this.domElement.removeEventListener('contextmenu', this.onContextMenu);

    domElement.removeEventListener('pointermove', this.onPointerMove);
    domElement.removeEventListener('pointerup', this.onPointerUp);

    domElement.removeEventListener('resize', this.onWindowResize);

    if (this.scene != null) this.scene!.remove(this._gizmos);
    this.disposeGrid();
  }

  /**
	 * remove the grid from the scene
	 */
  disposeGrid() {
    if (this._grid != null && this.scene != null) {
      this.scene!.remove(this._grid);
      this._grid = null;
    }
  }

  /**
	 * Compute the easing out cubic function for ease out effect in animation
	 * @param {Number} t The absolute progress of the animation in the bound of 0 (beginning of the) and 1 (ending of animation)
	 * @returns {Number} Result of easing out cubic at time t
	 */
  easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
  }

  /**
	 * Make rotation gizmos more or less visible
	 * @param {Boolean} isActive If true, make gizmos more visible
	 */
  activateGizmos(isActive) {
    var gizmoX = this._gizmos.children[0];
    var gizmoY = this._gizmos.children[1];
    var gizmoZ = this._gizmos.children[2];

    if (isActive) {
      gizmoX.material.setValues({'opacity': 1});
      gizmoY.material.setValues({'opacity': 1});
      gizmoZ.material.setValues({'opacity': 1});
    } else {
      gizmoX.material.setValues({'opacity': 0.6});
      gizmoY.material.setValues({'opacity': 0.6});
      gizmoZ.material.setValues({'opacity': 0.6});
    }
  }

  /**
	 * Calculate the cursor position in NDC
	 * @param {number} x Cursor horizontal coordinate within the canvas
	 * @param {number} y Cursor vertical coordinate within the canvas
	 * @param {HTMLElement} canvas The canvas where the renderer draws its output
	 * @returns {Vector2} Cursor normalized position inside the canvas
	 */
  getCursorNDC(cursorX, cursorY, canvas) {
    // var canvasRect = canvas.getBoundingClientRect();

    var box = listenableKey.currentContext!.findRenderObject() as RenderBox;
    var canvasRect = box.size;
    var local = box.globalToLocal(Offset(0, 0));

    this._v2_1.setX(((cursorX - local.dx) / canvasRect.width) * 2 - 1);
    this._v2_1.setY(
        (((local.dy + canvasRect.height) - cursorY) / canvasRect.height) * 2 -
            1);
    return this._v2_1.clone();
  }

  /**
	 * Calculate the cursor position inside the canvas x/y coordinates with the origin being in the center of the canvas
	 * @param {Number} x Cursor horizontal coordinate within the canvas
	 * @param {Number} y Cursor vertical coordinate within the canvas
	 * @param {HTMLElement} canvas The canvas where the renderer draws its output
	 * @returns {Vector2} Cursor position inside the canvas
	 */
  getCursorPosition(cursorX, cursorY, canvas) {
    this._v2_1.copy(this.getCursorNDC(cursorX, cursorY, canvas));
    this._v2_1.x *= (this.camera.right - this.camera.left) * 0.5;
    this._v2_1.y *= (this.camera.top - this.camera.bottom) * 0.5;
    return this._v2_1.clone();
  }

  /**
	 * Set the camera to be controlled
	 * @param {Camera} camera The virtual camera to be controlled
	 */
  setCamera(camera) {
    camera.lookAt(this.target);
    camera.updateMatrix();

    //setting state
    if (camera.type == 'PerspectiveCamera') {
      this._fov0 = camera.fov;
      this._fovState = camera.fov;
    }

    this._cameraMatrixState0.copy(camera.matrix);
    this._cameraMatrixState.copy(this._cameraMatrixState0);
    this._cameraProjectionState.copy(camera.projectionMatrix);
    this._zoom0 = camera.zoom;
    this._zoomState = this._zoom0;

    this._initialNear = camera.near;
    this._nearPos0 = camera.position.distanceTo(this.target) - camera.near;
    this._nearPos = this._initialNear;

    this._initialFar = camera.far;
    this._farPos0 = camera.position.distanceTo(this.target) - camera.far;
    this._farPos = this._initialFar;

    this._up0.copy(camera.up);
    this._upState.copy(camera.up);

    this.camera = camera;
    this.camera.updateProjectionMatrix();

    //making gizmos
    this._tbRadius = this.calculateTbRadius(camera);
    this.makeGizmos(this.target, this._tbRadius);
  }

  /**
	 * Set gizmos visibility
	 * @param {Boolean} value Value of gizmos visibility
	 */
  setGizmosVisible(value) {
    this._gizmos.visible = value;
    this.dispatchEvent(_changeEvent);
  }

  /**
	 * Set gizmos radius factor and redraws gizmos
	 * @param {Float} value Value of radius factor
	 */
  setTbRadius(value) {
    this.radiusFactor = value;
    this._tbRadius = this.calculateTbRadius(this.camera);

    var curve = new EllipseCurve(0, 0, this._tbRadius, this._tbRadius);
    var points = curve.getPoints(this._curvePts);
    var curveGeometry = new BufferGeometry().setFromPoints(points);

    for (var gizmo in this._gizmos.children) {
      // this._gizmos.children[ gizmo ].geometry = curveGeometry;
      gizmo.geometry = curveGeometry;
    }

    this.dispatchEvent(_changeEvent);
  }

  /**
	 * Creates the rotation gizmos matching trackball center and radius
	 * @param {Vector3} tbCenter The trackball center
	 * @param {number} tbRadius The trackball radius
	 */
  makeGizmos(tbCenter, tbRadius) {
    var curve = new EllipseCurve(0, 0, tbRadius, tbRadius);
    var points = curve.getPoints(this._curvePts);

    //geometry
    var curveGeometry = new BufferGeometry().setFromPoints(points);

    //material
    var curveMaterialX = new LineBasicMaterial(
        {'color': 0xff8080, 'fog': false, 'transparent': true, 'opacity': 0.6});
    var curveMaterialY = new LineBasicMaterial(
        {'color': 0x80ff80, 'fog': false, 'transparent': true, 'opacity': 0.6});
    var curveMaterialZ = new LineBasicMaterial(
        {'color': 0x8080ff, 'fog': false, 'transparent': true, 'opacity': 0.6});

    //line
    var gizmoX = new Line(curveGeometry, curveMaterialX);
    var gizmoY = new Line(curveGeometry, curveMaterialY);
    var gizmoZ = new Line(curveGeometry, curveMaterialZ);

    var rotation = Math.PI * 0.5;
    gizmoX.rotation.x = rotation;
    gizmoY.rotation.y = rotation;

    //setting state
    this
        ._gizmoMatrixState0
        .identity()
        .setPosition(tbCenter.x, tbCenter.y, tbCenter.z);
    this._gizmoMatrixState.copy(this._gizmoMatrixState0);

    if (this.camera.zoom != 1) {
      //adapt gizmos size to camera zoom
      var size = 1 / this.camera.zoom;
      this._scaleMatrix.makeScale(size, size, size);
      this
          ._translationMatrix
          .makeTranslation(-tbCenter.x, -tbCenter.y, -tbCenter.z);

      this
          ._gizmoMatrixState
          .premultiply(this._translationMatrix)
          .premultiply(this._scaleMatrix);
      this
          ._translationMatrix
          .makeTranslation(tbCenter.x, tbCenter.y, tbCenter.z);
      this._gizmoMatrixState.premultiply(this._translationMatrix);
    }

    this._gizmoMatrixState.decompose(
        this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);

    this._gizmos.clear();

    this._gizmos.add(gizmoX);
    this._gizmos.add(gizmoY);
    this._gizmos.add(gizmoZ);
  }

  /**
	 * Perform animation for focus operation
	 * @param {Number} time Instant in which this function is called as performance.now()
	 * @param {Vector3} point Point of interest for focus operation
	 * @param {Matrix4} cameraMatrix Camera matrix
	 * @param {Matrix4} gizmoMatrix Gizmos matrix
	 */
  onFocusAnim(time, point, cameraMatrix, gizmoMatrix) {
    if (this._timeStart == -1) {
      //animation start
      this._timeStart = time;
    }

    if (this._state == STATE2.ANIMATION_FOCUS) {
      var deltaTime = time - this._timeStart;
      var animTime = deltaTime / this.focusAnimationTime;

      this._gizmoMatrixState.copy(gizmoMatrix);

      if (animTime >= 1) {
        //animation end

        this._gizmoMatrixState.decompose(
            this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);

        this.focus(point, this.scaleFactor);

        this._timeStart = -1;
        this.updateTbState(STATE2.IDLE, false);
        this.activateGizmos(false);

        this.dispatchEvent(_changeEvent);
      } else {
        var amount = this.easeOutCubic(animTime);
        var size = ((1 - amount) + (this.scaleFactor * amount));

        this._gizmoMatrixState.decompose(
            this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);
        this.focus(point, size, amount);

        this.dispatchEvent(_changeEvent);
        var self = this;
        this._animationId = requestAnimationFrame((t) {
          self.onFocusAnim(t, point, cameraMatrix, gizmoMatrix.clone());
        });
      }
    } else {
      //interrupt animation

      this._animationId = -1;
      this._timeStart = -1;
    }
  }

  /**
	 * Perform animation for rotation operation
	 * @param {Number} time Instant in which this function is called as performance.now()
	 * @param {Vector3} rotationAxis Rotation axis
	 * @param {number} w0 Initial angular velocity
	 */
  onRotationAnim(time, rotationAxis, w0) {
    if (this._timeStart == -1) {
      //animation start
      this._anglePrev = 0;
      this._angleCurrent = 0;
      this._timeStart = time;
    }

    if (this._state == STATE2.ANIMATION_ROTATE) {
      //w = w0 + alpha * t
      var deltaTime = (time - this._timeStart) / 1000;
      var w = w0 + ((-this.dampingFactor) * deltaTime);

      if (w > 0) {
        //tetha = 0.5 * alpha * t^2 + w0 * t + tetha0
        this._angleCurrent =
            0.5 * (-this.dampingFactor) * Math.pow(deltaTime, 2) +
                w0 * deltaTime +
                0;
        this.applyTransformMatrix(
            this.rotate(rotationAxis, this._angleCurrent));
        this.dispatchEvent(_changeEvent);
        var self = this;
        this._animationId = requestAnimationFrame((t) {
          self.onRotationAnim(t, rotationAxis, w0);
        });
      } else {
        this._animationId = -1;
        this._timeStart = -1;

        this.updateTbState(STATE2.IDLE, false);
        this.activateGizmos(false);

        this.dispatchEvent(_changeEvent);
      }
    } else {
      //interrupt animation

      this._animationId = -1;
      this._timeStart = -1;

      if (this._state != STATE2.ROTATE) {
        this.activateGizmos(false);
        this.dispatchEvent(_changeEvent);
      }
    }
  }

  /**
	 * Perform pan operation moving camera between two points
	 * @param {Vector3} p0 Initial point
	 * @param {Vector3} p1 Ending point
	 * @param {Boolean} adjust If movement should be adjusted considering camera distance (Perspective only)
	 */
  pan(p0, p1, [adjust = false]) {
    var movement = p0.clone().sub(p1);

    if (this.camera is OrthographicCamera) {
      //adjust movement amount
      movement.multiplyScalar(1 / this.camera.zoom);
    } else if (this.camera is PerspectiveCamera && adjust) {
      //adjust movement amount
      this._v3_1.setFromMatrixPosition(
          this._cameraMatrixState0); //camera's initial position
      this._v3_2.setFromMatrixPosition(
          this._gizmoMatrixState0); //gizmo's initial position
      var distanceFactor = this._v3_1.distanceTo(this._v3_2) /
          this.camera.position.distanceTo(this._gizmos.position);
      movement.multiplyScalar(1 / distanceFactor);
    }

    this
        ._v3_1
        .set(movement.x, movement.y, 0)
        .applyQuaternion(this.camera.quaternion);

    this._m4_1.makeTranslation(this._v3_1.x, this._v3_1.y, this._v3_1.z);

    this.setTransformationMatrices(this._m4_1, this._m4_1);
    return _transformation;
  }

  /**
	 * Reset trackball
	 */
  reset() {
    this.camera.zoom = this._zoom0;

    if (this.camera is PerspectiveCamera) {
      this.camera.fov = this._fov0;
    }

    this.camera.near = this._nearPos;
    this.camera.far = this._farPos;
    this._cameraMatrixState.copy(this._cameraMatrixState0);
    this._cameraMatrixState.decompose(
        this.camera.position, this.camera.quaternion, this.camera.scale);
    this.camera.up.copy(this._up0);

    this.camera.updateMatrix();
    this.camera.updateProjectionMatrix();

    this._gizmoMatrixState.copy(this._gizmoMatrixState0);
    this._gizmoMatrixState0.decompose(
        this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale);
    this._gizmos.updateMatrix();

    this._tbRadius = this.calculateTbRadius(this.camera);
    this.makeGizmos(this._gizmos.position, this._tbRadius);

    this.camera.lookAt(this._gizmos.position);

    this.updateTbState(STATE2.IDLE, false);

    this.dispatchEvent(_changeEvent);
  }

  /**
	 * Rotate the camera around an axis passing by trackball's center
	 * @param {Vector3} axis Rotation axis
	 * @param {number} angle Angle in radians
	 * @returns {Object} Object with 'camera' field containing transformation matrix resulting from the operation to be applied to the camera
	 */
  rotate(axis, angle) {
    var point = this._gizmos.position; //rotation center
    this._translationMatrix.makeTranslation(-point.x, -point.y, -point.z);
    this._rotationMatrix.makeRotationAxis(axis, -angle);

    //rotate camera
    this._m4_1.makeTranslation(point.x, point.y, point.z);
    this._m4_1.multiply(this._rotationMatrix);
    this._m4_1.multiply(this._translationMatrix);

    this.setTransformationMatrices(this._m4_1);

    return _transformation;
  }

  copyState() {
    // var state;
    // if ( this.camera is OrthographicCamera ) {

    // 	state = JSON.stringify( { 'arcballState': {

    // 		'cameraFar': this.camera.far,
    // 		'cameraMatrix': this.camera.matrix,
    // 		'cameraNear': this.camera.near,
    // 		'cameraUp': this.camera.up,
    // 		'cameraZoom': this.camera.zoom,
    // 		'gizmoMatrix': this._gizmos.matrix

    // 	} } );

    // } else if ( this.camera is PerspectiveCamera ) {

    // 	state = JSON.stringify( { 'arcballState': {
    // 		'cameraFar': this.camera.far,
    // 		'cameraFov': this.camera.fov,
    // 		'cameraMatrix': this.camera.matrix,
    // 		'cameraNear': this.camera.near,
    // 		'cameraUp': this.camera.up,
    // 		'cameraZoom': this.camera.zoom,
    // 		'gizmoMatrix': this._gizmos.matrix

    // 	} } );

    // }

    // navigator.clipboard.writeText( state );
  }

  pasteState() {
    // var self = this;
    // navigator.clipboard.readText().then( function resolved( value ) {

    // 	self.setStateFromJSON( value );

    // } );
  }

  /**
	 * Save the current state of the control. This can later be recover with .reset
	 */
  saveState() {
    this._cameraMatrixState0.copy(this.camera.matrix);
    this._gizmoMatrixState0.copy(this._gizmos.matrix);
    this._nearPos = this.camera.near;
    this._farPos = this.camera.far;
    this._zoom0 = this.camera.zoom;
    this._up0.copy(this.camera.up);

    if (this.camera is PerspectiveCamera) {
      this._fov0 = this.camera.fov;
    }
  }

  /**
	 * Perform uniform scale operation around a given point
	 * @param {Number} size Scale factor
	 * @param {Vector3} point Point around which scale
	 * @param {Boolean} scaleGizmos If gizmos should be scaled (Perspective only)
	 * @returns {Object} Object with 'camera' and 'gizmo' fields containing transformation matrices resulting from the operation to be applied to the camera and gizmos
	 */
  scale(size, point, [scaleGizmos = true]) {
    _scalePointTemp.copy(point);
    var sizeInverse = 1 / size;

    if (this.camera is OrthographicCamera) {
      //camera zoom
      this.camera.zoom = this._zoomState;
      this.camera.zoom *= size;

      //check min and max zoom
      if (this.camera.zoom > this.maxZoom) {
        this.camera.zoom = this.maxZoom;
        sizeInverse = this._zoomState / this.maxZoom;
      } else if (this.camera.zoom < this.minZoom) {
        this.camera.zoom = this.minZoom;
        sizeInverse = this._zoomState / this.minZoom;
      }

      this.camera.updateProjectionMatrix();

      this
          ._v3_1
          .setFromMatrixPosition(this._gizmoMatrixState); //gizmos position

      //scale gizmos so they appear in the same spot having the same dimension
      this._scaleMatrix.makeScale(sizeInverse, sizeInverse, sizeInverse);
      this
          ._translationMatrix
          .makeTranslation(-this._v3_1.x, -this._v3_1.y, -this._v3_1.z);

      this
          ._m4_2
          .makeTranslation(this._v3_1.x, this._v3_1.y, this._v3_1.z)
          .multiply(this._scaleMatrix);
      this._m4_2.multiply(this._translationMatrix);

      //move camera and gizmos to obtain pinch effect
      _scalePointTemp.sub(this._v3_1);

      var amount = _scalePointTemp.clone().multiplyScalar(sizeInverse);
      _scalePointTemp.sub(amount);

      this._m4_1.makeTranslation(
          _scalePointTemp.x, _scalePointTemp.y, _scalePointTemp.z);
      this._m4_2.premultiply(this._m4_1);

      this.setTransformationMatrices(this._m4_1, this._m4_2);
      return _transformation;
    } else if (this.camera is PerspectiveCamera) {
      this._v3_1.setFromMatrixPosition(this._cameraMatrixState);
      this._v3_2.setFromMatrixPosition(this._gizmoMatrixState);

      //move camera
      var distance = this._v3_1.distanceTo(_scalePointTemp);
      var amount = distance - (distance * sizeInverse);

      //check min and max distance
      var newDistance = distance - amount;
      if (newDistance < this.minDistance) {
        sizeInverse = this.minDistance / distance;
        amount = distance - (distance * sizeInverse);
      } else if (newDistance > this.maxDistance) {
        sizeInverse = this.maxDistance / distance;
        amount = distance - (distance * sizeInverse);
      }

      _offset
          .copy(_scalePointTemp)
          .sub(this._v3_1)
          .normalize()
          .multiplyScalar(amount);

      this._m4_1.makeTranslation(_offset.x, _offset.y, _offset.z);

      if (scaleGizmos) {
        //scale gizmos so they appear in the same spot having the same dimension
        var pos = this._v3_2;

        distance = pos.distanceTo(_scalePointTemp);
        amount = distance - (distance * sizeInverse);
        _offset
            .copy(_scalePointTemp)
            .sub(this._v3_2)
            .normalize()
            .multiplyScalar(amount);

        this._translationMatrix.makeTranslation(pos.x, pos.y, pos.z);
        this._scaleMatrix.makeScale(sizeInverse, sizeInverse, sizeInverse);

        this
            ._m4_2
            .makeTranslation(_offset.x, _offset.y, _offset.z)
            .multiply(this._translationMatrix);
        this._m4_2.multiply(this._scaleMatrix);

        this._translationMatrix.makeTranslation(-pos.x, -pos.y, -pos.z);

        this._m4_2.multiply(this._translationMatrix);
        this.setTransformationMatrices(this._m4_1, this._m4_2);
      } else {
        this.setTransformationMatrices(this._m4_1);
      }

      return _transformation;
    }
  }

  /**
	 * Set camera fov
	 * @param {Number} value fov to be setted
	 */
  setFov(value) {
    if (this.camera is PerspectiveCamera) {
      this.camera.fov = MathUtils.clamp(value, this.minFov, this.maxFov);
      this.camera.updateProjectionMatrix();
    }
  }

  /**
	 * Set values in transformation object
	 * @param {Matrix4} camera Transformation to be applied to the camera
	 * @param {Matrix4} gizmos Transformation to be applied to gizmos
	 */
  setTransformationMatrices([camera = null, gizmos = null]) {
    if (camera != null) {
      if (_transformation['camera'] != null) {
        _transformation['camera']!.copy(camera);
      } else {
        _transformation['camera'] = camera.clone();
      }
    } else {
      _transformation.remove('camera');
    }

    if (gizmos != null) {
      if (_transformation['gizmos'] != null) {
        _transformation['gizmos']!.copy(gizmos);
      } else {
        _transformation['gizmos'] = gizmos.clone();
      }
    } else {
      _transformation.remove('gizmos');
    }
  }

  /**
	 * Rotate camera around its direction axis passing by a given point by a given angle
	 * @param {Vector3} point The point where the rotation axis is passing trough
	 * @param {Number} angle Angle in radians
	 * @returns The computed transormation matix
	 */
  zRotate(point, angle) {
    this._rotationMatrix.makeRotationAxis(this._rotationAxis, angle);
    this._translationMatrix.makeTranslation(-point.x, -point.y, -point.z);

    this._m4_1.makeTranslation(point.x, point.y, point.z);
    this._m4_1.multiply(this._rotationMatrix);
    this._m4_1.multiply(this._translationMatrix);

    this
        ._v3_1
        .setFromMatrixPosition(this._gizmoMatrixState)
        .sub(point); //vector from rotation center to gizmos position
    this
        ._v3_2
        .copy(this._v3_1)
        .applyAxisAngle(this._rotationAxis, angle); //apply rotation
    this._v3_2.sub(this._v3_1);

    this._m4_2.makeTranslation(this._v3_2.x, this._v3_2.y, this._v3_2.z);

    this.setTransformationMatrices(this._m4_1, this._m4_2);
    return _transformation;
  }

  getRaycaster() {
    return _raycaster;
  }

  /**
	 * Unproject the cursor on the 3D object surface
	 * @param {Vector2} cursor Cursor coordinates in NDC
	 * @param {Camera} camera Virtual camera
	 * @returns {Vector3} The point of intersection with the model, if exist, null otherwise
	 */
  unprojectOnObj(cursor, camera) {
    var raycaster = this.getRaycaster();
    raycaster.near = camera.near;
    raycaster.far = camera.far;
    raycaster.setFromCamera(cursor, camera);

    var intersect = raycaster.intersectObjects(this.scene!.children, true);

    for (var i = 0; i < intersect.length; i++) {
      if (intersect[i].object.uuid != this._gizmos.uuid &&
          intersect[i].face != null) {
        return intersect[i].point.clone();
      }
    }

    return null;
  }

  /**
	 * Unproject the cursor on the trackball surface
	 * @param {Camera} camera The virtual camera
	 * @param {Number} cursorX Cursor horizontal coordinate on screen
	 * @param {Number} cursorY Cursor vertical coordinate on screen
	 * @param {HTMLElement} canvas The canvas where the renderer draws its output
	 * @param {number} tbRadius The trackball radius
	 * @returns {Vector3} The unprojected point on the trackball surface
	 */
  unprojectOnTbSurface(camera, cursorX, cursorY, canvas, tbRadius) {
    if (camera.type == 'OrthographicCamera') {
      this._v2_1.copy(this.getCursorPosition(cursorX, cursorY, canvas));
      this._v3_1.set(this._v2_1.x, this._v2_1.y, 0);

      var x2 = Math.pow(this._v2_1.x, 2);
      var y2 = Math.pow(this._v2_1.y, 2);
      var r2 = Math.pow(this._tbRadius, 2);

      if (x2 + y2 <= r2 * 0.5) {
        //intersection with sphere
        this._v3_1.setZ(Math.sqrt(r2 - (x2 + y2)));
      } else {
        //intersection with hyperboloid
        this._v3_1.setZ((r2 * 0.5) / (Math.sqrt(x2 + y2)));
      }

      return this._v3_1;
    } else if (camera.type == 'PerspectiveCamera') {
      //unproject cursor on the near plane
      this._v2_1.copy(this.getCursorNDC(cursorX, cursorY, canvas));

      this._v3_1.set(this._v2_1.x, this._v2_1.y, -1);
      this._v3_1.applyMatrix4(camera.projectionMatrixInverse);

      var rayDir = this._v3_1.clone().normalize(); //unprojected ray direction
      var cameraGizmoDistance =
          camera.position.distanceTo(this._gizmos.position);
      var radius2 = Math.pow(tbRadius, 2);

      //	  camera
      //		|\
      //		| \
      //		|  \
      //	h	|	\
      //		| 	 \
      //		| 	  \
      //	_ _ | _ _ _\ _ _  near plane
      //			l

      var h = this._v3_1.z;
      var l = Math.sqrt(Math.pow(this._v3_1.x, 2) + Math.pow(this._v3_1.y, 2));

      if (l == 0) {
        //ray aligned with camera
        rayDir.set(this._v3_1.x, this._v3_1.y, tbRadius);
        return rayDir;
      }

      var m = h / l;
      var q = cameraGizmoDistance;

      /*
			 * calculate intersection point between unprojected ray and trackball surface
			 *|y = m * x + q
			 *|x^2 + y^2 = r^2
			 *
			 * (m^2 + 1) * x^2 + (2 * m * q) * x + q^2 - r^2 = 0
			 */
      var a = Math.pow(m, 2) + 1;
      var b = 2 * m * q;
      var c = Math.pow(q, 2) - radius2;
      var delta = Math.pow(b, 2) - (4 * a * c);

      if (delta >= 0) {
        //intersection with sphere
        this._v2_1.setX((-b - Math.sqrt(delta)) / (2 * a));
        this._v2_1.setY(m * this._v2_1.x + q);

        var angle = MathUtils.RAD2DEG * this._v2_1.angle();

        if (angle >= 45) {
          //if angle between intersection point and X' axis is >= 45°, return that point
          //otherwise, calculate intersection point with hyperboloid

          var rayLength = Math.sqrt(Math.pow(this._v2_1.x, 2) +
              Math.pow((cameraGizmoDistance - this._v2_1.y), 2));
          rayDir.multiplyScalar(rayLength);
          rayDir.z += cameraGizmoDistance;
          return rayDir;
        }
      }

      //intersection with hyperboloid
      /*
			 *|y = m * x + q
			 *|y = (1 / x) * (r^2 / 2)
			 *
			 * m * x^2 + q * x - r^2 / 2 = 0
			 */

      a = m;
      b = q;
      c = -radius2 * 0.5;
      delta = Math.pow(b, 2) - (4 * a * c);
      this._v2_1.setX((-b - Math.sqrt(delta)) / (2 * a));
      this._v2_1.setY(m * this._v2_1.x + q);

      var rayLength = Math.sqrt(Math.pow(this._v2_1.x, 2) +
          Math.pow((cameraGizmoDistance - this._v2_1.y), 2));

      rayDir.multiplyScalar(rayLength);
      rayDir.z += cameraGizmoDistance;
      return rayDir;
    }
  }

  /**
	 * Unproject the cursor on the plane passing through the center of the trackball orthogonal to the camera
	 * @param {Camera} camera The virtual camera
	 * @param {Number} cursorX Cursor horizontal coordinate on screen
	 * @param {Number} cursorY Cursor vertical coordinate on screen
	 * @param {HTMLElement} canvas The canvas where the renderer draws its output
	 * @param {Boolean} initialDistance If initial distance between camera and gizmos should be used for calculations instead of current (Perspective only)
	 * @returns {Vector3} The unprojected point on the trackball plane
	 */
  unprojectOnTbPlane(camera, cursorX, cursorY, canvas,
      [initialDistance = false]) {
    if (camera.type == 'OrthographicCamera') {
      this._v2_1.copy(this.getCursorPosition(cursorX, cursorY, canvas));
      this._v3_1.set(this._v2_1.x, this._v2_1.y, 0);

      return this._v3_1.clone();
    } else if (camera.type == 'PerspectiveCamera') {
      this._v2_1.copy(this.getCursorNDC(cursorX, cursorY, canvas));

      //unproject cursor on the near plane
      this._v3_1.set(this._v2_1.x, this._v2_1.y, -1);
      this._v3_1.applyMatrix4(camera.projectionMatrixInverse);

      var rayDir = this._v3_1.clone().normalize(); //unprojected ray direction

      //	  camera
      //		|\
      //		| \
      //		|  \
      //	h	|	\
      //		| 	 \
      //		| 	  \
      //	_ _ | _ _ _\ _ _  near plane
      //			l

      var h = this._v3_1.z;
      var l = Math.sqrt(Math.pow(this._v3_1.x, 2) + Math.pow(this._v3_1.y, 2));
      var cameraGizmoDistance;

      if (initialDistance) {
        cameraGizmoDistance = this
            ._v3_1
            .setFromMatrixPosition(this._cameraMatrixState0)
            .distanceTo(
                this._v3_2.setFromMatrixPosition(this._gizmoMatrixState0));
      } else {
        cameraGizmoDistance = camera.position.distanceTo(this._gizmos.position);
      }

      /*
			 * calculate intersection point between unprojected ray and the plane
			 *|y = mx + q
			 *|y = 0
			 *
			 * x = -q/m
			*/
      if (l == 0) {
        //ray aligned with camera
        rayDir.set(0, 0, 0);
        return rayDir;
      }

      var m = h / l;
      var q = cameraGizmoDistance;
      var x = -q / m;

      var rayLength = Math.sqrt(Math.pow(q, 2) + Math.pow(x, 2));
      rayDir.multiplyScalar(rayLength);
      rayDir.z = 0;
      return rayDir;
    }
  }

  /**
	 * Update camera and gizmos state
	 */
  updateMatrixState() {
    //update camera and gizmos state
    this._cameraMatrixState.copy(this.camera.matrix);
    this._gizmoMatrixState.copy(this._gizmos.matrix);

    if (this.camera is OrthographicCamera) {
      this._cameraProjectionState.copy(this.camera.projectionMatrix);
      this.camera.updateProjectionMatrix();
      this._zoomState = this.camera.zoom;
    } else if (this.camera is PerspectiveCamera) {
      this._fovState = this.camera.fov;
    }
  }

  /**
	 * Update the trackball FSA
	 * @param {STATE2} newState New state of the FSA
	 * @param {Boolean} updateMatrices If matriices state should be updated
	 */
  updateTbState(newState, updateMatrices) {
    this._state = newState;
    if (updateMatrices) {
      this.updateMatrixState();
    }
  }

  update() {
    var EPS = 0.000001;

    if (this.target.equals(this._currentTarget) == false) {
      this._gizmos.position.copy(this.target); //for correct radius calculation
      this._tbRadius = this.calculateTbRadius(this.camera);
      this.makeGizmos(this.target, this._tbRadius);
      this._currentTarget.copy(this.target);
    }

    //check min/max parameters
    if (this.camera is OrthographicCamera) {
      //check zoom
      if (this.camera.zoom > this.maxZoom || this.camera.zoom < this.minZoom) {
        var newZoom =
            MathUtils.clamp(this.camera.zoom, this.minZoom, this.maxZoom);
        this.applyTransformMatrix(this
            .scale(newZoom / this.camera.zoom, this._gizmos.position, true));
      }
    } else if (this.camera is PerspectiveCamera) {
      //check distance
      var distance = this.camera.position.distanceTo(this._gizmos.position);

      if (distance > this.maxDistance + EPS ||
          distance < this.minDistance - EPS) {
        var newDistance =
            MathUtils.clamp(distance, this.minDistance, this.maxDistance);
        this.applyTransformMatrix(
            this.scale(newDistance / distance, this._gizmos.position));
        this.updateMatrixState();
      }

      //check fov
      if (this.camera.fov < this.minFov || this.camera.fov > this.maxFov) {
        this.camera.fov =
            MathUtils.clamp(this.camera.fov, this.minFov, this.maxFov);
        this.camera.updateProjectionMatrix();
      }

      var oldRadius = this._tbRadius;
      this._tbRadius = this.calculateTbRadius(this.camera);

      if (oldRadius < this._tbRadius - EPS ||
          oldRadius > this._tbRadius + EPS) {
        var scale = (this._gizmos.scale.x +
                this._gizmos.scale.y +
                this._gizmos.scale.z) /
            3;
        var newRadius = this._tbRadius / scale;
        var curve = new EllipseCurve(0, 0, newRadius, newRadius);
        var points = curve.getPoints(this._curvePts);
        var curveGeometry = new BufferGeometry().setFromPoints(points);

        for (var gizmo in this._gizmos.children) {
          // this._gizmos.children[ gizmo ].geometry = curveGeometry;
          gizmo.geometry = curveGeometry;
        }
      }
    }

    this.camera.lookAt(this._gizmos.position);
  }

  setStateFromJSON(json) {
    // var state = JSON.parse( json );

    // if ( state.arcballState != null ) {

    // 	this._cameraMatrixState.fromArray( state.arcballState.cameraMatrix.elements );
    // 	this._cameraMatrixState.decompose( this.camera.position, this.camera.quaternion, this.camera.scale );

    // 	this.camera.up.copy( state.arcballState.cameraUp );
    // 	this.camera.near = state.arcballState.cameraNear;
    // 	this.camera.far = state.arcballState.cameraFar;

    // 	this.camera.zoom = state.arcballState.cameraZoom;

    // 	if ( this.camera is PerspectiveCamera ) {

    // 		this.camera.fov = state.arcballState.cameraFov;

    // 	}

    // 	this._gizmoMatrixState.fromArray( state.arcballState.gizmoMatrix.elements );
    // 	this._gizmoMatrixState.decompose( this._gizmos.position, this._gizmos.quaternion, this._gizmos.scale );

    // 	this.camera.updateMatrix();
    // 	this.camera.updateProjectionMatrix();

    // 	this._gizmos.updateMatrix();

    // 	this._tbRadius = this.calculateTbRadius( this.camera );
    // 	var gizmoTmp = new Matrix4().copy( this._gizmoMatrixState0 );
    // 	this.makeGizmos( this._gizmos.position, this._tbRadius );
    // 	this._gizmoMatrixState0.copy( gizmoTmp );

    // 	this.camera.lookAt( this._gizmos.position );
    // 	this.updateTbState( STATE2.IDLE, false );

    // 	this.dispatchEvent( _changeEvent );

    // }
  }

  cancelAnimationFrame(instance) {}

  requestAnimationFrame(Function callback) {}
}
