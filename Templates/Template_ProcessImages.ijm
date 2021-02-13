/*
 * Project: Template for Macro
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Department for Anatomy and Cell Biology @ Heidelberg University
 * Email: carlo.beretta@uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 8682
 * 
 * Description: In this project I included what I think is frequently useful
 * for developing a macro. Any suggestion is very much useful!
 * 
 * Created: 2021-02-11
 * Last update: 2021-02-11
 */

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 0 
// Contact Information
function ContactInformation() {

	print("##############################################################");	
 	print("Developed by Dr. Carlo A. Beretta"); 
 	print("Department for Anatomy and Cell Biology @ Heidelberg University");
 	print("Email: carlo.beretta@uni-heidelberg.de");
 	print("Tel.: +49 (0) 6221 54 8682");
 	print("Tel.: +49 (0) 6221 54 51435");
 	print("##############################################################\n");	
 	
}

// # 1 General setting
function Setting() {
	
	// Set the Measurements parameters
	run("Set Measurements...", "area mean standard min perimeter integrated limit redirect=None decimal=8");

	// Set binary background to 0 
	run("Options...", "iterations=1 count=1 black");

	// General color setting
	run("Colors...", "foreground=white background=black selection=yellow");

}

// # 2
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
}

// # 3a
// Choose the input directories (Raw)
function InputDirectoryRaw() {

	dirIn = getDirectory("Please choose the RAW input source directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirIn) == 0) {
		print("Exit!");
		exit();
			
	} else {

		// Output the path
		text = "Input row path:\t" + dirIn;
		print(text);
		return dirIn;
			
	}
	
}

// # 3b
// Choose the input directories (Raw and PM)
function InputDirectoryRawPM() {

	dirInRaw = getDirectory("Please choose the RAW input source directory");
	dirInPM = getDirectory("Please choose the PM input source directory");

	// The macro check that you choose a directory and output the input path
	if (lengthOf(dirInRaw) == 0 || lengthOf(dirInPM) == 0) {
		
		exit("Exit");
			
	} else {

		// Output the path
		text = "Input RAW path:\t" + dirInRaw;
		print(text);
		text = "Input PM path:\t" + dirInPM;
		print(text);

		inputPath = newArray(dirInRaw, dirInPM);
		return inputPath;
			
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
	dirOutRoot = dirOutRoot + "MacroResults_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;
	return dirOutRoot;
	
}

// # 5
// Open the ROI Manager
function OpenROIsManager() {
	
	if (!isOpen("ROI Manager")) {
		
		run("ROI Manager...");
		
	}
	
}

// # 6
// Close the ROI Manager 
function CloseROIsManager() {
	
	if (isOpen("ROI Manager")) {
		
		selectWindow("ROI Manager");
     	run("Close");
     	
     } else {
     	
     	print("ROI Manager window has not been found");
     	
     }	
     
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

// # 9
// Print summary function (Modified from ImageJ/Fiji Macro Documentation)
function printSummary(textSummary) {

	titleSummaryWindow = "Summary Window";
	titleSummaryOutput = "["+titleSummaryWindow+"]";
	outputSummaryText = titleSummaryOutput;
	
	if (!isOpen(titleSummaryWindow)) {

		// Create the results window
		run("Text Window...", "name="+titleSummaryOutput+" width=90 height=20 menu");
		
		// Print the header and output the first line of text
		print(outputSummaryText, "% Input File Name\t" + "% Area\t" + "\n");
		print(outputSummaryText, textSummary +"\n");
	
	} else {

		print(outputSummaryText, textSummary +"\n");
		
	}

}

// # 10
function SaveStatisticWindow(dirOutRoot) {

	// Save the SummaryWindow and close it
	selectWindow("Summary Window");
	saveAs("Text",  dirOutRoot + "SummaryIntensityMeasurements"+ ".xls");
	run("Close");
	
}

// # 11a Happy Christmas
// It shows how to access to the Fiji installation directory to copy any useful file
// the img. directory as to be copy together with the macro and can contain the file to copy (e.g.: Chr.jpg)
function CopyFile2FijiInstallation() {

	path2Macro = File.directory;
	path2Image = path2Macro + "img" + File.separator;
	fileListImg = getFileList(path2Image);
	path2Fiji = getDirectory("imagej");

	if (File.exists(path2Image) && fileListImg.length != 0) {

		// Copy the image to the Fiji installation path
		File.copy(path2Image + "Chr.jpg", path2Fiji + "Chr.jpg");
	
		// Delete the temp file from img folder after copying it in the Fiji installation directroy
		File.delete(path2Image + "Chr.jpg");

		// Clear the Log
		print("\\Clear");
	
	} 

	return path2Fiji;
	
}

// # 11b Happy Christmas
// It shows how time works in Fiji and how can be use to track the analysis
// It also help to understand the showStatus function.
function HappyChristmas(dayOfMonth, month, path2Fiji) {

	if (dayOfMonth == 25 && month+1 == 12) {
		
		// Wishes and all the best
		open(path2Fiji + "Chr.jpg");
		setLocation(0, 0, screenWidth, screenHeight);
		chmassWishes = getTitle();

		for (i = 0; i < 3; i++) {
			
			showStatus("****");
			wait(500);
			showStatus("***********");
			wait(500);
			showStatus("*******************");
			wait(500);
			showStatus("*************************");
			wait(500);
			showStatus("*** Merry Christmas ***");
			wait(1000);
			
		}
		
		close(chmassWishes);	
		
	} else if (dayOfMonth != 25 && month+1 == 12) {

		dayToMass = 25 - dayOfMonth;
		showStatus("*** Christmas day: -" + dayToMass + " days ***");
		
	}
	
}

// # 12
// Loop through pixel, catch pixel value and set pixel value
function PixelIntensityValue(inputTitleRaw, binaryTitle) {

	// Update the user 
	showStatus("Reading pixel intensity...");

	// Input size of the image
	wd = getWidth();
	hd = getHeight();

	// Initilize counting variables
	countPixelForegroundROI = 0;
	countPixelBackgroundROI = 0;
	intensityForegroundROI = 0;
	
	// Move ROI selection in (x)
	for (i=0; i<wd; i++) {

		// Show progress
		wait(1);
		showProgress(1 -(((wd - i)) / wd));

		// in (y)
		for (k=0; k<hd; k++) {

			//
			selectImage(binaryTitle);

			// Make a selection around each pixel in xy
			makeRectangle(i, k, 1, 1);
			
			// Get selected pixel statistic
			getStatistics(area, mean, min, max);

			// Measure intensity of all the pixels above background
			// or background value
			if (mean > 0) {

				//
				selectImage(inputTitleRaw);
				
				// Make a selection around each pixel in xy
				makeRectangle(i, k, 1, 1);
			
				// Get selected pixel statistic
				getStatistics(area, mean, min, max);

				// Get the number of pixel above background value
				countPixelForegroundROI += 1;
			
				// Sum the intensity of each pixel above background value 
				// Use mean but also min and max gives same value on single pixel
				intensityForegroundROI += mean;
				
				// Used to check the value loop through
				selectImage(binaryTitle);
 				setPixel(i, k, mean);

			} else {

				//
				selectImage(inputTitleRaw);
				
				// Make a selection around each pixel in xy
				makeRectangle(i, k, 1, 1);
			
				// Get selected pixel statistic
				getStatistics(area, mean, min, max);

				// Get the number of pixels for background 
				countPixelBackgroundROI += 1;

				// Used to check the value loop through
				selectImage(binaryTitle);
 				setPixel(i, k, -0.1); // Change this value if 16 or 8 bits

			}
				 	
		}
			
	}

	roiStatistic = newArray(countPixelForegroundROI, intensityForegroundROI, countPixelBackgroundROI);
	return roiStatistic;
}

// # 13
// Check the memory available to ImageJ/Fiji
function MaxMemory() {

	// Max memory available
	memory = IJ.maxMemory();

	if (memory > 4000000000) {
		
		print("Max Memory (RAM) Available for Fiji/ImageJ is:", memory); 
		print("Please change the amount of memory available to Fiji/ImageJ to 70% of your total memory");
		print("Edit >> Options >> Memory % Threads...");
		run("Memory & Threads...");
		exit();
		
	}

}

// # 14a
// Check Bio-Formats plugin installation
function CheckBioFormatPluginInstallation() {
	
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

// # 14b
// Check ilastik import export plugin installation
function CheckIlastikPluginInstallation() {

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
		wait(3000);
		print("\\Clear");
   		
	}

}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Simple example, not all the above functions are included in the macro part.
macro Template {

	// Start functions
	// 1.
	Setting();
	
	// 2.
	CloseAllWindows();

	// 3.
	OpenROIsManager();

	// Display memory usage
	doCommand("Monitor Memory...");

	// Get the starting time
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// 4. Function choose the input root directory
	dirIn = InputDirectoryRaw();
	outputPath = dirIn;

	// Get the list of file in the input directory
	fileList = getFileList(dirIn);

	// 5. Create the output root directory in the input path
	dirOutRoot = OutputDirectory(outputPath, year, month, dayOfMonth, second);

	if (!File.exists(dirOutRoot)) {	
		File.makeDirectory(dirOutRoot);
		text = "Output path:\t" + dirOutRoot;
		print(text);
	
	} 

	// Do not display the images
	setBatchMode(true);

	// Open the file located in the input directory
	for (i=0; i<fileList.length; i++) {

		// Check the input file format .tiff
		if (endsWith(fileList[i], '.tiff') || endsWith(fileList[i], '.tif')) {

			// Update the user
			print("Processing file:\t\t" +(i+1));

			// Open the input raw image
			open(dirIn + fileList[i]);
			inputTitle = getTitle();
			print("Opening:\t" + inputTitle);

			// Remove file extension .something
			dotIndex = indexOf(inputTitle, ".");
			title = substring(inputTitle, 0, dotIndex);
			
			// Check if the output directory already exist
			if (File.exists(dirOutRoot)) {
				
				// Create the image and analysis directory inside each subdirectory
				dirOut = dirOutRoot + "0" + (i+1) + "_" + title + File.separator;
				File.makeDirectory(dirOut);
	
			}
			
			// Get input image dimentions
			getDimensions(width, height, channels, slices, frames);

			// YOU CAN ADD YOUR CODE HERE!
			// ...
			
			
            
		} else {

			// Update the user
			print("Skypped: Input file format not supported: " + fileList[i]);

		}

	}

	// Update the user 
	text = "\nNumber of file processed:\t\t" + fileList.length;
	print(text);
	text = "\n%%% Congratulation your file have been successfully processed %%%";
	print(text);
	
	// End functions
	SaveStatisticWindow(dirOutRoot);
	CloseROIsManager();
	CloseLogWindow(dirOutRoot);
	CloseMemoryWindow();
	
	// Display the images
	setBatchMode(false);
	showStatus("Completed");
	
}