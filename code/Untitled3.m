clear;clc;
path1='.\EVM_Matlab\compile\up_uncover_cover';
path2='.\';
f=fullfile(path1,'*.avi');
videoDir = dir(f);
number = 1;
TVBS=[];
for i = 1 : length(videoDir)
    f = fullfile(path1,videoDir(i).name);
    obj=VideoReader(f);
    numFrames=obj.NumFrames;
    for k=1:1:numFrames
        img=read(obj,k);
%         graypic=rgb2gray(img);
        graypic = img(: , : , 1)*1.20-img(: , : , 2)*0.90-img(: ,: , 3)*0.90;
%         graypic = max(max(img(: , : , 1),img(: , : , 2)),img(: ,: , 3));
%         graypic = (img(: , : , 1)+img(: , : , 2)+img(: ,: , 3))/3;

        graypic = uint8(graypic);
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
        
        img_dct = zeros(row, col); 
        for m=1:8:row-7
            for n=1:8:col-7
                img_block = img(m:m+7, n:n+7);
                TVB=sum(sum(diff(img_block,1,1)))+sum(sum(diff(img_block,1,2)));
                
                a=tabulate(img_block(:));
                b=sum(a(:,3).^2)/10000;
                
                s=fftshift(fft2(img_block));
                [M,N]=size(s);
                H = zeros(M,N);
                n1=floor(M/2); 
                n2=floor(N/2);
                d0=40;
                for h=1:M
                    for l=1:N
                        d=sqrt((h-n1)^2+(l-n2)^2);
                        g = double(d<=d0); 
                        s(h,l)=g*s(h,l);     
                    end
                end
                s=ifftshift(s);
                s=uint8(real(ifft2(s)));
                a1=tabulate(s(:));
                b1=sum(a1(:,3).^2)/10000;
                en=b1/b;
                img_double(m:m+3, n:n+7) = TVB;
                img_double(m+3:m+7, n:n+7) = en;
%                 dct_block = dct2(img_block); 
%                 imshow(dct_block); 
%                 img_dct(m:m+7, n:n+7) = dct_block;
            end
        end

%         TVB=sum(sum(diff(graypic,1,1)))+sum(sum(diff(graypic,1,2)));
%         TVBS(end+1)=TVB;
        %1.2 -0.9 -0.9
%         imgName = num2str(number,'%05d');
%         front = 'moto-images-003-';
%         FullName = [front imgName '.jpg'];
%         f2 = fullfile(path2,FullName);
%         imwrite(dfpic,f2);
        number = number + 1;
    end
end
imshow(TVBS)
