 /*
  * HISTOMATCH
  * 
  * S.Nowotarski (2018)
  * stn@stowers.org
  * 
  * About
  * This macro will adjust the histograms on individual slices in a stack to a reference slide within the stack.
  * It's good for reducing flickering and long term drift in movies. 
  * Originally used for normalization of 3View SBFEM stacks
  * 
  * 
  * 
  */
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 1: DIRECTORIES, VARIABLES and TABLES

//standard coding shortcuts
cs = ", "

//Let user know requirements 
waitForUser("This works on STACKS only, click OK to point to a stack you want to process");

//Prompt user to pick folders for processing and saving
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
   dir2 = getDirectory("Choose a Directory");



//Generate Dialog and get info from user 
  requires("1.45f");
  extension = "_match";
  Dialog.create("HistoMatch Information");
  Dialog.addString("Add this name extension on processed files:"  extension);
  Dialog.addChoice("Save as bit depth:", newArray("8-bit", "16-bit", "32-bit", "RGB"));
  Dialog.addNumber("Histogram reference slice:", 1);
  Dialog.addCheckbox("Run Enhance Contrast?", false);
  Dialog.addMessage("If you are running Enhance Contrast, please select a saturation below.\nNote smaller number = less contrast"); 
  Dialog.addSlider("Saturation", 0.01, 1.00, 0.35);
  Dialog.show();

  ref = Dialog.getNumber();
  sat = Dialog.getNumber();;
  ec = Dialog.getCheckbox();
  bt =Dialog.getChoice();
  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 2: HISTOGRAM MATCH 


//run histomatch
macro "Float the stack"{ 
setBatchMode (true); 
open(dir);
run("32-bit");

print("ran 32 bit");

setSlice(ref); 
getRawStatistics(nPixels, meanref, min, max, stdref, histogram); 
for (i = 1; i <= nSlices; i++) { 
       setSlice(i); 
       getRawStatistics(nPixels, meani, min, max, stdi, histogram); 
       run("Subtract...", "value="+meani+" slice"); 
       run("Divide...", "value="+stdi+" slice"); 
       run("Multiply...", "value="+stdref+" slice"); 
       run("Add...", "value="+stdref+" slice"); 
       print("adjusted histogram" + i);
}

if (ec==1){
run("Enhance Contrast", "saturated=&sat");
print("Ran enhance contrast at the end of the adjusted histogram");
}


setSlice(1); 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 4: bit depth and SAVE 

run(bt);
print("ran bitdepth change");

t1=getTitle();
t2=replace(t1,".tif","");
saveAs("Tiff", dir2 + t2 + extension + ".tif");

print("File location:" +dir2);

//save as you like from here
waitForUser ("Done. You can find your files at:" +dir2);
}