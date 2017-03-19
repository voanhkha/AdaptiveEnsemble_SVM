%% create_classifiers
% Author: Kha Vo.
% Date: March 2017.
% Usage: create files Predictor_group_3,6,9,... 
% Each file created is the accumulated training files (by concat x and y)
% of the first 10 subjects.
% .._group_3 consists of training letters 1 to 3, _group_6 of 1 to 6....
 
%% BEGIN
Cvec = [0.25 0.5 0.75 1]; % tp
% kernel='poly';
% kerneloptionvec=1;
subject={'ACS' 'APM' 'ASG' 'ASR'  'CLL' 'DCM' 'DLP'  'DMA' 'ELC' 'FSZ' ...
    %'GCE' 'ICE' 'IZH' 'JCR' 'JLD' 'JLP' 'JMR' 'JSC' ...
    %        'JST' 'LAC' 'LAG' 'LGP' 'PGA' 'WFG' 'XCL'...
    };
DirInfo.pathdata='.\preprocesseddata\Train\Akimpech\Groups\';

for i = [3 6 9 12 15]
for no_sub = 1:length(subject)
    File.app{no_sub} = [char(subject{no_sub}) '_group_' num2str(i)];
end
cross_validation(DirInfo,File,Cvec,['New_Predictor_' num2str(i)]);
         clear File
end
%% END
