function g = patchF3(patch)

[H, W] = size(patch);

g1=0;
for i=1:H  % scan through the rows
    if mod(sum(patch(i,:)),2) == 0
        g1 = g1+1;
    end
end

g2=0;
for i=1:W  % scan through the columns
    if mod(sum(patch(:,i)),2) == 0
        g2 = g2+1;
    end
end

g = (g1+g2)/(W+H);

end