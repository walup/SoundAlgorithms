classdef WindowCalculator
    
    methods
        function w = getWindow(obj, windowType, nPoints)
            n = 0:nPoints-1;
            if(windowType == WindowType.HANNING)
                w = 0.5*(1 - cos(2*pi*n/(nPoints -1)));
            elseif(windowType == WindowType.BLACKMAN)
                w = 0.42 - 0.5*cos(2*pi*n/(nPoints - 1)) + 0.08*cos(4*pi*n/(nPoints - 1));
            elseif(windowType == WindowType.HAMMING)
                w = 0.54 - 0.46*cos(2*pi*n/(nPoints - 1));
            elseif(windowType == WindowType.KAISER)
                beta = 5;
                w = besseli(0, beta*sqrt(1 - ((n-nPoints/2)/(nPoints/2)).^(2)))/besseli(0,beta);
            end
        end
    end
    
    
end