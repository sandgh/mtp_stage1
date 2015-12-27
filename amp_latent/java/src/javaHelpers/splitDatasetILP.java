package javaHelpers;

/*
 *
 * 
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                       
	/   _ _  _    _. _ |_ |_ 						  /
	/ @(_(_)|_)\/| |(_)| )|_ 						  /
	/       |  /    _/       						  /
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	/      __										  /                                  
	/    /    )                   /   ,         	  /
	/    \        __    __    __ /          __ 		  /
	/     \     /   ) /   ) /   /   /     /   )		  /
	/ (____/___(___(_/___/_(___/___/_____/___/		  /
	/                                   /      		  /
	/                                  /       		  /
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
 *                     
 *
 */

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import net.sf.javailp.Linear;
import net.sf.javailp.OptType;
import net.sf.javailp.Problem;
import net.sf.javailp.Result;
import net.sf.javailp.Solver;
import net.sf.javailp.SolverFactory;
import net.sf.javailp.SolverFactoryLpSolve;

public class splitDatasetILP {
	
static int totNumberofRels_inFile = 0;

static Map<Integer, List<Integer>> relnEntCount = new TreeMap<Integer, List<Integer>>();

//N
static int numEgs = 0;
//R
static int totNumberofRels = 0;
//K
static int numChunks = 0;
//I matrix (#Relation x #NoOfExamples)
static int[][] ent_reln_mat = null;
//count_r Array
static int[] reln_count_mat = null;
//P matrix
static String[][] p_var = null;
//t matrix - used to remove the mod
static String[][] t_var = null;
//stores the IP constraints
static Linear[][] constraint_mat = null;
static Linear[][] constraint_mat_mult_k = null;
static Set<Integer> notGoodRelns = new HashSet<Integer>();
static int theCriticalNo = 1;

	
	/**
	 * This function reads a training file and randomly splits it into non overlapping batch files 
	 * 
	 * @param args
	 * args[1] - Training_File_Path  
	 * args[2] - Batch_File_Path 
	 * args[3] - No_of_Batches
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		
		String datasetFile = args[0];
		numChunks = Integer.parseInt(args[1]);
		
		String chunkDatasetDirName = datasetFile+".chunks";
		
		System.out.println("CWD " + System.getProperty("user.dir"));
		System.out.println("Creating " + numChunks + " chunks from this dataset");
		System.out.println("Storing the chunks in " + chunkDatasetDirName);
		
		/*try {
			System.out.println("Thread Sleeping for 10s. ");
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		
		File chunkDatasetDir = new File(chunkDatasetDirName);
		if(!chunkDatasetDir.getAbsoluteFile().exists())
			chunkDatasetDir.mkdir();
		else {
			System.out.println(chunkDatasetDirName + " exits. So deleting existing contents.");
			for(String fname : chunkDatasetDir.list()){
				File file = new File(chunkDatasetDir + "/" + fname);
				if(file.delete()) 
					System.out.println(file.getCanonicalPath() + " is deleted. ");
			}
		}
		
		//Check if the relation is expressed by at least those mane entity pairs > the no. of chunks we wanna break 
		theCriticalNo = numChunks;
//		theCriticalNo = 1000;
		//Reading Dataset
		System.out.println("Reading Dataset");
//		filterGoodOnlyRelns(datasetFile);
		List<BatchDatasetEntryILP> dataset = readDataset(datasetFile);
		
		//Creating Batches	
		System.out.println("Creating Batches");
//		List<SplittedDatasetILP> splitDataset = splitDatasetILP(dataset, numChunks);
		
		Result resultILP = splitDatasetILP(dataset);
		List<SplittedDatasetILP> splitDataset = getSplittedList(resultILP, dataset);
		
		
		for (int i = 1; i <= splitDataset.size(); i++) {
			//Writing each batch file
			Map<Integer, Integer> mp1 = new TreeMap<Integer, Integer>(); 
			List<BatchDatasetEntryILP> split_examples = splitDataset.get(i - 1).getBatchDatasetEntries();

			for (BatchDatasetEntryILP BatchDatasetEntryILP : split_examples) {
				for(int r:  BatchDatasetEntryILP.getyLabels()){
					if(!mp1.containsKey(r))	mp1.put(r, 0);
					mp1.put(r, mp1.get(r)+1);
				}
			}
			
			for (int reln : mp1.keySet()) 	System.out.print(reln + "=" + mp1.get(reln) + ", ");
			System.out.println();
		}
		
		//Writing Batches to separate Files	
		System.out.println("Writing Batches to File");
		writesplittedDataset(splitDataset, chunkDatasetDirName);
	}
	
	public static void filterGoodOnlyRelns(String filePath)
			throws IOException {
		
		BufferedReader br = new BufferedReader(new FileReader(new File(filePath)));
		//The first line is the total no. of training examples present in the file    
		numEgs = Integer.parseInt(br.readLine());
		br.readLine();

		//Reading the training examples
		for (int i = 0; i < numEgs; i++) { // for each example

			int numYlabels = Integer.parseInt(br.readLine()); // num of y labels
			
			//Get the yLabels for the curr entry
			for (int j = 0; j < numYlabels; j++)
			{
				int relnId = Integer.parseInt(br.readLine());
				List<Integer> al = relnEntCount.get(relnId);
				if(al == null)	al = new ArrayList<Integer>();
				al.add(i+1);
				relnEntCount.put(relnId, al);
			}

			int numMentions = Integer.parseInt(br.readLine()); // num of mentions

			for (int j = 0; j < numMentions; j++)	br.readLine();

		}
		br.close();
		
		for (int reln : relnEntCount.keySet()){
			if(relnEntCount.get(reln).size()<1)	notGoodRelns.add(reln);
			System.out.print(reln + "=" + relnEntCount.get(reln).size() + ",");
		}
		System.out.println("\n");
		//relnEntCount.clear();
	}
	
	/**
	 * 
	 * @param filePath - Path to the training file
	 * @return - The training data as a list of BatchDatasetEntryILP instances
	 * @throws IOException
	 */
	public static List<BatchDatasetEntryILP> readDataset(String filePath)
			throws IOException {

		BufferedReader br = new BufferedReader(new FileReader(new File(filePath)));
		Set<Integer> relationsInFile = new HashSet<Integer>();
		
		//The first line is the total no. of training examples present in the file    
		numEgs = Integer.parseInt(br.readLine());

		totNumberofRels = Integer.parseInt(br.readLine()); // total number of relations
		
		ent_reln_mat = new int[totNumberofRels][numEgs];
		
		//This list holds the chunk(pattern) of an example along with the no. of relations present for that example 
		List<BatchDatasetEntryILP> examplePattern = new ArrayList<BatchDatasetEntryILP>();
		StringBuilder sb;
		//Reading the training examples
		for (int i = 0; i < numEgs; i++) { // for each example
			sb = new StringBuilder();

			int numYlabels = Integer.parseInt(br.readLine()); // num of y labels
			sb.append(numYlabels + "\n");
			
			//Get the yLabels for the curr entry
			Set<Integer> yLabels = new HashSet<Integer>();
			for (int j = 0; j < numYlabels; j++)
			{
				int relnId = Integer.parseInt(br.readLine());
				
				//check if enough examples are there
				if(notGoodRelns.contains(relnId))	continue;
				
				sb.append(relnId + "\n"); // each y label
				yLabels.add(relnId);
				relationsInFile.add(relnId);
				
				List<Integer> al = relnEntCount.get(relnId);
				
				if(al == null)	al = new ArrayList<Integer>();
					
				al.add(i+1);
				relnEntCount.put(relnId, al);
				
				ent_reln_mat[relnId-1][i] = 1;
			}

			int numMentions = Integer.parseInt(br.readLine()); // num of mentions
			sb.append(numMentions + "\n");

			for (int j = 0; j < numMentions; j++)
				sb.append(br.readLine() + "\n"); // each mention

			examplePattern.add(new BatchDatasetEntryILP(sb.toString(), numYlabels, i+1, yLabels));///////////////
		}
		br.close();
		totNumberofRels_inFile = relationsInFile.size();
		
		reln_count_mat = new int[totNumberofRels];
		for (int reln : relnEntCount.keySet()){
//			if(notGoodRelns.contains(reln))	continue;
			/**
			 * WTF!!! Don'no how 2*size is working, but somehow the ilp got solved
			 */
			reln_count_mat[reln-1] = (int)(2*relnEntCount.get(reln).size());
//			reln_count_mat[reln-1] = (int)1.5*relnEntCount.get(reln).size();
			
		}
			 
//		for (int reln : relnEntCount.keySet()) 	System.out.print(reln + "=" + relnEntCount.get(reln).size() + ",");
		
		return examplePattern;
	}
	
	/**
	 * 
	 * @param dataset
	 * @param noOfBatches
	 * @return
	 * @throws IOException
	 */
	public static Result splitDatasetILP(
			List<BatchDatasetEntryILP> dataset)
			throws IOException {
		
		SolverFactory factory = new SolverFactoryLpSolve(); // use lp_solve
		factory.setParameter(Solver.VERBOSE, 0); 
		factory.setParameter(Solver.TIMEOUT, 150); // set timeout to 10000 seconds

		createConstraintMatrix();
		
		Problem problem = new Problem();

		//Constraint - All data points are covered
		//for all i in (1 to N) sum_(j=1 to k) P_(ij) >= 1
		for(int i=0; i<numEgs; i++){
			Linear linear = new Linear();
			for(int j=0; j<numChunks; j++){
				linear.add(1, p_var[i][j]);
			}
			problem.add(linear, ">=", 1);
		}
		
		
		//Constraint - P is a binary matrix
		for(int i=0; i<numEgs; i++){
			for(int j=0; j<numChunks; j++){
//				problem.setVarType(p_var[i][j], Integer.class);
				problem.setVarUpperBound(p_var[i][j], 1);
				problem.setVarLowerBound(p_var[i][j], 0);
			}
		}
		
		//Constraint - Each dataset covered all he relations
		// all the IxP entries >= 1
		/*for(int i=0; i<totNumberofRels; i++){
			if(reln_count_mat[i] > theCriticalNo)
			for(int j=0; j<numChunks; j++){
				Linear linear = constraint_mat[i][j];
				problem.add(linear, ">=", 1);
			}
		}*/

		//Constraint - t's are integer 
		for(int i=0; i<totNumberofRels; i++)
			for(int j=0; j<numChunks; j++)
				problem.setVarType(t_var[i][j], Integer.class);

		/******** The obj function ********/
		Linear obj = new Linear();
		for(int i=0; i<totNumberofRels; i++)
			if(reln_count_mat[i] >= theCriticalNo)
			for(int j=0; j<numChunks; j++)
				obj.add(1, t_var[i][j]);
		
		problem.setObjective(obj, OptType.MIN);
		
		/******** Constraints introduce for mod operator in the obj function ********/
		
		for(int i=0; i<totNumberofRels; i++){
			if(reln_count_mat[i] >= theCriticalNo)
			for(int j=0; j<numChunks; j++){
				Linear linear = new Linear(constraint_mat_mult_k[i][j]);
//				linear.add(-1, reln_count_mat[i]);
				linear.add(-1, t_var[i][j]);
				problem.add(linear, "<=", reln_count_mat[i]);
				
				linear = new Linear(constraint_mat_mult_k[i][j]);
//				linear.add(-1, reln_count_mat[i]);
				linear.add(1, t_var[i][j]);
				problem.add(linear, ">=", reln_count_mat[i]);
				
			}
		}
		
		
		//write problem to file
//		BufferedWriter bw;
//		bw = new BufferedWriter(new FileWriter(new File("dataset/problem/problem_"+ numEgs + "_" + numChunks + ".data")));
//		bw.write(problem.toString());
//		bw.close();
		
		
		System.out.println("----- Problem writing - Done -----");
		System.out.println("----- Solving LP -----");
		
		Solver solver = factory.get();
		
		long startTime = Calendar.getInstance().getTimeInMillis();
		
		Result result = solver.solve(problem);
		
		long endTime = Calendar.getInstance().getTimeInMillis();
		System.out.println("Time to solve - " + (endTime - startTime)/1000);

		return result;
	}
	
	static void createConstraintMatrix()
	{
		constraint_mat = new Linear[totNumberofRels][numChunks];
		constraint_mat_mult_k = new Linear[totNumberofRels][numChunks];
		
		for(int i=0; i<totNumberofRels; i++){
			for(int j=0; j<numChunks; j++){
				constraint_mat[i][j]=new Linear();
				constraint_mat_mult_k[i][j]=new Linear();
			}
		}
		
		p_var = new String[numEgs][numChunks];
		for(int i=0; i<numEgs; i++){
			for(int j=0; j<numChunks; j++){
				p_var[i][j] = "P_" + i + "_" + j;
			}
		}
		
		t_var = new String[totNumberofRels][numChunks];
		for(int i=0; i<totNumberofRels; i++){
			for(int j=0; j<numChunks; j++){
				t_var[i][j] = "t_" + i + "_" + j;
			}
		}
		
		for(int i=0; i<totNumberofRels; i++){
			for(int j=0; j<numChunks; j++){
				for(int k=0; k<numEgs; k++){
					Linear ln = constraint_mat[i][j];
					if(ent_reln_mat[i][k] != 0)	ln.add(ent_reln_mat[i][k], p_var[k][j]);
					ln = constraint_mat_mult_k[i][j];
					if(ent_reln_mat[i][k] != 0)	ln.add(numChunks*ent_reln_mat[i][k], p_var[k][j]);
				}
			}
		}
	}
	
	
	public static List<SplittedDatasetILP> getSplittedList(Result resultILP, List<BatchDatasetEntryILP> dataset)
			throws IOException {

		List<SplittedDatasetILP> splittedDataset = new ArrayList<SplittedDatasetILP>();// //////////////

		// initialize
		for (int i = 0; i < numChunks; i++)
			splittedDataset.add(new SplittedDatasetILP());
		
		for(int i=0; i<numEgs; i++){
			for(int j=0; j<numChunks; j++){
				long isTrue = Math.round(resultILP.get(p_var[i][j]).doubleValue());
				if(isTrue == 1)
					splittedDataset.get(j).getBatchDatasetEntries().add(dataset.get(i));
				
			}
		}
		return splittedDataset;

	}
	
	/**
	 * 
	 * @param splitDataset
	 * @param batchLocation
	 * @throws IOException
	 */
	public static void writesplittedDataset(
			List<SplittedDatasetILP> splitDataset, String batchLocation)
			throws IOException {

		BufferedWriter bw;
		int maxFP;

		for (int i = 1; i <= splitDataset.size(); i++) {
			//Writing each batch file
			bw = new BufferedWriter(new FileWriter(new File(batchLocation+ "/chunk." + (i-1))));
			List<BatchDatasetEntryILP> split_examples = splitDataset.get(i - 1).getBatchDatasetEntries();
			maxFP = 0;

			bw.write(split_examples.size() + "\n");
			bw.write(totNumberofRels + "\n");

			for (BatchDatasetEntryILP BatchDatasetEntryILP : split_examples) {
				//Counting the max no. of false positives possible for the current batch   
				maxFP += BatchDatasetEntryILP.getNumYlabels();
				bw.write(BatchDatasetEntryILP.getExampleStr());
			}
			bw.close();		//Done writing the batch with training data
			
		}
		
		for (int reln : relnEntCount.keySet()) 	System.out.print(reln + "=" + relnEntCount.get(reln).size() + ", ");
		System.out.println("----- Done -----");
	}
}

/*
*
* 
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                       
	/   _ _  _    _. _ |_ |_ 						  /
	/ @(_(_)|_)\/| |(_)| )|_ 						  /
	/       |  /    _/       						  /
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	/      __										  /                                  
	/    /    )                   /   ,         	  /
	/    \        __    __    __ /          __ 		  /
	/     \     /   ) /   ) /   /   /     /   )		  /
	/ (____/___(___(_/___/_(___/___/_____/___/		  /
	/                                   /      		  /
	/                                  /       		  /
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
*                     
*
*/
//class BatchDatasetEntryILP {
//	private String exampleStr;
//	private int numYlabels;
//	private Set<Integer> yLabels;
//	private int id;
//
//	public BatchDatasetEntryILP(String exampleStr, int numYlabels,int id,Set<Integer> yLabels) {
//		this.exampleStr = exampleStr;
//		this.numYlabels = numYlabels;
//		this.id=id;
//		this.yLabels = yLabels;
//	}
//
//	public String getExampleStr() {
//		return exampleStr;
//	}
//
//	public void setExampleStr(String exampleStr) {
//		this.exampleStr = exampleStr;
//	}
//
//	public int getNumYlabels() {
//		return numYlabels;
//	}
//
//	public void setNumYlabels(int numYlabels) {
//		this.numYlabels = numYlabels;
//	}
//
//	public int getId() {
//		return id;
//	}
//
//	public void setId(int id) {
//		this.id = id;
//	}
//
//	public Set<Integer> getyLabels() {
//		return yLabels;
//	}
//
//	public void setyLabels(Set<Integer> yLabels) {
//		this.yLabels = yLabels;
//	}
//	
//	
//	public boolean equals(Object object){
//		BatchDatasetEntryILP item = (BatchDatasetEntryILP) object;
//	    if (this.id == item.id)
//	        return true;
//	    return false;
//	}
//}

////////////////


//class SplittedDatasetILP{
//	private List<BatchDatasetEntryILP> batchDatasetEntries ;
//	private Set<Integer> relationsCovered; 
//	
//	public SplittedDatasetILP(){
//		this.batchDatasetEntries=new ArrayList<BatchDatasetEntryILP>();
//		this.relationsCovered= new HashSet<Integer>();
//	}
//
//	public List<BatchDatasetEntryILP> getBatchDatasetEntries() {
//		return batchDatasetEntries;
//	}
//
//	public void setBatchDatasetEntries(List<BatchDatasetEntryILP> batchDatasetEntries) {
//		this.batchDatasetEntries = batchDatasetEntries;
//	}
//
//	public Set<Integer> getRelationsCovered() {
//		return relationsCovered;
//	}
//
//	public void setRelationsCovered(Set<Integer> relationsCovered) {
//		this.relationsCovered = relationsCovered;
//	}
//}