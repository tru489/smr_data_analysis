close all;

tab = readtable("C:\thomasu\smr_data_analysis\analysis\2024-02-24_density_cals\data\dff1.csv");

aa2_man = tab(tab.sample == "AA Man PBS", :);
aa2_sms = tab(tab.sample == "AA SMS PBS", :);
ss2_man = tab(tab.sample == "SS Man PBS", :);
ss2_sms = tab(tab.sample == "AA SMS PBS", :);

fh_ndev_swarm_myra = figure; hold on;
add_swarmchart(fh_ndev_swarm_myra, "aa2 mannitol", aa2_man.ND, "blue", "green")
add_swarmchart(fh_ndev_swarm_myra, "aa2 sms", aa2_sms.ND, "red", "green")
add_swarmchart(fh_ndev_swarm_myra, "ss2 mannitol", ss2_man.ND, "blue", "green")
add_swarmchart(fh_ndev_swarm_myra, "ss2 sms", ss2_sms.ND, "red", "green")
ylabel('Node deviation (Hz)')
saveas(fh_ndev_swarm_myra, 'fig\myra_ndev_swarm.jpg')

fh_snacs_swarm_myra = figure; hold on;
add_swarmchart(fh_snacs_swarm_myra, "aa2 mannitol", aa2_man.SNACS, "blue", "green")
add_swarmchart(fh_snacs_swarm_myra, "aa2 sms", aa2_sms.SNACS, "red", "green")
add_swarmchart(fh_snacs_swarm_myra, "ss2 mannitol", ss2_man.SNACS, "blue", "green")
add_swarmchart(fh_snacs_swarm_myra, "ss2 sms", ss2_sms.SNACS, "red", "green")
ylabel('SNACS (au)')
saveas(fh_snacs_swarm_myra, 'fig\myra_snacs_swarm.jpg')