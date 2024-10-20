part of renderer_nodes;

class ExpressionNode extends TempNode {
  late String snipped;

  String? name;

  ExpressionNode([snipped = '', nodeType = 'void']) : super(nodeType) {
    generateLength = 1;

    this.snipped = snipped;
  }

  generate([builder, output]) {
    var type = this.getNodeType(builder);
    var snipped = this.snipped;

    if (type == 'void') {
      builder.addFlowCode(snipped);
    } else {
      return "( ${snipped} )";
    }
  }
}
