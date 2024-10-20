import 'package:openworld/updateable.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;

class Smoke extends Updateable
{
  THREE.Group smokeGroup=THREE.Group();

  createSmoke(path,{numparticles:20}) async
  {
    var particleorig=await OPENWORLD.Sprite.loadSprite(path,2000,2000,ambient:false);
    smokeGroup=THREE.Group();
    for (var p = 0; p < numparticles; p++) {
      var particle =  OPENWORLD.Sprite.cloneSprite(particleorig);
      // new THREE.Mesh(smokeGeo,smokeMaterial);
      particle.position.set(OPENWORLD.Math.random()*500-250, OPENWORLD.Math.random()*500-250,OPENWORLD.Math.random()*500-250);
      particle.rotation.z = OPENWORLD.Math.random() * 360;
      //   particle.rotation=THREE.Euler(2.0*(OPENWORLD.Math.random()-0.5),2.0*(OPENWORLD.Math.random()-0.5),2.0*(OPENWORLD.Math.random()-0.5));
      //  particle.up=THREE.Vector3(1.0*(OPENWORLD.Math.random()-0.5),1.0*(OPENWORLD.Math.random()-0.5),1.0*(OPENWORLD.Math.random()-0.5));
      var fct=3*2;
      particle.up=THREE.Vector3(fct*0.25*(OPENWORLD.Math.random()-0.5),fct*1.0*(OPENWORLD.Math.random()+0.1),fct*0.25*(OPENWORLD.Math.random()-0.5));
      //print("uuu"+particle.up.x.toString()+' '+particle.up.y.toString()+' '+particle.up.z.toString());
      smokeGroup.add(particle);

      //smokeParticles.push(particle);
    }
    return smokeGroup;
    //OPENWORLD.Space.worldToLocalSurfaceObjHide(smokeGroup,  -0.42, 1.35, 0.21,2);
//    OPENWORLD.Space.worldToLocalSurfaceObj(smokeGroup,  7.7, 1.0, 0.25);

   // smokeGroup.scale.set(0.00007,0.00007,0.00007);
  }

  @override
  update(frameTime, elapsedTime)
  {
    if (smokeGroup.visible) {
      for (var particle in smokeGroup.children) {
        //THREE.Vector3 rot=particle.rotation;
        //rot.mu

        particle.position.add(particle.up.multiplyScalar(1.0));
        // print("pos"+particle.position.x.toString()+" "+particle.position.y.toString()+" "+particle.position.z.toString());


        if (/*particle.position.x.abs()>1000||*/particle.position.y >
            800 /*||particle.position.z.abs()>1000*/) {
          /* var fct=3;
        particle.up=THREE.Vector3(fct*0.25*(OPENWORLD.Math.random()-0.5),fct*1.0*(OPENWORLD.Math.random())+0.1,fct*0.25*(OPENWORLD.Math.random()-0.5));
        particle.position.y=-1000;
        particle.position.x=OPENWORLD.Math.random()*500-250;
        particle.position.z=OPENWORLD.Math.random()*500-250;*/
          if (particle.scale.x < 0.01) {
            //particle is now small enough to reset particle
            //particle.scale.set(1.0, 1.0, 1.0);
            var fct = 3*2;
            particle.up = THREE.Vector3(
                fct * 0.25 * (OPENWORLD.Math.random() - 0.5),
                fct * 1.0 * (OPENWORLD.Math.random()) + 0.1,
                fct * 0.25 * (OPENWORLD.Math.random() - 0.5));
            particle.position.x = OPENWORLD.Math.random() * 500 - 250;
            particle.position.z = OPENWORLD.Math.random() * 500 - 250;
            particle.position.y =  OPENWORLD.Math.random() * 500 - 250;
          } else {
            particle.scale.x -= 0.1 * frameTime;
            particle.scale.y -= 0.1 * frameTime;
            particle.scale.z -= 0.1 * frameTime;
            particle.up.y *= 1 + 0.1 * frameTime;
            /* particle.scale.set(particle.scale.x * (1 - 0.1*frameTime),
              particle.scale.y * (1 -  0.1*frameTime),
              particle.scale.z * (1 -  0.1*frameTime));*/
          }

          //particle.children[0].material.opacity*=(1-0.1*frameTime);
          //particle.up = THREE.Vector3(0.5 * (OPENWORLD.Math.random() - 0.5),
          //    0.5 * (OPENWORLD.Math.random() - 0.5),
          //    0.5 * (OPENWORLD.Math.random() - 0.5));
        } else if (particle.scale.x<1) {
          // gradually grow smoke
          particle.scale.x += 0.1 * frameTime;
          particle.scale.y += 0.1 * frameTime;
          particle.scale.z += 0.1 * frameTime;
        }
        //OPENWORLD.Space.objForward(particle,1);

        //particle.
        //particle.position.x+=2*(OPENWORLD.Math.random()-0.5);
        // particle.position.y+=2*(OPENWORLD.Math.random()-0.5);
        //particle.position.z+=2*(OPENWORLD.Math.random()-0.5);

      }
    }
  }
}