# High-Throughput RT-DC Mechanical Phenotyping

This repository contains a multi-stage computational pipeline for **Real-Time Deformability Cytometry (RT-DC)**. The workflow is designed to process high-speed microscopy data to perform label-free mechanical phenotyping of cell populations, specifically investigating the impact of the **Cytoskeletal Protein X** on cancer cell deformability.

## 🔬 Scientific Context

RT-DC is a high-throughput method that deforms cells by passing them through a narrow microfluidic channel. By analyzing the resulting shape changes, we can extract mechanical properties (e.g., elasticity and roundness) that serve as markers for cellular functionality or disease states.

This project specifically targets:

* **Data Engineering:** Reducing massive microscopy datasets (~11 GB) while retaining 100% of cellular events.
* **Mechanical Characterization:** Comparing the deformability of **Native**, **Over-expressed (OE)**, and **Knock-down (KD)** cancer cell populations to determine the structural role of Cytoskeletal Protein X.

## 🛠 Tech Stack & Dependencies

* **Image Engineering:** FIJI / ImageJ (Macro Language)
* **Advanced Segmentation:** `Omnipose` (CNN-based segmentation), `Cellpose`
* **Data Analysis:** Python 3.10+
* **Core Libraries:** `pandas`, `numpy`, `scikit-image`, `scipy`, `matplotlib`, `seaborn`

---

## 🚀 The Pipeline & Script Evolution

### Part 1: High-Speed Data Reduction (FIJI)

High-speed RT-DC generates data at a rate that can quickly overwhelm storage and processing power.

* **Script:** `RT-DC_Data_Reduction.ijm`
* **Method:** Implements a **"pixel-intensity gate"** within the microfluidic detection zone.
* **Impact:** Reduced a raw 11GB dataset to **1.04GB**, achieving a **10x data reduction factor** by automatically discarding frames without cell events.

### Part 2: Deep Learning Segmentation (Omnipose)

To obtain accurate mechanical measurements from deformed cells, high-fidelity boundary detection is required.

* **Notebook:** `01_Cell_Segmentation_Omnipose.ipynb`
* **Method:** Utilizes the `bact_phase_omni` model to generate 16-bit labeled masks from high-speed image sequences. This model is optimized for the phase-contrast signatures found in microfluidic channels.

### Part 3: Mechanical Feature Extraction (Python)

The final stage translates binary masks into biophysical parameters.

* **Notebook:** `02_Mechanical_Feature_Extraction.ipynb`
* **Analysis:** Calculates **Area**, **Circularlity**, and **Deformation ($D$)**.
* **Quality Control:** Implements a **90% Confidence Interval (CI)** area filter to exclude cell clumps and debris, ensuring statistical rigor across genotypes.

---

## 📊 Results & Biological Interpretation

The integration of high-speed data engineering (FIJI) and deep-learning-based feature extraction (Python) allowed for a robust mechanical characterization of cell populations.

* **Data Engineering Efficiency (Part A):** The automated "pixel-intensity gate" achieved a **90.5% reduction in data volume** (from 11 GB to 1.04 GB). By retaining 33,750 high-interest frames, the pipeline enabled a 10-fold increase in processing speed for downstream segmentation without losing single-cell events.
* **Mechanical Role of Cytoskeletal Protein X:** Quantitative analysis revealed that Protein X is a primary regulator of cortical stiffness and structural integrity in the studied cancer cell line.
* **OE (Over-expression) Phenotype:** Cells with over-expressed Protein X exhibited **significantly lower deformation** and higher circularity. This suggests a reinforced cytoskeletal network that increases cellular stiffness, making the cells more resistant to microfluidic shear stress.
* **KD (Knock-down) Phenotype:** Conversely, the knock-down population showed a shift toward **higher deformation values** and reduced roundness. This mechanical softening indicates a compromise in structural support, likely due to a weakened actin-myosin cortex or reduced cross-linking.
* **High-Throughput Statistical Rigor:** By applying a 90% Confidence Interval (CI) filter to the extracted features, we successfully isolated core populations from biological noise, confirming that mechanical phenotyping can serve as a reliable, label-free proxy for protein-driven structural changes.

