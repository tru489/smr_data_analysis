function [dvol, ddens, wc] = calc_wc(rho_f1, rho_f2, bm1, bm2, cf, vol)

[dvol, ddens] = calc_dry(rho_f1, rho_f2, bm1, bm2, cf);
wc = (vol - dvol) / vol;

end

