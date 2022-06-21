classdef ToolBox
   methods
       function mag = getVectorMagnitude(obj, vector)
          mag = 0;
          for i = 1:length(vector)
             mag = mag + vector(i)^2; 
          end          
          mag = sqrt(mag);
       end
       
       function index = getMaxIndex(obj, signal)
          index = 0;
          max = -Inf;
          for i = 1:length(signal)
              if(signal(i) > max)
                 index = i; 
                 max = signal(i);
              end
          end
       end
       
       function [index, max] = getMaxIndexRestricted(obj, signal, Fs, maxTime)
           maxIndex = floor(Fs*maxTime);
           index = 0;
           max = -Inf;
           for i = 1:maxIndex
              if(signal(i) > max)
                 max = signal(i);
                 index = i;
              end
           end
           
           for i = length(signal) - maxIndex + 1:length(signal)
              if(signal(i) > max)
                 max = signal(i);
                 index = i;
              end
           end
           
       end
       
       function centeredSignal = centerSignal(obj, signal)
           meanSignal = mean(signal);
           centeredSignal = signal - meanSignal;
       end
       
       
   end
    
    
end