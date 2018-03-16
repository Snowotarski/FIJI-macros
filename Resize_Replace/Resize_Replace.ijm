//Resize Replace 
//
//S.Nowotarski (2018)
//stn@stowers.org



//ABOUT
//
// This was designed to easily incorporate images of different sizes into a stack while eliminating any skewing on image math by padding values.
//
//This plugin recursively runs though folders and determines the largest x and y dimensions of all the tifs present
//then resizes all of the tifs to match those largest dimensions by padding smaller images with NaN values and saves
//resulting tifs renamed in a directory of your choice.


//NOTE: 
//This runs replace all 0 (black) in the dataset with NaN as the original use was to deal with images that already had a black padding
//around them before resizing. The NaN function requires a 32 bit image and your image will be saved as such.


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 1: DIRECTORIES, VARIABLES and TABLES 


//Start by prompting user to pick folders for processing and saving
waitForUser("Click OK to select a folder of data to process");
   dir = getDirectory("Choose a Directory");

waitForUser("Click OK to select where to save results");
   dir2 = getDirectory("Choose a Directory");

//ask the user to create the addition to the file name they want
 extension = "_resize";
  Dialog.create("Add to end of file name");
  Dialog.addString("Add this name extension on processed files:"  extension);
  Dialog.show();
  extension = Dialog.getString();


//REINSTATE (+ line 127) to  print all image_dimensions to a table in case you want a .csv from this
  //name1 = "[all_image_dimensions]";
  //run("New... ", "name="+name1+" type=Table");
  //f = name1;
  
//REINSTATE (+line 69) to print max dimesions out to a max_dimensions table
  //name2 = "[max_dimensions]";
  //run("New... ", "name="+name2+" type=Table");
  //g = name2;
  

//set start max dimension variables
var xmax = 1;
var ymax = 1;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SECTION 2: FUNCTION WORKFLOW

//imageJ version requirement and setting batch mode to not display images (this is ~20x faster than false).
requires("1.33s"); 
setBatchMode(true);

   
//run through data to be processed and determine the maxDimensions 
endpoint = 1
count = 0;  
	countFiles(dir);
n = 0;   
	processFiles(dir);
	//print(g, xmax+", "+ymax); //uncomment along with lines 45-47 to print out max dimensions to separate table

//run through data to be processed and resize, turn to 32bit, replace all 0 with NaN, and save
endpoint = 2
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
             	maxDimension(path); 
             	
             if (endpoint == 2)
             	sizeNsave(path);
            
      }       	
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //SECTION 4: SECONDARY FUNCTIONS 

 
function maxDimension(path) {
       if (endsWith(path, ".tif")) {
           open(path);
			
         	x=getWidth;
			y=getHeight;

			//print(f, x+", "+y); //uncomment along with lines 40-42 to report all image widths and heights to a table
			
			if ( x > xmax){
				xmax = x;
			};
			
			if (y > ymax) {
				ymax = y;
			};
								
           save(path);
           close();
      }
  }
  
 
function sizeNsave(path) {
       if (endsWith(path, ".tif")) {
           open(path);
		
			t1=getTitle();
			t2=replace(t1,".tif","");
  			
  			run("Canvas Size...", "width=&xmax height=&ymax position=Center zero"); 
          	
			run("32-bit");
			
			run("Macro...", "code=[if (v==0) v=NaN]"); 
			
			saveAs("Tiff", dir2 + t2 + extension + ".tif");
					
           save(path);
           close();
      }
  }