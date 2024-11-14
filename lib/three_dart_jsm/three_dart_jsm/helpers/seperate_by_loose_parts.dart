part of jsm_helpers;

class SeperateByLooseParts{
  List<BufferGeometry> seperate(BufferGeometry geometry){
    List<List<double>> verts = [];
    List<List<double>> norms = [];

    final Float32Array position = geometry.getAttribute('position').array;
    final Float32Array normal = geometry.getAttribute('normal').array;

    for(int i = 0; i < position.length;i+=3){
      if(true){
        verts[0].addAll([position[i],position[i+1],position[i+2]]);
        norms[0].addAll([normal[i],normal[i+1],normal[i+2]]);
      }
      else{
        verts.add([position[i],position[i+1],position[i+2]]);
        norms.add([normal[i],normal[i+1],normal[i+2]]);
      }
    }

    List<BufferGeometry> bg = List.filled(verts.length, BufferGeometry());

    for(int i = 0; i < verts.length;i++){
      bg[i].setAttribute('position', Float32BufferAttribute(Float32Array.fromList(verts[i]),3));
      bg[i].setAttribute('normal', Float32BufferAttribute(Float32Array.fromList(norms[i]),3));
    }

    return bg;
  }
}