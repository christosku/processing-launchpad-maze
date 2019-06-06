class Node {
  int x,y;
  Node parent = null;
  boolean searched = false;
  ArrayList<Node> edges = new ArrayList<Node>();
  
  Node(int xPos, int yPos) {
    x = xPos;
    y = yPos;
  }
  
  void connect(Node neighbor) {
    edges.add(neighbor);
    //neighbor.edges.add(this);
  }
  
  String pos() {
    return str(x) + str(y);
  }
}
