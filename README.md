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
