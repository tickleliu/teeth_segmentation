function [cout,marked_img]=corner(varargin)


%   CORNER Find corners in intensity image. 
%   
%       CORNER works by the following step:
%       1.	Apply the Canny edge detector to the gray level image and obtain a
%       binary edge-map.
%       2.	Extract the edge contours from the edge-map, fill the gaps in the
%       contours.
%       3.	Compute curvature at a low scale for each contour to retain all
%       true corners.
%       4.	All of the curvature local maxima are considered as corner
%       candidates, then rounded corners and false corners due to boundary
%       noise and details were eliminated.
%       5.  End points of line mode curve were added as corner, if they are not
%       close to the above detected corners.
%
%       Syntax :    
%       [cout,marked_img]=corner(I,C,T_angle,sig,H,L,Endpiont,Gap_size)
%
%       Input :
%       I -  the input image, it could be gray, color or binary image. If I is
%           empty([]), input image can be get from a open file dialog box.
%       C -  denotes the minimum ratio of major axis to minor axis of an ellipse, 
%           whose vertex could be detected as a corner by proposed detector.  
%           The default value is 1.5.
%       T_angle -  denotes the maximum obtuse angle that a corner can have when 
%           it is detected as a true corner, default value is 162.
%       Sig -  denotes the standard deviation of the Gaussian filter when
%           computeing curvature. The default sig is 3.
%       H,L -  high and low threshold of Canny edge detector. The default value
%           is 0.35 and 0.
%       Endpoint -  a flag to control whether add the end points of a curve
%           as corner, 1 means Yes and 0 means No. The default value is 1.
%       Gap_size -  a paremeter use to fill the gaps in the contours, the gap
%           not more than gap_size were filled in this stage. The default 
%           Gap_size is 1 pixels.
%
%       Output :
%       cout -  a position pair list of detected corners in the input image.
%       marked_image -  image with detected corner marked.
%
%       Examples
%       -------
%       I = imread('alumgrns.tif');
%       cout = corner(I,[],[],[],0.2);
%
%       [cout, marked_image] = corner;
%
%       cout = corner([],1.6,155);
%
%
%   Composed by He Xiaochen 
%   HKU EEE Dept. ITSR, Apr. 2005
%
%   Algorithm is derived from :
%       X.C. He and N.H.C. Yung, ¡°Curvature Scale Space Corner Detector with  
%       Adaptive Threshold and Dynamic Region of Support¡±, Proceedings of the
%       17th International Conference on Pattern Recognition, 2:791-794, August 2004.
%   Improved algorithm is included in ¡°A Corner Detector based on Global and Local 
%   Curvature Properties¡±and submitted to Pattern Recognition. 


[I,C,T_angle,sig,H,L,Endpoint,Gap_size] = parse_inputs(varargin{:});

if size(I,3)==3
    I=rgb2gray(I); % Transform RGB image to a Gray one. 
end

tic
BW=edge(I,'canny',[L,H]);  % Detect edges
time_for_detecting_edge=toc
% BW = I;
tic
[curve,curve_start,curve_end,curve_mode,curve_num]=extract_curve(BW,Gap_size);  % Extract curves
time_for_extracting_curve=toc
cout = 0;
% tic
% cout=get_corner(curve,curve_start,curve_end,curve_mode,curve_num,BW,sig,Endpoint,C,T_angle); % Detect corners
% time_for_detecting_corner=toc
% 
% img=I;
% for i=1:size(cout,1)
%     img=mark(img,cout(i,1),cout(i,2),5);
% end
% marked_img=img;
% % figure(2)
% imshow(marked_img);
% title('Detected corners')
% imwrite(marked_img,'corner.jpg');


function [curve,curve_start,curve_end,curve_mode,cur_num]=extract_curve(BW,Gap_size)

%   Function to extract curves from binary edge map, if the endpoint of a
%   contour is nearly connected to another endpoint, fill the gap and continue
%   the extraction. The default gap size is 1 pixles.

[L,W]=size(BW);
BW1=zeros(L+2*Gap_size,W+2*Gap_size);
BW_edge=zeros(L,W);
BW1(Gap_size+1:Gap_size+L,Gap_size+1:Gap_size+W)=BW;
[r,c]=find(BW1==1);
cur_num=0;

while size(r,1)>0
    point=[r(1),c(1)];
    cur=point;
    BW1(point(1),point(2))=0;
    [I,J]=find(BW1(point(1)-Gap_size:point(1)+Gap_size,point(2)-Gap_size:point(2)+Gap_size)==1);
    while size(I,1)>0
        dist=(I-Gap_size-1).^2+(J-Gap_size-1).^2;
        [min_dist,index]=min(dist);
        point=point+[I(index),J(index)]-Gap_size-1;
        cur=[cur;point];
        BW1(point(1),point(2))=0;
        [I,J]=find(BW1(point(1)-Gap_size:point(1)+Gap_size,point(2)-Gap_size:point(2)+Gap_size)==1);
    end
    
    % Extract edge towards another direction
    point=[r(1),c(1)];
    BW1(point(1),point(2))=0;
    [I,J]=find(BW1(point(1)-Gap_size:point(1)+Gap_size,point(2)-Gap_size:point(2)+Gap_size)==1);
    while size(I,1)>0
        dist=(I-Gap_size-1).^2+(J-Gap_size-1).^2;
        [min_dist,index]=min(dist);
        point=point+[I(index),J(index)]-Gap_size-1;
        cur=[point;cur];
        BW1(point(1),point(2))=0;
        [I,J]=find(BW1(point(1)-Gap_size:point(1)+Gap_size,point(2)-Gap_size:point(2)+Gap_size)==1);
    end
        
    if size(cur,1)>(size(BW,1)+size(BW,2))/25
        cur_num=cur_num+1;
        curve{cur_num}=cur-Gap_size;
    end
    [r,c]=find(BW1==1);
    
end

for i=1:cur_num
    curve_start(i,:)=curve{i}(1,:);
    curve_end(i,:)=curve{i}(size(curve{i},1),:);
    if (curve_start(i,1)-curve_end(i,1))^2+...
        (curve_start(i,2)-curve_end(i,2))^2<=32
        curve_mode(i,:)='loop';
    else
        curve_mode(i,:)='line';
    end
    
    BW_edge(curve{i}(:,1)+(curve{i}(:,2)-1)*L)=1;
end
% figure(1)
imshow(~BW_edge)
title('Edge map')
% imwrite(~BW_edge,'edge.jpg');


function cout=get_corner(curve,curve_start,curve_end,curve_mode,curve_num,BW,sig,Endpoint,C,T_angle)

corner_num=0;
cout=[];

GaussianDieOff = .0001; 
pw = 1:30; 
ssq = sig*sig;
width = max(find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff));
if isempty(width)
    width = 1;  
end
t = (-width:width);
gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq); 
gau=gau/sum(gau);

for i=1:curve_num;
    x=curve{i}(:,1);
    y=curve{i}(:,2);
    W=width;
    L=size(x,1);
    if L>W
        
        % Calculate curvature
        if curve_mode(i,:)=='loop'
            x1=[x(L-W+1:L);x;x(1:W)];
            y1=[y(L-W+1:L);y;y(1:W)];
        else
            x1=[ones(W,1)*2*x(1)-x(W+1:-1:2);x;ones(W,1)*2*x(L)-x(L-1:-1:L-W)];
            y1=[ones(W,1)*2*y(1)-y(W+1:-1:2);y;ones(W,1)*2*y(L)-y(L-1:-1:L-W)];
        end
       
        xx=conv(x1,gau);
        xx=xx(W+1:L+3*W);
        yy=conv(y1,gau);
        yy=yy(W+1:L+3*W);
        Xu=[xx(2)-xx(1) ; (xx(3:L+2*W)-xx(1:L+2*W-2))/2 ; xx(L+2*W)-xx(L+2*W-1)];
        Yu=[yy(2)-yy(1) ; (yy(3:L+2*W)-yy(1:L+2*W-2))/2 ; yy(L+2*W)-yy(L+2*W-1)];
        Xuu=[Xu(2)-Xu(1) ; (Xu(3:L+2*W)-Xu(1:L+2*W-2))/2 ; Xu(L+2*W)-Xu(L+2*W-1)];
        Yuu=[Yu(2)-Yu(1) ; (Yu(3:L+2*W)-Yu(1:L+2*W-2))/2 ; Yu(L+2*W)-Yu(L+2*W-1)];
        K=abs((Xu.*Yuu-Xuu.*Yu)./((Xu.*Xu+Yu.*Yu).^1.5));
        K=ceil(K*100)/100;
               
        % Find curvature local maxima as corner candidates
        extremum=[];
        N=size(K,1);
        n=0;
        Search=1;
        
        for j=1:N-1
            if (K(j+1)-K(j))*Search>0
                n=n+1;
                extremum(n)=j;  % In extremum, odd points is minima and even points is maxima
                Search=-Search;
            end
        end
        if mod(size(extremum,2),2)==0
            n=n+1;
            extremum(n)=N;
        end
    
        n=size(extremum,2);
        flag=ones(size(extremum));
  
        % Compare with adaptive local threshold to remove round corners
        for j=2:2:n
            %I=find(K(extremum(j-1):extremum(j+1))==max(K(extremum(j-1):extremum(j+1))));
            %extremum(j)=extremum(j-1)+round(mean(I))-1; % Regard middle point of plateaus as maxima
            
            [x,index1]=min(K(extremum(j):-1:extremum(j-1)));
            [x,index2]=min(K(extremum(j):extremum(j+1)));
            ROS=K(extremum(j)-index1+1:extremum(j)+index2-1);
            K_thre(j)=C*mean(ROS);
            if K(extremum(j))<K_thre(j)
                flag(j)=0;
            end
        end
        extremum=extremum(2:2:n);
        flag=flag(2:2:n);
        extremum=extremum(find(flag==1));
        
        % Check corner angle to remove false corners due to boundary noise and trivial details
        flag=0;
        smoothed_curve=[xx,yy];
        while sum(flag==0)>0
            n=size(extremum,2);
            flag=ones(size(extremum)); 
            for j=1:n
                if j==1 & j==n
                    ang=curve_tangent(smoothed_curve(1:L+2*W,:),extremum(j));
                elseif j==1 
                    ang=curve_tangent(smoothed_curve(1:extremum(j+1),:),extremum(j));
                elseif j==n
                    ang=curve_tangent(smoothed_curve(extremum(j-1):L+2*W,:),extremum(j)-extremum(j-1)+1);
                else
                    ang=curve_tangent(smoothed_curve(extremum(j-1):extremum(j+1),:),extremum(j)-extremum(j-1)+1);
                end     
                if ang>T_angle & ang<(360-T_angle)
                    flag(j)=0;  
                end
            end
             
            if size(extremum,2)==0
                extremum=[];
            else
                extremum=extremum(find(flag~=0));
            end
        end
            
        extremum=extremum-W;
        extremum=extremum(find(extremum>0 & extremum<=L));
        n=size(extremum,2);     
        for j=1:n     
            corner_num=corner_num+1;
            cout(corner_num,:)=curve{i}(extremum(j),:);
        end
    end
end


% Add Endpoints
if Endpoint
    for i=1:curve_num
        if size(curve{i},1)>0 & curve_mode(i,:)=='line'
            
            % Start point compare with detected corners
            compare_corner=cout-ones(size(cout,1),1)*curve_start(i,:);
            compare_corner=compare_corner.^2;
            compare_corner=compare_corner(:,1)+compare_corner(:,2);
            if min(compare_corner)>25       % Add end points far from detected corners 
                corner_num=corner_num+1;
                cout(corner_num,:)=curve_start(i,:);
            end
            
            % End point compare with detected corners
            compare_corner=cout-ones(size(cout,1),1)*curve_end(i,:);
            compare_corner=compare_corner.^2;
            compare_corner=compare_corner(:,1)+compare_corner(:,2);
            if min(compare_corner)>25
                corner_num=corner_num+1;
                cout(corner_num,:)=curve_end(i,:);
            end
        end
    end
end


function ang=curve_tangent(cur,center)

for i=1:2
    if i==1
        curve=cur(center:-1:1,:);
    else
        curve=cur(center:size(cur,1),:);
    end
    L=size(curve,1);
    
    if L>3
        if sum(curve(1,:)~=curve(L,:))~=0
            M=ceil(L/2);
            x1=curve(1,1);
            y1=curve(1,2);
            x2=curve(M,1);
            y2=curve(M,2);
            x3=curve(L,1);
            y3=curve(L,2);
        else
            M1=ceil(L/3);
            M2=ceil(2*L/3);
            x1=curve(1,1);
            y1=curve(1,2);
            x2=curve(M1,1);
            y2=curve(M1,2);
            x3=curve(M2,1);
            y3=curve(M2,2);
        end
        
        if abs((x1-x2)*(y1-y3)-(x1-x3)*(y1-y2))<1e-8  % straight line
            tangent_direction=angle(complex(curve(L,1)-curve(1,1),curve(L,2)-curve(1,2)));
        else
            % Fit a circle 
            x0 = 1/2*(-y1*x2^2+y3*x2^2-y3*y1^2-y3*x1^2-y2*y3^2+x3^2*y1+y2*y1^2-y2*x3^2-y2^2*y1+y2*x1^2+y3^2*y1+y2^2*y3)/(-y1*x2+y1*x3+y3*x2+x1*y2-x1*y3-x3*y2);
            y0 = -1/2*(x1^2*x2-x1^2*x3+y1^2*x2-y1^2*x3+x1*x3^2-x1*x2^2-x3^2*x2-y3^2*x2+x3*y2^2+x1*y3^2-x1*y2^2+x3*x2^2)/(-y1*x2+y1*x3+y3*x2+x1*y2-x1*y3-x3*y2);
            % R = (x0-x1)^2+(y0-y1)^2;

            radius_direction=angle(complex(x0-x1,y0-y1));
            adjacent_direction=angle(complex(x2-x1,y2-y1));
            tangent_direction=sign(sin(adjacent_direction-radius_direction))*pi/2+radius_direction;
        end
    
    else % very short line
        tangent_direction=angle(complex(curve(L,1)-curve(1,1),curve(L,2)-curve(1,2)));
    end
    direction(i)=tangent_direction*180/pi;
end
ang=abs(direction(1)-direction(2));



function img1=mark(img,x,y,w)

[M,N,C]=size(img);
img1=img;

if isa(img,'logical')
    img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)=...
        (img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)<1);
    img1(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:)=...
        img(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:);
else
    img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)=...
        (img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)<128)*255;
    img1(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:)=...
        img(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:);
end


function [I,C,T_angle,sig,H,L,Endpoint,Gap_size] = parse_inputs(varargin);

error(nargchk(0,8,nargin));

Para=[1.5,162,3,0.35,0,1,1]; %Default experience value;

if nargin>=2
    I=varargin{1};
    for i=2:nargin
        if size(varargin{i},1)>0
            Para(i-1)=varargin{i};
        end
    end
end

if nargin==1
    I=varargin{1};
end
    
if nargin==0 | size(I,1)==0
    [fname,dire]=uigetfile('*.bmp;*.jpg;*.gif','Open the image to be detected');
    I=imread([dire,fname]);
end

C=Para(1);
T_angle=Para(2);
sig=Para(3);
H=Para(4);
L=Para(5);
Endpoint=Para(6);
Gap_size=Para(7);