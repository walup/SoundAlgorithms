classdef AudioCooker
    
methods
    
    function [cutTimes, cutSignal] = cutSignal(obj, signal, tArray, tStart, tEnd)
        Fs = 1/(tArray(2) - tArray(1));
        sizeCut = round((tEnd - tStart)*Fs);
        cutSignal = zeros(sizeCut, 1);
        disp(sizeCut);
        cutTimes = linspace(0, tEnd - tStart, sizeCut);
        counter = 1;
        for i  = 1:length(signal)
            time = tArray(i);
            if(time >= tStart && time <= tEnd && counter <= length(cutSignal))
                cutSignal(counter) = signal(i);
                counter = counter +1;
            elseif(time > tEnd)
                break;
            end
        end
    end
    
    
    function [tCut, signalCut] = cutByThreshold(obj, signal, tArray, threshold, recordTime)
        tCut = [];
        signalCut = [];
        tStart = -1;
        tEnd = -1;
        for i = 1:length(signal)
           value = abs(signal(i));
           if(value > threshold)
              tStart = tArray(i);
              tEnd = tStart + recordTime;
              break;
           end
        end
        
        if(tStart ~= -1 && tEnd ~= -1)
           [tCut, signalCut] = obj.cutSignal(signal,tArray, tStart, tEnd); 
        end
    end
    
    
    
    
end
    
end
