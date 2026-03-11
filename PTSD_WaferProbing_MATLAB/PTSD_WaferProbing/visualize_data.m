function visualize_data(data, cfg)
%VISUALIZE_DATA  Generate all plots for the PTSD wafer probing simulation
%  Produces 4 figures matching key paper analyses.

N = cfg.N_total;
fail_idx = data.needle_fail;
pass_idx = ~data.needle_fail;

%% === Figure 1: CRES vs Touchdowns (Paper Fig.2 equivalent) ===
figure('Name','CRES vs Touchdowns','Position',[100 100 900 500]);

scatter(data.touchdowns(pass_idx), data.cres(pass_idx), ...
    10, [0.2 0.5 0.8], 'filled', 'MarkerFaceAlpha', 0.3); hold on;
scatter(data.touchdowns(fail_idx), data.cres(fail_idx), ...
    30, [0.9 0.2 0.2], 'filled', 'Marker', '^');
yline(1.5, 'r--', 'LineWidth', 1.5, 'Label', 'Failure Threshold (1.5Ω)');
xline(30000, 'k--', 'LineWidth', 1.2, 'Label', '30k Touchdowns');

xlabel('Number of Touchdowns', 'FontSize', 12);
ylabel('Contact Resistance CRES (Ohm)', 'FontSize', 12);
title('CRES vs Touchdowns — Contamination Buildup', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Pass', 'Fail'}, 'Location', 'northwest');
grid on; box on;
saveas(gcf, fullfile(cfg.output_dir, 'Fig1_CRES_vs_Touchdowns.png'));

%% === Figure 2: Yield vs Touchdowns (paper Fig.2 style) ===
figure('Name','Yield vs Touchdowns','Position',[100 100 900 450]);

td_bins   = linspace(500, 50000, 50);
bin_yield = zeros(1, length(td_bins)-1);
for i = 1:length(td_bins)-1
    in_bin = data.touchdowns >= td_bins(i) & data.touchdowns < td_bins(i+1);
    if sum(in_bin) > 0
        bin_yield(i) = mean(strcmp(data.needle_status(in_bin), 'PASS')) * 100;
    end
end
bin_centers = (td_bins(1:end-1) + td_bins(2:end)) / 2;

plot(bin_centers, bin_yield, 'b-o', 'LineWidth', 2, 'MarkerSize', 5); hold on;
yline(99, 'g--', 'LineWidth', 1.5, 'Label', 'Max Yield');
yline(95, 'r--', 'LineWidth', 1.5, 'Label', 'Min Yield Threshold');
ylim([85 101]);
xlabel('Number of Touchdowns', 'FontSize', 12);
ylabel('Yield (%)', 'FontSize', 12);
title('Yield Variation vs. Number of Touchdowns', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box on;
saveas(gcf, fullfile(cfg.output_dir, 'Fig2_Yield_vs_Touchdowns.png'));

%% === Figure 3: Feature Distributions (Pass vs Fail) ===
figure('Name','Feature Distributions','Position',[100 100 1200 700]);
features    = {data.cres, data.zHeight, data.over_travel, data.planarity, data.tip_diam, data.fc};
feat_names  = {'CRES (Ohm)', 'zHeight (um)', 'Over-Travel (um)', ...
               'Planarity (um)', 'Tip Diameter (um)', 'Applied Force (g)'};

for f = 1:6
    subplot(2,3,f);
    hold on;
    histogram(features{f}(pass_idx), 40, 'FaceColor', [0.2 0.5 0.8], ...
        'FaceAlpha', 0.6, 'Normalization', 'probability');
    histogram(features{f}(fail_idx), 40, 'FaceColor', [0.9 0.2 0.2], ...
        'FaceAlpha', 0.7, 'Normalization', 'probability');
    xlabel(feat_names{f}, 'FontSize', 10);
    ylabel('Probability', 'FontSize', 9);
    title(feat_names{f}, 'FontSize', 10, 'FontWeight', 'bold');
    legend({'Pass', 'Fail'}, 'FontSize', 8);
    grid on;
end
sgtitle('Sensor Feature Distributions: Pass vs Fail', 'FontSize', 13, 'FontWeight', 'bold');
saveas(gcf, fullfile(cfg.output_dir, 'Fig3_Feature_Distributions.png'));

%% === Figure 4: Defect Pattern & Product Breakdown ===
figure('Name','Defect & Product Summary','Position',[100 100 1100 480]);

% Defect patterns pie chart
subplot(1,2,1);
patterns = {'None','Bonded_Debris','Uneven_Wear','Tip_Degradation'};
counts   = cellfun(@(p) sum(strcmp(data.defect_pattern, p)), patterns);
explode  = [0 1 1 1];
pie(counts, explode);
legend(strrep(patterns,'_',' '), 'Location','southoutside', 'FontSize', 9);
title('Defect Pattern Distribution', 'FontSize', 12, 'FontWeight', 'bold');
colormap(gca, [0.85 0.85 0.85; 0.9 0.2 0.2; 0.95 0.6 0.1; 0.2 0.6 0.9]);

% Per-product failure rate bar chart
subplot(1,2,2);
products  = {'Product 1','Product 2','Product 3','Product 4','Product 5'};
fail_rate = zeros(1,5);
for p = 1:5
    pname    = sprintf('Product_%d', p);
    in_prod  = strcmp(data.product, pname);
    fail_rate(p) = mean(data.needle_fail(in_prod)) * 100;
end
bar(fail_rate, 'FaceColor', [0.2 0.5 0.8]);
set(gca, 'XTickLabel', products, 'XTickLabelRotation', 20, 'FontSize', 10);
ylabel('Failure Rate (%)', 'FontSize', 11);
title('Failure Rate per Product', 'FontSize', 12, 'FontWeight', 'bold');
grid on; ylim([0 max(fail_rate)*1.4]);

sgtitle('PTSD Framework — Dataset Overview', 'FontSize', 13, 'FontWeight', 'bold');
saveas(gcf, fullfile(cfg.output_dir, 'Fig4_Defect_Product_Summary.png'));

fprintf('      4 figures saved.\n');
end
