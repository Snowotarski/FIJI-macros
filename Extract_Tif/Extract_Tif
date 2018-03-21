//Extract_Tif 
//
//S.Nowotarski (2018)
//stn@stowers.org



//ABOUT
//
//Recursively searchs through a complex file structure to remove tifs and save them to a new 
//directory.
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 1: DIRECTORIES, VARIABLES and TABLES 


//Start by prompting user to pick folders for processing and saving
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
   dir2 = getDirectory("Choose a Directory");

//ask the user to create the addition to the file name they want
 extension = "_copy";
  Dialog.create("Add to end of file name");
  Dialog.addString("Add this name extension on processed files:"  extension);
  Dialog.show();
  extension = Dialog.getString();


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 2: FUNCTION WORKFLOW

//imageJ version requirement and setting batch mode to not display images (this is ~20x faster than false).
requires("1.33s"); 
setBatchMode(true);

   
//run through data to be processed and save as  
endpoint = 1
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
  			
  			//run("8-bit");  
			
			saveAs("Tiff", dir2 + t2 + extension + ".tif");
					
           save(path);
           close();
      }
  }
