coff1 = 0.5;

idx1 = find(abs((test(:,11)-test(:,10))./test(:,12))<coff1);
disp(' ');
fprintf('percentage of peaks within the percentage cutoff %2.0f is: %2.1f', coff1*100, length(idx1)/length(test)*100);


coff2 = 0.3;

idx2 = find(abs((test(:,11)-test(:,10))./test(:,12))<coff2);
disp(' ');
fprintf('percentage of peaks within percentage cutoff %2.0f is: %2.1f', coff2*100, length(idx2)/length(test)*100);
disp(' ');


coff3 = 0.3; %2std 
idx3 = find(abs((test(:,11)-test(:,10)))<coff3);
disp(' ');
fprintf('percentage of peaks within cutoff %2.2f is: %2.1f', coff3, length(idx3)/length(test)*100);
disp(' ');

test2 = test(idx3,:);

disp(' ' );
fprintf('median normND for all idx is %2.5f and CV is %2.5f', median(test(:,20)), std(test(:,20))./median(test(:,20)));
disp(' ' );
fprintf('median normND for cutoff1 is %2.5f and CV is %2.5f', median(test(idx1,20)), std(test(idx1,20))./median(test(idx1,20)));
disp(' ');
fprintf('median normND for cutoff2 is %2.5f and CV is %2.5f', median(test(idx2,20)), std(test(idx2, 20))./median(test(idx2,20)));
disp(' ');

disp(' ');
fprintf('median normND for cutoff3 is %2.6f and CV is %2.6f', median(test(idx3,20)), std(test(idx3,20))./median(test(idx3,20)));
disp(' ');