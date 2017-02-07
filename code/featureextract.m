function [blocks,D]=featureextract(phase1)     
blocks=0;
[rows,cols]=size(phase1);
for i=1:50:rows
    for j=1:50:cols
        blocks=blocks+1;
        [h,c]=homogenity_contrast(phase1(i:min(rows,i+50),j:min(j+50,cols))); 
        %[h(2),c(2)]=homogenity_contrast(imrotate(phase1(i:min(rows,i+50),j:min(j+50,cols)),45)); 
        %[h(3),c(3)]=homogenity_contrast(imrotate(phase1(i:min(rows,i+50),j:min(j+50,cols)),90)); 
        %[h(4),c(4)]=homogenity_contrast(imrotate(phase1(i:min(rows,i+50),j:min(j+50,cols)),135)); 
        D(blocks,:)=[i,min(rows,i+50),j,min(j+50,cols),h(1),c(1),h(2),c(2),h(3),c(3),h(4),c(4),0];        
    end
end
end

%function for calculating homgenity and contrast for a block
function [homogenity,contrast]=homogenity_contrast(arr)
P(1,:,:)=graycomatrix(arr,'offset', [0 1]);
P(2,:,:)=graycomatrix(arr,'offset', [-1 1]);
P(3,:,:)=graycomatrix(arr,'offset', [-1 0]);
P(4,:,:)=graycomatrix(arr,'offset', [-1 -1]);
[tmp,rows,cols]=size(P);
R(1,1:4)=0;
for i=1:rows
    for j=1:cols
        for k=1:4
            R(k)=R(k)+P(k,i,j);
        end
    end
end
homogenity(1,1:4)=0;
contrast(1,1:4)=0;
for i=1:rows
    for j=1:cols
        for k=1:4
            homogenity(k)=homogenity(k)+(P(k,i,j)/R(k))^2;
            contrast(k)=contrast(k)+(abs(i-j))^2*P(k,i,j)/R(k);
        end
    end
end
    
end