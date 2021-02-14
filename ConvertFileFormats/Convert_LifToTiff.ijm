/*
 * Project lifToTiffConverter_V3
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Department for Anatomy and Cell Biology @ Heidelberg University
 * Email: carlo.beretta@uni-heidelberg.de
 * 
 * Created: 2018/05/09
 * Last update: 2021/02/01
 */
 
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 0
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
// Check Bio-Formats installation
function CheckPluginInstallation() {
	
	List.setCommands;
    if (List.get("Bio-Formats")!="") {

		print("> Bio-Formats plugin is installed!");
		wait(1000);
		print("\\Clear");
       
    } else {
    	
		print("Before to start to use this macro you need to install the Bio-Formats plugin!");
		wait(3000);
		print("1. Select Help >> Update... from the menu to start the updater");
		print("2. Click on Manage update sites. This brings up a dialog where you can activate additional update sites");
		print("3. Activate the Bio-Formats update site and close the dialog. Now you should see an additional jar file or more to download");
		print("4. Click Apply changes and restart ImageJ/Fiji");
		exit();
    	
    }

}

// # 3
// User can specify if split channel in single file or save a multipage tiff
function InputDialog() {

	splitChannels = false;
	runProjections = true;
	
	processStitch = true;
	createSubfolders = false;

	removeChannel = false;
	channelID = 2;
	
	Dialog.create("User Inputs Settings...");
	Dialog.addMessage("Settings", 18);
	Dialog.addCheckbox("Split Channels", splitChannels);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Compute MIP", runProjections);
	
	Dialog.addCheckbox("Process Only Stitched Images", processStitch);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Save Images in Subfolders", createSubfolders);
	Dialog.addMessage("_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _");
	Dialog.addMessage("\n");

	Dialog.addCheckbox("Delete Channel", removeChannel);
	Dialog.addToSameRow();
	Dialog.addNumber("Channel Number(1, 2, 3)", channelID);
	
	Dialog.addMessage("__________________________________________________");
	Dialog.addMessage("\n*Last Update: 2021-02-01", 11, "#001090");

	// Add Help button

	html = "<html>"
		+ "<style> html, body { width: 500; height: 350; margin: 10; padding: 0; border: 0px solid black; background-color: #ECF1F4; }"
		+ "<h1> <center>&#127866; LifToTiff &#127867; </center> </h1>"
		+ "<h3> <section> " 
		+ "<b> Options &#128722;</b>" 
			+ "<li><i>Split Channels</i>: It allows to split multi-channels images and save the single channels separated<br/><br/></li>"
			+ "<li><i>Compute MIP</i>: Compute and save the Maximum Intensity Projections <br/><br/></li>"
			+ "<li><i>Process Stitch Images</i>: In case of unstitch and stitch images in the same lif file allows to save only the stitched stacks<br/><br/></li>"
			+ "<li><i>Save Images in subfolders</i>: Create subfolders for each lif sereis in the lif file<br/><br/></li>"
			+ "<li><i>Delete Channel</i>: Remove 1 channel from the input lif file. It works for now only with 2 and 3 channels multipage stacks<br/><br/></li>"
			+ "<li><i>Channel Number</i>: the channel to remove from the multipage output tiff<br/><br/></li>"
		+ "</h3> </section>"
		+ "</style>"
		+ "</html>";

	Dialog.addHelp(html);
  	Dialog.show();

	splitChannels = Dialog.getCheckbox();
	runProjections = Dialog.getCheckbox();
	processStitch = Dialog.getCheckbox();
	createSubfolders = Dialog.getCheckbox();
	removeChannel =  Dialog.getCheckbox();
	channelID = Dialog.getNumber();
	outputDialog = newArray(splitChannels, runProjections, processStitch, createSubfolders, removeChannel, channelID);
	
	return outputDialog;
		
}

// # 4
// Compute the MIP, Split channes, save multipage tiff and delete channels
function RunMaxProjections(inputTitle, splitChannels, runProjections, dirOutSeries, i, outputFileName, removeChannel, channelID) {

	if (nSlices > 1 && runProjections == 1 && splitChannels == 1) {

		run("Z Project...", "projection=[Max Intensity]");
		maxTitle = getTitle();

		// Get MIP dimentions
		getDimensions(width, height, channels, slices, frames);

		if (channels == 1 && splitChannels == 1) {

			// Save the image as tiff
			saveAs("Tiff", dirOutSeries + "MIP_" + outputFileName + "_0" + i);
			
			// Close the open images
			maxTitle = getTitle();
			close(maxTitle);
			selectImage(inputTitle);
			close(inputTitle);
		
		} else if (channels == 2 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + maxTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_MIP_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + maxTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_MIP_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

			// Close the open images
			selectImage(inputTitle);
			close(inputTitle);

		} else if (channels == 3 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;
			dirOutC3 = dirOutSeries + "C3" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2) && !File.exists(dirOutC3)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);
				File.makeDirectory(dirOutC3);
				print("Created output directory:\t" + dirOutC3);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + maxTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_MIP_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + maxTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_MIP_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

			selectImage("C3-" + maxTitle);
			ch3 = getTitle();		
			saveAs("Tiff", dirOutC3 + "C3_MIP_" + outputFileName + "_0" + i);
			ch3 = getTitle();
			close(ch3);

			// Close the open images
			selectImage(inputTitle);
			close(inputTitle);
		
		} else if (channels == 4 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;
			dirOutC3 = dirOutSeries + "C3" + File.separator;
			dirOutC4 = dirOutSeries + "C4" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2) && !File.exists(dirOutC3) && !File.exists(dirOutC4)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);
				File.makeDirectory(dirOutC3);
				print("Created output directory:\t" + dirOutC3);
				File.makeDirectory(dirOutC4);
				print("Created output directory:\t" + dirOutC4);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + maxTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_MIP_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + maxTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_MIP_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

			selectImage("C3-" + maxTitle);
			ch3 = getTitle();		
			saveAs("Tiff", dirOutC3 + "C3_MIP_" + outputFileName + "_0" + i);
			ch3 = getTitle();
			close(ch3);

			selectImage("C4-" + maxTitle);
			ch4 = getTitle();		
			saveAs("Tiff", dirOutC4 + "C4_MIP_" + outputFileName + "_0" + i);
			ch4 = getTitle();
			close(ch4);

			// Close the open images
			selectImage(inputTitle);
			close(inputTitle);

		} else {

			// Close all the open images and through an error message
			run("Close All");
			exit("Error! Max number of channels supported is 4");
		
		}
		
	} else if ((nSlices == 1 || runProjections == 0) && splitChannels == 1) {

		// Get MIP dimentions
		getDimensions(width, height, channels, slices, frames);

		if (channels == 1 && splitChannels == 1) {

			// Save the image as tiff
			saveAs("Tiff", dirOutSeries + "Stack_" + outputFileName + "_0" + i);
			
			// Close the open images
			inputTitle = getTitle();
			selectImage(inputTitle);
			close(inputTitle);
		
		} else if (channels == 2 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + inputTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_Stack_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + inputTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_Stack_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

		} else if (channels == 3 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;
			dirOutC3 = dirOutSeries + "C3" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2) && !File.exists(dirOutC3)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);
				File.makeDirectory(dirOutC3);
				print("Created output directory:\t" + dirOutC3);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + inputTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_Stack_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + inputTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_Stack_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

			selectImage("C3-" + inputTitle);
			ch3 = getTitle();		
			saveAs("Tiff", dirOutC3 + "C3_Stack_" + outputFileName + "_0" + i);
			ch3 = getTitle();
			close(ch3);
		
		} else if (channels == 4 && splitChannels == 1) {

			// Create a new output directory for each channel
			dirOutC1 = dirOutSeries + "C1" + File.separator;
			dirOutC2 = dirOutSeries + "C2" + File.separator;
			dirOutC3 = dirOutSeries + "C3" + File.separator;
			dirOutC4 = dirOutSeries + "C4" + File.separator;

			// Check if the output directory already exist
			if (!File.exists(dirOutC1) && !File.exists(dirOutC2) && !File.exists(dirOutC3) && !File.exists(dirOutC4)) {	
				
				// Create a new directory inside the output directory
				File.makeDirectory(dirOutC1);
				print("Created output directory:\t" + dirOutC1);
				File.makeDirectory(dirOutC2);
				print("Created output directory:\t" + dirOutC2);
				File.makeDirectory(dirOutC3);
				print("Created output directory:\t" + dirOutC3);
				File.makeDirectory(dirOutC4);
				print("Created output directory:\t" + dirOutC4);

			}

			// Split channels
			run("Split Channels");
			
			// Catch channel ID
			selectImage("C1-" + inputTitle);
			ch1 = getTitle();
			saveAs("Tiff", dirOutC1 + "C1_Stack_" + outputFileName + "_0" + i);
			ch1 = getTitle();
			close(ch1);
		
			selectImage("C2-" + inputTitle);
			ch2 = getTitle();		
			saveAs("Tiff", dirOutC2 + "C2_Stack_" + outputFileName + "_0" + i);
			ch2 = getTitle();
			close(ch2);

			selectImage("C3-" + inputTitle);
			ch3 = getTitle();		
			saveAs("Tiff", dirOutC3 + "C3_MIP_" + outputFileName + "_0" + i);
			ch3 = getTitle();
			close(ch3);

			selectImage("C4-" + inputTitle);
			ch4 = getTitle();		
			saveAs("Tiff", dirOutC4 + "C4_Stack_" + outputFileName + "_0" + i);
			ch4 = getTitle();
			close(ch4);

		}

	} else if (nSlices > 1 && runProjections == 1 && splitChannels == 0) {

		// Compute MIP
		run("Z Project...", "projection=[Max Intensity]");
		maxTitle = getTitle();

		// Save the image as tiff
		saveAs("Tiff", dirOutSeries + "MIP_" + outputFileName + "_0" + i);
			
		// Close the open images
		maxTitle = getTitle();
		close(maxTitle);
		selectImage(inputTitle);
		close(inputTitle);

	} else if (runProjections == 0 && splitChannels == 0) {

		// Get MIP dimentions
		getDimensions(width, height, channels, slices, frames);

		// For Alina Red == Ch2
		// Now it works only with 2 and 3 channels images. It could be dvelopped further for 4 channles images
		if (removeChannel == 1 && channels == 2) {

			run("Split Channels");

			selectImage("C1-" + inputTitle);
			ch1 = getTitle();
			selectImage("C2-" + inputTitle);
			ch2= getTitle();

			if (channelID == 1) {

				selectImage(ch1);
				close(ch1);
				run("Merge Channels...", "c2=["+ ch2 +"] create");
				
				// Save the z-stack as tiff file
				saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

				// Close the open images
				inputTitle = getTitle();
				close(inputTitle);
				
			} else if (channelID == 2) {

				selectImage(ch2);
				close(ch2);

				run("Merge Channels...", "c1=["+ ch1 +"] create");
				
				// Save the z-stack as tiff file
				saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

				// Close the open images
				inputTitle = getTitle();
				close(inputTitle);

			} 
		
		} else if (removeChannel == 1 && channels == 3) {

			run("Split Channels");

			selectImage("C1-" + inputTitle);
			ch1 = getTitle();
			selectImage("C2-" + inputTitle);
			ch2= getTitle();
			selectImage("C3-" + inputTitle);
			ch3 = getTitle();

			if (channelID == 1) {

				selectImage(ch1);
				close(ch1);
				run("Merge Channels...", "c1=["+ ch2 +"] c2=["+ ch3 +"] create");
				
				// Save the z-stack as tiff file
				saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

				// Close the open images
				inputTitle = getTitle();
				close(inputTitle);

			} else if (channelID == 2) {

				selectImage(ch2);
				close(ch2);

				run("Merge Channels...", "c1=["+ ch1 +"] c2=["+ ch3 +"] create");
				
				// Save the z-stack as tiff file
				saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

				// Close the open images
				inputTitle = getTitle();
				close(inputTitle);
				
			} else if (channelID == 3) {

				selectImage(ch3);
				close(ch3);

				run("Merge Channels...", "c1=["+ ch1 +"] c2=["+ ch2 +"] create");
				
				// Save the z-stack as tiff file
				saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

				// Close the open images
				inputTitle = getTitle();
				close(inputTitle);

			}
			
		} else {

			// Save the z-stack as tiff file
			saveAs("Tiff", dirOutSeries + outputFileName + "_0" + i);

			// Close the open images
			inputTitle = getTitle();
			close(inputTitle);

		}

	}

}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro lifToTiffConverter {

	// Call the own close function
	CloseAllWindows();

	// Check if the bioformats are installed
	CheckPluginInstallation();

	// Input user setting
	outputDialog = InputDialog();
	splitChannels = outputDialog[0];
	runProjections = outputDialog[1];
	processStitch = outputDialog[2];
	createSubfolders = outputDialog[3];
	removeChannel = outputDialog[4];
	channelID = outputDialog[5];
	print("User setting - Split Cahnnels: " +  splitChannels + " Compute MIP: " + runProjections);

	// Get the starting time for later
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Choose the input root directory
	dirIn = getDirectory("Choose the INPUT source directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirIn) == 0) {
		
		print("Exit!");
		exit();
			
	} else {
		
		text = "Input path: \t" + dirIn;
		print(text);
			
	}

	// Get list of file in the input directory
	fileList = getFileList(dirIn);

	/* Here we play around with the path and we create an output directory to save the results
	 * You do not need to choose the output directory but you can just create an output directory in the input path.
	 */
	dirOut = dirIn;
	lastSeparator = lastIndexOf(dirOut, File.separator);
	dirOut = substring(dirOut, 0, lastSeparator);
	
	// Split the string by file separtor
	splitString = split(dirOut, File.separator); 
	
	for (i=0; i<splitString.length; i++) {
		
		lastString = splitString[i];
		
	} 

	// Remove the end part of the string
	indexLastSeparator = lastIndexOf(dirOut, lastString);
	dirOutRoot = substring(dirOut, 0, indexLastSeparator);

	// Use the new string as a path to create the OUTPUT directory.
	dirOut = dirOutRoot + "MacroResults_" + year + "-" + (month+1) + "-" + dayOfMonth + "_0" + second + File.separator;

	if (!File.exists(dirOut)) {	
		
		File.makeDirectory(dirOut);
		text = "Output path:\t" + dirOut;
		print(text);
	
	} 

	// We want to run the macro as fast as possible and use less RAM.
	// You can use the follwing function to do not dispaly the images
	setBatchMode(true);
	
	// Print the number of file to convert
	print("Number of liff file to process:", fileList.length);

	/* Process all the file located in the input directory
	 * 1. The macro process the file in the input directory.
	 * 2. Use the bioformat to open all the subfile in the .lif file
	 * 3. It counts the number of input subfile (stacks)
	 * 4. Save the output
	 */
	for (j=0; j<fileList.length; j++) {

		// Check that the input file is .lif
		if (endsWith(fileList[j], '.lif')) {
	
			// Open the input file as virtual stack to save memory
			run("Bio-Formats Importer", "open=["+dirIn + fileList[j]+"] color_mode=Default open_files open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack");

			// Update the processing
			print("\nProcess .lif file:", fileList.length-j);
			
			// Get the number of open series x lif file
			n = nImages;
			print("Number of series: " + n);

			// Get lif image title
			lifTitle = getTitle();

			// Get the fist part of file name -
			plusIndex = lastIndexOf(lifTitle, "-");
			titleFirst = substring(lifTitle, plusIndex, lengthOf(lifTitle));

			// Remove file extension .lif
			dotIndex = lastIndexOf(lifTitle, ".");
			titleOut = substring(lifTitle, 0, dotIndex);
			print("Input lif file name: " + titleOut); 

			// Create a new directory inside the output directory where to save the single channel images
			if (createSubfolders == true) {
			
				dirOutSeries = dirOut + titleOut + File.separator;

				// Check if the output directory already exist
				if (!File.exists(dirOutSeries)) {	
				
					// Create a new directory inside the output directory
					File.makeDirectory(dirOutSeries);
					text = "Created output directory:\t" + dirOutSeries;
					print(text);
					
				}

			} else {

				dirOutSeries = dirOut;
				
			}

			// Process each serie
			for(i=1; i<=n; i++) {

				// Get the title
				inputTitle = getTitle();

				if (i <= 9) {

					rename("000" + i + "_" + inputTitle);
					inputTitle = getTitle();


				} else if (i >= 10 && i<=99) {

					rename("00" + i + "_" + inputTitle);
					inputTitle = getTitle();

					
				} else if (i >= 10 && i<=999) {

					rename("0" + i + "_" + inputTitle);
					inputTitle = getTitle();

				} else {

					exit("Index not supported! Max Value 999");
					
				}

				// Remove file extension .lif
				dotIndex = indexOf(inputTitle, ".");
				titleIn = substring(inputTitle, 0, dotIndex);
        	
				// Get the last part of file name -
				minusIndex = lastIndexOf(inputTitle, "-");
				titleLast = substring(inputTitle, minusIndex, lengthOf(inputTitle));

				// Index file seprator in case of lif subdirectory
				separatorIndex = lastIndexOf(titleLast, "/");
				
				if (separatorIndex != -1) {

					titleSepAfter = substring(titleLast, separatorIndex+1, lengthOf(titleLast));
					titleSepBefore = substring(titleLast, 0, separatorIndex);

					outputFileName =  titleIn + titleSepBefore + "_" + titleSepAfter;
        			
				} else {

					outputFileName =  titleIn + titleLast;
					
				}

				// Skip tiels
				if (processStitch == true) {

					// Get image dimentions
					width = getWidth();
					height = getHeight();

					if (width > 1025 && height > 1025) {

						// Compute the max projection ond or split channels
						print("Processing: " + outputFileName);
						RunMaxProjections(inputTitle, splitChannels, runProjections, dirOutSeries, i, outputFileName, removeChannel, channelID);
						
					} else if (width <= 1024 && height <= 1024) {

						selectImage(inputTitle);
						close(inputTitle);
						print("Tile Skipped: " + outputFileName);
							
					} 
					
				} else if (processStitch == false) {
				
					// Compute the max projection ond or split channels
					print("Processing: " + outputFileName);
					RunMaxProjections(inputTitle, splitChannels, runProjections, dirOutSeries, i, outputFileName, removeChannel, channelID);
					
				}	
 				
			}
				
		}
			
	}

	// Update the user
	print("Number of file processed:", fileList.length);
	print("\n%%% Congratulation your file have been successfully processed %%%");

	// Save and close the log window
	CloseLogWindow(dirOutRoot);

	// Call the own close function
	CloseAllWindows();

	// Close the batch mode
	setBatchMode(false);

}