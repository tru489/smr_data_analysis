close all;
addpath(genpath('..\..\final_code'))

%% Load baseline calibration
% bl_cal_pth = "";
% bl_cal = get_json_struct('bl cal', bl_cal_pth);
slope = -1.73443e+05;
intc = 1.33317e+06;
p = [slope, intc];

%% Load preprocessed data
st = load("data\data_preload.mat");
data_dict = st.data_dict;

%% Reference densities
% Use densities from ref freqs and baseline dens calibrations
use_cal_densities = 1;
ref_dens_keys = [...
    "mannitol_pbs", "mannitol_d2o", "mannitol_opt", "sms_pbs", "sms_d2o", "sms_opt",...
    ];
ref_dens_vals = [...
    1.0367, 1.0823, 1.0603, 1.0116, 1.0571, 1.0351
    ];

ref_dens_dict = dictionary(ref_dens_keys, ref_dens_vals);

%% Buoyant mass scatter plots
sorted_keys = sort(keys(data_dict));
fh_bm_swarm = figure;
for i = 1:length(sorted_keys)
    samp_st = data_dict(sorted_keys(i));
    if samp_st.fluid == 'pbs'
        % fprintf('  n=%i  ', length(samp_st.mass_pg))
        if samp_st.solute == "sms"
            swarm_color = 'red';
        elseif samp_st.solute == "mannitol"
            swarm_color = 'blue';
        end

        label_ = strcat(samp_st.rbc_type, samp_st.rep_num, " ", samp_st.solute);
        add_swarmchart(fh_bm_swarm, label_, samp_st.mass_pg, swarm_color, 'green')
    end
end
ylabel('Buoyant mass (pg)')
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
saveas(fh_bm_swarm, "fig\bm_swarms.jpg")

%% Node deviation scatter plots
fh_ndev_swarm = figure;
for i = 1:length(sorted_keys)
    samp_st = data_dict(sorted_keys(i));
    if samp_st.fluid == 'pbs'
        if samp_st.solute == "sms"
            swarm_color = 'red';
        elseif samp_st.solute == "mannitol"
            swarm_color = 'blue';
        end

        label_ = strcat(samp_st.rbc_type, samp_st.rep_num, " ", samp_st.solute);
        slice = samp_st.ndev_hz > -1.3 & samp_st.ndev_hz < 1.1;
        add_swarmchart(fh_ndev_swarm, label_, samp_st.ndev_hz(slice), swarm_color, 'green')
    end
end
ylabel('Node deviation (Hz)')
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
saveas(fh_ndev_swarm, "fig\ndev_swarms.jpg")

%% Dry volume/density
fh_dry_dens_bar = figure; hold on;
fh_dry_vol_bar = figure; hold on;
fh_dry_mass_bar = figure; hold on;

% fh_pct_change_dry_dens = figure; 
% fh_pct_change_dry_vol = figure; 
% fh_pct_change_dry_mass = figure; 

rep_nums = [1 2 3]; rbc_types = ["aa", "ss"]; solutes = ["mannitol", "sms"];
fprintf(' --- Dry volume and density ---\n')
for j = 1:length(rbc_types)
    for i = 1:length(rep_nums)
        for k = 1:length(solutes)
            rn = rep_nums(i);
            rbct = rbc_types(j);
            sol = solutes(k);

            st_pbs = data_dict(rbct + rn + "_" + sol + "_pbs");
            pbs_mass = st_pbs.mass_mean;
            st_d2o = data_dict(rbct + rn + "_" + sol + "_d2o");
            d2o_mass = st_d2o.mass_mean;

            if use_cal_densities
                pbs_dens = get_dens(p, st_pbs.rf); 
                d2o_dens = get_dens(p, st_d2o.rf);
            else
                pbs_dens = ref_dens_dict(sol + "_pbs");
                d2o_dens = ref_dens_dict(sol + "_d2o");
            end
            
            %----------------------------------
            if sol == 'sms'
                name_ = "     " + rbct + rn + "_" + sol;
            else
                name_ = rbct + rn + "_" + sol;
            end
            fprintf('%s | PBS density: %.3f, D2O density: %.3f, rf=%d, %d\n', ...
                name_, pbs_dens, d2o_dens, st_pbs.rf_raw, st_d2o.rf_raw)
            
            sem_pbs = st_pbs.sem;
            sem_d2o = st_d2o.sem;
            
            % ----------------------------------
            % CALCULATE DRY DENSITY AND ERROR PROPAGATION
            dry_numerator = (d2o_dens * pbs_mass - pbs_dens * d2o_mass);
            dry_denominator = (pbs_mass - d2o_mass);
            dry_dens = dry_numerator / dry_denominator;
            
            num_sem = sqrt((sem_pbs*d2o_dens)^2 + (sem_d2o*pbs_dens)^2);
            denom_sem = sqrt(sem_pbs^2 + sem_d2o^2);
            total_dry_dens_sem = dry_dens * sqrt((num_sem/dry_numerator)^2 + (denom_sem/dry_denominator)^2);
            
            % ----------------------------------
            % CALCULATE DRY VOLUME AND ERROR PROPAGATION
            dry_vol = (pbs_mass - d2o_mass) / (d2o_dens - pbs_dens);
            total_dry_vol_sem = sqrt(sem_pbs^2 + sem_d2o^2) / (d2o_dens - pbs_dens);

            % ----------------------------------
            % CALCULATE DRY MASS AND ERROR PROPAGATION
            dry_mass = dry_vol * dry_dens;
            total_dry_mass_sem = sqrt((sem_pbs*d2o_dens)^2 + (sem_d2o*pbs_dens)^2) / (d2o_dens - pbs_dens);

            % ----------------------------------
            if sol == 'sms'
                color_ = 'red';
            elseif sol == 'mannitol'
                color_ = 'blue';
            end

            figure(fh_dry_dens_bar);
            label_ = strcat(st_pbs.rbc_type, st_pbs.rep_num, " ", st_pbs.solute);
            b = bar(categorical({char(label_)}), dry_dens, FaceColor=color_);
            er = errorbar(categorical({char(label_)}), dry_dens, total_dry_dens_sem, total_dry_dens_sem);
            er.LineWidth = 2; er.Color = 'black';
            b.FaceAlpha = 0.4;



            figure(fh_dry_vol_bar);
            b = bar(categorical({char(label_)}), dry_vol, FaceColor=color_);
            er = errorbar(categorical({char(label_)}), dry_vol, total_dry_vol_sem, total_dry_vol_sem);
            er.LineWidth = 2; er.Color = 'black';
            b.FaceAlpha = 0.4;



            figure(fh_dry_mass_bar);
            b = bar(categorical({char(label_)}), dry_mass, FaceColor=color_);
            er = errorbar(categorical({char(label_)}), dry_mass, total_dry_mass_sem, total_dry_mass_sem);
            er.LineWidth = 2; er.Color = 'black';
            b.FaceAlpha = 0.4;


        end
    end
end

figure(fh_dry_dens_bar);
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
ylabel('Density of dry mass (g/cm3)')

figure(fh_dry_vol_bar);
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
ylabel('Volume of dry mass (fl)')

figure(fh_dry_mass_bar);
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
ylabel('Dry mass (pg)')

saveas(fh_dry_dens_bar, "fig\dry_dens_bar.jpg")
saveas(fh_dry_vol_bar, "fig\dry_vol_bar.jpg")
saveas(fh_dry_mass_bar, "fig\dry_mass_bar.jpg")

%% Total volume/density
fh_tot_dens_bar = figure; hold on;
fh_tot_vol_bar = figure; hold on;
fh_snacs_opt = figure; hold on;

rep_nums = [1 2 3]; rbc_types = ["aa", "ss"]; solutes = ["mannitol", "sms"];

fprintf('\n --- Total volume and density ---\n')
for j = 1:length(rbc_types)
    for i = 1:length(rep_nums)
        for k = 1:length(solutes)
            rn = rep_nums(i);
            rbct = rbc_types(j);
            sol = solutes(k);
            if rn == 1
                continue
            end
            
            st_pbs = data_dict(rbct + rn + "_" + sol + "_pbs");
            pbs_mass = st_pbs.mass_mean;
            st_opt = data_dict(rbct + rn + "_" + sol + "_opt");
            opt_mass = st_opt.mass_mean;

            if use_cal_densities
                pbs_dens = get_dens(p, st_pbs.rf); 
                opt_dens = get_dens(p, st_opt.rf);
            else
                pbs_dens = ref_dens_dict(sol + "_pbs");
                opt_dens = ref_dens_dict(sol + "_opt"); 
            end
            
            %----------------------------------
            if sol == 'sms'
                name_ = "     " + rbct + rn + "_" + sol;
            else
                name_ = rbct + rn + "_" + sol;
            end
            fprintf('%s | PBS density: %.3f, opt density: %.3f, rf=%i, %i\n', ...
                name_, pbs_dens, opt_dens, st_pbs.rf, st_opt.rf)
            
            sem_pbs = st_pbs.sem;
            sem_opt = st_opt.sem;
            % ----------------------------------
            % CALCULATE TOTAL DENSITY AND ERROR PROPAGATION
            tot_numerator = (opt_dens * pbs_mass - pbs_dens * opt_mass);
            tot_denominator = (pbs_mass - opt_mass);
            tot_dens = tot_numerator / tot_denominator;

            num_sem = sqrt((sem_pbs*opt_dens)^2 + (sem_opt*pbs_dens)^2);
            denom_sem = sqrt(sem_pbs^2 + sem_opt^2);
            total_tot_dens_sem = tot_dens * sqrt((num_sem/tot_numerator)^2 + (denom_sem/tot_denominator)^2);

            % ----------------------------------
            tot_vol = (pbs_mass - opt_mass) / (opt_dens - pbs_dens);
            total_tot_vol_sem = sqrt((sem_pbs*opt_dens)^2 + (sem_opt*pbs_dens)^2) / (opt_dens - pbs_dens);

            % ----------------------------------
            % Snacs
            bm_i = st_pbs.mass_pg;
            dens_const = median(bm_i) / tot_vol;
            v_i = bm_i / dens_const;
            
            ndev_snacs = st_pbs.ndev_hz;
            nv = ndev_snacs ./ v_i;
            p_snacs = polyfit(v_i, nv, 1);

            fh_fit = figure;
            scatter(v_i, nv, 'Marker', '.'); hold on;
            plot(v_i, polyval(p_snacs, v_i), 'LineWidth', 2)
            xlabel('Volume (fl)')
            ylabel('Node deviation / volume (fl^-1)')

            m = p_snacs(1);
            v_ref = median(v_i);
            snacs = nv - m * (v_ref - v_i);
            % ----------------------------------
            if sol == 'sms'
                color_ = 'red';
            elseif sol == 'mannitol'
                color_ = 'blue';
            end
            
            figure(fh_tot_dens_bar);
            label_ = strcat(st_pbs.rbc_type, st_pbs.rep_num, " ", st_pbs.solute);
            b = bar(categorical({char(label_)}), tot_dens, FaceColor=color_);
            b.FaceAlpha = 0.4;
            er = errorbar(categorical({char(label_)}), tot_dens, total_tot_dens_sem, total_tot_dens_sem);
            er.LineWidth = 2; er.Color = 'black';

            figure(fh_tot_vol_bar);
            b = bar(categorical({char(label_)}), tot_vol, FaceColor=color_);
            b.FaceAlpha = 0.4;
            er = errorbar(categorical({char(label_)}), tot_vol, total_tot_vol_sem, total_tot_vol_sem);
            er.LineWidth = 2; er.Color = 'black';

            figure(fh_snacs_opt);
            if st_pbs.solute == "sms"
                swarm_color = 'red';
            elseif st_pbs.solute == "mannitol"
                swarm_color = 'blue';
            end

            add_swarmchart(fh_snacs_opt, label_, snacs, swarm_color, 'green')
        end
    end
end

figure(fh_tot_dens_bar);
xline([2.5, 6.5], LineWidth=1.5)
xline(4.5, LineWidth=2, Color='red')
ylim([1 1.25]);
ylabel('Total density (g/cm3)')

figure(fh_tot_vol_bar);
xline([2.5, 6.5], LineWidth=1.5)
xline(4.5, LineWidth=2, Color='red')
ylabel('Total volume (fl)')

figure(fh_snacs_opt);
xline([2.5, 6.5], LineWidth=1.5)
xline(4.5, LineWidth=2, Color='red')
ylabel('SNACS (au)')
ylim([-0.03,0.03])

saveas(fh_tot_dens_bar, "fig\tot_dens_bar.jpg")
saveas(fh_tot_vol_bar, "fig\tot_vol_bar.jpg")
saveas(fh_snacs_opt, 'fig\opti_snacs.jpg')

%% SNACS from coulter
s_temp = load('data\coulter_preload.mat');
coulter_dict = s_temp.coulter_dict;

fh_snacs_coul = figure; hold on;
for j = 1:length(rbc_types)
    for i = 1:length(rep_nums)
        for k = 1:length(solutes)
            rn = rep_nums(i);
            rbct = rbc_types(j);
            sol = solutes(k);

            st_pbs = data_dict(rbct + num2str(rn) + "_" + sol + "_pbs");
            
            coul_vol = coulter_dict(strcat(rbct, num2str(rn), "_", sol));
            bm_i = st_pbs.mass_pg;
            dens_const = median(bm_i) / coul_vol;
            v_i = bm_i / dens_const;
            
            ndev_snacs = st_pbs.ndev_hz;
            nv = ndev_snacs ./ v_i;
            p_snacs = polyfit(v_i, nv, 1);

            fh_fit = figure;
            scatter(v_i, nv, 'Marker', '.'); hold on;
            plot(v_i, polyval(p_snacs, v_i), 'LineWidth', 2)
            xlabel('Volume (fl)')
            ylabel('Node deviation / volume (fl^-1)')

            m = p_snacs(1);
            v_ref = median(v_i);
            snacs = nv - m * (v_ref - v_i);

            figure(fh_snacs_coul);
            if st_pbs.solute == "sms"
                swarm_color = 'red';
            elseif st_pbs.solute == "mannitol"
                swarm_color = 'blue';
            end
            label_ = strcat(st_pbs.rbc_type, st_pbs.rep_num, " ", st_pbs.solute);
            add_swarmchart(fh_snacs_coul, label_, snacs, swarm_color, 'green')
        end
    end
end

figure(fh_snacs_coul);
xline([2.5, 4.5, 8.5, 10.5], LineWidth=1.5)
xline(6.5, LineWidth=2, Color='red')
ylabel('SNACS (au)')
% title('asdfasdfasdf')
ylim([-0.03,0.03])
saveas(fh_snacs_coul, 'fig\coul_snacs.jpg')


%% Helpers
function dens = get_dens(p, q_val)
    dens = (q_val - p(2)) / p(1);
end