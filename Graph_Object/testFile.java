
/**
 * This file contains tests for the methods in Graph.java
 * @author Nathan Isaman
 */
public class testFile {
	public static void main(String args[]) {
		
		//Problem 2.8--------------------------------------------
		Graph G1 = new Graph(4);
		//Graph should be connected.
		G1.addVertex(1, 2);
		G1.addVertex(2, 1);
		G1.addVertex(2, 3);
		G1.addVertex(3, 2);
		G1.addVertex(3, 4);
		G1.addVertex(4, 3);
		System.out.println("\nAdjacency List for G1:");
		G1.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G1.isConnected());
		
		Graph G2 = new Graph(4);
		//Graph should be disconnected.
		//G2.addVertex(1);
		G2.addVertex(2, 3);
		G2.addVertex(3, 2);
		G2.addVertex(3, 4);
		G2.addVertex(4, 3);
		System.out.println("\nAdjacency List for G2:");
		G2.printGraph();
		System.out.println("System is Disconnected.");
	    System.out.println("isConnected = " + G2.isConnected());
		
		Graph G3 = new Graph(4);
		//Graph should be disconnected.
		G3.addVertex(1, 2);
		G3.addVertex(2, 1);
		G3.addVertex(3, 4);
		G3.addVertex(4, 3);
		System.out.println("\nAdjacency List for G3:");
		G3.printGraph();
		System.out.println("System is Disconnected.");
		System.out.println("isConnected = " + G3.isConnected());
		
		Graph G4 = new Graph(6);
		//Graph should be connected.
		G4.addVertex(1, 2);
		G4.addVertex(1, 6);
		G4.addVertex(2, 1);
		G4.addVertex(2, 3);
		G4.addVertex(3, 2);
		G4.addVertex(3, 4);
		G4.addVertex(4, 3);
		G4.addVertex(4, 5);
		G4.addVertex(5, 4);
		G4.addVertex(5, 6);
		G4.addVertex(6, 1);
		G4.addVertex(6, 5);
		System.out.println("\nAdjacency List for G4:");
		G4.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G4.isConnected());
		
		Graph G5 = new Graph(6);
		//Graph should be disconnected.
		G5.addVertex(1, 2);
		G5.addVertex(1, 6);
		G5.addVertex(2, 1);
		G5.addVertex(2, 1);
		G5.addVertex(3, 2);
		G5.addVertex(3, 4);
		G5.addVertex(4, 3);
		G5.addVertex(4, 5);
		G5.addVertex(4, 4);
		//G5.addVertex(5, 6);
		G5.addVertex(6, 1);
		//G5.addVertex(6, 5);
		System.out.println("\nAdjacency List for G5:");
		G5.printGraph();
		System.out.println("System is Disconnected.");
		System.out.println("isConnected = " + G5.isConnected());
		
		Graph G6 = new Graph(9);
		//Graph should be Connected.
		G6.addVertex(1, 2);
		G6.addVertex(2, 1);
		G6.addVertex(2, 4);
		G6.addVertex(4, 2);
		G6.addVertex(4, 3);
		G6.addVertex(4, 6);
		G6.addVertex(4, 7);
		G6.addVertex(3, 5);
		G6.addVertex(3, 4);
		G6.addVertex(5, 3);
		G6.addVertex(6, 4);
		G6.addVertex(6, 7);
		G6.addVertex(7, 4);
		G6.addVertex(7, 6);
		G6.addVertex(7, 8);
		G6.addVertex(8, 7);
		G6.addVertex(8, 9);
		G6.addVertex(9, 8);
		System.out.println("\nAdjacency List for G6:");
		G6.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G6.isConnected());
		
		Graph G7 = new Graph(9);
		//Graph should be Connected.
		G7.addVertex(1, 2);
		G7.addVertex(2, 1);
		G7.addVertex(2, 4);
		G7.addVertex(4, 2);
		G7.addVertex(4, 3);
		G7.addVertex(4, 6);
		G7.addVertex(4, 7);
		G7.addVertex(3, 5);
		G7.addVertex(3, 4);
		G7.addVertex(5, 3);
		G7.addVertex(6, 4);
		G7.addVertex(6, 7);
		G7.addVertex(7, 4);
		G7.addVertex(7, 6);
		G7.addVertex(7, 8);
		G7.addVertex(8, 7);
		//G7.addVertex(8, 9);
		//G7.addVertex(9, 8);
		System.out.println("\nAdjacency List for G7:");
		G7.printGraph();
		System.out.println("System is Disconnected.");
		System.out.println("isConnected = " + G7.isConnected());
		
		//Additional Problem 3 -------------------------------------------------
		//Testing evenDegree() method
		Graph G8 = new Graph(4);
		G8.addVertex(1, 2);
		G8.addVertex(1, 4);
		G8.addVertex(2, 1);
		G8.addVertex(2, 3);
		G8.addVertex(3, 2);
		G8.addVertex(3, 4);
		G8.addVertex(4, 3);
		G8.addVertex(4, 1);
		System.out.println("\nAdjacency List for G8:");
		G8.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G8.isConnected());
		System.out.println("The graph is 2-regular.");
		System.out.println("Even Degree? : " + G8.evenDegree());
		
		Graph G9 = new Graph(4);
		G9.addVertex(1, 2);
		G9.addVertex(1, 4);
		G9.addVertex(1,3);
		G9.addVertex(2, 1);
		G9.addVertex(2, 3);
		G9.addVertex(3, 2);
		G9.addVertex(3,1);
		G9.addVertex(3, 4);
		G9.addVertex(4, 3);
		G9.addVertex(4, 1);
		System.out.println("\nAdjacency List for G9:");
		G9.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G9.isConnected());
		System.out.println("The graph contains non-even degrees.");
		System.out.println("Even Degree? : " + G9.evenDegree());
		
		//Testing the Eulerian Tour method
		Graph G10 = new Graph(5);		//K5 Graph
		G10.addVertex(1, 2);
		G10.addVertex(1, 3);
		G10.addVertex(1, 4);
		G10.addVertex(1, 5);
		G10.addVertex(2, 1);
		G10.addVertex(2, 3);
		G10.addVertex(2, 4);
		G10.addVertex(2, 5);
		G10.addVertex(3, 1);
		G10.addVertex(3, 2);
		G10.addVertex(3, 4);
		G10.addVertex(3, 5);
		G10.addVertex(4, 1);
		G10.addVertex(4, 2);
		G10.addVertex(4, 3);
		G10.addVertex(4, 5);
		G10.addVertex(5, 1);
		G10.addVertex(5, 2);
		G10.addVertex(5, 3);
		G10.addVertex(5, 4);
		System.out.println("\nAdjacency List for G10:");
		G10.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G10.isConnected());
		System.out.println("The graph is 4-regular.");
		System.out.println("Even Degree? : " + G10.evenDegree());
		System.out.println("The Eulerian Tour:" + G10.eulerianTour());
		
		Graph G11 = new Graph(7);		//K7 Graph
		G11.addVertex(1, 2);
		G11.addVertex(1, 3);
		G11.addVertex(1, 4);
		G11.addVertex(1, 5);
		G11.addVertex(1, 6);
		G11.addVertex(1, 7);
		G11.addVertex(2, 1);
		G11.addVertex(2, 3);
		G11.addVertex(2, 4);
		G11.addVertex(2, 5);
		G11.addVertex(2, 6);
		G11.addVertex(2, 7);
		G11.addVertex(3, 1);
		G11.addVertex(3, 2);
		G11.addVertex(3, 4);
		G11.addVertex(3, 5);
		G11.addVertex(3, 6);
		G11.addVertex(3, 7);
		G11.addVertex(4, 1);
		G11.addVertex(4, 2);
		G11.addVertex(4, 3);
		G11.addVertex(4, 5);
		G11.addVertex(4, 6);
		G11.addVertex(4, 7);
		G11.addVertex(5, 1);
		G11.addVertex(5, 2);
		G11.addVertex(5, 3);
		G11.addVertex(5, 4);
		G11.addVertex(5, 6);
		G11.addVertex(5, 7);
		G11.addVertex(6, 1);
		G11.addVertex(6, 2);
		G11.addVertex(6, 3);
		G11.addVertex(6, 4);
		G11.addVertex(6, 5);
		G11.addVertex(6, 7);
		G11.addVertex(7, 1);
		G11.addVertex(7, 2);
		G11.addVertex(7, 3);
		G11.addVertex(7, 4);
		G11.addVertex(7, 5);
		G11.addVertex(7, 6);
		System.out.println("\nAdjacency List for G11:");
		G11.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G11.isConnected());
		System.out.println("The graph is 6-regular.");
		System.out.println("Even Degree? : " + G11.evenDegree());
		System.out.println("The Eulerian Tour:" + G11.eulerianTour());
		
		//Should return false for Eulerian Tour
		Graph G12 = new Graph(4);
		G12.addVertex(1, 2);
		G12.addVertex(1, 4);
		G12.addVertex(1,3);
		G12.addVertex(2, 1);
		G12.addVertex(2, 3);
		G12.addVertex(3, 2);
		G12.addVertex(3,1);
		G12.addVertex(3, 4);
		G12.addVertex(4, 3);
		G12.addVertex(4, 1);
		System.out.println("\nAdjacency List for G12:");
		G12.printGraph();
		System.out.println("System is Connected.");
		System.out.println("isConnected = " + G12.isConnected());
		System.out.println("The graph contains non-even degrees.");
		System.out.println("Even Degree? : " + G12.evenDegree());
		System.out.println("The Eulerian Tour:" + G12.eulerianTour());
	}

}
