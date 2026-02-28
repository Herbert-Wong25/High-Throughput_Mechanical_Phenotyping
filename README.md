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
