/*
 * RT-DC_Data_Reduction.ijm
 * Project : High-Throughput RT-DC Mechanical Phenotyping
 *
 * Purpose : Filter high-speed microscopy stacks by retaining only frames
 *           that contain a cellular event, reducing dataset size by ~90%.
 *
 * Criterion : A frame is kept when the minimum pixel intensity (darkest point)
 *             inside the microfluidic channel ROI falls within the
 *             experimentally validated cell-signal window [minThreshold, maxThreshold].
 *
 * Usage   : 1. Open your raw .tif stack in FIJI before running this macro.
 *           2. Run the macro — you will be prompted for an output directory.
 *           3. Retained frames are saved as individual TIFFs named Frame_<i>.tif.
 *           4. Reassemble in FIJI via File > Import > Image Sequence...
 *              (enable "Sort names numerically").
 *
 * Note    : Close the Results table (Analyze > Clear Results) before running
 *           if it already contains rows from a previous session.
 */

// ── User-Defined Parameters ──────────────────────────────────────────────────
var minThreshold = 20;   // Exclude extremely dark artifacts / noise floor
var maxThreshold = 91;   // Upper bound for a phase-contrast cell signal

// ── Macro Entry Point ────────────────────────────────────────────────────────
macro "RT-DC Frame Filter" {

    if (nSlices < 1) {
        exit("No image stack is open.\nPlease open your high-speed .tif stack first.");
    }

    outputDir = getDirectory("Select Output Directory for Compactified Frames");

    cellCount = 0;

    setBatchMode(true);

    nFrames  = nSlices;
    filename = getTitle();

    // Define the Detection Zone (Microfluidic Channel ROI)
    // A slanted quasi-parallelepiped that excludes the high-contrast channel
    // borders while covering the full flow cross-section.
    // Channel dimensions: 500 x 30 x 30 µm  (length x width x depth)

    makePolygon(103, 255, 95, 0, 25, 0, 33, 255);

    // Restrict measurements to minimum intensity only (fastest possible scan).
    run("Set Measurements...", "min redirect=None decimal=1");

    run("Clear Results");

    print("\\Clear");   // Clear the Log window for a clean run summary
    print("Starting RT-DC reduction for: " + filename);
    print("Total frames to scan: " + nFrames);
    print("Intensity gate: (" + minThreshold + ", " + maxThreshold + ")");
    print("Output directory: " + outputDir);
    print("------------------------------------------------------------");

    for (i = 1; i <= nFrames; i++) {
        setSlice(i);
        run("Measure");

        // After clearing, the next Measure call writes to row 0 again.
        if (nResults >= 500) {
            run("Clear Results");
        }

        // Retrieve the minimum intensity for the current frame.
        // nResults - 1 is robust: it always points to the row just written,
        // regardless of whether the table was flushed above.
        currentMin = getResult("Min", nResults - 1);

        // Gate: retain frames where the darkest pixel indicates a cell.
        if (currentMin > minThreshold && currentMin < maxThreshold) {
            cellCount++;

            run("Duplicate...", "ignore");

            // Filename uses original frame index i to guarantee unambiguous
            // numeric sort order when reimporting via Image Sequence.

            saveAs("Tiff", outputDir + "Frame_" + i + ".tif");
            close();
        }

        // Progress report every 1000 frames (visible in FIJI Log window).
        if (i % 1000 == 0) {
            print("Processed " + i + "/" + nFrames + " frames  |  Events kept so far: " + cellCount);
        }
    }

    // Final cleanup
    run("Clear Results");

    close("*");

    setBatchMode(false);

    // ── Summary Report ───────────────────────────────────────────────────────
    print("============================================================");
    print("Reduction complete.");
    print("Original frames : " + nFrames);
    print("Frames retained : " + cellCount);

    if (cellCount > 0) {
        reductionPct = (1 - cellCount / nFrames) * 100;
        print("Reduction factor: " + d2s(nFrames / cellCount, 1) + "x  (" + d2s(reductionPct, 1) + "% of frames removed)");
    } else {
        print("WARNING: No frames were retained. Check your intensity thresholds.");
        print("  minThreshold = " + minThreshold + "  |  maxThreshold = " + maxThreshold);
    }
    print("============================================================");
}
