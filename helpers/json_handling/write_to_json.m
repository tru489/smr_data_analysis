function write_to_json(st, fpath)
    json_id = fopen(fpath, 'w');
    js_str = jsonencode(st, PrettyPrint=true);
    fprintf(json_id, js_str);
    fclose(json_id);
end