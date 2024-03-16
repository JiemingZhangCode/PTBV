clear;clc;
path1='.\EVM_Matlab\compile\up_uncover_cover';%视频存放路径
path2='.\';%图片输出路径
f=fullfile(path1,'*.avi');%用通配符构造完整路径
videoDir = dir(f);%获取文件信息
number = 1;%标号
TVBS=[];
for i = 1 : length(videoDir)%遍历所有文件 
    f = fullfile(path1,videoDir(i).name);%依次获取每个文件的路径
    obj=VideoReader(f);%读取视频文件
    numFrames=obj.NumFrames;%计算总帧数
    for k=1:1:numFrames%按固定间隔抽取图片（我这里每十帧读取一次）
        img=read(obj,k);%读取第k帧图片
%         graypic=rgb2gray(img);
        graypic = img(: , : , 1)*1.20-img(: , : , 2)*0.90-img(: ,: , 3)*0.90;
%         graypic = max(max(img(: , : , 1),img(: , : , 2)),img(: ,: , 3));
%         graypic = (img(: , : , 1)+img(: , : , 2)+img(: ,: , 3))/3;
        % matlab直接进行矩阵运算
        % 加权平均值法转化之后的灰度图像
        graypic = uint8(graypic);% 将得到的新矩阵转化为uint8格式，因为用上面的语句创建之后图像是double型的
%         hang=diff(graypic,1,1);
%         hang(end+1,:)=0;
%         lie=diff(graypic,1,2);
%         lie(:,end+1)=0;
%         dfpic=hang+lie;
%         TVB=sum(sum(dfpic));
%         if k==1
%             continue
%         end
        [row,col] = size(graypic);
        row = round(row/8) * 8; 
        col = round(col/8) * 8;
        graypic = imresize(graypic, [row, col]);
        
        img_dct = zeros(row, col); % 存放转换后的dct系数
        for m=1:8:row-7
            for n=1:8:col-7
                img_block = img(m:m+7, n:n+7);
                TVB=sum(sum(diff(img_block,1,1)))+sum(sum(diff(img_block,1,2)));
                
                a=tabulate(img_block(:));
                b=sum(a(:,3).^2)/10000;
                
                s=fftshift(fft2(img_block));
                %生成ILPF并对白条图像进行低通滤波
                [M,N]=size(s);
                H = zeros(M,N);
                n1=floor(M/2); %对M/2进行取整
                n2=floor(N/2);
                d0=40;
                for h=1:M
                    for l=1:N
                        d=sqrt((h-n1)^2+(l-n2)^2); %点(i,j)到Fourier变换中心的距离
                        g = double(d<=d0); %ILPF滤波函数
                        s(h,l)=g*s(h,l);           %ILPF滤波后的频域表示
                    end
                end
                %进行反Fourier变换并显示
                s=ifftshift(s);
                s=uint8(real(ifft2(s)));%对s进行二维反离散的Fourier变换后，取复数的实部转化为无符号8位整数
                a1=tabulate(s(:));
                b1=sum(a1(:,3).^2)/10000;
                en=b1/b;
                img_double(m:m+3, n:n+7) = TVB;
                img_double(m+3:m+7, n:n+7) = en;
%                 dct_block = dct2(img_block); % 也可用刚才实现的(定义成一个函数即可)
%                 imshow(dct_block); % 显示dct块
%                 img_dct(m:m+7, n:n+7) = dct_block;
            end
        end

%         TVB=sum(sum(diff(graypic,1,1)))+sum(sum(diff(graypic,1,2)));
%         TVBS(end+1)=TVB;
        %1.2 -0.9 -0.9
%         imgName = num2str(number,'%05d');%按五位整数的固定格式命名
%         front = 'moto-images-003-';%前缀命名
%         FullName = [front imgName '.jpg'];%构造完整文件名
%         f2 = fullfile(path2,FullName);%完整路径
%         imwrite(dfpic,f2);%保存图片
        number = number + 1;%标号加一
    end
end
imshow(TVBS)
