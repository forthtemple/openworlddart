library three_webgpu;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:openworld_gl/native-array/index.dart';
// import 'package:flutter_webgpu/flutter_webgpu.dart';
import 'package:openworld/three_dart/extra/console.dart';
import 'package:openworld/three_dart/three_dart.dart';

import '../nodes/index.dart';



part './extension_helper.dart';
part './constants.dart';
part './WebGPURenderer.dart';
part './WebGPUInfo.dart';
part './WebGPUProperties.dart';

part './WebGPUAttributes.dart';
part './WebGPUGeometries.dart';
part './WebGPUTextures.dart';
part './WebGPUObjects.dart';
part './WebGPUComputePipelines.dart';

part './WebGPUProgrammableStage.dart';
part './WebGPURenderPipeline.dart';
part './WebGPURenderPipelines.dart';
part './WebGPUBinding.dart';
part './WebGPUBindings.dart';
part './WebGPUBackground.dart';
part './WebGPURenderLists.dart';

part './nodes/WebGPUNodes.dart';
part './nodes/WebGPUNodeBuilder.dart';

part './WebGPUTextureUtils.dart';
part './WebGPUSampler.dart';
part './nodes/WebGPUNodeSampler.dart';
part './WebGPUSampledTexture.dart';
part './WebGPUStorageBuffer.dart';
part './nodes/WebGPUNodeSampledTexture.dart';
part './WebGPUUniformBuffer.dart';
part './WebGPUUniformsGroup.dart';
part './WebGPUBufferUtils.dart';
part './nodes/WebGPUNodeUniformsGroup.dart';
part './nodes/WebGPUNodeUniform.dart';
part './WebGPUTextureRenderer.dart';
part './WebGPUUniform.dart';
