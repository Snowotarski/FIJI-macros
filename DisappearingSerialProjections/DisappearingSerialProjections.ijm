/*
 * DISAPPEARING SERIAL PROJECTIONS
 * 
 * S.Nowotarski & M.Mir 2019
 * stn@stowers.org 
 * mmir@stowers.org
 * 
 * This macro generates a projection at each frame of a stack so 
 * projections can be paired with original images leaving a memory trail
 * of the data before
 * 
 * For use in Body of Inquiry: The Art, Biology, and Being of Flatworms 2020
 * 
 * Wishlist
 * Add another save with another extension for the addition
 *
 */

 
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory"); 

waitForUser("Click OK to select where to save results \nThis macro works best if this directory is empty");
   dir2 = getDirectory("Choose a Directory"); 

print("Please be patient for the files to load.\nAfter this is done, a dialog box will appear with options for the user.");
setBatchMode (true); 
open(dir); 
length = nSlices;

//Asks for input for projection variables
 extension = "_Zproj"; 
  Dialog.create("Z Projection Options"); 
  Dialog.addString("Add this name extension on z projected files:"  extension); 
  Dialog.addChoice ("Projection Type:", newArray("Max Intensity", "Standard Deviation")); 
  Dialog.addNumber ("Divide subject intensity by:", 1); 
  Dialog.addSlider("Length of trail visibility:", 1, length, 1);
  Dialog.addMessage (" For projections: Max intensity will yield more solid-ended trails\nwhile Standard Deviation will give a softer end to the trails.");
  Dialog.show(); 
  extension = Dialog.getString(); 
  projtype = Dialog.getChoice(); 
  divdir = Dialog.getNumber(); 
  divdir2 = Dialog.getNumber();;
  trailvis = Dialog.getNumber();;;

t1=getTitle(); 
t2=replace(t1,".tif","");  

//Runs the Z projection
for (i=1; i<=length; i++) {   
   if (i <= trailvis) {
   	run("Z Project...", "start=1 stop=&i projection=[&projtype]"); 
	saveAs("Tiff", dir2 + t2 + extension +"_"+i+ ".tif"); 
	print(i + "/" + length); 
	close(); 
   } else {
   	trail = i-trailvis;
   	run("Z Project...", "start=&trail stop=&i projection=[&projtype]"); 
	saveAs("Tiff", dir2 + t2 + extension +"_"+i+ ".tif"); 
	print(i + "/" + length); 
	close(); 
   }
}

setBatchMode(false);

open(dir2); 
s2=getTitle();

finalsave = dir2 + t2 + extension; 

//Divides the intensity of each stack in preparation for adding both stacks together
run("Divide...", "value=&divdir stack"); 
run("Divide...", "value=&divdir2 stack"); 

imageCalculator("Add create stack", t1, s2); 
saveAs("Tiff", " &finalsave");



