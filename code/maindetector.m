function  [labels]= maindetector(src_img)
%TEXTDETECTOR1 detects text regions in an image
%src_img='..\dataset\3.jpg';
%loading the source image
%rgb=imread(src_img);
% rows=size(rgb,2);
% if rows>1000
%     rgb=imresize(rgb,[768 1024]);
% end
 [filename, user_canceled] = imgetfile ;
 a=imread(filename);
 info=imfinfo(filename);
na=info.Filename;
 
rgb=imread(na);
 gray=rgb2gray(rgb);
 figure('Name','Original Image','NumberTitle','off');
 imshow(gray);
%gray=gray';
[rows,cols]=size(gray);
%background removal/supression
phase1=baksupp(gray);
 figure('Name','After background supression','NumberTitle','off');
 contrast(phase1);
 imshow(phase1);

%feature extraction
[blocks,D]=featureextract(phase1);


%classification
classes=classifyTextBlocks(D);
%classes=svmclassify(classifier,D(:,5:12));
%refinement the text bocks
%[D,classes]=refineblocks(D,classes,rows,cols);

%storing only text blocks into seperate variable
blcks=0;
for i=1:blocks
    if classes(i)==1
        blcks=blcks+1;
        D1(blcks,:)=D(i,:);
    end
end

%displaying the resultatnt image after classification
blocks=size(D1,1);
phase3=zeros(rows,cols);
for i=1:blocks
    phase3(D1(i,1):D1(i,2),D1(i,3):D1(i,4))=gray(D1(i,1):D1(i,2),D1(i,3):D1(i,4));
end
  figure('Name','After classification','NumberTitle','off');
  imshow(uint8(phase3));

%merging the adjacent text blocks
D2=mergeBlocks(D1);
% D2=removeFalsePositives(D2);
%preparing the output
labels=getLabels(D2,D);

%displaying the resultatnt image after classification
blocks=size(D2,1);
phase2=zeros(rows,cols);
for i=1:blocks
    phase2(D2(i,1):D2(i,2),D2(i,3):D2(i,4))=gray(D2(i,1):D2(i,2),D2(i,3):D2(i,4));
end
  figure('Name','final image','NumberTitle','off');
   imshow(uint8(phase2));
end

%classification to discriminannt text blocks from no text blocks
function [classes]=classifyTextBlocks(D)
t1=0;
t2=0;
blocks=size(D,1);
for i=1:blocks
    t1=t1+D(i,12)+D(i,6)+D(i,8)+D(i,10);
    t2=t2+D(i,11)+D(i,5)+D(i,7)+D(i,9);
end
t1=1.2*t1/(4*blocks);
t2=1.2*t2/(4*blocks);
classes=zeros(blocks,1);
%classification
for i=1:blocks
    if D(i,5)<=t2 && D(i,7)<=t2  && D(i,9)<=t2   && D(i,11)<=t2 && D(i,12)>=t1&& D(i,6)>=t1&& D(i,8)>=t1&& D(i,10)>=t1
        classes(i)=1;
    end
end
end

%function for merging adjacent text blocks
function [merged_blocks]=mergeBlocks(D)
D(:,1:4)
blocks=size(D,1);
blcks=0;
lookup=zeros(blocks,1);
for i=1:blocks
    lookup(i)=i;
end
for i=1:blocks
    ind=lookup(i);
    if ind==i 
        tmp=D(ind,:);
        lookup(i)=blcks+1;
    else
        tmp=merged_blocks(ind,:);
    end
    for j=1:blocks
        if i==j
            continue;
        end
        ind2=lookup(j);
        if ind2==j && j~=1
            tmp2=D(ind2,:);
        else
            tmp2=merged_blocks(ind2,:);
        end
        if   rowequivalent(tmp,tmp2) || colequivalent(tmp,tmp2)  rowequivalent(D(i,:),D(j,:)) || colequivalent(D(i,:),D(j,:)) 
            tmp(1)=min(tmp(1),tmp2(1));
            tmp(2)=max(tmp(2),tmp2(2));
            tmp(3)=min(tmp(3),tmp2(3));
            tmp(4)=max(tmp(4),tmp2(4));
            lookup(j)=lookup(i);
        end            
    end
    if ind==i 
        blcks=blcks+1;
        merged_blocks(blcks,:)=tmp;
    else
        merged_blocks(ind,:)=tmp;
    end
end
%merged_blocks(:,1:4)
merged_blocks=removeDuplicates(merged_blocks);
%merged_blocks(:,1:4)
end
function [flag]=rowequivalent(D1,D2)
rmin1=D1(1);
rmin2=D2(1);
rmax1=D1(2);
rmax2=D2(2);
cmin1=D1(3);
cmin2=D2(3);
cmax1=D1(4);
cmax2=D2(4);
if (rmin2<=rmin1 && rmin1<=rmax2 && cmin2<=cmin1 && cmin1<=cmax2) || (rmin2<=rmin1 && rmin1<=rmax2 && cmin2<=cmax1 && cmax1<=cmax2) || (rmax1>=rmin2 && rmax1<=rmax2 && cmin2<=cmin1 && cmin1<=cmax2) || (rmax1>=rmin2 && rmax1<=rmax2 && cmin2<=cmax1 && cmax1<=cmax2)
    flag=1;
else
    flag=0;
end
end
function [flag]=colequivalent(D1,D2)
rmin1=D1(1);
rmin2=D2(1);
rmax1=D1(2);
rmax2=D2(2);
cmin1=D1(3);
cmin2=D2(3);
cmax1=D1(4);
cmax2=D2(4);
if (cmin2<=cmin1 && cmin1<=cmax2 && rmin2<=rmin1 && rmin1<=rmax2) || (cmin2<=cmin1 && cmin1<=cmax2 && rmin2<=rmax1 && rmax1<=rmax2) || (cmax1>=cmin2 && cmax1<=cmax2 && rmin2<=rmin1 && rmin1<=rmax2) || (cmax1>=cmin2 && cmax1<=cmax2 && rmin2<=rmax1 && rmax1<=rmax2)
    flag=1;
else
    flag=0;
end
end
function [D1]=removeDuplicates(D)
blocks=size(D,1);
blcks=0;
for i=1:blocks
    flag=0;
    for j=i+1:blocks
        if i==j
            continue;
        end
        if D(i,1)>=D(j,1) && D(i,2)<=D(j,2) && D(i,3)>=D(j,3) && D(i,4)<=D(j,4)
            flag=1;
            break;
        end
    end
    if flag==0 || i==blocks
        blcks=blcks+1;
        D1(blcks,:)=D(i,:);
    end
end
end
function [D_new,classes_new]=refineblocks(D,classes,rows,cols)
t1=0;
blocks=size(D,1);
for i=1:blocks
    t1=t1+D(i,12)+D(i,6)+D(i,8)+D(i,10);
end
t1=t1/(4*blocks);
classes_new=zeros(blocks,1);
for i=1:blocks
    if classes(i)==1
        classes_new(i)=1;
        [adj_blcks,pos]=findAdjacentBlocks(D(i,:),rows,cols);
        size(pos)
        for k=1:size(pos,2)
            j=adj_blcks(k);
            if classes(j)==1
                continue;
            else
                avg_contrast=(D(j,6)+D(j,8)+D(j,10)+D(j,12))/4;
                if avg_contrast>=t1
                    classes_new(j)=1;
                else if avg_contrast>=0.5*t1
                        D(i,:)=update(D(i,:),pos(k),20,rows,cols);
                    else if avg_contrast>=0.25*t1
                            D(i,:)=update(D(i,:),pos(k),10,rows,cols);
                        else if avg_contrast>=0.125*t1
                                D(i,:)=update(D(i,:),pos(k),5,rows,cols);
                            end
                        end
                    end
                end
            end
        end
    end
end
D_new=D;
end
function [adj,pos]=findAdjacentBlocks(D,rows,cols)
count=0;
if D(3)~=0
    count=count+1;
    adj(count)=getBlock(D(1),max(D(3)-50,1),rows,cols);
    pos(count)=1;
end
if D(1)~=0 && D(3)~=0
    count=count+1;
    adj(count)=getBlock(max(D(1)-50,1),max(D(3)-50,1),rows,cols);
    pos(count)=2;
end
if D(1)~=0
    count=count+1;
    adj(count)=getBlock(max(D(1)-50,1),D(3),rows,cols);
    pos(count)=3;
end
if D(1)~=0 && D(4)~=cols
    count=count+1;
    adj(count)=getBlock(max(D(1)-50,1),D(4),rows,cols);
    pos(count)=4;
end
if D(4)~=cols
    count=count+1;
    adj(count)=getBlock(D(1),D(4),rows,cols);
    pos(count)=5;
end
if D(4)~=cols && D(2)~=rows
    count=count+1;
    adj(count)=getBlock(D(2),D(4),rows,cols);
    pos(count)=6;
end
if D(2)~=rows
    count=count+1;
    adj(count)=getBlock(D(2),D(3),rows,cols);
    pos(count)=7;
end
if D(2)~=rows && D(3)~=0
    count=count+1;
    adj(count)=getBlock(D(2),max(D(3)-50,0),rows,cols);
    pos(count)=8;
end
end
function [ind]=getBlock(minx,miny,rows,cols)
ind=floor(minx/50)*ceil(cols/50)+ceil(miny/50);
end
function [new_D]=update(D1,blockpos,lines,rows,cols)
new_D=D1;
if blockpos==1
    new_D(3)=max(new_D(3)-lines,1);
else if blockpos==2
        new_D(1)=max(new_D(1)-lines,1);
        new_D(3)=max(new_D(3)-lines,1);
    else if blockpos==3
            new_D(1)=max(new_D(1)-lines,1);
        else if blockpos==4
                new_D(1)=max(new_D(1)-lines,1);
                new_D(4)=min(new_D(4)+lines,cols);
            else if blockpos==5
                    new_D(4)=min(new_D(4)+lines,cols);
                else if blockpos==6
                        new_D(2)=min(new_D(2)+lines,rows);
                        new_D(4)=min(new_D(4)+lines,cols);
                    else if blockpos==7
                            new_D(2)=min(new_D(2)+lines,rows);
                        else 
                            new_D(2)=min(new_D(2)+lines,rows);
                            new_D(3)=max(new_D(3)-lines,1);
                        end
                    end
                end
            end
        end
    end
end
new_D(1)=uint8(new_D(1));
new_D(2)=uint8(new_D(2));
new_D(3)=uint8(new_D(3));
new_D(4)=uint8(new_D(4));
end
function [labels]=getLabels(D1,D)
blocks=size(D,1);
blcks=size(D1,1);
labels=zeros(1,blocks);
for i=1:blocks
    for j=1:blcks
        if D(i,1)>=D1(j,1) && D(i,3)>=D1(j,3) && D(i,2)<=D1(j,2) && D(i,4)<=D1(j,4)
            labels(i)=1;
            break;
        end
    end
end    
end
function [D_new]=removeFalsePositives(D)
blocks=size(D,1)
blcks=0;
D_new=[];
for i=1:blocks
    if (D(i,2)-D(i,1)>=150) || (D(i,4)-D(i,3)>=150)
        blcks=blcks+1;
        D_new(blcks,:)=D(i,:);
    end   
end
blcks
end