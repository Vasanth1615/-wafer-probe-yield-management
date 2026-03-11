# 🔬 Wafer Probe Yield Enhancement via ML-Driven Sensor Analytics

<div align="center">

![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-ML-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![Colab](https://img.shields.io/badge/Google_Colab-Ready-F9AB00?style=for-the-badge&logo=googlecolab&logoColor=white)
![IEEE](https://img.shields.io/badge/IEEE_ITC_2023-Referenced-00629B?style=for-the-badge&logo=ieee&logoColor=white)

**Replication & Extension of the PTSD Framework**
*Based on: "Machine-Learning Driven Sensor Data Analytics for Yield Enhancement of Wafer Probing"*
*IEEE International Test Conference (ITC) 2023 — DOI: [10.1109/ITC51656.2023.00023](https://doi.org/10.1109/ITC51656.2023.00023)*

[▶️ Run in Colab](#-quick-start) · [📊 Results](#-results) · [📁 Project Structure](#-project-structure) · [🧠 Background](#-background)

</div>

---

## 🎯 Problem Statement

In semiconductor wafer testing, **probe needle contamination** is a leading cause of yield loss. Contaminating particles (bonded debris) accumulate on probe tips over thousands of touchdowns, degrading contact resistance (CRES) and causing false failures.

Current industry practice:
- ❌ Cleans probes on a **fixed schedule** (wastes probe life)
- ❌ No **prediction** of when contamination will occur
- ❌ Over-cleaning **shortens needle lifespan**

This project implements the **PTSD (Probing Tips Status prediction by Sensor Data)** framework — a supervised ML approach that predicts probe failure **before it happens**, using real-time sensor data.

---

## 🏗️ Framework Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PTSD FRAMEWORK                           │
│                                                             │
│  ┌──────────┐   ┌──────────────┐   ┌──────────────────┐   │
│  │  Phase I │   │   Phase II   │   │    Phase III     │   │
│  │          │──▶│              │──▶│                  │   │
│  │   Data   │   │   Feature    │   │  Model Training  │   │
│  │  Preprocessing  Extraction  │   │  SVM / DT / RF   │   │
│  │          │   │  + PCA       │   │                  │   │
│  └──────────┘   └──────────────┘   └────────┬─────────┘   │
│                                             │              │
│  ┌──────────────────────────────────────────▼──────────┐   │
│  │                     Phase IV                        │   │
│  │         Evaluation: Accuracy / Precision /          │   │
│  │               Recall / F1 Score                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📡 Sensor Variables

| Variable | Unit | Description | Impact |
|---|---|---|---|
| `CRES` | Ω | Contact Resistance | Primary contamination indicator |
| `zHeight` | µm | Probe-to-wafer distance | Signal integrity |
| `OverTravel` | µm | Probe over-travel | Mechanical wear |
| `Planarity` | µm | Tip uniformity | Uneven wear detection |
| `TipDiameter` | µm | Needle tip size | Degradation tracking |
| `AppliedForce_Fc` | g | Contact force | Tip stress |
| `Temperature` | °C | Ambient temperature | Thermal expansion |
| `Touchdowns` | count | Total probe contacts | Lifetime indicator |

---

## 📊 Results

### Model Performance

| Model | Accuracy | Precision | Recall | F1 Score |
|---|---|---|---|---|
| **SVM (RBF kernel)** | **99.89%** | 99.10% | 99.10% | 99.10% |
| **Random Forest** | **99.89%** | 99.10% | 99.10% | 99.10% |
| **Decision Tree** | 99.51% | 94.74% | 97.30% | 96.00% |
| *Paper Target* | *>95%* | — | — | — |

✅ All models **exceed** the paper's 95% accuracy target.

### Yield Recovery (Replicated from Paper — Table I)

| Product | Fail Count | False Fail | True Fail | Accuracy | Yield Recovery |
|---|---|---|---|---|---|
| Product 1 | 12 | 0 | 12 | 100% | 7.68% |
| Product 1 | 14 | 0 | 14 | 100% | 21.20% |
| Product 2 | 11 | 0 | 11 | 100% | 10.90% |
| Product 4 | 47 | 0 | 47 | 100% | **50.30%** |
| Product 5 | 825 | 25 | 800 | 96.97% | 34.70% |

> 🏆 **Up to 50.3% yield recovery** achieved by detecting contamination before test failure.

---

## 🔧 Methodology Details

### Phase I — Data Preprocessing
- Removed empty rows (>3 missing values per row)
- **KNN + Regression imputation** for sparse missing values
- **Data augmentation**: Gaussian noise (σ=0.02) + translations (range=0.05)
- **Class imbalance handling**: >99% PASS vs <1% FAIL → SMOTE-style oversampling
- **Regularization**: L1 (Lasso) + L2 (Ridge) + Early stopping

### Phase II — Feature Extraction
- **Statistical**: Mean, Std Dev of CRES per touchdown bin
- **Frequency domain**: FFT-based spectral density, dominant frequency
- **Wavelet proxy**: IQR, range in rolling windows (transient behavior)
- **Correlation**: Cross-correlation between die CRES values
- **PCA**: Dimensionality reduction retaining 95% variance

### Phase III — Model Training
- **SVM**: RBF kernel, C=10, cost-sensitive (FAIL penalty ×10)
- **Decision Tree**: Gini impurity, max depth=10, balanced class weight
- **Random Forest**: 100 estimators (Bagging), balanced class weight

### Data Split
```
70% Training │ 10% Validation │ 20% Testing
```

---

## ⚡ Quick Start

### Option 1: Google Colab (Recommended — No Setup)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/)

1. Upload `PTSD_WaferProbing_Simulation.ipynb` to Colab
2. Click **Runtime → Run All**
3. Last cell auto-downloads results ZIP

### Option 2: Local Python
```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/wafer-probe-yield-management.git
cd wafer-probe-yield-management

# Install dependencies
pip install -r requirements.txt

# Run notebook
jupyter notebook PTSD_WaferProbing_Simulation.ipynb
```

### Option 3: MATLAB
```matlab
cd PTSD_WaferProbing/
main_simulate
% Requires: Statistics and Machine Learning Toolbox
```

---

## 📁 Project Structure

```
wafer-probe-yield-management/
│
├── 📓 PTSD_WaferProbing_Simulation.ipynb   ← Main Colab notebook
│
├── 📂 PTSD_WaferProbing/                   ← MATLAB scripts
│   ├── main_simulate.m                     ← Entry point
│   ├── generate_sensor_data.m              ← Data simulation
│   ├── preprocess_and_split.m              ← Feature engineering
│   ├── train_and_evaluate.m                ← ML training
│   └── export_to_csv.m                     ← Export utilities
│
├── 📂 outputs/                             ← Generated plots & CSV
│   ├── wafer_probing_dataset.csv
│   ├── Fig1_CRES_vs_Touchdowns.png
│   ├── Fig2_Yield_vs_Touchdowns.png
│   ├── Fig3_Feature_Distributions.png
│   ├── Fig4_Defect_Product_Summary.png
│   ├── Fig5_Confusion_Matrices.png
│   └── Fig6_Model_Comparison.png
│
├── 📄 requirements.txt
└── 📄 README.md
```

---

## 📦 Requirements

```txt
numpy>=1.23
pandas>=1.5
scikit-learn>=1.2
matplotlib>=3.6
seaborn>=0.12
jupyter>=1.0
```

---

## 🧠 Background

### What is Wafer Probing?
Wafer probing is the step in semiconductor manufacturing where each die on a wafer is electrically tested **before dicing**. Tiny probe needles make contact with bond pads on each die, delivering test current to verify functionality.

### Why Does Yield Management Matter?
In a fab producing millions of chips, even a **1% improvement in yield** translates to millions of dollars in recovered revenue. Yield engineers are responsible for finding, diagnosing, and eliminating sources of loss throughout the fabrication and test process.

### Key Concepts
- **CRES (Contact Resistance)**: Electrical resistance at the probe-pad interface. Rises with contamination.
- **a-Spots**: Microscopic metallic contact points. Contamination reduces their area, raising CRES.
- **Bonded Debris**: Metal oxide particles that accumulate on probe tips over touchdowns.
- **Bin Numbers**: Classification codes assigned to dies based on electrical performance.
- **OEE (Overall Equipment Effectiveness)**: Industry metric for equipment utilization.

---

## 📚 References

1. **Sinhabahu et al.** (2023). *Machine-Learning Driven Sensor Data Analytics for Yield Enhancement of Wafer Probing.* IEEE ITC. DOI: 10.1109/ITC51656.2023.00023
2. Yeo et al. (2021). OEE Improvement by Pogo Pin Defect Detection. *Microsyst Technologies*, 27, 3111–3123.
3. Liu et al. (2007). Measurement and Analysis of Contact Resistance in Wafer Probe Testing. *Microelectronics Reliability*, 47(7), 1086–1094.
4. Hsiao & Chiang (2021). AI-Assisted Reliability Life Prediction for WLP using Random Forest. *Journal of Mechanics*, 37.

---

## 🙋 Author

**VASANTH A]**
- 🎓 Indian Institute of Technology, Madras
- 💼 [LinkedIn Profile URL]
- 📧 vasanthanandharaj16@gmail.com

*Interested in yield management, semiconductor test engineering, and ML-driven manufacturing analytics.*

---

<div align="center">

⭐ **Star this repo if it helped you!** · 🍴 **Fork to build your own extension**

*Built as part of a yield management portfolio project — replicating and extending IEEE ITC 2023 research.*

</div>
