clear;clc;
f=fullfile('E:\AAworking\smoke\EVM_Matlab\compile\beside_uncover\0.avi');
number = 1;
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

for k=90:15:numFrames 
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
    %background=ones(row, col);
    des=img;
    for m=1:16:row-15
        for n=1:16:col-15
            try
                if imgTVB(m, n)<bmTVBS(m, n) && imgen(m, n)>bmEns(m, n)
                    %background(m:m+15, n:n+15)=0;
                    des = drawRect(des,[m,n],[15,15],2 );
                end
            catch
                continue
            end
        end
    end
    adressString = ['C:\Users\lenovo\Desktop\6\' ,sprintf('%0.4d', number),'.jpg'];
    imwrite(des, adressString,'jpg');
    number = number + 1;
    %graypo=graypo.*uint8(background);
    
end

%imshow(graypo)
