//BitDepth_AutoBC 
//
//S.Nowotarski (2018)
//stn@stowers.org



//ABOUT
//
//Recursively searchs through a complex project file structure to remove tifs and save them to a new 
//directory. Features easy clickable interface to decide input directory, output directory, conversion to 
//8-bit,16-bit,32-bit or RGB, optional Auto Brightness and Contrast.

//Processed files are accompanied by a .txt file describing what has been done to the data
//for documentation and data sharing purposes. 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 1: DIRECTORIES, VARIABLES and TABLES 


//Start by prompting user to pick folders for processing and saving
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
   dir2 = getDirectory("Choose a Directory");

//select the bit depth you want to save as and if you want to run autoBC
  extension = "_processed";
  Dialog.create("Processing");
  Dialog.addString("Add this name extension on processed files:"  extension);
  Dialog.addChoice("Bit Depth:", newArray("8-bit", "16-bit", "32-bit", "RGB"));
  Dialog.addCheckbox("Auto B/C", true);
  Dialog.show();
  type = Dialog.getChoice();
  auto = Dialog.getCheckbox();
  extension = Dialog.getString();


//use log to display how the data has been processed and save it as .txt in same dir as output
  print("\\Clear");
  print("Your data is " + type + ".");
  
  if (auto==true)
  	print("Your data has been auto brightness contrasted to encompass the full dynamic range of pixel intensities.");
  	
 
  selectWindow("Log");
  saveAs("Text...", dir2 + "README_Image_processing" + ".txt");
  close("Log");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 2: FUNCTION WORKFLOW

//imageJ version requirement and setting batch mode to not display images (this is ~20x faster than false).
requires("1.33s"); 
setBatchMode(true);

   
//run through data to be processed and save as  
endpoint = 1;
count = 0;  
	countFiles(dir);
n = 0;   
	processFiles(dir);

waitForUser ("Your files are finshed, you can find them at:" +dir2);
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 3: PRIMARY FUNCTIONS   

   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

 function processFiles(dir) {
 
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
          	}
             path = dir+list[i];

             if (endpoint == 1)
             	fileSave(path); 
            
      }       	
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //SECTION 4: SECONDARY FUNCTION


function fileSave(path) {
       if (endsWith(path, ".tif")) {
           open(path);
		
			t1=getTitle();
			t2=replace(t1,".tif","");
  			
  			run(type);  

  			if (auto==true){
  				run("Brightness/Contrast...");//problem not here 
  				resetMinAndMax();
  				run("Enhance Contrast", "saturated=0.35"); 
  				getMinAndMax(min,max);  // get display range
    				if (min != 0 && max != 255) {  // check if the display has been changed
        				run("Apply LUT", "stack"); 
        				}
  			}
 
			saveAs("Tiff", dir2 + t2 + extension + ".tif");
					
           save(path);
           close();
      }
  }

