/*
 * Project: ilastik users
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Department for Anatomy and Cell Biology @ Heidelberg University
 * Email: carlo.beretta@uni-heidelberg.de
 * 
 * 
 * Assumption: this macro can be use to convert ilastik H5 files into tiff and vice versa.
 * The macro has been specifically designed to convert time series or large z-stack. 
 * 
 * How it works:
 * The user selects the folder with the source images in H5 or tiff/tif file format.
 * In case of H5 to tiff/tif the user needs to input the axis order dimensions (default: tzyxc).
 * The macro will generate an output folder outside the input path where the converted images are saved.
 * 
 * Created: 2019/03/06
 * Last update: 2020/11/16
 */

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 1
function CloseAllWindows() {
	while(nImages > 0) {
		selectImage(nImages);
		close();
	}
}

// # 2
// Check plugin installation
function CheckPluginInstallation() {

	List.setCommands;
				
	if (List.get("Export HDF5") == "") {
			
		print("Before to start to use this macro you need to install the ilastik Import Export plugin!");
		wait(3000); 	
    	print("1. Select Help >> Update... from the menu to start the updater");
		print("2. Click on Manage update sites. This brings up a dialog where you can activate additional update sites");
    	print("3. Activate ilastik Import Export update sites (http://sites.imagej.net/Ilastik/)");
    	print("4. Click Apply changes and restart ImageJ/Fiji");
    	print("5. After restarting ImageJ you should be able to run this macro");
    	print("6. Further information can be found: https://www.ilastik.org/documentation/fiji_export/plugin/");
    	wait(3000);
    	exec("open", "https://www.ilastik.org/documentation/fiji_export/plugin/");
    	exit(); 
       	
	} else {

		print("ilastik Import Export plugin is installed!");
		wait(1000);
		print("\\Clear");
   		
	}

}
// # 3
// Choose the input directories
function InputDirectory() {

	dirIn = getDirectory("Choose the INPUT source directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirIn) == 0) {
		print("Exit!");
		exit();
			
	} else {

		// Output the path
		text = "Input path:\t" + dirIn;
		print(text);
		return dirIn;
			
	}
	
}

//  # 4
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
	dirOutRoot = dirOutRoot + "Converted_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;

	if (!File.exists(dirOutRoot)) {
			
		File.makeDirectory(dirOutRoot);
		text = "Output path:\t" + dirOutRoot;
		print(text);
	
	} 

	return dirOutRoot;
	
}

// # 5
// Input user setting
function InputUserSettingParameters() {

	axisDimentions = "zyxc";
	datasetName = "/exported_data"; // Change this with the right dataset name if not will ask each time the name of the dataset
	singleTiff = false;
	
	Dialog.create("User Settings ");
	Dialog.addMessage("Ilastik HDF5 to Tiff and Tiff to HDF5", 18);
	Dialog.addMessage("___________________________________________________________________________________________");
	Dialog.addString("Axis Dimention", axisDimentions,5);
	Dialog.addToSameRow();
	Dialog.addString("Dataset Name", datasetName, 15);
	
	Dialog.addMessage(" _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _");
	Dialog.addCheckbox("Convert Tiff Sequence to hdf5", singleTiff);

	Dialog.addMessage("\n__________________________________________________________________________________________");
	Dialog.addMessage("  *Last Update: 2021-01-29", 11, "#001090");
	
	// Add Help button
	html = "<html>"
		+ "<style> html, body { width: 500; height: 350; margin: 10; padding: 0; border: 0px solid black; background-color: #ECF1F4; }"
		+ "<h1> <center> &#128000; Help &#128000; </center> </h1>"
		+ "<h3> <section> " 
		+ "<b> Options:</b>" 
			+ "<li><i>Convert HDF5 to Tiff</i>: [INPUT OPTION 1] Choose an input folder with subfolders containing the ilastik HDF5 to convert to Tiff <br/><br/></li>"
			+ "<li><i>Convert Tiff to HDF5</i>: [INPUT OPTION 2] Choose an input folder with subfolders containing the Tiff files to convert to HDF5 <br/><br/></li>"
			+ "<li>Choose the Tiff sequence option to convert the HDF5 files in Tiff sequences<br/><br/></li>"
		+ "</h3> </section>"
		+ "</style>"
		+ "</html>";

	Dialog.addHelp(html);
	Dialog.show();

  	
  	Dialog.show();
	axisDimentions = Dialog.getString();
	datasetName = Dialog.getString();
	singleTiff = Dialog.getCheckbox();

	userSettings = newArray(axisDimentions, datasetName, singleTiff);
	return userSettings;
	
}


// # 6
// Check file format
// Convert the image to h5 if the input is tiff
function CheckFileFormat(folderPath) {

	// Count tiff images
	countFile = 0;
	fileList = getFileList(folderPath);

	for (j = 0; j < fileList.length; j++) {

		if (endsWith(fileList[j], 'tiff') || endsWith(fileList[j], 'tif')) {

			countFile += 1;
					
		}
			
	}

	// Check the image file format
	if (countFile == fileList.length) {

		fileFormat = "tiff";
		
	} else {

		fileFormat = "NAN";
		
	}

	return fileFormat;
	
}

// # 7
// Save and close Log window
function CloseLogWindow(dirOutRoot) {
	if (isOpen("Log")) {
		selectWindow("Log");
		saveAs("Text", dirOutRoot + "Log.txt"); 
		run("Close");
		
	} else {

		print("Log window has not been found");
	}
	
}

// # 8
// Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");
		
	} else {
		
		print("Memory window has not been found!");
	
	}
	
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro IlastikConverter {

	// Start functions
	CloseAllWindows();
	CheckPluginInstallation();

	// Display memory usage
	doCommand("Monitor Memory...");

	// Get the starting time toi create the output root directory
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Do not display the images
	setBatchMode(true);
		
	// Get the path of the input file
	dirIn = InputDirectory();

	// Get the list of folder in the input directory
	folderList = getFileList(dirIn);

	// Initialize count H5
	getFirstH5 = 0;

	// Set the order dimensions when the first h5 file is found
	// Assumption: the h5 file to convert needs to have the same order dimensions
	// if you enter the wrong dimensions the ilastik dialog box popup. To avoid the problem input the right dimensions in the dialog box
	if (getFirstH5 == 0) {

		// Set the count to 1
		getFirstH5 = 1;
						
		// User input setting dimensions
		userSettings = InputUserSettingParameters();
					
	}

	// Create the output directory in the input path
	outputPath = dirIn;
	dirOutRoot = OutputDirectory(outputPath, year, month, dayOfMonth, second);
					
	// Loop through the folders in the input directory
	for (i=0; i<folderList.length; i++) {

		// List of folders
		folderPath = dirIn + folderList[i];

		if (endsWith(folderPath, '/') || userSettings[2] == false) {
	
			print("\n################################################################################################################");
			print((i+1) + ". Reading Folder: " + folderPath);

			// Show progress
			showProgress(i /folderList.length);
		
			// Get the list of subfolder
			fileList = getFileList(dirIn + folderList[i]);

			// Open the file located in the input directory
			for (k=0; k<fileList.length; k++) {

				// Check the input file format .h5
				if (endsWith(fileList[k], '.h5')) {
	
					// Update the user
					print("Processing file:\t" + (k+1));
					print(folderPath + fileList[k]);

					// Open the input image
					run("Import HDF5", "select=["+ folderPath + fileList[k] +"] datasetname=["+ userSettings[1] +"] axisorder=["+ userSettings[0]+"]");

					// Catch the input image file name
					// Remove the .h5 extetion
           			dotIndex = lastIndexOf(fileList[k], ".");
           		 	title = substring(fileList[k], 0, dotIndex);

            		// Save the file as tiff
          		 	print("Saving: \t" + title + ".tiff");
            		saveAs("Tiff", dirOutRoot + title);
            		outputTitle = getTitle();
           			close(outputTitle);

				} else if (endsWith(fileList[k], 'tiff') || endsWith(fileList[k], 'tif')) {

					// Update the user
					print("Processing file:\t" + (k+1));
					print(folderPath + fileList[k]);

					// Open the input image
					open(folderPath + fileList[k]);

					// Catch the input image file name
					// Remove the .tiff extetion
            		dotIndex = lastIndexOf(fileList[k], ".");
            		title = substring(fileList[k], 0, dotIndex);

            		// Save the file as h5
            		print("Saving: \t" + title + ".h5");
					run("Export HDF5", "select=[" + dirOutRoot + title + ".h5" + "] exportpath=[" + dirOutRoot + title + ".h5" + "] datasetname=data compressionlevel=0 input=["+title+"]");	
            		outputTitle = getTitle();
            		close(outputTitle);


				} else { 
			
            		// Update the user
					print("Input file is not {.hdf5/.tiff/.tif or a tiff Sequence}: " + fileList[k]);
			
				}
				
			} 

		} else {

			// Open all the images in the foder as sequence
			print("\n################################################################################################################");
			print((i+1) + ". Opening Image Sequence: " + folderPath);

			// Check input file format
			fileFormat = CheckFileFormat(folderPath);
			
			// Tiff to H5
			if (fileFormat == "tiff") {

				// Open image sequence
				run("Image Sequence...", "open=["+ folderPath + "] sort");

				// Catch the input image file name
				// Remove the .tiff extetion
				title = getTitle();
            	dotIndex = lastIndexOf(title, ".");

				if (dotIndex != -1) {
				
					title = substring(title, 0, dotIndex);

				}

				// Check if the output directory already exists
				if (File.exists(dirOutRoot)) {
						
					// Create the image and the analysis output directory inside the output root directory
					dirOut = dirOutRoot + "0" + (i+1) + "_" + title + File.separator;
					File.makeDirectory(dirOut);
	
				}
				
				// Save the file as h5
         	   	print("Saving: \t" + title + ".h5");
				run("Export HDF5", "select=[" + dirOut + title + ".h5" + "] exportpath=[" + dirOutRoot + title + ".h5" + "] datasetname=data compressionlevel=0 input=["+title+"]");	
            	outputTitle = getTitle();
           	 	close(outputTitle);

			} else {

				print("File format is not supported!");

			}
    			       	
		}
			
	}

	// Update the user 
	print("\nNumber of directories processed:\t" + folderList.length);
	print("\n%%% Congratulation your file have been successfully processed %%%");
	
	// End functions
	CloseLogWindow(dirOutRoot);
	CloseMemoryWindow();
	
	// Display the images
	setBatchMode(false);
	showStatus("Completed");

	// Clear memory
	call("java.lang.System.gc");     
	
}