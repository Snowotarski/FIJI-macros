/*Isolate_&_Enhance
 * 
 * S. Nowotarski (2022)
 * stn@stowers.org
 * 
 * ABOUT
 * This macro takes a folder of stacks with 2 channels and uses the second to mask the data on the first. 
 * The resulting stack is then CLAHE processed.
 * Stacks are saved to an output folder with a new name extension.
 * 
 * Originally used for enhancement of nuclear texture in SBF-SEM images.
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
extension = "_isoContrast";
blocksize = 127;
histogram_bins = 256;
maximum_slope = 1.5;
mask = "*None*";
fast = false;
process_as_composite = true;

	Dialog.create("Isolate and Enhance Contrast Settings");
	Dialog.addString("Add this name extension on processed files:" extension);
	Dialog.addSlider("Blocksize", 1, 256, 127);
	Dialog.addSlider("Histogram Bins", 1, 256, 256);
	Dialog.addSlider("Slope", 1, 3, 1.5); 
	Dialog.addMessage("Masking is not supported in this version \n You can edit masking in macro file.");
	Dialog.addCheckbox("fast", false);
	Dialog.addCheckbox("Process as composite?", false);
	Dialog.addMessage("Batch mode is enabled for speed. \n Note that you will not see your data being processed. \n Set batch mode to true in line 63 to view processsing (slower!).");
	Dialog.show();

extension = Dialog.getString();
blocksize = Dialog.getNumber();
histogram_bins = Dialog.getNumber();
maximum_slope = Dialog.getNumber();
fast = Dialog.getCheckbox();
process_as_composite = Dialog.getCheckbox();


//reset log, display settings
print("\\Clear");
print("This data has been masked and processed with CLAHE settings:" + blocksize + cs + histogram_bins + cs + maximum_slope + p);


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
		
			t1=getTitle(); 
			t2= "C1-"+t1;
			t3= "C2-"+t1;
			t4= dir2 + t1 + extension;
  			
			run("Split Channels");
			
			selectWindow(t2);
			run("8-bit"); 
			run("Grays");
			
			selectWindow(t3); 
			run("8-bit");
			run("Grays");
			run("Invert", "stack");
			
			imageCalculator("Subtract create stack", t2, t3);
			selectWindow("Result of "+t2);
			
			getDimensions( width, height, channels, slices, frames );
			isComposite = channels > 1;
			parameters =
			  "blocksize=" + blocksize +
			  " histogram=" + histogram_bins +
			  " maximum=" + maximum_slope +
			  " mask=" + mask;
			if ( fast )
			  parameters += " fast_(less_accurate)";
			if ( isComposite && process_as_composite ) {
			  parameters += " process_as_composite";
			  channels = 1;
			}
			   
			for ( f=1; f<=frames; f++ ) {
			  Stack.setFrame( f );
			  for ( s=1; s<=slices; s++ ) {
			    Stack.setSlice( s );
			    for ( c=1; c<=channels; c++ ) {
			      Stack.setChannel( c );
			      run( "Enhance Local Contrast (CLAHE)", parameters );

			      saveAs("Tiff", t4);
			      file_number = i+1;
			      print ("Isolate and Enhance performed on stack " + file_number +cs+ " slice " + s);
			     
   
    } 
  }
}
			
        				}
  			}
 
			
					
           
   








 






