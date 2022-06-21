classdef GCPhatDirectionDetector
   properties
       tArray;
       signalMic1;
       signalMic2;
       Fs;
       soundSpeed;
       distanceBetweenMics;
       
   end
   
   
   
   methods
       
       function obj = GCPhatDirectionDetector(tArray, signalMic1, signalMic2, distanceBetweenMics)
           obj.tArray = tArray;
           windowCalculator = WindowCalculator();
           toolBox = ToolBox();
           window = windowCalculator.getWindow(WindowType.HANNING, length(signalMic1));
           obj.signalMic1 = signalMic1.*window';
           obj.signalMic2 = signalMic2.*window';
           obj.signalMic1= toolBox.centerSignal(obj.signalMic1);
           obj.signalMic2 = toolBox.centerSignal(obj.signalMic2);
           obj.Fs = 1/(tArray(2) - tArray(1));
           obj.soundSpeed = 343;
           obj.distanceBetweenMics = distanceBetweenMics;
           
       end
       
       function [dir, timeDelays, tArr, crossCorrelation] = getDirection(obj)
          tArr = obj.tArray;
          fftCalculator = FFTCalculator();
          [~,spectrum1] = fftCalculator.getFFT(obj.signalMic1, obj.tArray);
          [~,spectrum2] = fftCalculator.getFFT(obj.signalMic2, obj.tArray);
          tools = ToolBox();

          crossCorr = (spectrum1.*conj(spectrum2))./(abs(spectrum1.*conj(spectrum2)));
          crossCorrelation = real(ifft(crossCorr));
          
          maxSearchTime = obj.distanceBetweenMics/obj.soundSpeed;
          
          [maxIndex, maxVal] = tools.getMaxIndexRestricted(crossCorrelation, obj.Fs, maxSearchTime);
          disp(maxVal);
          if(maxIndex >= floor(length(crossCorrelation)/2))
              maxIndex = length(crossCorrelation) - maxIndex +1;
              disp("here");
          end
          
          timeDelay = tArr(maxIndex);
          %timeDelay = maxIndex*(1/obj.Fs);
          distanceDelay = obj.soundSpeed*timeDelay;
          dir = acos(distanceDelay/obj.distanceBetweenMics);
          dir = rad2deg(dir);
          timeDelays = [0, timeDelay];
       end
       
       
       
       
   end
    
    
    
end