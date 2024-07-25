function [TVB,en] = smoke(img)
%img=imread('nosmoke.jpg');
graypic=rgb2gray(img);
graypic = uint8(graypic);
TVB=sum(sum(diff(graypic,1,1)))+sum(sum(diff(graypic,1,2)));
TVB=log(TVB);%14.9125
a=tabulate(graypic(:));
        %b=sum(a(:,3).^2)/10000;
b=sum((a(:,1)./255).^2.*a(:,3))/100;
        
f=double(graypic);
g=fft2(f);
g=fftshift(g);
[N1,N2]=size(g);
d0=5;
n1=fix(N1/2);
n2=fix(N2/2);
for i=1:N1
    for j=1:N2
        d=sqrt((i-n1)^2+(j-n2)^2);
        if d==0
            h=0;
        else
            h=1/(1+(d/d0)^(2*2));
        end
        result(i,j)=h*g(i,j);
    end
end
result=ifftshift(result);
X2=ifft2(result);
X3=uint8(real(X2));
%         imshow(uint8(X3));

a1=tabulate(X3(:));
%b1=sum(a1(:,3).^2)/10000;
b1=sum((a1(:,1)./255).^2.*a1(:,3))/100;
en=b1/b;%0.9260
if isnan(en)
    en=0;
end
end
