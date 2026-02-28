/*
 * High-Throughput RT-DC Data Reduction Macro
 * * Project: High-Throughput RT-DC Mechanical Phenotyping
 * Purpose: To filter high-speed microscopy stacks by retaining only frames containing 
 * cellular events, reducing dataset size by ~90%.
 * * Criteria: Frames are kept if the minimum pixel intensity (darkest point) in the 
 * microfluidic channel falls within the experimentally validated cell range.
 */

// --- User-Defined Parameters ---
var minThreshold = 20;  // Exclude extremely dark artifacts/noise
var maxThreshold = 91;  // Upper bound for a "dark" cell signal against bright background
var cellCount = 0;

// --- Setup ---
macro "RT-DC Frame Filter" {
    
    // Select Directories
    inputDir = getDirectory("Select Input Directory containing .tif stacks");
    outputDir = getDirectory("Select Output Directory for Compactified Data");
    
    setBatchMode(true); 
    
    // Process the active stack
    if (nSlices < 1) {
        exit("No image stack open. Please open your high-speed movie first.");
    }
    
    nFrames = nSlices;
    filename = getTitle();
    
    // Define the Detection Zone (Microfluidic Channel)
    // Exclude high-contrast borders to avoid false positives
    // Coordinates based on standard 20µm x 20µm channel geometry
    makePolygon(103, 255, 95, 0, 25, 0, 33, 255);
    
    // Configure measurements to only look for the darkest pixel (Min)
    run("Set Measurements...", "min redirect=None decimal=1");

    print("Starting reduction for: " + filename);
    print("Total frames to scan: " + nFrames);

    for (i = 1; i <= nFrames; i++) {
        setSlice(i);
        run("Measure");
        
        // Retrieve the minimum intensity value for current frame
        currentMin = getResult("Min", nResults - 1);
        
        // If intensity indicates a cell is passing through the detection zone
        if (currentMin < maxThreshold && currentMin > minThreshold) {
            cellCount++;
            
            // Extract the single frame and save as individual TIFF
            run("Duplicate...", "use");
            saveAs("Tiff", outputDir + "Event_" + cellCount + "_Frame_" + i + ".tif");
            close(); 
        }
        
        // Progress update every 1000 frames
        if (i % 1000 == 0) {
            print("Processed " + i + "/" + nFrames + " frames...");
        }
    }

    // Cleanup and Summary
    run("Clear Results");
    print("--- Reduction Complete ---");
    print("Original Frames: " + nFrames);
    print("Relevant Events Kept: " + cellCount);
    print("Data Reduction Factor: " + (nFrames/cellCount) + "x");
    
    setBatchMode(false);
}