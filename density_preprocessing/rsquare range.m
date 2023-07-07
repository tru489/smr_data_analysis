idx = find(datafullpmt1(2,:)>0.1 & datafullpmt1(2,:)<4);

datapmt1 = datafullpmt1(2,idx); datapmt2 = datafullpmt2(2,idx);
rsquare(datapmt1, datapmt2);