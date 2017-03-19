function cross_validation(DirInfo,file,Cvec,ClassifierName)
% Author: Kha Vo.
% Date: March 2017.
% USAGE
classcode=[1 -1];
classifier(length(file.app))=struct('a',[],'b',[],'C',[],...
    'g',[],'ind',[],'Q',[],'Rs',[],'X',[],'Y',[]...  
    ,'mnormalize',[],'stdnormalize',[] );
    
for itercrossval=1:length(file.app);

    %-------------------------------------------------------------
    %                           Creating Data
    %--------------------------------------------------------------
    
    fileapp = char(file.app{itercrossval});
    j=1;
    for k=1:length(file.app)
        if k~=itercrossval %exclude the file for cross-validation
            filet{j}=char(file.app{k});
            j=j+1;
        end;
    end;
    % construct train file at 1 partition: 'xaaux' and 'yaaux'
    filen= [DirInfo.pathdata fileapp '.mat'];
    load(filen)
    xaaux = x;
    yaaux = y;
    [xaaux,mnormalize,stdnormalize]=normalise(xaaux);
    
    %---------------------------------------------
    % create, read and save test data in temp file and in a single matrix
    %----------------------------------------
%     yt=[];
%     xtaux=[];
%     for filen=filet % construct test vectors from the other (n-1) partitions
%         filen= [DirInfo.pathdata char(filen)];
%         load(filen)
%         xtaux2=[x];
%         yt=[yt;y]; 
%         [xtaux1]=normalise(xtaux2,mnormalize,stdnormalize);
%         xtaux=[xtaux;xtaux1];    
%     end;
%     clear xtaux2 xtaux1;
    %--------------------------------------------------------------------------------------------------------
    for iterC=1:length(Cvec)
     %   for iterK=1:length(kerneloptionvec)         
            Ct=Cvec(iterC);
               % [xsup,w,b,~,~,~]=svmclass(xaaux,yaaux,C,lambda,kernel,kerneloption,verbose,span);                        
                newmodel = svm_newmodel(xaaux',yaaux,Ct,mnormalize,stdnormalize);   
                yptest=[];
                yt=[];
                for filen=filet
                    filen = [DirInfo.pathdata char(filen)];
                    load(filen)
                    xtaux=[x];
                    yt=[yt;y]; 
                    [xtaux]=normalise(xtaux,mnormalize,stdnormalize);
                    [f,~] = svmscore(xtaux');
                    yptest=[yptest;f];
                end; 
                [Conf,~]=ConfusionMatrix(sign(yptest),yt,classcode);
                ValueMaxCK{iterC}=Conf(1,1)/(Conf(1,1)+ Conf(2,1)+ Conf(1,2));
%             end;
                        
 %       end;
        save temp.mat
    end;
    % finding the best
    %
    maxi=-inf;
    for iterC=1:length(Cvec)
      %  for iterK=1:length(kerneloptionvec)
            if maxi < max(max(ValueMaxCK{iterC}))
                [maxi,~] = max(max(ValueMaxCK{iterC}));
                iterCmax=iterC;
               % iterKmax=iterK;
       %         value = ValueMaxCK{iterC,iterK};
            end;
            
       % end;
    end;
    Ct=Cvec(iterCmax);
    filedata= [DirInfo.pathdata fileapp '.mat'];
    load(filedata)
    xa = x;  
    ya = y;

%     if isempty(kernel) 
%         kernel='poly';
%     end;

    % xa=KeepChannel(xa,channel,lengthperchannel);
    [xa,mnormalize,stdnormalize]=normalise(xa) ;
   % if size(mnormalize,2)~=size(xa,2)
   %     keyboard    
  %  end;
    %[xsup,w,b]=svmclass(xa,ya,Ct,lambda_2,kernel,kerneloption,verbose,span);
    
    
%     cl.mnormalize=mnormalize;
%     cl.stdnormalize=stdnormalize;
%     cl.filename=char(file.app{itercrossval});
      classifier(itercrossval) = svm_newmodel(xa',ya,Ct,mnormalize,stdnormalize); 
%     classifier(itercrossval).mnormalize = mnormalize;
%     classifier(itercrossval).stdnormalize = stdnormalize;
end;

    save(ClassifierName , 'classifier')
