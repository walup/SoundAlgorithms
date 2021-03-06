classdef DelayAndSumSeparator
    
    properties
        delays;
        nMics;
        nSources;
    end
    
    
    
   methods
       %Recibe un arreglo con el delay de cada microfono
       %Se incluye el de referencia que no tiene delays
       function obj = DelayAndSumSeparator(delays)
           obj.nMics = size(delays, 1);
           obj.nSources = size(delays, 2);
           obj.delays = delays;
           
       end
       
       %Aquí solo se separan dos fuentes
       function separatedSignal = separateSignal(obj, index, tArr, audioSignals)
          fftCalculator = FFTCalculator();
          [freqs, ~] = fftCalculator.getFFT(audioSignals(:,1), tArr);
          audioFFTs = zeros(size(audioSignals, 1), size(audioSignals,2));
          for i = 1:obj.nMics
             [~,audioFFTs(:,i)] = fftCalculator.getFFT(audioSignals(:,i), tArr); 
          end
          audioFFTs = transpose(audioFFTs);
          
          %Vamos a construir la matriz w
          W = zeros(obj.nMics,length(freqs));
          for i = 1:obj.nMics
             for j = 1:length(freqs)
                 W(i,j) = exp(-1i*2*pi*freqs(j)*obj.delays(i,index));
             end
          end
          
          separatedSignal = zeros(length(freqs), 1);
         for f = 2:length(freqs)
            separatedSignal(f) = W(:,f)'*audioFFTs(:,f)/obj.nMics;
         end
         
         separatedSignal = real(ifft(separatedSignal));
         
         
       end
       
       function separatedSignal = separateSignalWithSamples(obj, index, tArr, audioSignals, minFreq, maxFreq)
           fftCalculator = FFTCalculator();
           [freqs, ~] = fftCalculator.getFFT(audioSignals(:,1), tArr);
           
           samples = [];
           for i = 1:length(freqs)
              if(freqs(i)>= minFreq && freqs(i)<=maxFreq)
                 samples = [samples,i];
              end
           end
           
           %extendedSamples = [];
           %for i = 1:length(samples)
               %ind = length(freqs) - samples(i) + 1;
               %extendedSamples = [extendedSamples, ind];
           %end
           
          %samples = sort([samples, extendedSamples]);
          disp(length(samples))
          audioFFTs = zeros(size(audioSignals, 1), size(audioSignals,2));
          for i = 1:obj.nMics
             [~,transform] = fftCalculator.getFFT(audioSignals(:,i), tArr);
             audioFFTs(samples,i) = transform(samples); 
          end
          audioFFTs = transpose(audioFFTs);
          
          %Vamos a construir la matriz w
          W = zeros(obj.nMics,length(freqs));
          for i = 1:obj.nMics
             for j = 1:length(freqs)
                 W(i,j) = exp(-1i*2*pi*freqs(j)*obj.delays(i,index));
             end
          end
          
         separatedSignal = zeros(length(freqs), 1);
         for f = 2:length(freqs)
            separatedSignal(f) = W(:,f)'*audioFFTs(:,f)/obj.nMics;
         end
         separatedSignal = real(ifft(separatedSignal));
           
       end
       
       
   end
    
    
    
end