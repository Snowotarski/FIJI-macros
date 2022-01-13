/*
 * Representative Extract 
 * 
 * S. Nowotarski (2022)
 * stn@stowers.org
 * 
 * This macro takes a directory of tif stacks, allows user to pull out relatively evenly distributed slices of 
 * 1 (middle) to 5.  
 * 
 * Originally used to pull out z representative images of features for machine learning training
 * 
 * 
 */
//SECTION 1 : DIRECTORIES, VARIABLES, MONITORING //////////////////////////////////////////////////////////////////////////////////////////////////

cs = ","
p = "."

//Open and Save Paths for working with individual images 
waitForUser("Click OK to select a folder of data to process");
dir1 = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
dir2 = getDirectory("Choose a Directory");


//Dialog Box for settings 
extension = "_extracted";

	Dialog.create("Representative Extract Settings");
	Dialog.addString("Add this name extension on processed files:" extension);
	Dialog.addNumber("How many images do you want extracted?", 3);
	Dialog.show();

extension = Dialog.getString();
choice = Dialog.getNumber();


//SECTION 2: FUNCTION WORKFLOW /////////////////////////////////////////////////////////////////////////////////////////////
setBatchMode(true);

   
//run through data to be processed and save as  
endpoint = 1;
count = 0;  
	countFiles(dir1);  
n = 0;   
	processFiles(dir1);

waitForUser ("Your files are finshed, you can find them at:" +dir2);


//SECTION 3: PRIMARY FUNCTION/WORKFLOW ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   

   function countFiles(dir1) { 
      list = getFileList(dir1);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir1+list[i]);
          else
              count++;
      }
  }

 function processFiles(dir1) { 
 
      list = getFileList(dir1);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir1+list[i]);
          else {
             showProgress(n++, count);
          	}
             path = dir1+list[i];

             if (endpoint == 1)
             	fileSave(path); 
            
      }       	
  }


//SECTION 4: SECONDARY FUNCTIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function fileSave(path) {
       if (endsWith(path, ".tif")) {
           open(path);

 			stack= getTitle();
			getDimensions(width, height, channels, slices, frames);
 			interval= (slices / (choice +1));
 			 
			a=newArray(choice);
			Array.fill(a, interval);
		
			//populate the array with multiples of the interval, run through it duplicate and save.
			for (b=0; b<=a.length-1;b++){
				a[b]= interval + (interval*b); 
				setSlice(a[b]);
				run("Duplicate...", "use");
				t1=getTitle();
				t2=replace(t1,".tif","");
				saveAs("Tiff", dir2 + t2 + extension + "_" + floor(a[b])); //floor = decimal to integer
				close();
				selectWindow(stack);
	}

     
  }
}
			
        			
  			
 