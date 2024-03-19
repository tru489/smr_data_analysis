function add_pdf_histogram(fh, data, bin_width, color, face_alpha, edge_alpha, disp_name)
arguments
    fh
    data
    bin_width
    color = 'blue'
    face_alpha = 0.2
    edge_alpha = 0.2
    disp_name = ''
end

figure(fh);
[N, edges] = histcounts(data, 'BinWidth', bin_width);
if isempty(disp_name)
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), ...
        'FaceColor', color, 'FaceAlpha', face_alpha, 'EdgeAlpha', edge_alpha)
else
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), ...
        'FaceColor', color, 'FaceAlpha', face_alpha, ...
        'EdgeAlpha', edge_alpha, 'DisplayName', disp_name)
end

end