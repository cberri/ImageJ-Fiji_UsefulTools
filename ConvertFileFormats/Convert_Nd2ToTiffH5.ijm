/*
 * Convert nd2 file to tiff or ilastik h5
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Math-Clinic CellNetworks, University of Heidelberg
 * Email: carlo.beretta@bioquant.uni-heidelberg.de
 * Web: http://math-clinic.bioquant.uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 51435
 * 
 * Description:
 * Input: Directory containing subdirectory in which are stored the nd2 file. 
 * Output: A new directory with subdirectory where are saved the converted images.
 * The Log.txt file is saved in the output directory. 
 * 
 * Important:
 * Bioformat plugin and at least 4.0 GB of RAM are required.
 * 
 * Created: 2017/02/29
 * Last update: 2021/02/12
 */
 
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 0
// Check Bio-Formats installation
function CheckPluginInstallation() {
	
	List.setCommands;
    if (List.get("Bio-Formats")!= "") {

		print("> Bio-Formats plugin is installed!");
		wait(1000);
		print("\\Clear");
       
    } else {
    	
		print("Before to start to use this macro you need to install the Bio-Formats plugin!");
		wait(3000);
		print("1. Select Help >> Update... from the menu to start the updater");
		print("2. Click on Manage update sites. This brings up a dialog where you can activate additional update sites");
		print("3. Activate the Bio-Formats update site and close the dialog. Now you should see an additional jar file or more to download");
		print("4. Click Apply changes and restart ImageJ");
		print("5. After restarting ImageJ you should be able to run this macro");
		exit();
    	
    }

}

// # 1
// Close all the open images before to start the macro
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
	
}

// # 2
// Save and close Log window
function CloseLogWindow(dirOutRoot) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		
		saveAs("Text", dirOutRoot + "Log.csv"); 
		run("Close");
		
	} else {

		print("Log window has not been found");
		
	}
	
}

// # 3
// Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");
		
	} else {
		
		print("Memory window has not been found!");
		
	}
	
}

// # 4
// Check the memory available to ImageJ/Fiji
function MaxMemory() {

	// Max memory available
	memory = IJ.maxMemory();

	if (memory > 4000000000) {
		
		print("Max Memory (RAM) available for ImageJ/Fiji is:", memory); 
		print("Please change the amount of memory available to ImageJ/Fiji to 70% of your total memory");
		print("Edit >> Options >> Memory % Threads...");
		run("Memory & Threads...");
		exit();
		
	}

}

// # 5
// Choose the input directory
function InputDirectory() {

	dirIn = getDirectory("Please choose the INPUT root directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirIn) == 0) {
		
		print("Exit!");
		exit();
			
	} else {

		text = ">> Input path: " + dirIn;
		print(text);
		return dirIn;
			
	}
	
}

// # 6
// Split channels and save the images
function SplitChannelsAndSaveOutput(inputTitle, title, dirOut, h5, tiff, saveCh1, saveCh2) {

	// Select the input image and remove the file extention
	selectImage(inputTitle);
	rename(title);
	inputTitle = getTitle();
	
	// Split the channel and save the raw data ROI
	getDimensions(width, height, channels, slices, frames);

	// For Varun Ramani large data enhance.ai
	if (channels == 1 && (slices > 1 || frames > 1)) {

		// Save the output
		if (h5 == true && tiff == false) {

			// Save the image as h5
			run("Export HDF5", "select=[" + dirOut + inputTitle + ".h5" + "] exportpath=[" + dirOut + inputTitle + ".h5" + "] datasetname=data compressionlevel=0 input=["+inputTitle+"]");	

			// Close the image
			inputTitle = getTitle();
			close(inputTitle);

		} else if (h5 == false && tiff == true) {

			// Save the image as tiff
			saveAs("Tiff", dirOut + inputTitle);
			inputTitle = getTitle();
	
			// Close the input image file
			selectImage(inputTitle);
			close(title);
	
		} else {

			exit("User input setting not supported!");
			     			
		}
						
	} else if (channels == 2 && (slices > 1 || frames > 1)) {

		// Check if the output directory already exist
		// Create a subdirectory for each channel
		if (File.exists(dirOut)) {

			if (saveCh1 == true) {

				// Create the output subdirectory
				dirOutC1 = dirOut + "0" + (i+1) + "_Raw_" + title + File.separator;
				File.makeDirectory(dirOutC1);
	
			} 
			
			if (saveCh2 == true) {

				// Create the output subdirectory
				dirOutC2 = dirOut + "0" + (i+1) + "_Enhanced_" + title + File.separator;
				File.makeDirectory(dirOutC2);
				
			}

		}

		// Split the channel and catch the file name
		run("Split Channels");
		selectImage("C1-" + inputTitle);
		ch1 = getTitle();
		selectImage("C2-" + inputTitle);
		ch2 = getTitle();

		// Save the output
		if (h5 == true && tiff == false) {

			// Select ch1
			selectImage(ch1);

			if (saveCh1 == true) {
				
				// Save the image as h5
				run("Export HDF5", "select=[" + dirOutC1 + ch1 + ".h5" + "] exportpath=[" + dirOutC1 + ch1 + ".h5" + "] datasetname=data compressionlevel=0 input=["+ch1+"]");	
				ch1 = getTitle();
				close(ch1);
				
			} else if (saveCh1 == false) {

				close(ch1);

			}
			
			// Select ch2
			selectImage(ch2);

			if (saveCh2 == true) {

				// Save the image as h5
				run("Export HDF5", "select=[" + dirOutC2 + ch2 + ".h5" + "] exportpath=[" + dirOutC2 + ch2 + ".h5" + "] datasetname=data compressionlevel=0 input=["+ch2+"]");	
				ch2 = getTitle();
				close(ch2);

			} else if (saveCh2 == false) {

				close(ch2);
				
			}
			
		} else if (h5 == false && tiff == true) {

			// Select ch1
			selectImage(ch1);

			if (saveCh1 == true) {

				// Save the image as tiff
				saveAs("Tiff", dirOutC1 + ch1);
				ch1 = getTitle();
				close(ch1);
	
			} else if (saveCh1 == false) {

				// Close the input image file
				close(ch1);

			}
			
			// Select ch2
			selectImage(ch2);

			if (saveCh2 == true) {

				// Save the image as tiff
				saveAs("Tiff", dirOutC2 + ch2);
				ch2 = getTitle();
				close(ch2);
	
			} else if (saveCh2 == false) {

				// Close the input image file
				close(ch2);

			}
		
		} else {

			exit("User input setting not supported!");
			
		}

	} else {

		// Max number of channels supported is 2
		// Close the images and update the user in case of more channels
		selectImage(inputTitle);
		close(inputTitle);
		print("Warning: The input image must be a stack with max 2 channels");
		print("The input image " + title + " has " + channels + " channel and " + slices + " slices");
    			
	}
	
}

// # 7
// User settings
function UserInputDialogBox() {
	
	Dialog.create("User Setting...");
	h5 = true;
	tiff = false;
	saveCh1 = true; // Varun raw data
	saveCh2 = true;  // Varun enhanced AI
	
  	Dialog.addCheckbox("SaveAs ilastik .h5", h5);
  	Dialog.addToSameRow();
  	Dialog.addCheckbox("SaveAs Multipage .tiff", tiff);
  	Dialog.addCheckbox("Save Raw Images", saveCh1);
  	Dialog.addToSameRow();
  	Dialog.addCheckbox("Save Enhanced Images", saveCh2);
  	Dialog.show();

	h5 = Dialog.getCheckbox();
	tiff = Dialog.getCheckbox();
	saveCh1 = Dialog.getCheckbox();
	saveCh2 = Dialog.getCheckbox();

	inputDialogSetting = newArray(h5, tiff, saveCh1, saveCh2);
	return inputDialogSetting;
	
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro ConvertNd2FileToTiff {

	// User Inputs
	inputDialogSetting = UserInputDialogBox();
	h5 = inputDialogSetting[0];
	tiff = inputDialogSetting[1];
	saveCh1 = inputDialogSetting[2]; // Varun raw data
	saveCh2 = inputDialogSetting[3];  // Varun enhanced AI

	// Start UP Functions
	CloseAllWindows();
	CheckPluginInstallation();
	ContactInformation();

	// Check available memory to ImageJ/Fiji
	MaxMemory();

	// Input directory
	dirIn = InputDirectory();
	
	// Get the list of subfolder in the input directory
	folderList = getFileList(dirIn);

	// Output root directory
	dirOutRoot = dirIn;
	
	// Display memory usage and don't display the images
	doCommand("Monitor Memory...");
	setBatchMode(true);
	
	// Get the starting time for later
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Loop through the subfolders
	for (i=0; i<folderList.length; i++) {
	
		// List of subfolders
		path = dirIn + folderList[i];
		print("\n");
		print("################################################################################################################");
		print((i+1) + ". Processing Subfolder: " + path);

		// List of file x subfolder
		fileList = getFileList(dirIn + folderList[i]);

		if (endsWith(path, '/')) {

			// Remove the last directory file separator
			separatorIndex = lastIndexOf(path, '/');
			stringDirectory = substring(path, 0, separatorIndex);

			// Create the output directory inside the subfolder to store the results
			// Use the new string as a path to create the OUTPUT directory.
			dirOut = stringDirectory + File.separator + "Converted_" + year + "-" + (month+1) + "-" + dayOfMonth + "_0" + second + File.separator;	
			
			if (!File.exists(dirOut)) {	
				
				File.makeDirectory(dirOut);
				text = ">> Output root path: " + dirOut;
				print(text);
				//print("\n");
	
			}

			// Count the number of nd2 file converted
			// Preallocate
			countNd2File = 0;
	  		
			// Loop through the image file
			for (k=0; k<fileList.length; k++) {
	
				// Open only nd2 file
				if(endsWith(fileList[k], '.nd2')) {
	
					// Open
					run("Bio-Formats Importer", "open=["+ stringDirectory + File.separator + fileList[k]+"] color_mode=Default open_files open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
					inputTitle = getTitle();

					// Remove the .xxx extention
					dotIndex = indexOf(inputTitle, ".");
					title = substring(inputTitle, 0, dotIndex);

					// Split the channels and save the images as h5 or tiff
					SplitChannelsAndSaveOutput(inputTitle, title, dirOut, h5, tiff, saveCh1, saveCh2);
					
					// Update the user
					print("   " + k+1 + ". Processed: " + fileList[k]);

					// Count nd2 file
					countNd2File += 1;
	
				} else {

					// Update the user
					print( k+1 + ". Skipped! The input file is not nd2: " + fileList[k]);
					
				}

			}

			// Update the user when a subfolder has been processed
			print("\n%%% Congratulation your file have been successfully converted %%%");
			print("Number of file converted:", countNd2File);

			// Close all open images
			CloseAllWindows();

		} else {

			// Quit the macro if no subdirectory are found
			print("Warning: The input directory must contain at least one subdirectory with the input images save as nd2!");
			
			// Check which file cause the error
			indexFormat = lastIndexOf(path, File.separator);
			outPutFormat = substring(path, indexFormat+1); // +1 to delete the file separator from the printed output
			print("Invalid input: " + outPutFormat);
			
			// Close all open images
			CloseAllWindows();

		}
		
	}

	// Update the user when the macro has done
	print("\n");
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