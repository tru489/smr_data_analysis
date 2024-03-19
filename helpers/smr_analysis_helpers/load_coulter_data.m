function Vol_data = load_coulter_data(fname)

Coulter_data = readtable(fname, 'FileType', 'text', 'Delimiter', ' ');
ind_size_bin_start  = find(Coulter_data.Var1 == "[#Bindiam]");
ind_size_bin_end  = find(Coulter_data.Var1 == "[Binunits]");
ind_count_bin_start  = find(Coulter_data.Var1 == "[#Binheight]");
ind_count_bin_end  = find(Coulter_data.Var1 == "[SizeStats]");

Vol_data = table();
Vol_data.diameter= str2double(string(Coulter_data.Var1(ind_size_bin_start+1:ind_size_bin_end-1)));
Vol_data.count= str2double(string(Coulter_data.Var1(ind_count_bin_start+1:ind_count_bin_end-1)));
Vol_data.volume_fL = (4*pi*(Vol_data.diameter./2).^3)/3;

end