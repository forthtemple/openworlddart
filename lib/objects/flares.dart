import 'package:openworld/updateable.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;

class Flares {

  createFlares( textureA, textureB) async {

    var textureLoader = new THREE.TextureLoader();
    var flareA =
        await textureLoader.loadAsync(textureA);//"assets/models/ark/lensflare2.jpg");
    var flareB =
        await textureLoader.loadAsync(textureB);//"assets/models/ark/lensflare0.png");
    var fct = 0.03;
    var sa = 2 * fct, sb = 5 * fct;

    fct = 0.02;
    var params = {
      "a": {
        'map': flareA,
        'color': 0xffffff,
        'blending': THREE.AdditiveBlending
      },
      "b": {
        'map': flareB,
        'color': 0xffffff,
        'blending': THREE.AdditiveBlending
      },
      "ar": {
        'map': flareA,
        'color': 0xff0000,
        'blending': THREE.AdditiveBlending
      },
      "br": {
        'map': flareB,
        'color': 0xff0000,
        'blending': THREE.AdditiveBlending
      }
    };

    var flares = [
// front
      [
        "a",
        sa,
        [47, 38, 120]
      ],
      [
        "a",
        sa,
        [40, 38, 120]
      ],
      [
        "a",
        sa,
        [32, 38, 122]
      ],
      [
        "b",
        sb,
        [47, 38, 120]
      ],
      [
        "b",
        sb,
        [40, 38, 120]
      ],
      [
        "b",
        sb,
        [32, 38, 122]
      ],
      [
        "a",
        sa,
        [-47, 38, 120]
      ],
      [
        "a",
        sa,
        [-40, 38, 120]
      ],
      [
        "a",
        sa,
        [-32, 38, 122]
      ],
      [
        "b",
        sb,
        [-47, 38, 120]
      ],
      [
        "b",
        sb,
        [-40, 38, 120]
      ],
      [
        "b",
        sb,
        [-32, 38, 122]
      ],
// back
      [
        "ar",
        sa,
        [22, 50, -123]
      ],
      [
        "ar",
        sa,
        [32, 49, -123]
      ],
      [
        "br",
        sb,
        [22, 50, -123]
      ],
      [
        "br",
        sb,
        [32, 49, -123]
      ],
      [
        "ar",
        sa,
        [-22, 50, -123]
      ],
      [
        "ar",
        sa,
        [-32, 49, -123]
      ],
      [
        "br",
        sb,
        [-22, 50, -123]
      ],
      [
        "br",
        sb,
        [-32, 49, -123]
      ],
    ];

    THREE.Group group=THREE.Group();
    for (var i = 0; i < flares.length; i++) {
      var p = params[flares[i][0]];

      double s = flares[i][1] as double;

      List<int> item = flares[i][2] as List<int>;
      var x = item[0] * fct;
      var y = item[1] * fct;
      var z = item[2] * fct;

      var material = new THREE.SpriteMaterial(p);
      var sprite = new THREE.Sprite(material);

      var spriteWidth = 128;
      var spriteHeight = 128;

      sprite.scale.set(s * spriteWidth, s * spriteHeight, s);
      sprite.position.set(x, y, z);

      group.add(sprite);

    }
    return group;
  }
}
