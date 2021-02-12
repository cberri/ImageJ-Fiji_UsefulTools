/*
 * Developed by Dr. Carlo A. Beretta 
 * Institute for Anatomy and Cell Biology & Department of Pharmacology, University of Heidelberg
 * Email: carlo.beretta@bioquant.uni-heidelberg.de
 * Email: carlo.beretta@uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 51435
 * Tel.: +49 (0) 6221 54 8682
 * 
 * Index key words logic for LaVision 2P Imspector file naming:
 * 
 * 	1. TimeXX.tif: Start index with last Time string index . file extension
 * 	In case .fileFormat is missing in the file name it will be automatically added.
 * 	2. C0X: Start index with C0 for + index +1
 * 	3. ZXXX_: Start index with Z end index with last "_"
 * 	
 * 	Please use the following order in the original file name:  Channel -Z -Time
 * 	Start to count from FileName_C00_Z000_Time000.tiff
 * 	
 * 	NB: The INPUT Directory is a directory containing subdirectories with the images saved as sequences
 * 	If you have different logic index in the file name you will need to edit the code.
 * 
 *  Created: 2019-05-24
 *  Last update: 2021-02-12
 */

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 0
// Close all the open images before to start the macro
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
	
}

// # 1
// Check the memory available to ImageJ/Fiji
function MaxMemory() {

	// Max memory available
	memory = IJ.maxMemory();

	if (memory > 4000000000) {
		
		print("Max Memory (RAM) available for ImageJ/Fiji is:", memory); 
		print("Please change the amount of memory available to ImageJ/Fiji to 70% of your total memory");
		print("Edit >> Options >> Memory % Threads...");
		run("Memory & Threads...");
		exit("Insufficient Memory!");
		
	}

}

// # 2
// Choose the input directory
function InputDirectory() {

	// Input source directory
	dirIn = getDirectory("Please choose the INPUT source directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirIn) == 0) {
		
		print("Exit!");
		exit();
			
	} else {

		text = "Input path: " + dirIn;
		print(text);
		return dirIn;
			
	}
	
}

// # 3
// Output directory
function OutputDirectory(outputPath, year, month, dayOfMonth, second) {

	// Use the dirIn path to create the output path directory
	dirOutRoot = outputPath;

	// Change the path 
	lastSeparator = lastIndexOf(dirOutRoot, File.separator);
	dirOutRoot = substring(dirOutRoot, 0, lastSeparator);
	
	// Split the string by file separtor
	splitString = split(dirOutRoot, File.separator);
	
	for(i=0; i<splitString.length; i++) {

		lastString = splitString[i];
		
	} 

	// Remove the end part of the string
	indexLastSeparator = lastIndexOf(dirOutRoot, lastString);
	dirOutRoot = substring(dirOutRoot, 0, indexLastSeparator);

	// Use the new string as a path to create the OUTPUT directory.
	dirOutRoot = dirOutRoot + "MultipageTiff_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;
	return dirOutRoot;
	
}

// # 4
// Save and close Log window
function CloseLogWindow(dirOutRoot) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", dirOutRoot + "Log.txt"); 
		run("Close");
		
	} else {

		print("Log window has not been found!");
		
	}
	
}

// # 5
// Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");
		
	} else {
		
		print("Memory window has not been found!");
		
	}
	
}

// # 6
function IndexFileName(inputGetShape, saveTitle, firstFileName) {

	// Output general file name from input directory title
	print("Input Directory Name: " + saveTitle);

	// 0. Index file format
	// Remove file extention
	fileName = indexOf(inputGetShape, ".");

	if (fileName != -1) {

		prefixTitle = substring(inputGetShape, 0, fileName);

	} else {

		inputGetShape = inputGetShape + ".tiff";
		fileName = indexOf(inputGetShape, ".");
		prefixTitle = substring(inputGetShape, 0, fileName);
		
	}
	
	// Index key words
	// 1. Time
	time = lastIndexOf(prefixTitle, "Time");
	
	if (time != -1) {

		prefixTime = substring(prefixTitle, time);   

		if (matches(prefixTime, "Time.*")) {

			nTimePoints = substring(prefixTitle, time+4, fileName);
			firstTimeIndex = indexOf(firstFileName, "Time0000");

			if (firstTimeIndex != -1) {

				nTimePoints = parseInt(nTimePoints)+1; // Start to count from zero
				print("Time Ponits: " + nTimePoints); 

			} else {

				nTimePoints = parseInt(nTimePoints); // Start to count from zero
				print("Time Ponits: " + nTimePoints);  

			}
		   		
		}
	
	} else {

		print("File Name Identifier is missing:", "Time");
		print("Guessing: Time is 1!");
		prefixTitle = prefixTitle + "_";
		nTimePoints = 1;
	
	}

	// Index key words
	// 2. C / C0
	channel = indexOf(prefixTitle, "C");
	if (channel != -1) {
	
		prefixChannel = substring(prefixTitle, channel);
		
		if (matches(prefixChannel, "C.*"))  {

			if (matches(prefixChannel, "C0.*")) {
		
				nChannels = substring(prefixTitle, channel+2, channel+3);  // with C +1, +2
				nChannels = parseInt(nChannels) +1; // Start to count from zero
				print("N. Channels: "+  nChannels);

			} else if (matches(prefixChannel, "C.*")) {

				nChannels = substring(prefixTitle, channel+1, channel+2);  // with C +1, +2
				nChannels = parseInt(nChannels) +1; // Start to count from zero
				print("N. Channels: "+  nChannels);
				
			}
	
		}

	} else {

		print("File Name Identifier is missing:", "C0N");
		print("Guessing: Channel is 1!");
		nChannels = 1;
	
	}

	// Index key words
	// 3. Z
	zStack = indexOf(prefixTitle, "Z");
	if (zStack != -1) {

		prefixStack = substring(prefixTitle, zStack);

		if (matches(prefixStack, "Z.*"))  {

			// Use the underscore separator to get the number of slices
			underScoreIndex = indexOf(prefixStack, "_");
			underScoreIndex = zStack + underScoreIndex;

			nSlice = substring(prefixTitle, zStack+1, underScoreIndex);
			nSlice = parseInt(nSlice)+1; // Start to count from zero
			print("Z-slices: " + nSlice);
	
		}

	} else {

		print("File Name Identifier is missing:", "Z");
		print("Guessing: z-slice is 1!");
		nSlice = 1;
	
	}

	// Return the number of time points, channels and z slices
	indexStrings = newArray(nTimePoints, nChannels, nSlice);
	return indexStrings;
	
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro Convert_TiffSeqToMultipageTiff {

	// Start up functions
	CloseAllWindows();
	MaxMemory();
	ContactInformation();
	
	// Display memory usage
	doCommand("Monitor Memory...");

	// Get the starting time to create the output root directory
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		
	// Choose the input source directory
	dirIn = InputDirectory();

	// Get the list of file in the input directory
	folderList = getFileList(dirIn);

	// Create the output directory outside the input path
	outputPath = dirIn;
	dirOutRoot = OutputDirectory(outputPath, year, month, dayOfMonth, second);

	if (!File.exists(dirOutRoot)) {
			
		File.makeDirectory(dirOutRoot);
		text = "Output path: " + dirOutRoot + "\n";
		print(text);
	
	} 
	
	// Do not display the images
	setBatchMode(true);
	
	// #########################################################################################
	// SUBFOLDER
	for (i=0; i<folderList.length; i++) {

		if (endsWith(dirIn + folderList[i], '/')) {

			// List of subfolders
			print("################################################################################################################");
			print("Processing Subfolder: " + dirIn + folderList[i]);

			// Remove the file separator extetion and use it as name to save the output
        	fileSeparatorIndex = indexOf(folderList[i], "/");
        	saveTitle = substring(folderList[i], 0, fileSeparatorIndex);

			// List the file in the subfolder directroy
			fileList = getFileList(dirIn + folderList[i]);
			firstFileName = fileList[0];
			print("Fist index file name:", firstFileName);
			lastFileName = fileList.length;

			/* 
			// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
			// Control how the file list is read
			// We have a problem on Heidelberg University SDS storage
			for (jj=0; jj<fileList.length; jj++){
				
				// open(dirIn + folderList[0] + fileList[jj]);
				print(fileList[jj]);
				
			}
			// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
			*/
			
			// Get input file shape from last file in the subdirectory
			open(dirIn + folderList[i] + fileList[lastFileName-1]);
			inputGetShape = getTitle();
			print("Last index file name:", inputGetShape);

			// 6. Function Index file name elements ./Time/C0 & C00/ Z
			indexStrings = IndexFileName(inputGetShape, saveTitle, firstFileName);
			nTimePoints = indexStrings[0]; 
			nChannels = indexStrings[1]; 
			nSlice = indexStrings[2];

			// Close the last file in the input directory
			close(inputGetShape);

			// Open the images 
			run("Image Sequence...", "open=["+ dirIn + folderList[i] +"] sort");

			// Convert the stack to hyperstack
			// IMPORTANT: Check the dimensions order and change it in case the Hyperstack is wrong
			run("Stack to Hyperstack...", "order=xytzc channels=["+nChannels+"] slices=["+nSlice+"] frames=["+nTimePoints+"] display=Grayscale");

			// Save the hyperstack in the output root directory and close the images
			saveAs("Tiff", dirOutRoot + saveTitle);
			outputTitle = getTitle();
			close(outputTitle);

		} else {

			// Quit the macro if no subdirectories are found
			print("Error: The input directory must contain at least one subdirectory with the input images save as tiff sequence!");
			
			// Check which file cause the error and output the user
			indexFormat = lastIndexOf(dirIn + folderList[i], File.separator);
			outPutFormat = substring(dirIn + folderList[i], indexFormat+1); // +1 to delete the file separator from the printed output
			print("Invalid input: " + outPutFormat);
			
			// Close all open images
			CloseAllWindows();

			// Save the Log window
			CloseLogWindow(dirOutRoot);

			// Reclaim memory and set the batch mode back to false
			call("java.lang.System.gc");
			setBatchMode(false);
			exit("Invalid Input!");

		}
		
	}

	// Update the user when the macro has done
	print("################################################################################################################");
	print("\n%%% Congratulation your folders have been successfully processed %%%");
	print("Number of folders processed:", folderList.length);

	// Save the Log window
	CloseLogWindow(dirOutRoot);

	// Close memory window
	CloseMemoryWindow();

	// Reclaim memory and set the batch mode back to false
	call("java.lang.System.gc");
	setBatchMode(false);
	
}