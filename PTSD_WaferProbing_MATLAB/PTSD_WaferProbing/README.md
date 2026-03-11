# PTSD Wafer Probing — MATLAB Simulation Package

Based on: **"Machine-Learning Driven Sensor Data Analytics for Yield Enhancement of Wafer Probing"**
IEEE International Test Conference (ITC) 2023 — DOI: 10.1109/ITC51656.2023.00023

---

## Requirements
- MATLAB R2020b or newer
- **Toolboxes required:**
  - Statistics and Machine Learning Toolbox (for fitcsvm, fitctree, fitcensemble, pca)
  - Signal Processing Toolbox (optional, for advanced FFT features)

---

## File Structure

```
PTSD_WaferProbing/
├── main_simulate.m          ← RUN THIS FIRST
├── generate_sensor_data.m   ← Simulates all sensor variables
├── preprocess_and_split.m   ← Feature extraction, PCA, train/val/test split
├── train_and_evaluate.m     ← SVM, Decision Tree, Random Forest
├── export_to_csv.m          ← Save dataset as CSV + print results
└── outputs/                 ← Auto-created; all plots + CSV go here
```

---

## How to Run

1. Open MATLAB
2. Set working directory to this folder:
   ```matlab
   cd('path/to/PTSD_WaferProbing')
   ```
3. Run the main script:
   ```matlab
   main_simulate
   ```

That's it! All 4 phases run automatically.

---

## Configuration (edit in main_simulate.m)

| Parameter       | Default | Description                        |
|-----------------|---------|------------------------------------|
| `N_total`       | 9200    | Total sensor observations          |
| `N_products`    | 5       | Number of wafer products           |
| `failure_rate`  | 0.01    | Target failure rate (~1%)          |
| `random_seed`   | 42      | For reproducibility                |
| `train_ratio`   | 0.70    | Training set size (paper: 70%)     |
| `val_ratio`     | 0.10    | Validation set size (paper: 10%)   |
| `test_ratio`    | 0.20    | Test set size (paper: 20%)         |

---

## Simulated Sensor Variables

| Variable           | Unit    | Description                              |
|--------------------|---------|------------------------------------------|
| `CRES`             | Ohm     | Contact resistance — primary indicator   |
| `zHeight`          | µm      | Probe-to-wafer distance                  |
| `OverTravel`       | µm      | Probe over-travel distance               |
| `Planarity`        | µm      | Probe tip planarity (uniformity)         |
| `TipDiameter`      | µm      | Probe needle tip diameter                |
| `AppliedForce_Fc`  | g       | Contact force                            |
| `Temperature`      | °C      | Environmental temperature                |
| `Touchdowns`       | count   | Number of probe touchdowns               |
| `Site_Number`      | 1–16    | Multi-site probing site index            |
| `Bin_Number`       | 1–5     | Wafer bin (1=best, 5=worst)              |

---

## Output Labels

| Label              | Values                                              |
|--------------------|-----------------------------------------------------|
| `Needle_Status`    | PASS / FAIL                                         |
| `Defect_Pattern`   | None / Bonded_Debris / Uneven_Wear / Tip_Degradation|

---

## Outputs Generated

| File                              | Description                      |
|-----------------------------------|----------------------------------|
| `wafer_probing_dataset.csv`       | Full simulated dataset           |
| `Fig1_CRES_vs_Touchdowns.png`     | CRES scatter by touchdown count  |
| `Fig2_Yield_vs_Touchdowns.png`    | Yield curve vs touchdowns        |
| `Fig3_Feature_Distributions.png`  | Pass vs Fail feature histograms  |
| `Fig4_Defect_Product_Summary.png` | Pie + bar summary charts         |
| `Fig5_Confusion_Matrices.png`     | Confusion matrices for 3 models  |
| `Fig6_Model_Comparison.png`       | Accuracy/Precision/Recall/F1 bar |

---

## PTSD Framework Phases Implemented

| Phase   | Description                          | Function                  |
|---------|--------------------------------------|---------------------------|
| Phase I | Data Preprocessing + Augmentation   | `preprocess_and_split.m`  |
| Phase II| Feature Extraction (stat/freq/PCA)  | `preprocess_and_split.m`  |
| Phase III| Model Training (SVM/DT/RF)         | `train_and_evaluate.m`    |
| Phase IV| Evaluation (Acc/Prec/Recall/F1)     | `train_and_evaluate.m`    |
