clear;clc;
path1='.\EVM_Matlab\compile\beside_uncover';%视频存放路径
path2='.\';%图片输出路径
f=fullfile(path1,'*.avi');%用通配符构造完整路径
videoDir = dir(f);%获取文件信息
number = 1;%标号

for i = 1 : length(videoDir)%遍历所有文件 
    f = fullfile(path1,videoDir(0).name);%依次获取每个文件的路径
    obj=VideoReader(f);%读取视频文件
    numFrames=obj.NumFrames;%计算总帧数
    bTVBS=[];
    bEns=[];
    for k=1:1:90
        img=read(obj,k);%读取第k帧图片
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
        
    for k=90:1:numFrames %按固定间隔抽取图片（我这里每帧读取一次）
        TVBS=[];
        Ens=[];
        img=read(obj,k);%读取第k帧图片
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
        number = number + 1;%标号加一
        break
    end
end
imshow(graypo)
