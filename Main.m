%% MAIN CODE FOR ADAPTIVE ENSEMBLE CLASSIFICATION
% Author: Kha Vo.
% Date: March 2017.

%%%%
clear all; close all
setpath
testpath = '';

%% ----------------------------------------
%% AKIMPECH CLASSIFICATION
%----------------------------------------
 typedataset = 'Akimpech';
subject={%'ACS' 'APM' 'ASG' 'ASR'  'CLL' 'DCM' 'DLP'  'DMA' 'ELC' 'FSZ' ...
    'GCE' 'ICE' 'IZH' 'JCR' 'JLD' 'JLP' 'JMR' 'JSC' ...
            'JST' 'LAC' 'LAG' 'LGP' 'PGA' 'WFG' 'XCL'...
    };
          % 'LORONUBEGANJA' ... (JCRR02_1, khong hoi tu, file Tam remove)
 correct_result_Akimpech={%'PERASALONPERRO' 'COMIDACOCINACARPA' 'CENARCOLORDULCES'...
%                 'SUENONACHO_THAT_IS_OK' 'NARANJACUARENTENAROSA' ...
%                 'SOBORDE_TUCONEJITOHIERRO' 'CABALLOECLIPSEGATO' ...
%                 'BCICUBOPIXEL' 'CASCODOQUOTEPRINCE' 'ROMACORALRELOJ' ...
                'CASTABATCHROCA' 'AUTOCLAVEZETASHIELO' '1987JUN19YOUBIOMEDICA'...
                'LOROUBEGANJA' ...
                'HOLAFEOPAULA' 'LAPICEROLIBROBANCO' ...
                'PERROBARCOTIMON1' ...
                'GATOLAPIZBOTON' 'ZUKYMAYTEAZUL' 'LAURADANZACASA' ...
                'DORMIRQUIERO_COCAHAMBRE' ...
                'VITALFUERZAPARAMETRO' 'TRIPTOFANOAGUAPAVEL' 'UAM_IINGENIERIABIOMEDICA'...
                'GATOPEZPERRO' ...
                };
iter_all = cell(length(subject), 1);
letter_all = cell(length(subject), 1);
nb_sub = 0;

fileclassifier=load('New_Predictor_3');


%for sub = subject
    nb_sub = nb_sub + 1;
    
    nb_sub = 1;
    sub = subject(1);
    
    fprintf(['Subject ' char(sub) ' (' num2str(nb_sub) ')' '\n'])
    files_dir = dir(['./preprocesseddata/TestCharacters/Akimpech/' char(sub) '*.mat']); 
    for j=1:length(files_dir)
        filet{j} =files_dir(j).name;
    end
    
    classifiers = fileclassifier.classifier;
    
    for file = filet
    filetest = load(['./preprocesseddata/TestCharacters/Akimpech/' char(file)]);
    x = filetest.x; 
    code = filetest.code;
    
    [iter, letter, row, col]  = Dynamic_Classify_Letter(x, code, classifiers, typedataset);
    iter_all{nb_sub} = [iter_all{nb_sub}; iter];
    letter_all{nb_sub} = [letter_all{nb_sub} letter];
    
    %adaptive update
%         x_new = x(1:iter*12,:); codet = code(1:iter*12);
%         y_new = -1*ones(size(x_new,1),1);
%         y_new(codet==row) = 1; y_new(codet==col+6) = 1;
%          for k = 1:length(classifiers)
%              classifiers(k) = svmincrement(x_new, y_new, classifiers(k));
%          end
         
    end
    perf(nb_sub) = sum(letter_all{nb_sub}==correct_result_Akimpech{nb_sub})/length(files_dir);
    
    clear filet
    g=sprintf('%.2f  ', iter_all{nb_sub});
    fprintf('%s\n', g) 
    
%end

