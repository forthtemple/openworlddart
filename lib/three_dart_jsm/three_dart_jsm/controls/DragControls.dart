part of jsm_controls;

class DragControls with EventDispatcher {
  late DragControls scope;

  bool enabled = true;
  bool transformGroup = false;
  List<Intersection> _intersections = [];
  var _selected = null, _hovered = null;

  late Camera camera;
  late GlobalKey<DomLikeListenableState> listenableKey;
  DomLikeListenableState get _domElement => listenableKey.currentState!;
  late List<Object3D> objects;
  List<Object3D> get _objects => objects;
  Camera get _camera => camera;

  DragControls(List<Object3D> objects, camera, listenableKey) : super() {
    this.camera = camera;
    this.listenableKey = listenableKey;
    this.objects = objects;

    // _domElement.style.touchAction = 'none'; // disable touch scroll

    scope = this;

    activate();

    // API
  }

  activate() {
    _domElement.addEventListener('pointermove', onPointerMove);
    _domElement.addEventListener('pointerdown', onPointerDown);
    _domElement.addEventListener('pointerup', onPointerCancel);
    _domElement.addEventListener('pointerleave', onPointerCancel);
  }

  deactivate() {
    _domElement.removeEventListener('pointermove', onPointerMove);
    _domElement.removeEventListener('pointerdown', onPointerDown);
    _domElement.removeEventListener('pointerup', onPointerCancel);
    _domElement.removeEventListener('pointerleave', onPointerCancel);

    // _domElement.style.cursor = '';
  }

  dispose() {
    deactivate();
  }

  getObjects() {
    return _objects;
  }

  getRaycaster() {
    return _raycaster;
  }

  onPointerMove(event) {
    if (scope.enabled == false) return;

    updatePointer(event);

    _raycaster.setFromCamera(_pointer, _camera);

    if (_selected) {
      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {
        _selected.position
            .copy(_intersection.sub(_offset).applyMatrix4(_inverseMatrix));
      }

      scope.dispatchEvent(Event({'type': 'drag', 'object': _selected}));

      return;
    }

    // hover support

    if (event.pointerType == 'mouse' || event.pointerType == 'pen') {
      _intersections.length = 0;

      _raycaster.setFromCamera(_pointer, _camera);
      _raycaster.intersectObjects(_objects, true, _intersections);

      if (_intersections.length > 0) {
        var object = _intersections[0].object;

        _plane.setFromNormalAndCoplanarPoint(
            _camera.getWorldDirection(_plane.normal),
            _worldPosition.setFromMatrixPosition(object.matrixWorld));

        if (_hovered != object && _hovered != null) {
          scope.dispatchEvent(Event({'type': 'hoveroff', 'object': _hovered}));

          // _domElement.style.cursor = 'auto';
          _hovered = null;
        }

        if (_hovered != object) {
          scope.dispatchEvent(Event({'type': 'hoveron', 'object': object}));

          // _domElement.style.cursor = 'pointer';
          _hovered = object;
        }
      } else {
        if (_hovered != null) {
          scope.dispatchEvent(Event({'type': 'hoveroff', 'object': _hovered}));

          // _domElement.style.cursor = 'auto';
          _hovered = null;
        }
      }
    }
  }

  onPointerDown(event) {
    if (scope.enabled == false) return;

    updatePointer(event);

    _intersections.length = 0;

    _raycaster.setFromCamera(_pointer, _camera);
    _raycaster.intersectObjects(_objects, true, _intersections);

    if (_intersections.length > 0) {
      _selected = (scope.transformGroup == true)
          ? _objects[0]
          : _intersections[0].object;

      _plane.setFromNormalAndCoplanarPoint(
          _camera.getWorldDirection(_plane.normal),
          _worldPosition.setFromMatrixPosition(_selected.matrixWorld));

      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {
        _inverseMatrix.copy(_selected.parent.matrixWorld).invert();
        _offset
            .copy(_intersection)
            .sub(_worldPosition.setFromMatrixPosition(_selected.matrixWorld));
      }

      // _domElement.style.cursor = 'move';

      scope.dispatchEvent(Event({'type': 'dragstart', 'object': _selected}));
    }
  }

  onPointerCancel() {
    if (scope.enabled == false) return;

    if (_selected) {
      scope.dispatchEvent(Event({'type': 'dragend', 'object': _selected}));

      _selected = null;
    }

    // _domElement.style.cursor = _hovered ? 'pointer' : 'auto';
  }

  updatePointer(event) {
    // var rect = _domElement.getBoundingClientRect();
    var box = listenableKey.currentContext?.findRenderObject() as RenderBox;
    var size = box.size;
    var local = box.globalToLocal(Offset(0, 0));

    _pointer.x = (event.clientX - local.dx) / size.width * 2 - 1;
    _pointer.y = -(event.clientY - local.dy) / size.height * 2 + 1;
  }
}
