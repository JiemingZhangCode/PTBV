function [img_TVB,img_en] = change(img)
%   img  输入选取的帧图像
%   img_TVB 输出区块tvb值的合成图
%   img_en  输出图像区块低频占比的合成图
% graypic = img(: , : , 1)*1.20-img(: , : , 2)*0.90-img(: ,: , 3)*0.90;
graypic=rgb2gray(img);
graypic = uint8(graypic);
[row,col] = size(graypic);
row = round(row/16) * 16;
col = round(col/16) * 16;
graypic = imresize(graypic, [row, col]);

img_TVB = zeros(row, col); % 存放转换后的TVB系数
img_en = zeros(row, col); % 存放转换后的en系数
for m=1:16:row-15
    for n=1:16:col-15
        img_block = graypic(m:m+15, n:n+15);
        TVB=sum(sum(diff(img_block,1,1)))+sum(sum(diff(img_block,1,2)));
        %TVB=log(TVB);

        a=tabulate(img_block(:));
        %b=sum(a(:,3).^2)/10000;
        b=sum((a(:,1)./255).^2.*a(:,3))/100;
        
        f=double(img_block);%数据类型转换
        g=fft2(f);%图像傅里叶转换
        g=fftshift(g);%傅里叶变换平移
        [N1,N2]=size(g);%傅里叶变换图像尺寸
        d0=5;
        n1=fix(N1/2);%数据圆整
        n2=fix(N2/2);%数据圆整
        for i=1:N1%遍历图像像素
            for j=1:N2
                d=sqrt((i-n1)^2+(j-n2)^2);
                if d==0
                    h=0;
                else
                    h=1/(1+(d/d0)^(2*2));
                end
                result(i,j)=h*g(i,j);%?图像矩阵计算处理
            end
        end
        result=ifftshift(result);
        X2=ifft2(result);
        X3=uint8(real(X2));
        %         imshow(uint8(X3));
        
        a1=tabulate(X3(:));
        %b1=sum(a1(:,3).^2)/10000;
        b1=sum((a1(:,1)./255).^2.*a1(:,3))/100;
        en=b1/b;
        if isnan(en)
            en=0;
        end
        img_TVB(m:m+15, n:n+15) = TVB;
        img_en(m:m+15, n:n+15) = en;
    end
end
end