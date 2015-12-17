package javaHelpers;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TreeMap;

public class splitDataset {
	
	/*public static void createChunk(ArrayList<DataItem> dataset, int datasetStartIdx, int chunkSz, String chunkFile) throws IOException{
		
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File(chunkFile)));
//		OutputStreamWriter bw = new OutputStreamWriter(System.out);
		
		bw.write(chunkSz + "\n");
		bw.write(FindMaxViolatorHelperAll.totNumberofRels + "\n");
		
		for(int i = datasetStartIdx; i <= datasetStartIdx+chunkSz-1; i++){ // Only process datapoints within the current chunk

//			System.out.print(i + ", ");
			DataItem d = dataset.get(i); 
			bw.write(d.ylabel.length + "\n"); // Number of relations (y) true
			for( int y : d.ylabel) // Each of the relations (y)
				bw.write(y + "\n");
			
			bw.write(d.pattern.size()+"\n"); // Number of mentions
			for(int m = 0; m < d.pattern.size(); m++){ // Each of the mentions
				Counter<Integer> mention = d.pattern.get(m);
				
				ArrayList<Integer> keysSorted = new ArrayList<Integer>(mention.keySet());
				Collections.sort(keysSorted);

				bw.write(keysSorted.size() + "\t"); // Num of features in the mention
				for(int f : keysSorted)
					bw.write((f+1) + ":" + mention.getCount(f) + " "); // The actual feature vector (<fid:freq> <fid:freq> ...) in increasing order of feature id // Offset by 1
				bw.write("\n");
				
			}
		}
		
//		System.out.println();
		bw.close();
	}
	
	public static void main(String args[]) throws IOException{
		String datasetFile = args[0];
		int numChunks = Integer.parseInt(args[1]);
		String chunkDatasetDirName = datasetFile+".chunks";
		ArrayList<DataItem> dataset = Utils.populateDataset(datasetFile);

		System.out.println("CWD " + System.getProperty("user.dir"));
		System.out.println("Dataset Size : " + dataset.size());
		System.out.println("Creating " + numChunks + " chunks from this dataset");
		System.out.println("Storing the chunks in " + chunkDatasetDirName);

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
		
		int sz = dataset.size() / numChunks;
		for(int chunkid = 0; chunkid < numChunks; chunkid ++){ // For each chunk
			
			// Compute the start index and the chunkSz
			int datasetStartIdx = (chunkid) * sz;
			int chunkSz = (numChunks-1 == chunkid) ? 
					(dataset.size() - ((numChunks-1)*sz) )  : 
					(sz); 
			
			String chunkFile = chunkDatasetDirName + "/" + "chunk." + chunkid;
			createChunk(dataset, datasetStartIdx, chunkSz, chunkFile);	
			int datasetEndIdx = datasetStartIdx + chunkSz - 1;
//			System.out.println("(start-idx : " + datasetStartIdx + "  end-idx : " + datasetEndIdx + ")  chunk-sz : " + chunkSz);
			System.out.println("Created chunk " + chunkid + " (file : " + chunkFile + ") " + "[" + datasetStartIdx + "," + datasetEndIdx + "] -- Sz: " + chunkSz);
		}

		System.out.println("Completed all the chunks!");
	}*/

static int totNumberofRels = 0;
static int totNumberofRels_inFile = 0;
static int numEgs = 0;
static int numChunks = 0;
static Map<Integer, List<Integer>> relnEntCount = new TreeMap<Integer, List<Integer>>();
	
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
		//Read the training file name
//		String fileName = "";
//		//separate the file name from the path given
//		if(args[0].lastIndexOf("/") != -1)
//			fileName = args[0].substring(args[0].lastIndexOf("/"));
		
		String chunkDatasetDirName = datasetFile+".chunks";
		
		System.out.println("CWD " + System.getProperty("user.dir"));
		System.out.println("Creating " + numChunks + " chunks from this dataset");
		System.out.println("Storing the chunks in " + chunkDatasetDirName);
		
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
		
		
		//No_of_Batches
//		int numChunks = 10;		//Default - 10 batches
//		if(args.length>2)
//			numChunks = Integer.parseInt(args[2]);
		
		//Reading Dataset
		System.out.println("Reading Dataset");
		List<BatchDatasetEntry> dataset = readDataset(datasetFile);
		
		//Creating Batches	
		System.out.println("Creating Batches");
		List<SplittedDataset> splitDataset = splitDataset(dataset, numChunks);
		
		//uniformly distributing training data to batches
		//List<SplittedDataset> uniformSplitDataset = uniformDistrSplitDataset(dataset, splitDataset);
		List<SplittedDataset> uniformSplitDataset = splitDataset;
		//Writing Batches to separate Files	
		System.out.println("Writing Batches to File");
		writesplittedDataset(uniformSplitDataset, chunkDatasetDirName);
	}
	
	/**
	 * 
	 * @param filePath - Path to the training file
	 * @return - The training data as a list of BatchDatasetEntry instances
	 * @throws IOException
	 */
	public static List<BatchDatasetEntry> readDataset(String filePath)
			throws IOException {

		BufferedReader br = new BufferedReader(new FileReader(new File(filePath)));
		Set<Integer> relationsInFile = new HashSet<Integer>();
		
		//The first line is the total no. of training examples present in the file    
		numEgs = Integer.parseInt(br.readLine());

		totNumberofRels = Integer.parseInt(br.readLine()); // total number of relations
		
		//This list holds the chunk(pattern) of an example along with the no. of relations present for that example 
		List<BatchDatasetEntry> examplePattern = new ArrayList<BatchDatasetEntry>();
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
				sb.append(relnId + "\n"); // each y label
				yLabels.add(relnId);
				relationsInFile.add(relnId);
				
				List<Integer> al = relnEntCount.get(relnId);
				
				if(al == null)	al = new ArrayList<Integer>();
					
				al.add(i+1);
				relnEntCount.put(relnId, al);
			}

			int numMentions = Integer.parseInt(br.readLine()); // num of mentions
			sb.append(numMentions + "\n");

			for (int j = 0; j < numMentions; j++)
				sb.append(br.readLine() + "\n"); // each mention

			examplePattern.add(new BatchDatasetEntry(sb.toString(), numYlabels, i+1, yLabels));///////////////
		}
		br.close();
		totNumberofRels_inFile = relationsInFile.size();

		return examplePattern;
	}
	
	/**
	 * 
	 * @param dataset
	 * @param noOfBatches
	 * @return
	 * @throws IOException
	 */
	public static List<SplittedDataset> splitDataset(
			List<BatchDatasetEntry> dataset, int noOfBatches)
			throws IOException {

		
		
//		List<List<BatchDatasetEntry>> splittedDataset = new ArrayList<List<BatchDatasetEntry>>();
		List<SplittedDataset> splittedDataset=new ArrayList<SplittedDataset>();////////////////
		
		int trainingDataCount = dataset.size();

		//initialize
		for (int i = 0; i < noOfBatches; i++)
			splittedDataset.add(new SplittedDataset());

		int ind[] = new int[trainingDataCount];
		int count = 0;

		Random randomGenerator = new Random();
		while (count < trainingDataCount) {		//while all examples are not distributed among batches
			//Genrate a random no.
			int randNext = randomGenerator.nextInt(trainingDataCount);
			
			//Checks if the example is already taken in a batch
			if (ind[randNext] == 1)	continue;

			count++;
			ind[randNext] = 1;
			
			//Adding to a batch 
			splittedDataset.get(count % noOfBatches).getBatchDatasetEntries().add(dataset.get(randNext));
			splittedDataset.get(count % noOfBatches).getRelationsCovered().addAll(dataset.get(randNext).getyLabels());
		}
		
		

		return splittedDataset;
	}
	
	/**
	 * 
	 * @param dataset
	 * @param splitDataset
	 * @return
	 * @throws IOException
	 */
	public static List<SplittedDataset> uniformDistrSplitDataset(
			List<BatchDatasetEntry> dataset, List<SplittedDataset> splitDataset)
			throws IOException {

		
		for (SplittedDataset sdt : splitDataset) {
			List<BatchDatasetEntry> tempDataset = new ArrayList<BatchDatasetEntry>(dataset);
			tempDataset.removeAll(sdt.getBatchDatasetEntries());
			/*
			while(sdt.getRelationsCovered().size()<totNumberofRels_inFile && sdt.getBatchDatasetEntries().size() < 2*(numEgs/numChunks))
			{
				Random randomGenerator = new Random();
				int randNext = randomGenerator.nextInt(tempDataset.size());
				sdt.getBatchDatasetEntries().add(tempDataset.get(randNext));
				sdt.getRelationsCovered().addAll(tempDataset.get(randNext).getyLabels());
				tempDataset.remove(randNext);
			}
			System.out.println("--------- " + sdt.getRelationsCovered().size() + " ---------");
			*/
			for (int reln : relnEntCount.keySet()) {
				if(!sdt.getRelationsCovered().contains(reln)){
					List<Integer> al = relnEntCount.get(reln);
					Random randomGenerator = new Random();
					int randNext = randomGenerator.nextInt(al.size());
					sdt.getBatchDatasetEntries().add(dataset.get(al.get(randNext)-1));
					sdt.getRelationsCovered().addAll(dataset.get(al.get(randNext)-1).getyLabels());
					
				}
			}
			
		}
		return splitDataset;
	}
	
	/**
	 * 
	 * @param splitDataset
	 * @param batchLocation
	 * @throws IOException
	 */
	public static void writesplittedDataset(
			List<SplittedDataset> splitDataset, String batchLocation)
			throws IOException {

		BufferedWriter bw;
		int maxFP;

		for (int i = 1; i <= splitDataset.size(); i++) {
			//Writing each batch file
			bw = new BufferedWriter(new FileWriter(new File(batchLocation+ "/chunk." + (i-1))));
			List<BatchDatasetEntry> split_examples = splitDataset.get(i - 1).getBatchDatasetEntries();
			maxFP = 0;

			bw.write(split_examples.size() + "\n");
			bw.write(totNumberofRels + "\n");

			for (BatchDatasetEntry batchDatasetEntry : split_examples) {
				//Counting the max no. of false positives possible for the current batch   
				maxFP += batchDatasetEntry.getNumYlabels();
				bw.write(batchDatasetEntry.getExampleStr());
			}
			bw.close();		//Done writing the batch with training data
			
			
			//Writing the stats file for the current batch
//			bw = new BufferedWriter(new FileWriter(new File(batchLocation + "/stats." + i)));
//			bw.write(split_examples.size() + "\n");
//			bw.write(maxFP + "\n");
//			bw.write(totNumberofRels + "\n");
//			bw.close();
		}
		
		for (int reln : relnEntCount.keySet()) 	System.out.print(reln + "=" + relnEntCount.get(reln).size() + ", ");
		System.out.println("----- Done -----");
	}
}

/**
 * 
 * @author sandip
 *
 */
class BatchDatasetEntry {
	private String exampleStr;
	private int numYlabels;
	private Set<Integer> yLabels;
	private int id;

	public BatchDatasetEntry(String exampleStr, int numYlabels,int id,Set<Integer> yLabels) {
		this.exampleStr = exampleStr;
		this.numYlabels = numYlabels;
		this.id=id;
		this.yLabels = yLabels;
	}

	public String getExampleStr() {
		return exampleStr;
	}

	public void setExampleStr(String exampleStr) {
		this.exampleStr = exampleStr;
	}

	public int getNumYlabels() {
		return numYlabels;
	}

	public void setNumYlabels(int numYlabels) {
		this.numYlabels = numYlabels;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public Set<Integer> getyLabels() {
		return yLabels;
	}

	public void setyLabels(Set<Integer> yLabels) {
		this.yLabels = yLabels;
	}
	
	
	public boolean equals(Object object){
		BatchDatasetEntry item = (BatchDatasetEntry) object;
	    if (this.id == item.id)
	        return true;
	    return false;
	}
}

////////////////


class SplittedDataset{
	private List<BatchDatasetEntry> batchDatasetEntries ;
	private Set<Integer> relationsCovered; 
	
	public SplittedDataset(){
		this.batchDatasetEntries=new ArrayList<BatchDatasetEntry>();
		this.relationsCovered= new HashSet<Integer>();
	}

	public List<BatchDatasetEntry> getBatchDatasetEntries() {
		return batchDatasetEntries;
	}

	public void setBatchDatasetEntries(List<BatchDatasetEntry> batchDatasetEntries) {
		this.batchDatasetEntries = batchDatasetEntries;
	}

	public Set<Integer> getRelationsCovered() {
		return relationsCovered;
	}

	public void setRelationsCovered(Set<Integer> relationsCovered) {
		this.relationsCovered = relationsCovered;
	}
}
