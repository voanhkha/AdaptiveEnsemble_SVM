% Author: Kha Vo.
% Date: March 2017.
% Usage: group the first i files of each subject and save
% Output: files ACS_group_3,6,9,12,15; APM_group_3,6,... created

subject={'ACS' 'APM' 'ASG' 'ASR'  'CLL' 'DCM' 'DLP'  'DMA' 'ELC' 'FSZ' ...
    %'GCE' 'ICE' 'IZH' 'JCR' 'JLD' 'JLP' 'JMR' 'JSC' ...
    %        'JST' 'LAC' 'LAG' 'LGP' 'PGA' 'WFG' 'XCL'...
    };
for i = [3 6 9 12 15]
   for sub = subject
        for j = 1:i
           files{j} = [char(sub) '_char' num2str(j)]; 
        end
        join_mat_files(dir, files, [char(sub) '_group_' num2str(i)])
   end
end