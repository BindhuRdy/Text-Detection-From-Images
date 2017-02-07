function [ precision,recall,accuracy,truenegativerate ] =performance( input_args )
%EVALUATEPERFORMANCE Summary of this function goes here
%   Detailed explanation goes here
load dataset\labels
base_address='dataset\';
type='.jpg';

%initialization
tp=0; %true positives
fp=0; %false positives
tn=0; %true negatives
fn=0; %false negatives
no_images=5;
for k=1:no_images
    display(['Processing image ',num2str(k)]);
    img_address=[base_address,num2str(k),type];
    actual_labels=labels{k};
    obtained_labels=maindetector(img_address);
    blocks=size(obtained_labels,2);
    for i=1:blocks
        if actual_labels(i)==1 && obtained_labels(i)==1
            tp=tp+1;
        else if actual_labels(i)==0 && obtained_labels(i)==0
                tn=tn+1;
            else if actual_labels(i)==0 && obtained_labels(i)==1
                    fp=fp+1;
                else
                    fn=fn+1;
                end
            end
        end
    end
end
precision=tp/(tp+fp)
recall=tp/(tp+fn)
accuracy=(tp+tn)/(tp+tn+fp+fn)
truenegativerate=tn/(fp+tn)
end

