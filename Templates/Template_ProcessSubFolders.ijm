/*
 * Process images in folders
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Department for Anatomy and Cell Biology @ Heidelberg University
 * Email: carlo.beretta@uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 8682
 * Tel.: +49 (0) 6221 54 51435
 * 
 * Description:
 * Input:* Input directory >> folders >> subfolders >> imageFolders >> List of images
 * [ e.g.: Home >> TestA >> TestB >> TestC >> List of Files [File_01, File_02...]
 * Choose Home as input. Home should have the above structure ]
 * Output: New directroy where you can save the results
 * The Log file gives an overview of the processing steps.
 * 
 * Important:
 * Bioformat plugin and at least 4.0 GB of RAM are required.
 * 
 * Created: 11/02/2021
 * Last update: 11/02/2021
 */

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 0. Close all the open images before to start the macro
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
	
}

// 1. Save and close Log window
function CloseLogWindow(dirOut) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", dirOut + "Log.txt"); 
		run("Close");
		
	} else {

		print("Log window has not been found");
	}
	
}

// 2. Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");
		
		
	} else {
		
		print("Memory window has not been found!");
		
	}
	
}

// 3. Check the memory available to ImageJ/Fiji
function MaxMemory() {

	// Max memory available
	memory = IJ.maxMemory();

	if (memory > 4000000000) {
		
		print("Max Memory (RAM) available for Fiji/ImageJ is:", memory); 
		print("Please change the amount of memory available to ImageJ/Fiji to 70% of your total memory");
		print("Edit >> Options >> Memory % Threads...");
		exit();
		
	}

}

// 4. Choose the input directory
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
macro TemplateProcessImagesInSubfolders {

	// Start UP Functions
	CloseAllWindows();

	// Check available memory to ImageJ/Fiji
	MaxMemory();

	// Input directory
	dirIn = InputDirectory();
	
	// Get the list of subfolder in the input directory
	folderList = getFileList(dirIn);

	// Output root directrory
	dirOutRoot = dirIn;
	
	// Display memory usage and don't display the images
	doCommand("Monitor Memory...");
	setBatchMode(true);
	
	// Get the starting time for later
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Create the output root directory
	// Remove the last two directory file separators
	separatorIndex = lastIndexOf(dirOutRoot, '\\');
	stringDirectory = substring(dirOutRoot, 0, separatorIndex);
	separatorIndex = lastIndexOf(stringDirectory, '\\');
	stringStringDirectory = substring(stringDirectory, 0, separatorIndex);
	dirOut = stringStringDirectory + File.separator + "RootDirectory_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;	
			
	if (!File.exists(dirOut)) {	
			
		File.makeDirectory(dirOut);
		text = "Output root path: " + dirOut;
		print(text);
	
	}

	// Create the output working subdirectory
	dirOutSub = dirOut + File.separator + "ResultDirectory_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;	
			
	if (!File.exists(dirOutSub)) {	
			
		File.makeDirectory(dirOutSub);
		text = "Output result path: " + dirOutSub;
		print(text);
		print("\n");
	
	}

	// Loop through the folders in the input directory
	for (i=0; i<folderList.length; i++) {

		// List of folders
		folderPath = dirIn + folderList[i];

		if (endsWith(folderPath, '/')) {
	
			print("\n################################################################################################################");
			print((i+1) + ". Reading folder: " + folderPath);
		
			// Get the list of subfolders
			subFolderList = getFileList(dirIn + folderList[i]);

			// Loop through the subfolders
			for (k=0; k<subFolderList.length; k++) {

				// Create subfolders path
				subFolderPath = folderPath + subFolderList[k];
				print("\n");
				print("		################################################################################################");
				print("		" + (k+1) + ". Reading subfolder: " + subFolderPath);

				// Get the list of image folders
				subSubFolderList = getFileList(dirIn + folderList[i] + subFolderList[k]);

				if (endsWith(subFolderPath, '/')) {

					// Loop through the image folders
					for (j=0; j<subSubFolderList.length; j++) {

						// Create subsubfolders path
						imageFolderPath = subFolderPath + subSubFolderList[j];
						print("\n");
						print("			################################################################################################");
						print("			" + (j+1) + ". Reading image folder: " + imageFolderPath);

						if (endsWith(imageFolderPath, '/')) {
				
							// Get the list of images in the image folder
							fileList = getFileList(dirIn + folderList[i] + subFolderList[k] + subSubFolderList[j]);
	  		
							// Loop through the image file
							for (f=0; f<fileList.length; f++) {

								if (endsWith(fileList[f], '.tiff' ) || endsWith(fileList[f], '.tif' )) {

									// Open input image using the bioformat
									// run("Bio-Formats Importer", "open=["+ imageFolderPath + File.separator + fileList[f] +"] color_mode=Default view=Hyperstack stack_order=XYCZT ");

									// Open tiff images
									open(imageFolderPath + File.separator + fileList[f]);
									inputTitle = getTitle();
									print("			" + "Opening input image: " + inputTitle);

									// Remove file extension .somthing
									dotIndex = indexOf(inputTitleRaw, ".");
									title = substring(inputTitleRaw, 0, dotIndex);
									
									// YOU CAN ADD YOUR CODE HERE!
									// ...


									
								}

							}

						}

					}
					
				}

			}

		}

	}

	// Update the user when the macro has done
	print("\n");
	print("################################################################################################################");
	print("\n%%% Congratulation your folders have been successfully processed %%%");
	outputList = getFileList(dirOutSub);
	print("Number of folders processed:", outputList.length);

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