function datasmr = S3_Merge(datafull)
    % Filter out zero columns
    datafull_processed = datafull(:, datafull(12,:) > 0);

    idx = find(diff(datafull_processed(12,:)) ~= 0);
    idx = [0 idx];

    datasmr = zeros(length(idx), 20);
    for i = 1:length(idx)
        if i == length(idx)
            temp_idx = (idx(i) + 1):length(datafull_processed);
        else
            temp_idx = (idx(i) + 1):idx(i+1);
        end
        
        t1 = datafull_processed(1, temp_idx(1));
        t2 = datafull_processed(1, temp_idx(end));
        tm = mean([t1, t2]);

        % Left, middle, right peak heights (middle peak is path
        % dependent)
        m1 = datafull_processed(2, temp_idx(1)); % Left peak height
        m2 = datafull_processed(2, temp_idx(2)); % Middle peak height
        m3 = datafull_processed(2, temp_idx(end)); % Right peak height
        mm = mean([m1, m3]);

        b1 = mean([datafull_processed(4, temp_idx(1)), ...
            datafull_processed(5, temp_idx(1))]);
        b2 = mean([datafull_processed(4, temp_idx(end)), ...
            datafull_processed(5, temp_idx(end))]);
        bm = mean([b1, b2]);

        bs = datafull_processed(7, temp_idx(1));

        nd1 = datafull_processed(8, temp_idx(1));
        nd2 = datafull_processed(8, temp_idx(2));
        ndm = mean([nd1, nd2]);
        
        % FWHM
        w = datafull_processed(9, temp_idx(1)); 

        % Added by JK (transit time in ms)
        bd = datafull_processed(6, temp_idx(1)); 

        vs = datafull(13, temp_idx(2));
        
        % Sectnum
        sectnum = datafull_processed(10, temp_idx(1));
               
        pkorder = datafull_processed(12, temp_idx(1));

        % Peak width
        wth = datafull_processed(3, temp_idx(1));

        datasmr(i,:) = [tm, tm/60, mm, bm, bs, m1, m2, m3, nd1, nd2, ...
            ndm, w, bd, vs, sectnum, tm/3600, mm/2, pkorder, ndm/mm, wth];
        
    %     if(abs(datafull(7,temp_idx(1)))>0.001)
    %     if(abs(datafull(6,temp_idx(1)))>800)
    %     if(abs(datafull(7, temp_idx(1)))<0.0015)
    %         flag(i)=0;
    %     else
    %         flag(i)=1;
    %     end
    %     plot(t1(i), m1(i), '.c');
    %     plot(t2(i), m2(i), '.r');
    %     hold on;
    %      input('?');
    end
    
    % idx=find(abs(data(:,10))<10);
    % data=data(idx,:);
    % datafull_processed = datafull_processed';

