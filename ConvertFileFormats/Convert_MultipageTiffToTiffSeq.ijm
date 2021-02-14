/*
 * Process images in folders
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Math-Clinic CellNetworks, University of Heidelberg
 * Email: carlo.beretta@bioquant.uni-heidelberg.de
 * Web: http://math-clinic.bioquant.uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 51435
 * 
 * Description:
 * Input:* Input directory >> Image folders >> List of images
 * [ e.g.: Home >> TestA >> File_01, File_02...
 * Choose Home as input. Home should have the above subdirectory structure ]
 * Output: New directory with all the images save as .tiff
 * The summary text file gives an overview of the processing.
 * 
 * Important:
 * Bioformat plugin and at least 4.0 GB of RAM are required.
 * 
 * Created: 2020/09/29
 * Last update: 2021/02/12
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
// Save and close Log window
function CloseLogWindow(dirOut) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", dirOut + "Log.txt"); 
		run("Close");
		
	} else {

		print("Log window has not been found");
	}
	
}

// # 2
// Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");
		
	} else {
		
		print("Memory window has not been found!");
		
	}
	
}

// # 3
// Check the memory available to ImageJ/Fiji
function MaxMemory() {

	// Max memory available
	memory = IJ.maxMemory();

	if (memory > 4000000000) {
		
		print("Max Memory (RAM) available for ImageJ/Fiji is:", memory); 
		print("Please change the amount of memory available to ImageJ/Fiji to 70% of your total memory");
		print("Edit >> Options >> Memory % Threads...");
		exit();
		
	}

}

// # 4
// Choose the input directory
function InputDirectory() {

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

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro ProcessSubFoldersMultiTiffToSeq {

	// Start UP Functions
	CloseAllWindows();
	ContactInformation();

	// Input directory
	dirIn = InputDirectory();
	
	// Get the list of subfolders in the input directory
	folderList = getFileList(dirIn);

	// Output root directory
	dirOutRoot = dirIn;
	
	// Display memory usage and don't display the images
	doCommand("Monitor Memory...");
	setBatchMode(true);
	
	// Get the starting time for later
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Create the output root directory
	// Remove the last two directory file separators
	// \\ for Windows or / for Mac and Linux
	separatorIndex = lastIndexOf(dirOutRoot, '\\');
	stringDirectory = substring(dirOutRoot, 0, separatorIndex);
	separatorIndex = lastIndexOf(stringDirectory, '\\');
	stringStringDirectory = substring(stringDirectory, 0, separatorIndex);
	dirOut = stringStringDirectory + File.separator + "Converted_" + year + "-" + (month+1) + "-" + dayOfMonth + "_0" + second + File.separator;	
			
	if (!File.exists(dirOut)) {	
			
		File.makeDirectory(dirOut);
		text = "Output path: " + dirOut;
		print(text);
	
	}
	
	// Preallocate
	totalNumberImg = 0;
	
	// Loop through the folders in the input directory
	for (i=0; i<folderList.length; i++) {

		// List of folders
		folderPath = dirIn + folderList[i];

		if (endsWith(folderPath, '/')) {
	
			print("\n################################################################################################################");
			print((i+1) + ". Reading image directory: " + folderPath);
		
			// Get the list of subfolder
			fileList = getFileList(dirIn + folderList[i]);

			for (k=0; k<fileList.length; k++) {

				// Check the input file format .tiff/tif
				if (endsWith(fileList[k], '.tiff') || endsWith(fileList[k], '.tif')) {

					// Open the input image
					open(dirIn + folderList[i] + fileList[k]);
					inputTitle = getTitle();
					print("Open:\t" + inputTitle);
					totalNumberImg += 1;

					// Remove file extension .something
					dotIndex = lastIndexOf(inputTitle, ".");
					title = substring(inputTitle, 0, dotIndex);

					// Check if the output directory already exist
					if (File.exists(dirOut)) {
						
						// Create the output subdirectory
						dirOutSub = dirOut + "0" + (i+1) + "_" + title + File.separator;
						File.makeDirectory(dirOutSub);
	
					}

					// Save image stack as image sequence
					selectImage(inputTitle);
					run("Image Sequence... ", "format=TIFF save=["+dirOutSub+"]");
					inputTitle = getTitle();
					close(inputTitle);
            		
				}

			}

		}

	}

	// Update the user when the macro has done
	print("\n");
	print("################################################################################################################");
	print("\n%%% Congratulation your folders have been successfully processed %%%");
	print("Number of subfolder processed:", folderList.length);
	print("Number of images processed:", totalNumberImg);

	// Save the Log window
	CloseLogWindow(dirOut);

	// Close all open images
	CloseAllWindows();

	// Close memory window
	CloseMemoryWindow();

	// Reclaim memory and set the batch mode back to false
	call("java.lang.System.gc");
	setBatchMode(false);
	
}