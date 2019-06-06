class Graph {
  HashMap<Integer,Node> graph = new HashMap<Integer,Node>();
  Node start = null;
  Node end = null;
  ArrayList<Node> nodes = new ArrayList<Node>();
  
  Graph() {
    println("Created the graph");
  }
  
  void setStart(Node s) {
    start = s;
  }
  
  void setEnd(Node e) {
    end = e;
  }
  
  Node addNode(int x, int y) {
    Node n = new Node(x,y);
    graph.put(x+10*y,n);
    nodes.add(n);
    return n;
  }
  
  void clear() {
    for (int i=0; i<nodes.size(); i++) {
      nodes.get(i).searched = false;
      nodes.get(i).parent = null;
    }
  }
}
