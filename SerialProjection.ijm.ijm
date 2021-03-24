/*
 * SERIAL PROJECTIONS
 * 
 * S.Nowotarski 2019
 * stn@stowers.org 
 * 
 * This macro generates a projection at each frame of a stack so that 
 * projections can be paired with original images leaving a memory trail
 * of the data before
 * 
 * For use in Body of Inquiry; The art and biology of being a flatworm 2020
 * 
 * Wishlist
 * Add in dialog box and list to choose projection type
 * Add in image calculation where resuting projection is added to the image of the counter 
 */

 
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
   dir2 = getDirectory("Choose a Directory");


requires("1.45f");
extension = "_proj";
Dialog.create("File Name Extension");
Dialog.addString("Add this name extension on processed files:"  extension);

  
setBatchMode (true); 
open(dir);

length = nSlices
t1=getTitle();
t2=replace(t1,".tif","");

for (i=1; i<=length; i++) {
	run("Z Project...", "stop=&i projection=[Standard Deviation]");
	saveAs("Tiff", dir2 + t2 + extension + ".tif");
   }
