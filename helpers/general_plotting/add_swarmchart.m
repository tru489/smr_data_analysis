function add_swarmchart(fh, label_, data_vec, swarm_color, box_color)
    arguments
        fh
        label_
        data_vec
        swarm_color = 'blue'
        box_color = 'red'
    end
    if ~isstring(label_)
        label_ = string(label_);
    end

    figure(fh)
    s = swarmchart(categorical(repmat(label_, length(data_vec), 1)), ...
        data_vec, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', swarm_color, 'MarkerEdgeColor', swarm_color);
    hold on;
    b = boxchart(categorical(repmat(label_, length(data_vec), 1)), data_vec);
    b.BoxFaceColor = box_color;
    b.BoxMedianLineColor = box_color;
    b.MarkerColor = box_color;
    b.WhiskerLineColor = box_color;
    b.LineWidth = 1.5;
    b.MarkerStyle = 'none';
end