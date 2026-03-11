function results = train_and_evaluate(X_train, y_train, X_val, y_val, X_test, y_test)
%TRAIN_AND_EVALUATE  Train SVM, Decision Tree, Random Forest; evaluate all
%  Implements Phase III & IV of PTSD framework (paper Section IV.C-D)
%
%  Returns results struct with accuracy, precision, recall, F1 per model

results = struct();
models  = {'SVM', 'DecisionTree', 'RandomForest'};

for m = 1:3
    model_name = models{m};
    fprintf('      Training %s...\n', model_name);

    %% --- Train Model ---
    switch model_name
        case 'SVM'
            % RBF kernel SVM with cost-sensitive training (paper Sec III.A)
            mdl = fitcsvm(X_train, y_train, ...
                'KernelFunction', 'rbf', ...
                'BoxConstraint',  10, ...
                'KernelScale',    'auto', ...
                'Cost',           [0 1; 10 0], ...  % Penalize missing FAIL more
                'Standardize',    false);            % Already normalized

        case 'DecisionTree'
            mdl = fitctree(X_train, y_train, ...
                'MaxNumSplits',   50, ...
                'MinLeafSize',    5, ...
                'SplitCriterion', 'gdi');

        case 'RandomForest'
            % Ensemble of 100 trees (bagging) - paper Sec III.A
            mdl = fitcensemble(X_train, y_train, ...
                'Method',        'Bag', ...
                'NumLearningCycles', 100, ...
                'Learners',      templateTree('MaxNumSplits', 20));
    end

    %% --- Validate (hyperparameter check) ---
    y_val_pred = predict(mdl, X_val);
    val_acc    = mean(y_val_pred == y_val) * 100;

    %% --- Test ---
    y_test_pred = predict(mdl, X_test);

    %% --- Metrics ---
    TP = sum(y_test_pred == 1 & y_test == 1);
    TN = sum(y_test_pred == 0 & y_test == 0);
    FP = sum(y_test_pred == 1 & y_test == 0);
    FN = sum(y_test_pred == 0 & y_test == 1);

    accuracy  = (TP + TN) / length(y_test) * 100;
    precision = TP / max(TP + FP, 1) * 100;
    recall    = TP / max(TP + FN, 1) * 100;
    f1        = 2 * (precision * recall) / max(precision + recall, 1e-6);

    results.(model_name).model     = mdl;
    results.(model_name).accuracy  = accuracy;
    results.(model_name).precision = precision;
    results.(model_name).recall    = recall;
    results.(model_name).f1        = f1;
    results.(model_name).val_acc   = val_acc;
    results.(model_name).conf_mat  = [TP FP; FN TN];

    fprintf('      %s → Acc: %.2f%% | Prec: %.2f%% | Recall: %.2f%% | F1: %.2f%%\n', ...
        model_name, accuracy, precision, recall, f1);
end

%% === Plot: Confusion Matrices ===
figure('Name','Confusion Matrices','Position',[100 100 1200 400]);
for m = 1:3
    subplot(1,3,m);
    cm = results.(models{m}).conf_mat;
    imagesc(cm); colormap(flipud(gray));
    colorbar;
    title(sprintf('%s\nAcc: %.1f%%', strrep(models{m},'_',' '), ...
        results.(models{m}).accuracy), 'FontSize', 11, 'FontWeight', 'bold');
    set(gca, 'XTick', [1 2], 'XTickLabel', {'Pred FAIL','Pred PASS'}, ...
             'YTick', [1 2], 'YTickLabel', {'True FAIL','True PASS'}, 'FontSize', 10);
    xlabel('Predicted'); ylabel('Actual');
    for r = 1:2
        for c = 1:2
            text(c, r, num2str(cm(r,c)), 'HorizontalAlignment','center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'red');
        end
    end
end
sgtitle('Confusion Matrices — SVM vs Decision Tree vs Random Forest', ...
    'FontSize', 13, 'FontWeight', 'bold');
saveas(gcf, fullfile('outputs', 'Fig5_Confusion_Matrices.png'));

%% === Plot: Model Comparison Bar Chart ===
figure('Name','Model Comparison','Position',[100 100 900 500]);
metric_vals = zeros(3, 4);
for m = 1:3
    metric_vals(m,:) = [results.(models{m}).accuracy, ...
                        results.(models{m}).precision, ...
                        results.(models{m}).recall, ...
                        results.(models{m}).f1];
end
b = bar(metric_vals);
b(1).FaceColor = [0.2 0.5 0.8];
b(2).FaceColor = [0.9 0.4 0.1];
b(3).FaceColor = [0.2 0.7 0.3];
b(4).FaceColor = [0.7 0.2 0.7];
set(gca, 'XTickLabel', strrep(models,'_',' '), 'FontSize', 11);
ylabel('Score (%)', 'FontSize', 12);
title('Model Performance Comparison', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Accuracy','Precision','Recall','F1 Score'}, 'Location', 'southeast');
yline(95, 'r--', 'LineWidth', 1.5, 'Label', 'Paper Target (95%)');
ylim([0 110]); grid on;
saveas(gcf, fullfile('outputs', 'Fig6_Model_Comparison.png'));

end
