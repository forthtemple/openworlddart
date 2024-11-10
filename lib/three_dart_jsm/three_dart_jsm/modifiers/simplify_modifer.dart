part of jsm_modifiers;

class SimplifyModifier {
	BufferGeometry modify(BufferGeometry geometry, int count ) {
		geometry = geometry.clone();
		final attributes = geometry.attributes;
		
    List<String> keys = [];// this modifier can only process indexed and non-indexed geomtries with a position attribute
		attributes.keys.forEach((name){
      keys.add(name);
		});

    for(String name in keys){
			if(name != 'position' ){
        geometry.deleteAttribute( name );
      }
    }

		geometry = BufferGeometryUtils.mergeVertices( geometry );

		//
		// put data of original geometry in different data structures
		//

		final List<Vertex> vertices = [];
		final List<Tri> faces = [];

		// add vertices

		final positionAttribute = geometry.getAttribute( 'position' );

		for ( int i = 0; i < positionAttribute.count; i ++ ) {
			final v = Vector3().fromBufferAttribute( positionAttribute, i );
			final vertex = Vertex( v );
			vertices.add(vertex);
		}

		// add faces

		BufferAttribute<NativeArray<num>>? index = geometry.getIndex();

		if ( index != null ) {
			for ( int i = 0; i < index.count; i += 3 ) {
				final a = index.getX( i )!.toInt();
				final b = index.getX( i + 1 )!.toInt();
				final c = index.getX( i + 2 )!.toInt();

				final triangle = Tri( vertices[ a ], vertices[ b ], vertices[ c ], a, b, c );
				faces.add( triangle );
			}
		} 
    else{
			for(int i = 0; i < positionAttribute.count; i += 3){

				final a = i;
				final b = i + 1;
				final c = i + 2;

				final triangle = Tri(vertices[a], vertices[b], vertices[c], a, b, c);
				faces.add(triangle);
			}
		}

		// compute all edge collapse costs

		for ( int i = 0, il = vertices.length; i < il; i ++ ) {
			SMUtil.computeEdgeCostAtVertex( vertices[ i ] );
		}

		Vertex? nextVertex;
		int z = count;

		while (z != 0) {
			nextVertex = SMUtil.minimumCostEdge(vertices);

			if (nextVertex == null) {
				print( 'THREE.SimplifyModifier: No next vertex' );
				break;
			}

			SMUtil.collapse( vertices, faces, nextVertex, nextVertex.collapseNeighbor);
      z--;
		}

		//

		final simplifiedGeometry = BufferGeometry();
		List<double> position = [];
		//
		for (int i = 0; i < vertices.length; i ++ ) {
			final vertex = vertices[i].position;
      position.addAll([vertex.x,vertex.y,vertex.z]);
			// cache final index to GREATLY speed up faces reconstruction
			vertices[i].id = i;
		}

		//
    List<int> indexs = [];
		for (int i = 0; i < faces.length; i ++ ) {
			final face = faces[i];
      indexs.addAll([face.v1!.id,face.v2!.id,face.v3!.id]);
		}

		//
		simplifiedGeometry.setAttribute( 'position', Float32BufferAttribute( Float32Array.from(position), 3 ) );
		simplifiedGeometry.setIndex( indexs );

		return simplifiedGeometry;
	}
}

class SMUtil{
  static void pushIfUnique(array, Vertex object) {
    if ( array.indexOf( object ) == - 1 ) array.add( object );
  }

  static void removeFromArray( array, object) {
    if(array == null) return;
    final k = array.indexOf(object);
    if ( k > - 1 ){
      array.removeAt(k);
    }
  }

  static computeEdgeCollapseCost( u, v ) {
    // if we collapse edge uv by moving u to v then how
    // much different will the model change, i.e. the "error".
    final edgelength = v.position.distanceTo( u.position );
    double curvature = 0;

    final sideFaces = [];

    // find the "sides" triangles that are on the edge uv
    for (int i = 0, il = u.faces.length; i < il; i ++ ) {
      final Tri face = u.faces[ i ];
      if (face.hasVertex(v)) {
        sideFaces.add(face);
      }
    }

    // use the triangle facing most away from the sides
    // to determine our curvature term
    for (int i = 0, il = u.faces.length; i < il; i ++ ) {
      double minCurvature = 1;
      final Tri face = u.faces[i];

      for (int j = 0; j < sideFaces.length; j ++ ) {
        final sideFace = sideFaces[j];
        // use dot product of face normals.
        double dotProd = face.normal.dot(sideFace.normal).toDouble();
        minCurvature = Math.min( minCurvature, ( 1.001 - dotProd ) / 2 );
      }

      curvature = Math.max( curvature, minCurvature );
    }

    // crude approach in attempt to preserve borders
    // though it seems not to be totally correct
    const borders = 0;

    if ( sideFaces.length < 2 ) {
      // we add some arbitrary cost for borders,
      // borders += 10;
      curvature = 1;
    }

    final amt = edgelength * curvature + borders;

    return amt;
  }

  static void computeEdgeCostAtVertex(Vertex v ) {
    // compute the edge collapse cost for all edges that start
    // from vertex v.  Since we are only interested in reducing
    // the object by selecting the min cost edge at each step, we
    // only cache the cost of the least cost edge at this vertex
    // (in member variable collapse) as well as the value of the
    // cost (in member variable collapseCost).

    if ( v.neighbors.length == 0 ) {
      // collapse if no neighbors.
      v.collapseNeighbor = null;
      v.collapseCost = -0.01;
      return;
    }

    v.collapseCost = 100000;
    v.collapseNeighbor = null;

    // search all neighboring edges for "least cost" edge
    for (int i = 0; i < v.neighbors.length; i ++ ) {
      final collapseCost = computeEdgeCollapseCost( v, v.neighbors[ i ] );

      if(v.collapseNeighbor == null){
        v.collapseNeighbor = v.neighbors[i];
        v.collapseCost = collapseCost;
        v.minCost = collapseCost;
        v.totalCost = 0;
        v.costCount = 0;
      }

      v.costCount++;
      v.totalCost += collapseCost;

      if ( collapseCost < v.minCost ) {
        v.collapseNeighbor = v.neighbors[ i ];
        v.minCost = collapseCost;
      }
    }

    // we average the cost of collapsing at this vertex
    v.collapseCost = v.totalCost / v.costCount;
    // v.collapseCost = v.minCost;
  }

  static void removeVertex(Vertex v,List<Vertex> vertices ) {
    while ( v.neighbors.isNotEmpty ) {
      final n = v.neighbors.removeLast();
      removeFromArray( n.neighbors, v );
    }

    removeFromArray( vertices, v );
  }

  static void removeFace(Tri f, List<Tri> faces ) {
    removeFromArray( faces, f );

    if(f.v1 != null) removeFromArray(f.v1?.faces, f);
    if(f.v2 != null) removeFromArray(f.v2?.faces, f);
    if(f.v3 != null) removeFromArray(f.v3?.faces, f);

    // TODO optimize this!
    final vs = [f.v1, f.v2, f.v3];

    for(int i = 0; i < 3; i ++){
      final v1 = vs[i];
      final v2 = vs[(i + 1) % 3];

      if(v1 == null || v2 == null) continue;
      v1.removeIfNonNeighbor(v2);
      v2.removeIfNonNeighbor(v1);
    }
  }

  static void collapse(List<Vertex> vertices,List<Tri> faces, Vertex u, Vertex? v){ // u and v are pointers to vertices of an edge
    // Collapse the edge uv by moving vertex u onto v
    if (v == null) {
      // u is a vertex all by itself so just delete it..
      removeVertex( u, vertices );
      return;
    }

    final tmpVertices = [];

    for (int i = 0; i < u.neighbors.length; i ++ ) {
      tmpVertices.add( u.neighbors[ i ] );
    }


    // delete triangles on edge uv:
    for (int i = u.faces.length - 1; i >= 0; i -- ) {
      if(u.faces[i] != null && u.faces[ i ]!.hasVertex( v ) ) {
        removeFace( u.faces[ i ]!, faces );
      }
    }

    // update remaining triangles to have v instead of u
    for (int i = u.faces.length - 1; i >= 0; i -- ) {
      if(u.faces[i] != null){
        u.faces[i]!.replaceVertex(u, v);
      }
    }


    removeVertex( u, vertices );

    // recompute the edge collapse costs in neighborhood
    for (int i = 0; i < tmpVertices.length; i ++ ) {
      computeEdgeCostAtVertex( tmpVertices[ i ] );
    }
  }



  static Vertex? minimumCostEdge(List<Vertex> vertices ) {
    if(vertices.isEmpty) return null;
    // O(n * n) approach. TODO optimize this
    Vertex least = vertices[0];

    for (int i = 0; i < vertices.length; i ++ ) {
      if ( vertices[i].collapseCost < least.collapseCost ) {
        least = vertices[ i ];
      }
    }

    return least;
  }
}


// we use a triangle class to represent structure of face slightly differently

class Tri {
  late Vertex? v1;
  late Vertex? v2;
  late Vertex? v3;

  late int a;
  late int b;
  late int c;

  Vector3 normal = Vector3();

  final _cb = Vector3();
  final _ab = Vector3();

	Tri(this.v1,this.v2,this.v3,this.a,this.b,this.c) {
		computeNormal();

		v1?.faces.add(this);
		v1?.addUniqueNeighbor(v2);
		v1?.addUniqueNeighbor(v3);

		v2?.faces.add(this);
		v2?.addUniqueNeighbor(v1);
		v2?.addUniqueNeighbor(v3);


		v3?.faces.add(this);
		v3?.addUniqueNeighbor(v1);
		v3?.addUniqueNeighbor(v2);
	}

	void computeNormal() {
		final vA = this.v1!.position;
		final vB = this.v2!.position;
		final vC = this.v3!.position;

		_cb.subVectors( vC, vB );
		_ab.subVectors( vA, vB );
		_cb.cross( _ab ).normalize();

		this.normal.copy( _cb );
	}

	bool hasVertex(Vertex v){
		return v == this.v1 || v == this.v2 || v == this.v3;
	}

	void replaceVertex(Vertex oldv, Vertex newv) {
		if (oldv == this.v1 ) this.v1 = newv;
		else if (oldv == this.v2 ) this.v2 = newv;
		else if (oldv == this.v3 ) this.v3 = newv;

		SMUtil.removeFromArray( oldv.faces, this );
		newv.faces.add(this);


		oldv.removeIfNonNeighbor(this.v1);
		this.v1?.removeIfNonNeighbor(oldv);

		oldv.removeIfNonNeighbor(this.v2);
		this.v2?.removeIfNonNeighbor(oldv);

		oldv.removeIfNonNeighbor(this.v3);
		this.v3?.removeIfNonNeighbor(oldv);

		this.v1?.addUniqueNeighbor(this.v2);
		this.v1?.addUniqueNeighbor(this.v3);

		this.v2?.addUniqueNeighbor(this.v1);
		this.v2?.addUniqueNeighbor(this.v3);

		this.v3?.addUniqueNeighbor(this.v1);
		this.v3?.addUniqueNeighbor(this.v2);

		this.computeNormal();
	}
}

class Vertex {
  late Vector3 v;
  late Vector3 position;
  int id = -1;
  List<Tri?> faces = [];
  List<Vertex> neighbors = [];
  
  Vertex? collapseNeighbor;

  double collapseCost = 0;
  double minCost = 0;
  double totalCost = 0;
  int costCount = 0;

	Vertex(this.v) {
		this.position = v;
	}

	void addUniqueNeighbor(Vertex? vertex){
    if(vertex == null) return;
		SMUtil.pushIfUnique(this.neighbors, vertex);
	}

	void removeIfNonNeighbor(Vertex? n){
    if(n == null) return;
		final neighbors = this.neighbors;
		final faces = this.faces;
		final offset = neighbors.indexOf(n);

		if (offset == - 1 ) return;

		for (int i = 0; i < faces.length; i ++ ) {
			if(faces[i] != null && faces[i]!.hasVertex(n)) return;
		}

		neighbors.splice(offset, 1);
	}
}