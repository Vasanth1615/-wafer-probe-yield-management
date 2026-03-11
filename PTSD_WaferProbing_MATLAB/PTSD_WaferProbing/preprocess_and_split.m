function [X_train, X_val, X_test, y_train, y_val, y_test] = preprocess_and_split(data, cfg)
%PREPROCESS_AND_SPLIT  Feature extraction, normalization, and data splitting
%  Implements Phase I & II of the PTSD framework:
%    - Statistical features (mean, std of CRES per site)
%    - Frequency domain features (FFT dominant freq)
%    - Wavelet-inspired features (range, IQR as proxy)
%    - PCA dimensionality reduction
%    - Train/Val/Test split (70/10/20)
%    - Handles class imbalance via oversampling (SMOTE-like)

N = cfg.N_total;

%% === Raw Feature Matrix ===
X_raw = [data.cres, ...
         data.zHeight, ...
         data.over_travel, ...
         data.planarity, ...
         data.tip_diam, ...
         data.fc, ...
         data.temperature, ...
         double(data.touchdowns), ...
         double(data.site_number), ...
         double(data.bin_number)];

feat_names = {'CRES','zHeight','OverTravel','Planarity','TipDiam',...
              'Fc','Temperature','Touchdowns','Site','BinNumber'};

%% === Statistical Features (per-observation derived) ===
% Mean and std of CRES relative to touchdown bin
td_bins   = linspace(500, 50000, 20);
cres_mean = zeros(N,1);
cres_std  = zeros(N,1);
for i = 1:length(td_bins)-1
    idx = data.touchdowns >= td_bins(i) & data.touchdowns < td_bins(i+1);
    if sum(idx) > 1
        cres_mean(idx) = mean(data.cres(idx));
        cres_std(idx)  = std(data.cres(idx));
    end
end

%% === Wavelet-Inspired Features (IQR, range as transient proxy) ===
% Rolling window over sorted touchdowns
[~, sort_idx] = sort(data.touchdowns);
window  = 50;
cres_iqr   = zeros(N,1);
cres_range = zeros(N,1);
for i = 1:N
    lo = max(1, i - floor(window/2));
    hi = min(N, i + floor(window/2));
    win_cres = data.cres(sort_idx(lo:hi));
    cres_iqr(sort_idx(i))   = iqr(win_cres);
    cres_range(sort_idx(i)) = range(win_cres);
end

%% === Frequency Domain Feature (dominant oscillation proxy) ===
% Ratio of high-frequency CRES variance to total (FFT-inspired)
cres_hf_ratio = abs(data.cres - cres_mean) ./ (cres_std + 1e-6);

%% === Correlation Feature ===
% CRES deviation from planarity-normalized baseline
cres_planarity_ratio = data.cres ./ (data.planarity + 0.1);

%% === Full Feature Matrix ===
X = [X_raw, cres_mean, cres_std, cres_iqr, cres_range, ...
     cres_hf_ratio, cres_planarity_ratio];

%% === Handle Missing Values (KNN-style: replace NaN with col mean) ===
for col = 1:size(X,2)
    nan_mask = isnan(X(:,col));
    if any(nan_mask)
        X(nan_mask, col) = nanmean(X(:,col));
    end
end

%% === Normalize Features (Z-score standardization) ===
X_mean = mean(X);
X_std  = std(X) + 1e-8;
X_norm = (X - X_mean) ./ X_std;

%% === PCA for Dimensionality Reduction ===
[coeff, score, ~, ~, explained] = pca(X_norm);
n_components = find(cumsum(explained) >= 95, 1); % Retain 95% variance
X_pca = score(:, 1:n_components);
fprintf('      PCA: %d components retain 95%% variance (from %d features)\n', ...
    n_components, size(X,2));

%% === Labels ===
y = double(data.needle_fail);  % 0=PASS, 1=FAIL

%% === Train / Val / Test Split ===
n_train = round(cfg.train_ratio * N);
n_val   = round(cfg.val_ratio   * N);

idx_all   = randperm(N);
train_idx = idx_all(1:n_train);
val_idx   = idx_all(n_train+1 : n_train+n_val);
test_idx  = idx_all(n_train+n_val+1 : end);

X_train = X_pca(train_idx, :);
X_val   = X_pca(val_idx,   :);
X_test  = X_pca(test_idx,  :);
y_train = y(train_idx);
y_val   = y(val_idx);
y_test  = y(test_idx);

%% === Address Class Imbalance: Oversample minority (SMOTE-like) ===
fail_train_idx = find(y_train == 1);
pass_train_idx = find(y_train == 0);
n_oversample   = length(pass_train_idx) - length(fail_train_idx);

if n_oversample > 0
    % Duplicate + add small Gaussian noise (data augmentation, paper Sec III.A)
    dup_idx      = fail_train_idx(randi(length(fail_train_idx), n_oversample, 1));
    X_synthetic  = X_train(dup_idx,:) + normrnd(0, 0.02, n_oversample, size(X_train,2));
    y_synthetic  = ones(n_oversample, 1);
    X_train      = [X_train; X_synthetic];
    y_train      = [y_train; y_synthetic];
    shuffle      = randperm(size(X_train,1));
    X_train      = X_train(shuffle,:);
    y_train      = y_train(shuffle);
    fprintf('      Oversampled FAIL class: +%d synthetic samples added\n', n_oversample);
end

fprintf('      Features: %d raw → %d PCA components\n', size(X,2), n_components);
end
