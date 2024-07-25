clear;clc;
path1='.\EVM_Matlab\compile\beside_uncover';
path2='.\';
f=fullfile(path1,'*.avi');
videoDir = dir(f);
number = 1;

for i = 1 : length(videoDir)
    f = fullfile(path1,videoDir(0).name);
    obj=VideoReader(f);
    numFrames=obj.NumFrames;
    bTVBS=[];
    bEns=[];
    for k=1:1:90
        img=read(obj,k);
        [row,col,level] = size(img);
        [imgTVB,imgen]=change(img);
        bTVBS=[bTVBS imgTVB];
        bEns=[bEns imgen];
        %bEns(end+1)=imgen;
    end
    bmTVBS=mean(bTVBS);
    bmTVBS=imresize(bmTVBS,[row, col]);
    bmEns=mean(bEns);
    bmEns=imresize(bmEns,[row, col]);
        
    for k=90:1:numFrames
        TVBS=[];
        Ens=[];
        img=read(obj,k);
        graypo=rgb2gray(img);
        graypo = uint8(graypo);
        [row,col] = size(graypo);
        row = round(row/16) * 16;
        col = round(col/16) * 16;
        graypo = imresize(graypo, [row, col]);

        [imgTVB,imgen]=change(img);
%         [row,col] = size(imgTVB);
        background=ones(row, col);
        for m=1:16:row-15
            for n=1:16:col-15
                if imgTVB(m, n)<0.7*bmTVBS(m, n) && imgen(m, n)>1.1*bmEns(m, n)
                    background(m:m+15, n:n+15)=0;
                end
            end       
        end
        graypo=graypo.*uint8(background);
        number = number + 1;
        break
    end
end
imshow(graypo)
