part of jsm_controls;

var _changeEvent = Event({"type": 'change'});
var _startEvent = Event({'type': 'start'});
var _endEvent = Event({'type': 'end'});

var Infinity = Math.Infinity;

var _euler = new Euler(0, 0, 0, 'YXZ');
var _vector = new Vector3();

var _lockEvent = Event({'type': 'lock'});
var _unlockEvent = Event({'type': 'unlock'});

var _PI_2 = Math.PI / 2;

var _raycaster = new Raycaster();

var _plane = new Plane();

var _pointer = new Vector2();
var _offset = new Vector3();
var _intersection = new Vector3();
var _worldPosition = new Vector3();
var _inverseMatrix = new Matrix4();
