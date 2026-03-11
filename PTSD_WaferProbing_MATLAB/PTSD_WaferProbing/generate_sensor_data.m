function data = generate_sensor_data(cfg)
%GENERATE_SENSOR_DATA  Simulate wafer probing sensor data
%  Mirrors NXP UF3000EX prober variables from the PTSD paper.
%
%  Inputs:
%    cfg  - configuration struct from main_simulate.m
%  Output:
%    data - struct with all sensor fields + labels

N = cfg.N_total;

%% --- Product Assignment ---
product_names = {'Product_1','Product_2','Product_3','Product_4','Product_5'};
product_probs = [0.25, 0.20, 0.20, 0.20, 0.15];
prod_idx = randsample(cfg.N_products, N, true, product_probs);
data.product = product_names(prod_idx)';

%% --- Touchdowns (drives contamination buildup) ---
data.touchdowns = randi([500, 50000], N, 1);

%% --- CRES: Contact Resistance (Ohm) ---
% Normal range ~0.3-0.8 Ohm; spikes when contaminated (>30k touchdowns)
base_cres    = normrnd(0.50, 0.10, N, 1);
debris_spike = exprnd(0.50, N, 1) .* (data.touchdowns > 30000);
data.cres    = max(0.05, min(5.0, base_cres + debris_spike));

%% --- zHeight: Probe-to-wafer distance (microns) ---
data.zHeight = max(90, min(180, normrnd(125, 10, N, 1)));

%% --- Over-travel (microns) ---
data.over_travel = max(30, min(150, normrnd(75, 10, N, 1)));

%% --- Planarity (microns) - lower is better ---
data.planarity = max(0.5, min(30, exprnd(3, N, 1) + 1));

%% --- Tip Diameter (microns) - degrades over touchdowns ---
tip_base        = normrnd(30, 2, N, 1);
tip_wear        = (data.touchdowns / 100000) * 5;
data.tip_diam   = max(15, min(40, tip_base - tip_wear));

%% --- Applied Force Fc (grams) ---
data.fc = max(2.0, min(6.0, normrnd(3.5, 0.4, N, 1)));

%% --- Temperature (Celsius) ---
data.temperature = normrnd(25, 3, N, 1);

%% --- Site Number (1-16, multi-site probing) ---
data.site_number = randi(16, N, 1);

%% --- Wafer IDs ---
wafer_ids = cell(N,1);
for i = 1:N
    wafer_ids{i} = sprintf('W%04d', randi(9999));
end
data.wafer_id = wafer_ids;

%% --- Labels: Needle Status ---
% Failure conditions from paper:
%  - CRES too high (contamination/bonded debris)
%  - Planarity out of spec (uneven wear)
%  - Tip diameter too small (tip degradation)
fail_cres      = data.cres > 1.5;
fail_planarity = data.planarity > 15;
fail_tip       = data.tip_diam < 20;
data.needle_fail = fail_cres | fail_planarity | fail_tip;

% Ensure ~cfg.failure_rate overall
current_rate = mean(data.needle_fail);
if current_rate < cfg.failure_rate
    extra_n = round((cfg.failure_rate - current_rate) * N);
    pass_idx = find(~data.needle_fail);
    extra_idx = randsample(length(pass_idx), min(extra_n, length(pass_idx)));
    data.needle_fail(pass_idx(extra_idx)) = true;
end

data.needle_status = repmat({'PASS'}, N, 1);
data.needle_status(data.needle_fail) = {'FAIL'};

%% --- Defect Pattern ---
data.defect_pattern = repmat({'None'}, N, 1);
data.defect_pattern(fail_cres)      = {'Bonded_Debris'};
data.defect_pattern(fail_planarity & ~fail_cres) = {'Uneven_Wear'};
data.defect_pattern(fail_tip & ~fail_cres & ~fail_planarity) = {'Tip_Degradation'};

%% --- Bin Numbers (1=best, 5=worst) ---
data.bin_number = ones(N, 1);
data.bin_number(data.cres > 0.8)  = 2;
data.bin_number(data.cres > 1.2)  = 3;
data.bin_number(data.needle_fail) = randi([4,5], sum(data.needle_fail), 1);

end
