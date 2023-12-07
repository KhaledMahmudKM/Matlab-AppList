function digital_signal=NRZcode(bitarray, sampleperbit)
%Non return to zero line code signal generator
% +1 V means 1
% -1 V means 1

n=1:sampleperbit;
t = 0:1/sampleperbit:1-1/sampleperbit; %time samples 
OneLevel=ones(1,sampleperbit);   
ZeroLevel=-ones(1,sampleperbit);

digital_signal=[];

for i=1:length(bitarray)
    if(bitarray(i)==1)
        digital_signal=[digital_signal OneLevel];
    else
        digital_signal=[digital_signal ZeroLevel];
    end
        
end




    
    