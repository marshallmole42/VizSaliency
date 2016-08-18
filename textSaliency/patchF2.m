function f = patchF2(patch)

[H, W] = size(patch);

R = 4;
f1=0;
for i=1:H  % scan through the rows
    
    if sum(patch(i,:))>2
        f1 = f1+1;
    end
    
end

f2=0;
for i=1:W  % scan through the columns
    
    if sum(patch(:,i))>2
        f2 = f2+1;
    end
    
end

f=R^((f1+f2)/(W+H));

end