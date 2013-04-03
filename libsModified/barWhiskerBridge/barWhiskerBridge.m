function outHandle = barWhiskerBridge(inBar,inWhisker,inBridge, sigBar, colors, barNames, clusterNames)
%BARWHISKERBRIDGE creates a bar-and-whisker plot with bridges connecting
%related bars
%    OUTHANDLE = BARWHISKERBRIDGE( INBAR , INWHISKER , INBRIDGE ) outputs
%    the handle to an 'axes' containing a bar-and-whisker plot based on the
%    information in INBAR and INWHISKER; the plot is made in the currently
%    active axes.  INBAR and INWHISKER are N-by-M, where N is the number of
%    'clusters' and M is the number of bars within each 'cluster'.
%    INWHISKER determines how long the whiskers extend beyond the top of
%    the bars. If an element of either is NaN, the corresponding bar will not be made
%    INBRIDGE is an M-by-M-by-N array which contains
%    information on whether there is a significant relation between pairs
%    of bars within a cluster; a nonzero value means to make a bridge, and
%    integers greater than 1 lead to marking with asterisks (so 1 makes a
%    bridge, 2 makes a bridge with one asterisk, 3 makes a bridge with two
%    asterisks...). Only the upper half of each 2D 'slice' of the bridge
%    matrix is assessed.  Values in INBRIDGE are addressed as follows: each
%    M-by-M 'slice' of the matrix describes the Nth cluster; within a
%    slice, a given element describes the level of relationship between
%    bars in the Nth cluster (that is, (3,5,4) describes the level of
%    relationship to indicate between the 3rd and 5th bar in the 4th
%    cluster)

%aesthetics
%bridgeGap determines the minimum distance from the end of the whiskers to
%the start of the bridges
bridgeGap = 0.02*max(inBar(:)+inWhisker(:));
%bridgeStep determines the distance between one bridge connector and the
%next above it
bridgeStep = 0.03*max(inBar(:)+inWhisker(:));
%this value determines the additional step allocated for bridges which have
%additional markers
starGap = 0;
clusterNameGap = 0.07*max(inBar(:)+inWhisker(:));

%clear the current axes
cla

enn = size(inBar,1);
emm = size(inBar,2);

%number of possible bridges
bee = emm*(emm-1)/2;

%the amount to increase the height of bridges from previous bridges

%the current colormap?
colores = colormap;

%width of bars
Xwidth = 1/(emm+2);
%distance between bars
Xinterval = 1/(emm+1);
%set the offset for the first bar
Xoffset = Xinterval*(emm-1)/2;


%this keeps track of how high the plot ever gets
YtopMax = 0;
Xticks = [];

clusterMiddles = nan(enn, 1);

for iterCluster = 1:enn
    Xmiddles = NaN(emm,1);
    Ywhiskers = NaN(emm,1);
    
    %first make the bars
    for iterBar = 1:emm
        if ~isnan(inBar(iterCluster,iterBar)) && ~isnan(inWhisker(iterCluster,iterBar))
            XmiddleNow = (iterCluster-Xoffset+Xinterval*(iterBar-1));
            Xticks = [Xticks XmiddleNow];
            Ybar = inBar(iterCluster,iterBar);
            YwhiskerNow = Ybar + inWhisker(iterCluster,iterBar);
            rectangle('position',[ (XmiddleNow-Xwidth/2) , 0 , Xwidth , Ybar ],'edgecolor','none','facecolor', colors{iterCluster, iterBar});
            line( (XmiddleNow*ones(2,1)) , [Ybar;YwhiskerNow] ,'color',colors{iterCluster, iterBar},'linewidth',4);
            %line( (XmiddleNow + [-0.375 0.375]*Xwidth) , YwhiskerNow*ones(2,1) ,'color','k','linewidth',2)
            
            % add the significance stars to each bar
            if sigBar(iterCluster, iterBar) > 0
                text(XmiddleNow, YwhiskerNow+starGap, repmat('*', 1, sigBar(iterCluster, iterBar)), ...
                    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Color', 'k', 'FontSize', 14);
            end
        end
        Xmiddles(iterBar) = XmiddleNow;
        Ywhiskers(iterBar) = YwhiskerNow;
        
    end
    
    clusterMiddles(iterCluster) = mean(Xmiddles);
    
    Ywhiskers = Ywhiskers + bridgeGap;
    Ytops = Ywhiskers;
    YtopMax = max(YtopMax, max(Ywhiskers(:)));
    
    hold on
    
    %now fill in the bridges
    for iterOne = 2:emm
        for iterTwo = 1:(emm-iterOne+1)
            num1 = iterOne + iterTwo - 1;
            num2 = iterTwo;
            numL = min(num1,num2);
            numR = max(num1,num2);
            if inBridge(num1,num2,iterCluster) ~= 0
                Xl = Xmiddles(numL);
                Xr = Xmiddles(numR);
                Ytop = max(Ytops(numL:numR)) + bridgeStep;
                
                %now draw the bridge
                line( [Xl ; Xr] , Ytop*ones(2,1) ,'color','k','linewidth',1.5)
                line( Xl*ones(2,1) , [Ywhiskers(numL)+bridgeGap;Ytop] ,'color','k','linewidth',1.5)
                line( Xr*ones(2,1) , [Ywhiskers(numR)+bridgeGap;Ytop] ,'color','k','linewidth',1.5)
                
                %now add to the Ywhiskers to prevent bridge overlaps
                Ytops(numL:numR) = Ytop;
                YtopMax = max(YtopMax,Ytop);
                
                %now add the stars, if necessary
                if (inBridge(num1,num2,iterCluster) > 0) %%&& isinteger(inBridge(num1,num2,iterCluster))
                    nStars = inBridge(num1,num2,iterCluster);
                    %for iterStars = 1:(inBridge(num1,num2,iterCluster))
                        text((Xl+Xr)/2,(Ytop + starGap),repmat('*', 1, nStars), ...
                            'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Color', 'k', 'FontSize', 14)
                        %add to the new top for the relevant bars
                        Ytop = Ytop + starGap;
                        Ytops(numL:numR) = Ytop;
                        YtopMax = max(YtopMax,Ytop);
                    %end
                end
                
                
                
            end
        end
    end
end

minY = 0;
xlim([ (1-Xoffset-Xinterval) (enn+Xoffset+Xinterval) ])
ylim([minY (YtopMax+starGap)])
set(gca, 'XTick', Xticks, 'XTickLabel', barNames);

for iCluster = 1:enn
    text(clusterMiddles(iCluster), minY - clusterNameGap, clusterNames{iCluster}, ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', 'FontSize', 14);
end

outHandle = gca;





