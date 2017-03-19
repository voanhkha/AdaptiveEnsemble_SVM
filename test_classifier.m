function [resultlettre,resultlettre_blda, result]=test_classifier(fileclassifier,filet,...
    nbshotvec,typedataset, P3_coff, pP3_coff)
% USAGE Can change the third input to result or result_blda for SVM and
% BLDA score outputs
% Author: Kha Vo.
% Date: March 2017.
delta = 0; %adjacency coefficient
span=1;

switch typedataset
    case 'BCI2'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_'];
    case 'BCI3'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_'];
    case 'Akimpech'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_']';
end
nbilluminationperletter=180;

%VoteMatrix=cell(1,length(nbshotvec));
nberror=zeros(1,length(nbshotvec));
%fprintf('\n');
load(char(fileclassifier(1))) %load classifier for normal P300 classification with variable 'classifier'
b_blda = load(char(fileclassifier(2)));
b_blda = b_blda.b;
% load([fileclassifier '_pP3']) %load classifier for pre-P300 classification, with variable 'classifier_pP3'
nbclassifier=length(classifier);
kword=1;
nbcharacter=0;
resultlettre=[]; resultlettre_blda=[];
%SubB_SVM_Result = cell(size(filet,2),1);
filenb = 0;
for filen=filet % classify each spelling session (1 letter)
    filenb = filenb + 1;
    %fprintf('Character %d', (filenb)); fprintf('\n');
    xt=[];
    yt=[];
    %ADD THIS FOR OUTPUT: output_result_filepath = [char(filen) '-score']; %'Bt1-score', 'Bt2-score'....
    score = zeros(nbilluminationperletter, nbclassifier);
    yptestall=0;   yptestall_blda=0; 
    
    switch typedataset
    case 'BCI2'
      %   filen=['./preprocesseddata/TestCharacters/BCI2/' char(filen)];   
          filen=['./preprocesseddata/Train/BCI2/Chars/' char(filen)];   
    case 'BCI3'
        % filen=['./preprocesseddata/TestCharacters/BCI3/' char(filen) '-allfilt20'];   
         filen=['./preprocesseddata/Train/BCI3/Chars/' char(filen)];   
    case 'Akimpech'
    %    filen=['./preprocesseddata/TestCharacters/Akimpech/' char(filen)]; % DATA FILE
        filen=['./preprocesseddata/Train/Akimpech/SingleChars/' char(filen)]; % DATA FILE
    end
    
    load(filen)
    
    % nblettre=round(size(x,1)/nbilluminationperletter);
    vote=zeros(6,6,length(nbshotvec));
    %xt2=zeros(size(x,1),nbclassifier);
    %---------------------------------------------
    for ii=1:nbclassifier % total of 17 ensemble classifiers
        xt=x;
        xsup=classifier(ii).xsup;
        w=classifier(ii).w;
        b=classifier(ii).b;
        mnormalize=classifier(ii).mnormalize;
        stdnormalize=classifier(ii).stdnormalize;
        
%        xsup_pP3=classifier_pP3(ii).xsup;
  %      w_pP3=classifier_pP3(ii).w;
  %      b_pP3=classifier_pP3(ii).b;
   %     mnormalize_pP3=classifier_pP3(ii).mnormalize;
   %     stdnormalize_pP3=classifier_pP3(ii).stdnormalize;
        channel=classifier(ii).channel;
       % lengthperchannel=classifier(ii).lengthperchannel;
       % xt=KeepChannel(xt,channel,lengthperchannel);
        [~,xt]=normalize1([],xt,[],[],channel,triallength,mnormalize,stdnormalize,'normal');
%         [~,xt_pP3]=normalize1([],xt,[],[],channel,triallength,mnormalize_pP3,stdnormalize_pP3,'normal');
       
        if ~isfield(classifier,'kernel')  | ~isfield(classifier,'kerneloption')
            kernel='poly';
            kerneloption=1;
        else
            kernel=classifier(ii).kernel;
            kerneloption=classifier(ii).kerneloption;
        end;
        
        yptest=svmval(xt,xsup,w,b,kernel,kerneloption,span);

        yptest = adjacenting(yptest,code,delta);
        yptestall = yptestall + yptest; %yptestall: sum of all classifiers' scores
        
        yptest_blda = classify(b_blda(ii),xt');
        yptestall_blda = yptestall_blda + yptest_blda;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        score(:,ii) = yptest;
        score_blda(:,ii) = yptest_blda;%score: 180x17 individual scores of each classifier
        % in other words, score is the mean of yptestall
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        kk=1;
        for nbshot=nbshotvec
            [wordtest{ii,kk} votemat]=TestWord_Kha(yptest,code,nbshot,'sum',typedataset);
 %           fprintf('%s\t',wordtest{ii,kk}); %for each classifier output       
                [indlig,indcol]=find(matrix==wordtest{ii,kk});   
                vote(indlig,indcol,kk)= vote(indlig,indcol,kk) +1;                  
            kk=kk+1;
        end;
  %      fprintf('\n');
    end; 
  %  keyboard
   %  AUCall=svmroccurve(sign(yptestall),y)
    %----------------------------------------------------------------
     %ADD THIS FOR OUTPUT:save(output_result_filepath,'score','code');
    %----------------------------------------------------------------
     %fprintf('---------------Ensemble Vote --------------------\n');
    for kk=1:length(nbshotvec)
        wordvote=''   ; maxvalue = []; 
            [maxcol,indmaxcol]=max(max(vote(:,:,kk)));     
            [aux,indmaxlig]=max(max(vote(:,:,kk)'));  
            wordvote=strcat(wordvote,matrix(indmaxlig,indmaxcol));
            %maxvalue = [maxvalue, maxcol];
        %fprintf('%s\t',wordvote);  
        %fprintf('%s\n',num2str(maxvalue));  
    end;
    %fprintf('\n');
    %fprintf('---------------Sum Score--------------------\n');
    iternbshot=1;
    kkk=1;
    for nbshot=nbshotvec
        %%%%%%%% UNCOMMENT BELOW 2 LINES IF DO NOT USE ADJACENT Y%%%%%
        y_adjacented = adjacenting(yptestall,code,delta);
        [wordsum]=TestWord_Kha(y_adjacented,code,nbshot,'sum',typedataset);
        [wordsum_blda] = TestWord_Kha(yptestall_blda,code,nbshot,'sum',typedataset);
        %%%%%%% 
  %      fprintf('%s\t',wordsum);
        nberror(iternbshot)=nberror(iternbshot)+sum(char(target)~=wordsum);
        iternbshot=iternbshot+1;
        wordmat(kkk,:)=wordsum;
        wordmat_blda(kkk,:)=wordsum_blda;
        kkk=kkk+1;
    end;
 %   fprintf('| \t%s\t',target);
    %fprintf('\n-----------------------------------------------\n');
    resultlettre=[resultlettre wordmat];
    resultlettre_blda=[resultlettre_blda wordmat_blda];
    kword=kword+1;
    nbcharacter=nbcharacter+length(target);
    
    % VOANHKHA added code
    result{filenb} = score;
      result_blda{filenb} = score_blda;
%     result{filenb}.word_ensemble = wordtest;
%     result{filenb}.word_sum = wordmat;
%     result{filenb}.vote = vote;
end;

if nbcharacter~=0
    % Affichage Resultats si la lettre cible est connu
    for i=1:length(nbshotvec)
        fprintf('%d \t\t',nberror(i))
    end;
    fprintf('Number of errors : \n');
    for i=1:length(nbshotvec)
        fprintf('%2.2f \t',nberror(i)/nbcharacter)
        perf(i)=1-nberror(i)/nbcharacter;
    end;
    
end

end

