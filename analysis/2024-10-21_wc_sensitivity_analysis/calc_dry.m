function [dvol, ddens] = calc_dry(rho_f1, rho_f2, bm1, bm2, cf)
arguments
    rho_f1
    rho_f2
    bm1
    bm2
    cf = 0.8
end

std_cf = 0.8;
bm1 = bm1 / std_cf * cf;
bm2 = bm2 / std_cf * cf;

dvol = (bm1 - bm2) / (rho_f2 - rho_f1);
ddens = (rho_f2 .* bm1 - rho_f1 .* bm2) ./ (bm1 - bm2);

end

