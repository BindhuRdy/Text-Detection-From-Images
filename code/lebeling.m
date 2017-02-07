function [ labels ] = labelling( input_args )
%LABELLING is a function for labelling each block in the all the images
%based on the text rectangles.
load ..\dataset\data;
base_address='..\dataset\';
type='.jpg';
no_images=50;
for k=1:no_images
    img_address=[base_address,num2str(k),type];
    rgb=imread(img_address);
    [rows,cols,~]=size(rgb);
    blocks=0;
    
    for i=1:50:rows
        for j=1:50:cols
            blocks=blocks+1;
            minx=i;
            maxx=min(rows,i+50);
            miny=j;
            maxy=min(j+50,cols);
            if minx>=data(k,1) && miny>=data(k,2) && maxx<=data(k,3) && maxy<=data(k,4)
                tmp(blocks)=1;
            else
                tmp(blocks)=0;
            end
        end
    end
    labels{k}=tmp;
end
save ..\dataset\labels labels

end
