package javaHelpers;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class RewriteFeatureFileBias {

	public static void main(String[] args) throws NumberFormatException, IOException {
		
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

		BufferedWriter bw;
		
		bw = new BufferedWriter(new FileWriter(new File(datasetFile+ "1")));
		br = new BufferedReader(new FileReader(new File(datasetFile)));
		
		bw.write(br.readLine() + "\n");
		bw.write(br.readLine() + "\n");
		
		
		//Reading the training examples
		for (int i = 0; i < numEgs; i++) { // for each example

			int numYlabels = Integer.parseInt(br.readLine()); // num of y labels
			bw.write(numYlabels + "\n");
			
			//Get the yLabels for the curr entry
			for (int j = 0; j < numYlabels; j++){
				int relnId = Integer.parseInt(br.readLine());
				bw.write(relnId + "\n");
			}
				
				
			int numMentions = Integer.parseInt(br.readLine()); // num of mentions
			bw.write(numMentions + "\n");		//+1 to incorporate the bias feature

			for (int j = 0; j < numMentions; j++)	{
				String s1[] = br.readLine().split("\\t");
				String mentionStr = s1[1]; // each mention
				int noofFeatures = Integer.parseInt(s1[0]);
				
				bw.write((noofFeatures+1) + "\t" + mentionStr.trim() + " " + (maxFeatureId+1) + ":1.0" + " \n");
//				bw.write(br.readLine() + (maxFeatureId+1) + ":1.0" + " \n"); // each mention
			}
		}
		br.close();
		bw.close();
		
	}

}
