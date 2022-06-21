classdef MUSICDetector
    
    properties
        nMics;
        nSources;
        signals;
        tArray;
        distanceBetweenMics;
        Fs;
        c;
        phases;
    end
    
    
    methods
       %Algo importante, en MUSIC el número de fuentes debe ser menor al
       %número de MICS. 
        function obj = MUSICDetector(nSources, signals, tArray, distanceBetweenMics, phases)
            %Se da un arreglo de señales, donde las columnas corresponden a
            %distintos micrófonos
            obj.nMics = size(signals, 2);
            obj.nSources = nSources;
            obj.signals = signals;
            obj.tArray = tArray;
            obj.distanceBetweenMics = distanceBetweenMics;
            obj.Fs = 1/(tArray(2) - tArray(1));
            obj.c = 343;
            
            %Aplicamos una ventana a las señales
            %windowCalculator = WindowCalculator();
            %hannWindow = windowCalculator.getWindow(WindowType.HANNING, size(obj.signals, 1));
            %for i = 1:size(obj.signals, 2)
               %obj.signals(:,i) = obj.signals(:,i).*hannWindow'; 
            %end
           
            if(phases == -1)
                obj.phases = zeros(nMics, 1);
            else
                obj.phases = phases;
            end
        end
        
        
        
        function covMatrix = getCovarianceMatrix(obj, samples)
           covMatrix = 0;
           N = length(samples);
           for i = 1:N
               vec = conj(obj.signals(samples(i),:))';
               prod = vec*vec';
               covMatrix = covMatrix + (1/N)*prod;
           end
          
        end
        
        function nullMatrix = getNullMatrix(obj, samples)
            covMatrix = obj.getCovarianceMatrix(samples);
            %disp("Covariance Matrix");
            %disp(covMatrix);
            [eigVectors, eigValsMatrix] =  eig(covMatrix);
            
            eigenValues = zeros(size(eigValsMatrix,1), 1);
            for i = 1:size(eigValsMatrix,1)
               eigenValues(i) = real(eigValsMatrix(i,i)); 
            end
            
            [sortedEigs, indexes] = sort(eigenValues);
            sortedEigs = flip(sortedEigs);
            indexes = flip(indexes);
            %disp("Eigen values");
            %disp(sortedEigs);
            %Ordenamos los eigenvectores acorde 
            eigVectors = eigVectors(:,indexes);
            
            %disp(eigVectors);
            %Tomamos los eigenvectores desde nSources al fina
            nullMatrix = eigVectors(:,obj.nSources+1:end);
            %for i = 1:size(nullMatrix,2)
              % nullMatrix(:,i) = nullMatrix(:,i)/norm(nullMatrix(:,i)); 
            %end
            %Null Matrix
            %disp("Null matrix");
            %disp(nullMatrix);
            
        end
        
        function [angles, freqs, timeDelays, musicSpectrum] = getMusicSpectrum(obj, minFreq, maxFreq, angleMin, angleMax)
            %Direcciones que se van a probar
            %angles = -90:0.1:90;
            angles = linspace(angleMin,angleMax, 2000);
            %Matriz del espacio nulo
            samples = [];
            fftCalculator = FFTCalculator();
            [freqs, ~] = fftCalculator.getFFT(obj.signals(:,1), obj.tArray);
            for i = 1:length(freqs)
               if(freqs(i)>= minFreq && freqs(i)<= maxFreq)
                  samples = [samples, i]; 
               end
               if(freqs(i)>maxFreq)
                   break;
               end
            end
            
            nullSpaceMatrix = obj.getNullMatrix(samples);
            
            freqs = freqs(samples);
            
            timeDelays = cosd(angles)*obj.distanceBetweenMics/obj.c;
            
            musicSpectrum = zeros(length(freqs),length(angles));
            wb = waitbar(0, "Obteniendo espectro");
        
            for i = 1:length(angles)
                waitbar(i/length(angles), wb, "Obteniendo espectro");
                
                for j = 1:length(freqs)
                    w = [];
                    lambda = obj.c/freqs(j);
                    for k = 1:obj.nMics
                       %w = [w; exp(-2*pi*1j*timeDelays(i)*freqs(j)*(k-1))];
                       
                       if(obj.phases(k) == 0)
                            w = [w; exp(-2*pi*(1i)*sind(angles(i))*(k-1)*obj.distanceBetweenMics/lambda)];
                       else
                            w = [w; exp(-2*pi*(1i)*sind(angles(i) + obj.phases(k))*obj.distanceBetweenMics/lambda)];
                       end
                    end
                    
                    if(i == length(angles)/2&& j == length(freqs)/2)
                       disp(w);
                    end
                    musicSpectrum(j, i) = abs(1/(((w')*(nullSpaceMatrix*nullSpaceMatrix')*w)));
                end
            end
            close(wb)
            
        end
        
        
        
        function [dirs, timeDelays] = getSourcesDirections(obj, minFreq, maxFreq, angleMin, angleMax)
           [angles, freqs,times, musicSpectrum] = obj.getMusicSpectrum(minFreq, maxFreq, angleMin, angleMax);
           meanSpectrum = mean(musicSpectrum, 1);
           utilities = Utilities();
           [angles, localMaxima] = utilities.getLocalMaxima(meanSpectrum, angles);
           
           [sortedMaxima, sortIndexes] = sort(localMaxima);
           sortIndexes = flip(sortIndexes);
           finalIndexes = [];
           minAngleDiff = 1;
           
           finalIndexes = [finalIndexes,sortIndexes(1)];
           for i = 2:length(sortIndexes)
               if(abs(angles(sortIndexes(i)) - angles(sortIndexes(i-1)))> minAngleDiff)
                   finalIndexes = [finalIndexes, sortIndexes(i)];
               end
           end
           
           dirs = angles(finalIndexes(1:obj.nSources));
           timeDelays = obj.getTimeDelays(dirs);
        end
        
        function timeDelays = getTimeDelays(obj, dirs)
           timeDelays = zeros(obj.nMics, length(dirs));
           for i = 1:length(dirs)
              dir = dirs(i);
              for j = 1:obj.nMics
                  if(obj.phases(j) == 0)
                      timeDelay = sind(dir)*(j-1)*obj.distanceBetweenMics/obj.c;
                      timeDelays(j,i) = timeDelay;
                  else
                      timeDelay = sind(dir + obj.phases(j))*obj.distanceBetweenMics/obj.c;
                      timeDelays(j,i) = timeDelay;
                  end
                  
              end
           end
        end
        
        function avgFreq = getAverageFrequencyForDirection(obj, spectrum, dir, angles, freqs)
            dirIndex = 0;
            for i = 1:length(angles)
               if(angles(i) == dir)
                  dirIndex = i; 
                  break;
               end
            end
            spectrumDir = spectrum(:,dirIndex);
            spectrumDir = spectrumDir/sum(spectrumDir);
            avgFreq = 0;
            for i = 1:length(spectrumDir)
                avgFreq = avgFreq + spectrumDir(i)*freqs(i);
            end
            
        end
        
        
        
        
        
        
        
        
    end
    
    
end