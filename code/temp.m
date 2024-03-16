clear;clc;
f=fullfile('2333.mp4');
obj=VideoReader(f);%读取视频文件
numFrames=obj.NumFrames;%计算总帧数
number = 1;%标号

img=read(obj,1);%读取第1帧图片
[imgTVB,imgen]=smoke(img);

TVBS=[];
Ens=[];

for k=1:60:numFrames %按固定间隔抽取图片（我这里每帧读取一次）
    img=read(obj,k);%读取第k帧图片
    adressString = ['C:\Users\lenovo\Desktop\3\' ,sprintf('%0.4d', number),'.jpg'];
    imwrite(img, adressString,'jpg');
    number = number + 1;%标号加一
end