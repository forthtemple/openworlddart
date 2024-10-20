part of three_math;

class Vector {
  String type = "Vector";
  num x;
  num y;
  Vector([this.x = 0,this.y = 0]);

  Vector set(num x, num y) {
    throw('Not implimented in Vector type yet');
  }
  bool equals(Vector v) {
    throw('Not implimented in Vector type yet');
  }
  Vector copy(Vector v){
    throw('Not implimented in Vector type yet');
  }
  Vector sub(Vector v, {Vector? w}){
    throw('Not implimented in Vector type yet');
  }
  Vector add(Vector a, {Vector? b}){
    throw('Not implimented in Vector type yet');
  }
  Vector setScalar(double scalar) {
    throw('Not implimented in Vector type yet');
  }

  num getComponent(int index) {
    throw('Not implimented in Vector type yet');
  }

  Vector clone() {
    throw('Not implimented in Vector type yet');
  }

  Vector addScalar(num s) {
    throw('Not implimented in Vector type yet');
  }

  Vector subScalar(num s) {
    throw('Not implimented in Vector type yet');
  }

  Vector multiplyScalar(num scalar) {
    throw('Not implimented in Vector type yet');
  }

  Vector divideScalar(double scalar) {
    throw('Not implimented in Vector type yet');
  }

  Vector applyMatrix3(Matrix3 m) {
    throw('Not implimented in Vector type yet');
  }

  Vector clampScalar(double minVal, double maxVal) {
    throw('Not implimented in Vector type yet');
  }

  Vector clampLength(double min, double max) {
    throw('Not implimented in Vector type yet');
  }

  Vector floor() {
    throw('Not implimented in Vector type yet');
  }

  Vector ceil() {
    throw('Not implimented in Vector type yet');
  }

  Vector round() {
    throw('Not implimented in Vector type yet');
  }

  Vector roundToZero() {
    throw('Not implimented in Vector type yet');
  }

  Vector negate() {
    throw('Not implimented in Vector type yet');
  }

  num lengthSq() {
    throw('Not implimented in Vector type yet');
  }

  double length() {
    throw('Not implimented in Vector type yet');
  }

  num manhattanLength() {
    throw('Not implimented in Vector type yet');
  }

  Vector normalize() {
    throw('Not implimented in Vector type yet');
  }

  double angle() {
    throw('Not implimented in Vector type yet');
  }

  Vector setLength(double length) {
    throw('Not implimented in Vector type yet');
  }

  Vector fromArray(List<double> array, [int offset = 0]) {
    throw('Not implimented in Vector type yet');
  }

  List<num> toArray([List<double>? array, int offset = 0]) {
    throw('Not implimented in Vector type yet');
  }

  List<num> toJSON() {
    throw('Not implimented in Vector type yet');
  }

  Vector fromBufferAttribute(BufferAttribute attribute,int index) {
    throw('Not implimented in Vector type yet');
  }

  Vector random() {
    throw('Not implimented in Vector type yet');
  }

  Map<String, dynamic> toJson() {
    throw('Not implimented in Vector type yet');
  }

}
