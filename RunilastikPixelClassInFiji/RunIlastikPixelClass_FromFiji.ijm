/*
 * Run ilastik Pixel Classification from ImageJ/Fiji
 * This is just an example code on how to run ilastik pixel classification workflow in ImageJ/Fiji
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Department for Anatomy and Cell Biology @ Heidelberg University
 * Email: carlo.beretta@uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 8682
 * Tel.: +49 (0) 6221 54 51435
 * 
 * NB: Before to start set the ilastik executable location
 * Fiji Main Menu: Plugin >> ilastik >> Configure ilastik executable location
 * 
 * MAC OX:
 * 
 * 		pathToMyIlastikInstallation = "/Applications/ilastik-x.x.xxx-OSX.app/Contents/MacOS/ilastik"
 * 		run("Configure ilastik executable location", "executablefile=["+ pathToMyIlastikInstallation +"] numthreads=-1 maxrammb=4096");
 * 
 * Windows 10:
 * 
 * 		pathToMyIlastikInstallation = C:\\Program Files\\ilastik-x.x.xxx\\ilastik.exe
 * 		run("Configure ilastik executable location", "executablefile=["+ pathToMyIlastikInstallation +"] numthreads=-1 maxrammb=4096");
 * 
 * Tested version on Windows 10 and MAC OX!
 * 
 * Created: 2020-05-04
 * Last update: 2021-02-12
 * 
 */

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// # 0. Close all open images
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
	
}

// # 1. Check plugin installation
function CheckPluginInstallation() {

	List.setCommands;		
	if (List.get("Export HDF5") == "") {
			
		print("Before to start to use this macro you need to install the ilastik ImageJ/Fiji plugin!");
		wait(3000); 	
    	print("1. Select Help >> Update... from the menu to start the updater");
		print("2. Click on Manage update sites. This brings up a dialog where you can activate additional update sites");
    	print("3. Activate ilastik update sites (http://sites.imagej.net/Ilastik/)");
    	print("4. Click Apply changes and restart ImageJ/Fiji");
    	print("5. After restarting ImageJ you should be able to run this macro");
    	print("6. Further information can be found: https://www.ilastik.org/documentation/fiji_export/plugin/");
    	print("NB: After installing the plugin you need to setup the path to the ilastik executable location");
    	print(">> (Fiji Main Menu: Plugin >> ilastik >> Configure ilastik executable location)");
    	wait(3000);
    	exec("open", "https://www.ilastik.org/documentation/fiji_export/plugin/");
    	exit(); 
       	
	} else {

		print("ilastik Import Export plugin is installed!");
		wait(3000);
		print("\\Clear");
   		
	}

}

// # 2. Run ilastik Pixel Classification
function RunIlastikPixelClass(inputForIlastik, ilpPath) {
	
	// Ilastik project path
	// For Windows use: "\\" for MAC OX and Linux use: "/" 
	ilastikProjectPath = ilpPath;
	print("ilastik Project Path:\t " + ilastikProjectPath);

 	// Run ilastik pixel class project from ImageJ/Fiji 
 	// << TO CHECK with ilastik Team >> The input image stay in ilastik and you do not need to close it.
 	// 									It seems the case only with setBatchMode(true);
	print("Running ilastik Pixel Classification Project");
	run("Run Pixel Classification Prediction", "projectfilename=["+ ilastikProjectPath +"] inputimage=["+ inputForIlastik +"] pixelclassificationtype=Probabilities");

	// Output ilastik Probability Map
	rename(inputForIlastik +"_PM");
	outputIlastik = getTitle(); // NB: it is a multiple channels image. It contains the probability map of each label as channel!
	print("ilastik Output:\t " + outputIlastik);

	return outputIlastik;
	
}

// # 3. Build ilp project file path
function BuildIlpPath() {

	input = getDirectory("Choose the ilastik pixel classification project directory");
	ilpFile = getFileList(input);

	for (i = 0; i < ilpFile.length; i++) {
	
		if (endsWith(ilpFile[i], '.ilp')) {

			ilpPath = input + ilpFile[i];

		}

	}

	return ilpPath;
	
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Process a folder with the raw images
macro RunIlastikPixelClassification {

	// Close all open images
	CloseAllWindows();

	// Check ilastik ImageJ/Fiji plugin installation 
	CheckPluginInstallation();

	// Choose the input source directory with the raw images
	dirIn = getDirectory("Choose the INPUT source directory");

	// Get the file list in the input directory
	fileList = getFileList(dirIn);

	// Do not display the images
	setBatchMode(true);

	// Loop through the files
	for (i = 0; i < fileList.length; i++) {

		// Open the image
		open(dirIn + fileList[i]);

		// Get image title
		inputForIlastik = getTitle();
		print("Input Image File Name:\t " + inputForIlastik);

		// Build ilastik project path 
		if (i == 0) {

			ilpPath = BuildIlpPath();
			
		}
		
		// Function: Run ilastik Pixel Classification
		outputIlastik = RunIlastikPixelClass(inputForIlastik, ilpPath);
	
		// Add here your code
		// ...
		// ...
		// ...

		// Save the results
		// ...
		// ...
		// ...

		// Close the open images
		selectImage(outputIlastik);
		close(outputIlastik);
		// selectImage(inputForIlastik);
		// close(inputForIlastik);

	}

	// Display the images
	setBatchMode(false);
	showStatus("Completed");

}