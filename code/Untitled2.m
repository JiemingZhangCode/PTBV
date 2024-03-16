clear;clc;
path1='.\EVM_Matlab\compile\beside_uncover';%视频存放路径
path2='.\';%图片输出路径
f=fullfile(path1,'*.avi');%用通配符构造完整路径
videoDir = dir(f);%获取文件信息
number = 1;%标号

for i = 1 : length(videoDir)%遍历所有文件 
    f = fullfile(path1,videoDir(i).name);%依次获取每个文件的路径
    obj=VideoReader(f);%读取视频文件
    numFrames=obj.NumFrames;%计算总帧数
    for k=60:1:numFrames-50 %按固定间隔抽取图片（我这里每帧读取一次）
        TVBS=[];
        Ens=[];
        img=read(obj,k);%读取第k帧图片
        graypo=rgb2gray(img);
        graypo = uint8(graypo);
        [row,col] = size(graypo);
        row = round(row/25) * 25;
        col = round(col/25) * 25;
        graypo = imresize(graypo, [row, col]);
        [imgTVB,imgen]=change(img);
        img_1=read(obj,k-30);
        [imgTVB_1,imgen_1]=change(img_1);
        img_2=read(obj,k-50);
        [imgTVB_2,imgen_2]=change(img_2);
        img1=read(obj,k+30);
        [imgTVB1,imgen1]=change(img1);
        img2=read(obj,k+50);
        [imgTVB2,imgen2]=change(img2);
        
%         [row,col] = size(imgTVB);
        background=ones(row, col);
        for m=1:25:row-24
            for n=1:25:col-24
                TVBS=[imgTVB(m, n),imgTVB_1(m, n),imgTVB_2(m, n),imgTVB1(m, n),imgTVB2(m, n)];
                Ens=[imgen(m, n),imgen_1(m, n),imgen_2(m, n),imgen1(m, n),imgen2(m, n)];
                Tm = sort(TVBS);Tm(1)=[];Tm(length(TVBS)-1)=[];Tmean=mean(Tm);
                Em = sort(Ens);Em(1)=[];Em(length(Ens)-1)=[];Emean=mean(Em);
                if imgTVB(m, n)<imgTVB_1(m, n) && imgen(m, n)>imgen_1(m,n) && imgTVB(m, n)<0.8*Tmean && imgen(m, n)>1.0005*Emean
                    background(m:m+24, n:n+24)=0;
                end
            end       
        end
        graypo=graypo.*uint8(background);
        number = number + 1;%标号加一
        break
    end
    break
end
imshow(graypo)
