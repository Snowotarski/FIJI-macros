/*IMOD2FIJI
 * 
 * S. Nowotarski (2023)
 * stn@stowers.org
 * 
 * ABOUT
 * This macro takes IMOD Zap Window movies adjusted so that the EM signal is black and annotations are R,G or B
 * and turns them into Fiji stacks with interpolated ROIs to handle sparse annotation. Channels are optional.
 * Saves individual channel tifs binarized and filled in and ROIs.#
 * 
 * This is recursive and will run perfectly if you save in a directory inside of your input but will error out when done instead of a clean finish.
 * 
 * 
 */

//SECTION 1 : DIRECTORIES, VARIABLES, MONITORING //////////////////////////////////////////////////////////////////////////////////////////////////

cs = ","
p = "."

//Open and Save Paths for working with individual images 
dir1 = getDirectory("Choose data you want to process");

dir2 = getDirectory("Where are you saving this? Do not pick a child dir of input.");


//Dialog Box for settings 
extension = "_binaryVol";
redExt ="_r";
greenExt="_g";
blueExt="_b";


	Dialog.create("IMOD2FIJI Settings");
	Dialog.addString("Add this name extension on processed tif stacks:" extension);
	Dialog.addMessage("Select the channels you have annotations in");
	Dialog.addCheckbox("Red", true);
	Dialog.addString("Extension for red channel: " redExt);
	Dialog.addCheckbox("Green", false);
	Dialog.addString("Extension for green channel: " greenExt);
	Dialog.addCheckbox("Blue", false);
	Dialog.addString("Extension for blue channel: " blueExt);
	Dialog.addMessage("Batch mode is enabled for speed. \n Note that you will not see your data being processed.");
	Dialog.show();

extension = Dialog.getString();
redState = Dialog.getCheckbox();
redExt = Dialog.getString();
greenState = Dialog.getCheckbox();
greenExt = Dialog.getString();
blueState = Dialog.getCheckbox();
blueExt = Dialog.getString();

setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);

print("\\Clear");

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
			
			//retrieve info for naming and selecting 
			t1=getTitle();
			t2=replace(t1,".tif","");  
			
			//windowSelections and saving shorthands
			redWin= t1+" (red)";
			greenWin= t1+" (green)";
			blueWin= t1+" (blue)";
			t4= dir2 + t2 + extension;

			
			run("Split Channels");
		
		if (redState==true) {
			selectWindow(redWin);
			binaryROI();
			saveAs("Tiff", t4 + redExt + ".tif");
			roiManager("save", t4 + redExt + ".zip"); 
			roiManager("delete");
       }		
			
		if (greenState==1) {
			selectWindow(greenWin);
			binaryROI();
			saveAs("Tiff", t4 + greenExt + ".tif");
			roiManager("save", t4 + greenExt + ".zip"); 
			roiManager("delete");
		}	
		
		if (blueState==1) {
			selectWindow(blueWin);
			binaryROI();
			saveAs("Tiff", t4 + blueExt + ".tif");
			roiManager("save", t4 + blueExt + ".zip"); 
			roiManager("delete");		
			}			
		}	
				
		// make sure to close every image from current file before opening the next one
		run("Close All");      
}


function binaryROI() { 
			//BINARIZE, DILATE, FILL HOLES 
			run("Make Binary", "method=Default background=Dark calculate black");
			setOption("BlackBackground", true);
			run("Dilate", "stack");
			run("Dilate", "stack");
			run("Fill Holes", "stack");
	
			//ADD ROI IF ANNOTATION PRESENT
			for (i = 1; i <= nSlices; i++) {
   				setSlice(i);
    			getStatistics(area, mean, min, max, std, histogram);
    				if (max == 255){
    					run("Create Selection");
    					Roi.setPosition(i);
    					roiManager("Add");
    				}						
			}				
			//INTERPOLATE AND DRAW
			roiManager("Interpolate ROIs");
			roiManager("draw");
			roiManager("fill");			
}