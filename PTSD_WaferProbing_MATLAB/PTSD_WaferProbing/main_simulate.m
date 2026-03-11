%% =========================================================
%  PTSD Framework - Wafer Probing Dataset Simulation
%  Based on: "Machine-Learning Driven Sensor Data Analytics
%  for Yield Enhancement of Wafer Probing" (IEEE ITC 2023)
%
%  Run this script first. It calls all other modules.
%% =========================================================

clc; clear; close all;

fprintf('============================================\n');
fprintf('  PTSD Wafer Probing Simulation - Starting \n');
fprintf('============================================\n\n');

%% --- CONFIGURATION (Edit these parameters) ---
cfg.N_total        = 9200;       % Total observations
cfg.N_products     = 5;          % Number of products
cfg.failure_rate   = 0.01;       % ~1% failure (paper: >99% pass)
cfg.random_seed    = 42;
cfg.train_ratio    = 0.70;
cfg.val_ratio      = 0.10;
cfg.test_ratio     = 0.20;
cfg.output_dir     = 'outputs';

rng(cfg.random_seed);
if ~exist(cfg.output_dir, 'dir'), mkdir(cfg.output_dir); end

%% --- STEP 1: Generate Sensor Data ---
fprintf('[1/4] Generating synthetic sensor data...\n');
data = generate_sensor_data(cfg);
fprintf('      Done. Total samples: %d | Failures: %d (%.2f%%)\n', ...
    cfg.N_total, sum(data.needle_fail), mean(data.needle_fail)*100);

%% --- STEP 2: Visualize Data ---
fprintf('[2/4] Generating visualizations...\n');
visualize_data(data, cfg);
fprintf('      Plots saved to %s/\n', cfg.output_dir);

%% --- STEP 3: Preprocess & Extract Features ---
fprintf('[3/4] Preprocessing and feature extraction...\n');
[X_train, X_val, X_test, y_train, y_val, y_test] = preprocess_and_split(data, cfg);
fprintf('      Train: %d | Val: %d | Test: %d samples\n', ...
    size(X_train,1), size(X_val,1), size(X_test,1));

%% --- STEP 4: Train & Evaluate ML Models ---
fprintf('[4/4] Training ML models (SVM, Decision Tree, Random Forest)...\n');
results = train_and_evaluate(X_train, y_train, X_val, y_val, X_test, y_test);

%% --- STEP 5: Export to CSV ---
export_to_csv(data, cfg);
fprintf('\nExported dataset to %s/wafer_probing_dataset.csv\n', cfg.output_dir);

fprintf('\n============================================\n');
fprintf('  Simulation Complete!\n');
fprintf('============================================\n');
print_results_table(results);
