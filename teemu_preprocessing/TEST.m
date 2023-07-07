f = fopen("C:\Users\Blue\Desktop\test\f1", 'w');
fwrite(f,[1:9], 'float64', 0, 'b');
fclose(f);

f = fopen("C:\Users\Blue\Desktop\test\f1", 'r', 'b');
s = fread(f, inf, 'float64=>double');
disp(s)
fclose(f);
 