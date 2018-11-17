/** 
 * AA597 Homework 1, Problem 2.8
 * @author Nathan Isaman
 * The purpose of this class is to allow for various tests of a user-constructed
 * Graph.
 */
import java.util.*;

public class Graph {
	private ArrayList<LinkedList<Integer>> adjList;
	private int verts;
	private Set<Integer> visited;
	private int edges;
	
	/**
	 * This method initializes the graph based on the number of vertices in the
	 * graph.
	 * @param vert	The number of vertices in the graph.
	 * @return	An empty adjacency List.
	 */
	public Graph(int vert) {
		adjList = new ArrayList<LinkedList<Integer>>();
		verts = vert;
		for(int i = 0; i < verts; i++) {
			adjList.add(i,new LinkedList<Integer>());
		}
	}
	
	/**
	 * This method populates the adjacency list.
	 * @param v1	The initial entry of the list row.
	 * @param v2	A vertex to add to the list row.
	 */
	public void addVertex(int v1, int v2) {
		adjList.get(v1 - 1).add(v2);
	}
	
	/**
	 * This method prints the Adjacency List for the constructed Graph.
	 */
	public void printGraph() {
		for(int i = 0; i < verts; i++) {
			System.out.println(i + 1 + " : " + adjList.get(i));
		}
	}
	
	/**
	 * This method determines whether or not the graph is connected.
	 * @return		True if the graph is connected, False otherwise.
	 */
	public boolean isConnected() {
		visited = new HashSet<Integer>();
		Queue<Integer> next = new LinkedList<Integer>();
		//Visiting vertex 1 (index 0) by default
		visited.add(0);									//adding to visited list
		next.addAll(adjList.get(0));					//adding neighbors to queue
		
		while(!next.isEmpty()) {						//keep going until next depleted
			int v = next.remove();						//new vertex to visit
			visited.add(v-1);
			next.addAll(adjList.get(v-1));			    //get the vertex' neighbors
			for(int i = 0; i < next.size(); i++) {		//clear out prev visited 
				int curr = next.remove();
				if(!visited.contains(curr-1)) {
					next.add(curr);
				}
			}
			if(visited.size() == verts) {	//Avoiding a potential inf-loop
				return true;
			}
		}
		return visited.size() == verts;
		
	}
	
	/**
	 * This method checks the degree of each vertex to ensure they are all even.
	 * This is used to determine if a Graph is Eulerian (in addition to isConnected()).
	 * @return	True if all vertices have even degree, False otherwise.
	 */
	public boolean evenDegree() {
		ArrayList<Integer> degrees = new ArrayList<Integer>();
		int degSum = 0;
		for(int i = 0; i < verts; i++) {
			degrees.add(i,adjList.get(i).size());		//catalog degrees for each vertex
			degSum += adjList.get(i).size();
		}
		edges = degSum / 2;								//#edges = Tr(deg) / 2;
		for(int j = 0; j < verts; j++) {
			if(degrees.get(j) % 2 == 1) {			    //degree MOD 2 = 1 => odd degree
				return false;
			}
		}
		return true;
	}
	
	/**
	 * This method determines if a graph has an Eulerian Tour (closed) and, if it does,
	 * prints the tour to the console.
	 * @return True if ET exists, False otherwise.
	 */
	public boolean eulerianTour(){
		if(!this.isConnected() || !this.evenDegree()) {
			return false;
		}
		this.printTour();
		return true;		
	}
	
	/**
	 * This method is used to print the Eulerian Tour for a given graph.
	 */
	private void printTour() {
		List<Integer> options = new LinkedList<Integer>();
		List<Integer> tour = new ArrayList<Integer>();
		//Starting at node 1 (index 0) by default;
		int v1 = 1;
		options.addAll(adjList.get(v1 - 1));
		int v2;
		tour.add(v1);
		while(edges != 0) {
			Random choice = new Random();
			int num = choice.nextInt(options.size());
			v2 = options.get(num);
			this.removeVertex(v1, v2);
			tour.add(v2);
			v1 = v2;
			options.clear();
			options.addAll(adjList.get(v1 - 1));			
		}
		System.out.println(tour);
	}
	
	/**
	 * This method removes an edge between v1 and v2.
	 * @param v1	Initial vertex
	 * @param v2	Connected vertex
	 */
	private void removeVertex(int v1, int v2) {
		adjList.get(v1 - 1).removeFirstOccurrence(v2);
		adjList.get(v2 - 1).removeFirstOccurrence(v1);
		edges--;
	}
}
