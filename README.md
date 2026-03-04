# High-Throughput RT-DC Mechanical Phenotyping

A multi-stage computational pipeline for **Real-Time Deformability Cytometry (RT-DC)**. The workflow processes high-speed microscopy data to perform label-free mechanical phenotyping of cell populations, specifically investigating the impact of **Cytoskeletal Protein X** on cancer cell deformability.

---

## 🔬 Scientific Context

RT-DC is a high-throughput method that deforms cells by passing them through a narrow microfluidic channel (500 × 30 × 30 µm) at 10,000 fps. By analysing the resulting shape changes under microfluidic shear stress, we extract mechanical properties — primarily **deformation** and **circularity** — that serve as label-free markers of cytoskeletal integrity.

This project characterises three genotypes of a cancer cell line:

- **Native** — wild-type control
- **OE (Over-expressed)** — Cytoskeletal Protein X overexpressed
- **KD (Knock-down)** — Cytoskeletal Protein X silenced

---

## 🛠 Tech Stack & Dependencies

| Domain | Tool |
|---|---|
| Image engineering | FIJI / ImageJ (Macro Language) |
| Deep-learning segmentation | Omnipose (`cellpose-omni`) |
| Data analysis | Python 3.10+, `pandas`, `numpy`, `scikit-image`, `scipy`, `matplotlib`, `seaborn` |

---

## 🚀 Pipeline Overview

### Part A: High-Speed Data Reduction (FIJI)

High-speed RT-DC generates enormous datasets that must be pre-filtered before any analysis.

- **Script:** `macros/RT-DC_Data_Reduction.ijm`
- **Method:** A pixel-intensity gate is applied within a polygonal ROI covering the microfluidic detection zone. Only frames where the minimum pixel intensity falls within the experimentally validated cell-signal window `(20, 91)` are retained.
- **Result:** Raw 11 GB stack → **1.04 GB** of individual cell-event TIFFs — a **90.5% reduction** (356,953 → 33,750 frames, ~10.6× factor) with zero missed cellular events.

---

### Part B: Organoid Classification

Before mechanical feature extraction, frames were reviewed and classified by cell type using brightfield morphology and fluorescence co-registration.

- **Method:** Ch1 (phase contrast) and Ch2 (fluorescence) were split and saved as separate image sequences. Cells were assigned to Native, OE, or KD populations based on fluorescence signal intensity and morphological criteria.
- **Outcome:** The classified frame sets form three genotype-pure populations fed into Part C segmentation, ensuring downstream mechanical comparisons are made between defined groups.

> *Part B classification was performed externally to this repository. This section is included for pipeline completeness.*

---

### Part C: Deep-Learning Segmentation (Omnipose)

To obtain accurate mechanical measurements from deformed cells, precise single-cell boundary detection is required.

- **Notebook:** `notebooks/01_Cell_Segmentation_Omnipose.ipynb`
- **Pre-processing:** Each 256 × 128 px frame is cropped by **27 px on each lateral edge** to remove high-contrast tube-wall artefacts before segmentation (margin confirmed by visual inspection of 10 randomly selected frames). Effective analysis region: 202 × 128 px.
- **Model:** Omnipose **`cyto`** model — trained on mammalian cell morphologies and appropriate for the rounded-to-deformed shapes seen in RT-DC. The `bact_phase_omni` model assumes bacterial morphology and is not suitable here.
- **Key parameters:** `mask_threshold=0.3`, `flow_threshold=0.4`, `cluster=True` (DBSCAN), `niter=None` (auto-calculated), `omni=True`.
- **Output:** 16-bit labelled masks saved to `data/processed/masks/`, one per input frame.

---

### Part D: Mechanical Feature Extraction & Analysis (Python)

The final stage translates labelled masks into biophysical parameters and performs statistical comparison across genotypes.

- **Notebook:** `notebooks/02_Mechanical_Feature_Extraction.ipynb`
- **Features extracted:** Area, Perimeter, Deformation, Circularity, Solidity, AspectRatio, Roundness, Eccentricity, Orientation, MajorAxisLength, MinorAxisLength, BoundingBox, Centroid (X, Y), Cell_ID.
- **Quality control:**
  - **Area CI filter (per condition):** 90% CI (mean ± 1.645 × SD) computed independently for each genotype. A per-condition CI is used because OE and KD cells may differ in baseline size from Native — a global CI would incorrectly penalise legitimate biological size variation.
  - **Bounding-box aspect ratio filter:** Excludes elongated objects such as cell doublets and debris (valid range: 0.5 – 2.0).

The primary mechanical metric is **Deformation**:

$$D = 1 - \frac{2\sqrt{\pi \cdot \text{Area}}}{\text{Perimeter}}$$

- $D = 0$: perfectly circular cell (stiff, minimal shear response)
- $D \to 1$: highly deformed cell (soft, large shear response)

---

## 📊 Results & Biological Interpretation

### Data Engineering (Part A)

The automated intensity gate achieved a **90.5% reduction in data volume** (11 GB → 1.04 GB), enabling a ~10.6× speed-up for downstream segmentation with no loss of cellular events.

### Mechanical Role of Cytoskeletal Protein X

Quantitative analysis reveals that Cytoskeletal Protein X is a **positive regulator of cortical stiffness**: its presence reinforces the cytoskeletal network, and its loss compromises structural integrity.

- **OE (Over-expression) phenotype:** Cells with over-expressed Cytoskeletal Protein X exhibited **significantly lower deformation** and **higher circularity** compared to Native controls. This suggests a reinforced cytoskeletal network that increases cellular stiffness, making OE cells more resistant to microfluidic shear stress.
- **KD (Knock-down) phenotype:** Conversely, the knock-down population showed a shift toward **higher deformation values** and **reduced roundness**. This mechanical softening indicates a compromise in structural support, likely due to a weakened actin-myosin cortex or reduced cytoskeletal cross-linking.
- **Statistical rigour:** Applying a per-condition 90% CI area filter isolated each genotype's core cell population from debris and doublets, confirming that the mechanical differences between groups are statistically robust and not artefactual.

---

## ⚒️ Key Quantitative Metrics

| Metric | Native | OE | KD |
|---|---|---|---|
| Deformation *D* | ~0.050 (reference) | Lower (stiffer) | Higher (softer) |
| Circularity | Reference | Higher | Lower |
| Mechanical phenotype | Reference | Reinforced | Weakened |

---

## 📂 Project Structure

```
.
├── macros/
│   └── RT-DC_Data_Reduction.ijm               # Part A: FIJI frame filter
├── notebooks/
│   ├── 01_Cell_Segmentation_Omnipose.ipynb    # Part C: Omnipose segmentation
│   └── 02_Mechanical_Feature_Extraction.ipynb # Part D: feature extraction & stats
├── data/                                       # (blueprint — not tracked in git)
│   ├── raw/all_cells/                          # Input: per-frame TIFFs from Part A
│   └── processed/masks/                        # Output: 16-bit labelled masks
└── requirements.txt
```

---

## ⚙️ Setup & Installation

### 1. Data Reduction (FIJI)

1. Install [FIJI](https://fiji.sc/).
2. Open your raw `.tif` stack in FIJI.
3. Run `macros/RT-DC_Data_Reduction.ijm` and select an output directory when prompted.

### 2. Python Environment

```bash
conda create -n rtdc_phenotype python=3.10
conda activate rtdc_phenotype

pip install cellpose-omni omnipose pandas numpy scikit-image scipy matplotlib seaborn
```

Then launch Jupyter and run the notebooks in order (`01_` → `02_`).

---

## ✉️ Contact

For questions regarding the RT-DC pipeline, please contact **(Herbert) Siu-Ho Wong** at [herbert.wong150@gmail.com].
