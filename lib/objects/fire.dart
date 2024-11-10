import 'dart:collection';
import 'dart:core';

import 'package:openworld/updateable.dart';
import 'package:openworld_gl/native-array/index.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'dart:math' as math;

// 'System.out.println("version"+ gl.getContext().getGLSLVersionString()); ',


class VolumetricFire extends Updateable {
  static THREE.Texture? nzw;
  static THREE.Texture? fireProfile;

  var vs = [

    'attribute vec3 position;',
    'attribute vec3 tex;',
    'uniform mat4 projectionMatrix;',
    'uniform mat4 modelViewMatrix;',

    'varying vec3 texOut;',

    'void main ( void ) {',

    'gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0 );',
    'texOut = tex;',

    '}',

  ].join('\n');

  var fs = [

    'precision highp float;',

    // Modified Blum Blum Shub pseudo-random number generator.
    'vec2 mBBS( vec2 val, float modulus ) {',

    'val = mod( val, modulus ); // For numerical consistancy.',
    'return mod(val * val, modulus);',

    '}',

    // Pregenerated noise texture.
    'uniform sampler2D nzw;',
    'const float modulus = 61.0;  // Value used in pregenerated noise texture.',

    /**
     * Modified noise function.
     * @see http://www.csee.umbc.edu/~olano/papers/index.html#mNoise
     **/
    'float mnoise ( vec3 pos ) {',

    'float intArg = floor( pos.z );',
    'float fracArg = fract( pos.z );',
    'vec2 hash = mBBS( intArg * 3.0 + vec2( 0, 3 ), modulus );',
    'vec4 g = vec4 (',
    'texture2D( nzw, vec2( pos.x, pos.y + hash.x ) / modulus ).xy,',
    'texture2D( nzw, vec2( pos.x, pos.y + hash.y ) / modulus ).xy',
    ') * 2.0 - 1.0;',

    'return mix(',
    'g.x + g.y * fracArg,',
    'g.z + g.w * ( fracArg - 1.0 ),',
    'smoothstep( 0.0, 1.0, fracArg )',
    ');',

    '}',

    'const int octives = 4;',
    'const float lacunarity = 2.0;',
    'const float gain = 0.5;',

    /**
     * Adds multiple octives of noise together.
     **/
    'float turbulence( vec3 pos ) {',

    'float sum  = 0.0;',
    'float freq = 1.0;',
    'float amp  = 1.0;',

    'for ( int i = 0; i < 4; i++ ) {',

    'sum += abs( mnoise( pos * freq ) ) * amp;',
    'freq *= lacunarity;',
    'amp *= gain;',

    '}',

    'return sum;',

    '}',

    'const float magnatude = 1.3;',
    'uniform float time;',
    'uniform sampler2D fireProfile;',
    'uniform vec3 flamingcolor;',

    /**
     * Samples the fire.
     *
     * @param loc the normalized location (0.0-1.0) to sample the fire
     * @param scale the 'size' of the fire in world space and time
     **/
    'vec4 sampleFire( vec3 loc, vec4 scale ) {',

    // Convert xz to [-1.0, 1.0] range.
    'loc.xz = loc.xz * 2.0 - 1.0;',

    // Convert to (radius, height) to sample fire profile texture.
    'vec2 st = vec2( sqrt( dot( loc.xz, loc.xz ) ), loc.y );',

    // Convert loc to 'noise' space
    'loc.y -= time * scale.w; // Scrolling noise upwards over time.',
    'loc *= scale.xyz; // Scaling noise space.',

    // Offsetting vertial texture lookup.
    // We scale this by the sqrt of the height so that things are
    // relatively stable at the base of the fire and volital at the
    // top.
    'float offset = sqrt( st.y ) * magnatude * turbulence( loc );',
    'st.y += offset;',

    // TODO: Update fireProfile texture to have a black row of pixels.
    'if ( st.y > 1.0 ) {',

    'return vec4( 0, 0, 0, 1 );',

    '}',

    'vec4 result = texture2D( fireProfile, st );',

    // Fading out bottom so slice clipping isnt obvious
    'if ( st.y < 0.1 ) {',

    'result *= st.y / 0.1;',

    '}',

    'return result;',

    '}',

    'varying vec3 texOut;',
    //'vec3 flamingcolor= vec3( 0.2,0.2,1.0 ); ',

    'void main( void ) {',

    // Mapping texture coordinate to -1 => 1 for xy, 0=> 1 for y
    'vec3 color = sampleFire( texOut, vec4( 1.0, 2.0, 1.0, 0.5 ) ).xyz;',
    //'color = vec3(0.5, 0.5, 1.0) * color;  '
    'color.r=color.r * flamingcolor.x;',
    'color.b=color.b * flamingcolor.y;',
    'color.g=color.g * flamingcolor.z;',
    'gl_FragColor = vec4( color * 1.5, 1 );',

    '}',

  ].join('\n');

  late THREE.Camera camera;

  late double _sliceSpacing;

  late List _posCorners;

  late List _texCorners;

  late THREE.Vector3 _viewVector;

  late THREE.Mesh mesh;

  late List _index;

  late List<double> _points = [];
  late List<double> _texCoords = [];
  late List<int> _indexes ;

  late int _width;
  late int  _height;
  late int _depth;

  late THREE.Vector3? _color;

  VolumetricFire(width, height, depth, sliceSpacing, camera, {color})  {
    this.camera = camera;

    this._sliceSpacing = sliceSpacing;
    this._width=width;
    this._height=height;
    this._depth=depth;

    if (color!=null) {
      _color=THREE.Vector3(color.r, color.g, color.b);
    } else {
      _color=THREE.Vector3(1.0,1.0,1.0);
    }
    var widthHalf = width * 0.5;
    var heightHalf = height * 0.5;
    var depthHalf = depth * 0.5;

    this._posCorners = [
      new THREE.Vector3(-widthHalf, -heightHalf, -depthHalf),
      new THREE.Vector3(widthHalf, -heightHalf, -depthHalf),
      new THREE.Vector3(-widthHalf, heightHalf, -depthHalf),
      new THREE.Vector3(widthHalf, heightHalf, -depthHalf),
      new THREE.Vector3(-widthHalf, -heightHalf, depthHalf),
      new THREE.Vector3(widthHalf, -heightHalf, depthHalf),
      new THREE.Vector3(-widthHalf, heightHalf, depthHalf),
      new THREE.Vector3(widthHalf, heightHalf, depthHalf)
    ];
    this._texCorners = [
      new THREE.Vector3(0, 0, 0),
      new THREE.Vector3(1, 0, 0),
      new THREE.Vector3(0, 1, 0),
      new THREE.Vector3(1, 1, 0),
      new THREE.Vector3(0, 0, 1),
      new THREE.Vector3(1, 0, 1),
      new THREE.Vector3(0, 1, 1),
      new THREE.Vector3(1, 1, 1)
    ];

    this._viewVector = new THREE.Vector3();

  }

  init() async
  {
    // TODO
    // still did not figure out, how many vertexes should be...
    // three.jsでは可変にできない、ひとまず多めに用意

    var index = new Uint16Array ((_width + _height + _depth) * 30);
    var position = new Float32Array((_width + _height + _depth) * 30 * 3);
    var tex = new Float32Array((_width + _height + _depth) * 30 * 3);


    var geometry = new THREE.BufferGeometry();
    //geometry.dynamic = true;


    geometry.setIndex(new THREE.Uint16BufferAttribute(index, 1));
    //  geometry.attributes={'position': new THREE.BufferAttribute(position, 3),'tex': new THREE.BufferAttribute(tex, 3)});

    geometry.setAttribute(
        'position', THREE.Float32BufferAttribute(position, 3));
    geometry.setAttribute('tex', THREE.Float32BufferAttribute(tex, 3));


    var material = await initMaterial();

    this.mesh = new THREE.Mesh(
        geometry,
        material
    );

    this.mesh.updateMatrixWorld();
  }


  initMaterial() async {
   // var material;
    var textureLoader = new THREE.TextureLoader();


    /*if (! !material) {
      return material;
    }*/

    // TODO
    // Canvas2D で noise 画像を作る
   // print("xxx"+VolumetricFire.texturePath);
    if (nzw==null) {
      nzw = await textureLoader.loadAsync(VolumetricFire.texturePath + 'nzw.png');
      nzw?.wrapS = THREE.RepeatWrapping;
      nzw?.wrapT = THREE.RepeatWrapping;
      nzw?.magFilter = THREE.LinearFilter;
      nzw?.minFilter = THREE.LinearFilter;
    }

    if (fireProfile==null) {
      fireProfile = await textureLoader.loadAsync(
          VolumetricFire.texturePath + 'firetex.png');
      fireProfile?.wrapS = THREE.ClampToEdgeWrapping;
      fireProfile?.wrapT = THREE.ClampToEdgeWrapping;
      fireProfile?.magFilter = THREE.LinearFilter;
      fireProfile?.minFilter = THREE.LinearFilter;
    }

    var uniforms = {
      'nzw': {
        'type': 't',
        'value': nzw
      },
      'fireProfile': {
        'type': 't',
        'value': fireProfile
      },
      'time': {
        'type': 'f',
        'value': 1.0
      },
      'flamingcolor': {
        'value': _color //THREE.Vector3(0.1,0.1,1.0)
      }
    };

   // THREE.Material dog;

    THREE.RawShaderMaterial material = new THREE.RawShaderMaterial({
      'vertexShader': vs,
      'fragmentShader': fs,
      'uniforms': uniforms,
      'side': THREE.DoubleSide,
      'blending': THREE.AdditiveBlending,
      'transparent': true
    });

    //print("uuu"+ material.visible.toString());
    return material;
  }


  var cornerNeighbors = [
    [ 1, 2, 4],
    [ 0, 5, 3],
    [ 0, 3, 6],
    [ 1, 7, 2],
    [ 0, 6, 5],
    [ 1, 4, 7],
    [ 2, 7, 4],
    [ 3, 5, 6],
  ];

  var incomingEdges = [
    [ -1, 2, 4, -1, 1, -1, -1, -1],
    [ 5, -1, -1, 0, -1, 3, -1, -1],
    [ 3, -1, -1, 6, -1, -1, 0, -1],
    [ -1, 7, 1, -1, -1, -1, -1, 2],
    [ 6, -1, -1, -1, -1, 0, 5, -1],
    [ -1, 4, -1, -1, 7, -1, -1, 1],
    [ -1, -1, 7, -1, 2, -1, -1, 4],
    [ -1, -1, -1, 5, -1, 6, 3, -1],
  ];


  @override
  update(frameTime,elapsed) {
    if (this.mesh.visible) {
      this.updateViewVector();
      this.slice();
      this.updateGeometry();
      this.mesh.material.uniforms['time']['value'] = elapsed;
    }
  }


  updateGeometry() {
    this.mesh.geometry?.index?.array.set(this._indexes);
  //  print("ooo"+this._points.toString());
    this.mesh.geometry?.attributes['position'].array.set(this._points);
    this.mesh.geometry?.attributes['tex'].array.set(this._texCoords);

    this.mesh.geometry?.index?.needsUpdate = true;
    this.mesh.geometry?.attributes['position'].needsUpdate = true;
    this.mesh.geometry?.attributes['tex'].needsUpdate = true;
  }

  updateViewVector() {
    // TODO
    // MVMatrixが前回と同じなら、アップデートしないようにする
    //
    // つまり、カメラの位置とオブジェクトの位置に変化なければ
    // アップデートしないようにする

    var modelViewMatrix = new THREE.Matrix4();

    modelViewMatrix.multiplyMatrices(
        this.camera.matrixWorldInverse,
        this.mesh.matrixWorld
    );

    this._viewVector.set(
        -modelViewMatrix.elements[ 2 ],
        -modelViewMatrix.elements[ 6 ],
        -modelViewMatrix.elements[ 10 ]
    ).normalize();
  }

  slice() {
    this._points = [];
    this._texCoords = [];
    this._indexes = [];

    var i;
    var cornerDistance0 = this._posCorners[ 0 ].dot(this._viewVector);

   // print('nnn'+cornerDistance0.toString());
    var cornerDistance = [ cornerDistance0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var maxCorner = 0;
    var minDistance = cornerDistance0;
    var maxDistance = cornerDistance0;

    for (i = 1; i < 8; i = (i + 1) | 0) {
      //print('xxx'+i.toString()+" "+cornerDistance.toString()+" "+this._posCorners.toString()+" "+this._viewVector.toString());


      cornerDistance[ i ] = this._posCorners[ i ].dot(this._viewVector);

      if (cornerDistance[ i ] > maxDistance) {
        maxCorner = i;
        maxDistance = cornerDistance[ i ];
      }

      if (cornerDistance[ i ] < minDistance) {
        minDistance = cornerDistance[ i ];
      }
      //print("iii"+i.toString());
    }

    // Aligning slices
  //  print("ooo"+maxDistance.toString()+" "+this._sliceSpacing.toString());
    var sliceDistance = (maxDistance / this._sliceSpacing).floor() *
        this._sliceSpacing;

    var activeEdges = [];
    var firstEdge = 0;
    var nextEdge = 0;
    var expirations = new PriorityQueue();

    createEdge(startIndex, endIndex) {
      if (nextEdge >= 12) {
        return null;
      }

      var activeEdge = {
        'expired': false,
        'startIndex': startIndex,
        'endIndex': endIndex,
        'deltaPos': new THREE.Vector3(),
        'deltaTex': new THREE.Vector3(),
        'pos': new THREE.Vector3(),
        'tex': new THREE.Vector3(),
        'cur': nextEdge
      };

      var range = cornerDistance[ startIndex ] - cornerDistance[ endIndex ];

      if (range != 0.0) {
        var irange = 1.0 / range;

        activeEdge['deltaPos'].subVectors(
            this._posCorners[ endIndex ],
            this._posCorners[ startIndex ]
        ).multiplyScalar(irange);

        activeEdge['deltaTex'].subVectors(
            this._texCorners[ endIndex ],
            this._texCorners[ startIndex ]
        ).multiplyScalar(irange);

        var step = cornerDistance[ startIndex ] - sliceDistance;

        activeEdge['pos'].addVectors(
            activeEdge['deltaPos'].clone().multiplyScalar(step),
            this._posCorners[ startIndex ]
        );

        activeEdge['tex'].addVectors(
            activeEdge['deltaTex'].clone().multiplyScalar(step),
            this._texCorners[ startIndex ]
        );

        activeEdge['deltaPos'].multiplyScalar(this._sliceSpacing);
        activeEdge['deltaTex'].multiplyScalar(this._sliceSpacing);
      }

      expirations.push(activeEdge, cornerDistance[ endIndex ]);
      nextEdge++;
      if (nextEdge<activeEdges.length)
         activeEdges[ nextEdge] = activeEdge;
      else
         activeEdges.add(activeEdge);
      //activeEdges[ nextEdge++ ] = activeEdge;
      return activeEdge;
    };

    for (i = 0; i < 3; i = (i + 1) | 0) {
      var activeEdge = createEdge(
          maxCorner, cornerNeighbors[ maxCorner ][ i ]);
      if (activeEdge!=null) {//gl
        activeEdge['prev'] = (i + 2) % 3;
        activeEdge['next'] = (i + 1) % 3;
      }
    }

    int nextIndex = 0;

    while (sliceDistance > minDistance) {
      //print("ooo"+expirations.contents.length.toString());
      //print("nn"+sliceDistance.toString());
      while (/*expirations.contents.length>0&&*/expirations  //gl
          .top()
          ['priority'] >= sliceDistance) {
        var edge = expirations
            .pop()
            ['object'];

        if (edge['expired']) {
          continue;
        }

        if (
        edge['endIndex'] != activeEdges[ edge['prev'] ]['endIndex'] &&
        edge['endIndex'] != activeEdges[ edge['next'] ]['endIndex']
        ) {
          // split this edge.
          edge['expired'] = true;

          // create two new edges.
          var activeEdge1 = createEdge(
              edge['endIndex'],
              incomingEdges[ edge['endIndex'] ][ edge['startIndex'] ]
          );
          if (activeEdge1!=null) { //gl
            activeEdge1['prev'] = edge['prev'];
            activeEdges[ edge['prev'] ]['next'] = nextEdge - 1;
            activeEdge1['next'] = nextEdge;


            var activeEdge2 = createEdge(
                edge['endIndex'],
                incomingEdges[ edge['endIndex'] ][ activeEdge1['endIndex'] ]
            );
            if (activeEdge2 != null) {
              activeEdge2['prev'] = nextEdge - 2;
              activeEdge2['next'] = edge['next'];

              activeEdges[activeEdge2['next']]['prev'] = nextEdge - 1;
              firstEdge = nextEdge - 1;
            }
          }
        } else {
          // merge edge.
          var prev;
          var next;

          if (edge['endIndex'] == activeEdges[ edge['prev'] ]['endIndex']) {
            prev = activeEdges[ edge['prev'] ];
            next = edge;
          } else {
            prev = edge;
            next = activeEdges[ edge['next'] ];
          }

          prev['expired'] = true;
          next['expired'] = true;

          // make new edge
          var activeEdge = createEdge(
              edge['endIndex'],
              incomingEdges[ edge['endIndex'] ][ prev['startIndex'] ]
          );
          if (activeEdge!=null) {
            activeEdge['prev'] = prev['prev'];
            activeEdges[ activeEdge['prev'] ]['next'] = nextEdge - 1;
            activeEdge['next'] = next['next'];
            activeEdges[ activeEdge['next'] ]['prev'] = nextEdge - 1;
            firstEdge = nextEdge - 1;
          }
        }
      }

      var cur = firstEdge;
      var count = 0;

      do {
        ++count;
        var activeEdge = activeEdges[ cur ];
        this._points.addAll(
            [activeEdge['pos'].x,
            activeEdge['pos'].y,
            activeEdge['pos'].z]
        );
        this._texCoords.addAll(
            [activeEdge['tex'].x,
            activeEdge['tex'].y,
            activeEdge['tex'].z]
        );
        activeEdge['pos'].add(activeEdge['deltaPos']);
        activeEdge['tex'].add(activeEdge['deltaTex']);
        cur = activeEdge['next'];
      } while (cur != firstEdge);

      for (int i = 2; i < count; i = (i + 1) | 0) {

       // print("uuu"+this._indexes.toString()+" uu"+i.toString()+" mm"+nextIndex.toString());
       /* this._indexes.add(nextIndex);
        this._indexes.add((nextIndex+int(i)-1));
        this._indexes.add(nextIndex);*/
        this._indexes.addAll(
            [nextIndex,
              (nextIndex + i - 1),
            nextIndex + i]
        );
      }

      nextIndex += count;
      sliceDistance -= this._sliceSpacing;
    }
  }

  static String texturePath = 'assets/textures/fire/';

///
}


class PriorityQueue {

  List contents = [];
  bool sorted = false;


  sort() {
  //  print("con"+this.contents.toString());
    //this.contents.sort();
    //this.contents = Map.fromEntries(
    //    map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
   // final sorted = SplayTreeMap.from(
   //    this.contents, (key1, key2) => unsorted[key1].compareTo(unsorted[key2]));
   /* List ind=[];
    for (var content in this.contents)
      content['priority']*/
    this.contents.sort((m1, m2) {
      var r = m1["priority"].compareTo(m2["priority"]);
      if (r != 0) return r;
      return m1["priority"].compareTo(m2["priority"]);
    });

    this.sorted = true;
  }

  pop() {
    if (!this.sorted) {
      this.sort();
    }
    return this.contents.removeLast(); //.pop();
  }

  top() {
    if (!this.sorted) {
      this.sort();
    }
    //print("mmm"+this.contents.length.toString()+'ooo'+this.contents[this.contents.length-1].toString());
    return this.contents[ this.contents.length - 1 ];
  }

  push(object, priority) {
    this.contents.add({ 'object': object, 'priority': priority});
    this.sorted = false;
  }

}

