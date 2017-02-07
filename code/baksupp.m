function [phase1]=baksupp(gray)
%function for background removal/supression 
%initialization
[rows,cols]=size(gray);
res=zeros(rows,cols);
phase1=zeros(rows,cols);
phase1=gray;

%background removal/supression
for i=1:8:rows
    for j=1:8:cols
        res(i:min(rows,i+8),j:min(j+8,cols))=dct2(gray(i:min(rows,i+8),j:min(j+8,cols)));
        res(i,j)=0;
    end
end
for i=1:8:rows
    for j=1:8:cols
        phase1(i:min(rows,i+8),j:min(j+8,cols))=idct2(res(i:min(rows,i+8),j:min(j+8,cols)));        
    end
end
phase1=uint8(phase1);
end

