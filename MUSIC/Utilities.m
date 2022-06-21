classdef Utilities
   methods
       
       %Esta función supone que los incrementos de tiempo son constantes
       function derivative = getFirstDerivative(obj,signal, tArray)
           derivative = zeros(1,length(signal));
           extendedSignal = [0,0,signal];
           deltaT = tArray(2) - tArray(1);
           for i = 1:length(signal)
              der =  (4*extendedSignal(i + 1) - 3*extendedSignal(i) - extendedSignal(i + 2))*(1/(2*deltaT));
              derivative(i) = der;
           end
       end
       
       function derivative = getNthDerivative(obj,signal, tArray, n)
           derivative = signal;
           for i = 1:n
               derivative = obj.getFirstDerivative(derivative, tArray);
           end
       end
       
       function [localMaximaTimes, localMaximaValues] = getLocalMaxima(obj, signal, tArray)
          firstDerivative = obj.getFirstDerivative(signal, tArray);
          secondDerivative = obj.getNthDerivative(signal, tArray, 2);
          localMaximaValues = [];
          localMaximaTimes = [];
          for i = 2:length(signal) - 1
              if(firstDerivative(i - 1)*firstDerivative(i+1) < 0 && secondDerivative(i) < 0)
                  localMaximaValues = [localMaximaValues, signal(i)];
                  localMaximaTimes = [localMaximaTimes, tArray(i)];
              end
          end
       end
       
       function [localMinimaTimes, localMinimaValues] = getLocalMinima(obj, signal, tArray)
          firstDerivative = obj.getFirstDerivative(signal, tArray);
          secondDerivative = obj.getNthDerivative(signal, tArray, 2);
          localMinimaValues = [];
          localMinimaTimes = [];
          for i = 2:length(signal) - 1
             if(firstDerivative(i - 1)*firstDerivative(i + 1) < 0 && secondDerivative(i)>0)
                 localMinimaValues = [localMinimaValues, signal(i)];
                 localMinimaTimes = [localMinimaTimes, tArray(i)];
             end
          end
       end
       
       function [minTime, minValue] = getGlobalMinima(obj, signal, tArray)
          [localMinimaTimes, localMinimaValues] = obj.getLocalMinima(signal, tArray);
          candidateValues = [localMinimaValues, signal(1), signal(length(signal))];
          candidateTimes = [localMinimaTimes, tArray(1), tArray(length(signal))];
          
          minValue = Inf;
          minTime = 0;
          
          for i = 1:length(candidateValues)
             if(candidateValues(i) < minValue)
                 minValue = candidateValues(i);
                 minTime = candidateTimes(i);
             end
          end
       end
       
       function [maxTime, maxValue] = getGlobalMaxima(obj, signal, tArray)
           [localMaximaTimes, localMaximaValues] = obj.getLocalMaxima(signal, tArray);
           candidateValues = [localMaximaValues, signal(1), signal(length(signal))];
           candidateTimes = [localMaximaTimes, tArray(1), tArray(length(tArray))];
           
           maxValue = -Inf;
           maxTime = 0;
           for i = 1:length(candidateValues)
               if(candidateValues(i) > maxValue)
                  maxValue = candidateValues(i);
                  maxTime = candidateTimes(i);
               end
           end
       end
       
       
       
       
   end
    
    
end