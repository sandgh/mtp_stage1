package javaHelpers;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class FeatureFileToMatrixConverter {

	public static void main(String[] args) throws NumberFormatException, IOException {
		
//		int i[] = {1,2,3,4,5}; 
//		
//		double d[][] = new double[3][6];
//		
//		for(int j =0;j<3;j++){
//			for(int k =0;k<6;k++){
//				d[j][k] = j+k*2.5;
//			}
//		}
//
//		MLNumericArray<Double> s1 = new MLDouble("test", d);//MLArray("testarr", i, 9, 0);
//		ArrayList<MLArray> list = new ArrayList<MLArray>();
//		list.add(s1);
//		list.add(s1);
//		list.add(s1);
//		list.add(s1);
//		
//		MatFileWriter writer = new MatFileWriter();
//        writer.write( "test2.mat", list );
		
		String datasetFile = args[0];
		int maxFeatureId = 0;
		
		BufferedReader br = new BufferedReader(new FileReader(new File(datasetFile)));
		
		//The first line is the total no. of training examples present in the file    
		int numEgs = Integer.parseInt(br.readLine());
		int totNumberofRels = Integer.parseInt(br.readLine()); // total number of relations
		
		//Reading the training examples
		for (int i = 0; i < numEgs; i++) { // for each example

			int numYlabels = Integer.parseInt(br.readLine()); // num of y labels
			
			//Get the yLabels for the curr entry
			for (int j = 0; j < numYlabels; j++)	br.readLine();
				
				
			int numMentions = Integer.parseInt(br.readLine()); // num of mentions

			for (int j = 0; j < numMentions; j++){
				String mentionStr = br.readLine().split("\\t")[1]; // each mention
				
				String features[] = mentionStr.split(" ");
				for(String f : features){
					int fid = Integer.parseInt(f.split(":")[0]); // Subtracting 1 to map features from 0 to numSentenceFeatures - 1
					double freq = Double.parseDouble(f.split(":")[1]);
					maxFeatureId = (maxFeatureId<fid)?fid:maxFeatureId;
				}
			}
		}
		br.close();
		
		System.out.println(maxFeatureId);

		BufferedWriter bw_feature,bw_goldDB,bw_mentionVect;
		
		bw_feature = new BufferedWriter(new FileWriter(new File(datasetFile+ "_feature")));
		bw_goldDB = new BufferedWriter(new FileWriter(new File(datasetFile+ "_goldDB")));
		bw_mentionVect = new BufferedWriter(new FileWriter(new File(datasetFile+ "_mentionVect")));
		br = new BufferedReader(new FileReader(new File(datasetFile)));
		
//		bw.write(br.readLine() + "\n");
//		bw.write(br.readLine() + "\n");
		br.readLine();
		br.readLine();
		
		int goldDBMatrix[][] = new int[numEgs][totNumberofRels];
		int mentionVector[] = new int[numEgs];
//		double featureVector[][] = new double[numEgs][maxFeatureId];
		
		//Reading the training examples
		for (int i = 0; i < numEgs; i++) { // for each example

			int numYlabels = Integer.parseInt(br.readLine()); // num of y labels
			int prev = 0;
			//Get the yLabels for the curr entry
			for (int j = 0; j < numYlabels; j++){
				int relnId = Integer.parseInt(br.readLine());
				goldDBMatrix[i][relnId-1] = 1;
			}
				
				
			int numMentions = Integer.parseInt(br.readLine()); // num of mentions
			mentionVector[i] = numMentions;

			for (int j = 0; j < numMentions; j++)	{
				prev = 0;
				String s1[] = br.readLine().split("\\t");
				String mentionStr = s1[1]; // each mention
				int noofFeatures = Integer.parseInt(s1[0]);
				String features[] = mentionStr.split(" ");
				
				for(String f : features){
					int fid = Integer.parseInt(f.split(":")[0]); // Subtracting 1 to map features from 0 to numSentenceFeatures - 1
					double freq = Double.parseDouble(f.split(":")[1]);
					
					for(int k=prev+1;k<fid;k++)	bw_feature.write("0.0" + " ");
					bw_feature.write(freq + " ");
					prev = fid;
				}
				bw_feature.write("\n");
				
//				bw_feature.write((noofFeatures+1) + "\t" + mentionStr + (maxFeatureId+1) + ":1.0" + " \n");
//				bw.write(br.readLine() + (maxFeatureId+1) + ":1.0" + " \n"); // each mention
			}
//			for(int k=prev;k<maxFeatureId;k++)	bw_feature.write("0" + " ");
		}
		br.close();
		bw_feature.close();
		
		for (int i = 0; i < numEgs; i++) bw_mentionVect.write(mentionVector[i] + " ");
		
		for (int i = 0; i < numEgs; i++) {
			for (int j = 0; j < totNumberofRels; j++)	bw_goldDB.write(goldDBMatrix[i][j] + " ");
			bw_goldDB.write("\n");
		}
		
		bw_goldDB.close();
		bw_mentionVect.close();
	}
	
	

}
