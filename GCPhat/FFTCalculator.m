classdef FFTCalculator
    
    
    methods 
        
        function [freqs, transform] = getFFT(obj, signal, tArray)
            deltaT = tArray(2) - tArray(1);
            Fs = 1/deltaT;
            N = length(tArray);
            transform = fft(signal);
            freqs = (1:length(transform))*Fs/N;
        end
        
        function [tArray, signal] = getIFFT(obj, fftSignal, freqs)
            
            Fs = freqs(end);
            signal = ifft(fftSignal);
            N = length(freqs);
            deltaT = 1/Fs;
            tArray = (0:length(freqs) - 1)*deltaT;
            
        end
        
    end
    
    
end