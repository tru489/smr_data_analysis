function [dvol_out, ddens_out, wc_out] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol, cf)

arguments
    rho_f1
    rho_f2
    bm1
    bm2
    vol
    cf = 0.8
end

levels = [length(rho_f1), length(rho_f2), length(bm1), length(bm2), length(vol), length(cf)];
dff = fullfact(levels);

dvol_out = zeros(size(dff, 1), 1);
ddens_out = zeros(size(dff, 1), 1);
wc_out = zeros(size(dff, 1), 1);

for i = 1:size(dff, 1)
    dff_sl = dff(i,:);
    rho_f1_t = rho_f1(dff_sl(1));
    rho_f2_t = rho_f2(dff_sl(2));
    bm1_t = bm1(dff_sl(3));
    bm2_t = bm2(dff_sl(4));
    vol_t = vol(dff_sl(5));
    cf_t = cf(dff_sl(6));

    [dvol, ddens, wc] = calc_wc(rho_f1_t, rho_f2_t, bm1_t, bm2_t, cf_t, vol_t);

    dvol_out(i) = dvol;
    ddens_out(i) = ddens;
    wc_out(i) = wc;
end

