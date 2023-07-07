function merged_features = S3_Merge(peak_features)
    % Merges adjacent peaks corresponding to each SMR signal together. The
    % output from peak extraction should be individual peaks, not
    % accounting for the fact that each SMR signal should contain 3 peaks;
    % this function accounts for this by pooling the peaks together in
    % groups of 3, extracting peak feature metrics, and returning a new,
    % merged array.
    % 
    % Arguments:
    %     peak_features (array): features for each detected peak in data.
    %     dimensions are 13 x (number of peaks detected)
    % 
    % Returns: 
    %     merged_features (array): features for each SMR signal detected
    %     from pooling individual peaks. dimensions are (number of SMR
    %     signals) x 20

    % Filter out columns that have 0 in the pkorder feature of datafull
    % (column 12). pkorder tracks which SMR signal each peak corresponds
    % with (there will be 3 peaks for signals labeled 1, 2, 3, etc.),
    % indexing starting at 1
    pk_features_rm_0 = peak_features(:, peak_features(12,:) > 0);
    
    % Find the indices at which there is a transition between SMR signals.
    % In the pkorder row of datafull, this is where the differences between
    % adjacent elements are nonzero
    idx = find(diff(pk_features_rm_0(12, :)) ~= 0);
    idx = [0 idx];

    merged_features = zeros(length(idx), 20);
    % Iterate through all indices of SMR signals (that is, peaks will be
    % taken in groups of 3 to analyze)
    for i = 1:length(idx)
        % Pull out peaks with same pkorder label (for each SMR signal
        % collected, should be 3 peaks
        if i == length(idx)
            temp_idx = (idx(i) + 1):length(pk_features_rm_0);
        else
            temp_idx = (idx(i) + 1):idx(i+1);
        end
        
        t1 = pk_features_rm_0(1, temp_idx(1));
        t2 = pk_features_rm_0(1, temp_idx(end));
        tm = mean([t1, t2]);

        % Left, middle, right peak heights (middle peak is path
        % dependent)
        m1 = pk_features_rm_0(2, temp_idx(1)); % Left peak height
        m2 = pk_features_rm_0(2, temp_idx(2)); % Middle peak height
        m3 = pk_features_rm_0(2, temp_idx(end)); % Right peak height
        mm = mean([m1, m3]);

        b1 = mean([pk_features_rm_0(4, temp_idx(1)), ...
            pk_features_rm_0(5, temp_idx(1))]);
        b2 = mean([pk_features_rm_0(4, temp_idx(end)), ...
            pk_features_rm_0(5, temp_idx(end))]);
        bm = mean([b1, b2]);

        bs = pk_features_rm_0(7, temp_idx(1));

        nd1 = pk_features_rm_0(8, temp_idx(1));
        nd2 = pk_features_rm_0(8, temp_idx(2));
        ndm = mean([nd1, nd2]);
        
        % FWHM
        w = pk_features_rm_0(9, temp_idx(1)); 

        % Added by JK (transit time in ms)
        bd = pk_features_rm_0(6, temp_idx(1)); 

        vs = peak_features(13, temp_idx(2));
        
        % Sectnum
        sectnum = pk_features_rm_0(10, temp_idx(1));
               
        pkorder = pk_features_rm_0(12, temp_idx(1));

        % Peak width
        wth = pk_features_rm_0(3, temp_idx(1));

        merged_features(i,:) = [tm, tm/60, mm, bm, bs, m1, m2, m3, nd1, nd2, ...
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

