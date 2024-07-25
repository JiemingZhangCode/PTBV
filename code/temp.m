clear;clc;
f=fullfile('2333.mp4');
obj=VideoReader(f);
numFrames=obj.NumFrames;
number = 1;

img=read(obj,1);
[imgTVB,imgen]=smoke(img);

TVBS=[];
Ens=[];

for k=1:60:numFrames 
    img=read(obj,k);
    adressString = ['C:\Users\lenovo\Desktop\3\' ,sprintf('%0.4d', number),'.jpg'];
    imwrite(img, adressString,'jpg');
    number = number + 1;
end
