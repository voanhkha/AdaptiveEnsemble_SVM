function modelselclassifier_Kha(DirInfo,file,Cvec,...
    kernel,kerneloptionvec,ClassifierName)
% Author: Kha Vo.
% Date: March 2017.
% USAGE

lambda=1e-6;
lambda_2=1e-8;
verbose=1;
span=1; 
classcode=[1 -1];

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
    
    filen= [DirInfo.pathdata fileapp '.mat'];
    load(filen)
    xaaux = x;
    yaaux = y;
    [xaaux,~,mnormalize,stdnormalize]=normalize1(xaaux,[],yaaux,[],[],[],[],[],'normal');
    
    %---------------------------------------------
    % create, read and save test data in temp file and in a single matrix
    %----------------------------------------
    yt=[];
    xtaux=[];
    for filen=filet
        filen= [DirInfo.pathdata char(filen)];
        load(filen)
        xtaux2=[x];
        yt=[yt;y]; 
        [~,xtaux1]=normalize1([],xtaux2,[],[],[],[],mnormalize,stdnormalize,'normal');
        xtaux=[xtaux;xtaux1];    
    end;
    clear xtaux2 xtaux1;
    %--------------------------------------------------------------------------------------------------------
    for iterC=1:length(Cvec)
        for iterK=1:length(kerneloptionvec)         
            C=Cvec(iterC);
            kerneloption=kerneloptionvec(iterK);        
                [xsup,w,b,~,~,~]=svmclass(xaaux,yaaux,C,lambda,kernel,kerneloption,verbose,span);                        
                yptest=[];
                yt=[];
                for filen=filet
                    filen = [DirInfo.pathdata char(filen)];
                    load(filen)
                    xtaux=[x];
                    yt=[yt;y]; 
                    [~,xtaux]=normalize1([],xtaux,[],[],[],[],mnormalize,stdnormalize,'normal');
                    yptest=[yptest;svmval(xtaux,xsup,w,b,kernel,kerneloption,span)];
                end;
                   
                [Conf,~]=ConfusionMatrix(sign(yptest),yt,classcode);
                ValueMaxCK{iterC,iterK}=Conf(1,1)/(Conf(1,1)+ Conf(2,1)+ Conf(1,2));
%             end;
                        
        end;
        save temp.mat
    end;
    % finding the best
    %
    maxi=-inf;
    for iterC=1:length(Cvec)
        for iterK=1:length(kerneloptionvec)
            if maxi < max(max(ValueMaxCK{iterC,iterK}))
                [maxi,~] = max(max(ValueMaxCK{iterC,iterK}));
                iterCmax=iterC;
                iterKmax=iterK;
       %         value = ValueMaxCK{iterC,iterK};
            end;
            
        end;
    end;
    C=Cvec(iterCmax);
    kerneloption=kerneloptionvec(iterKmax);
    filedata= [DirInfo.pathdata fileapp '.mat'];
    load(filedata)
    xa = x;  
   ya = y;

    if isempty(kernel) 
        kernel='poly';
    end;

    % xa=KeepChannel(xa,channel,lengthperchannel);
    [xa,~,mnormalize,stdnormalize]=normalize1(xa,[],y,[],[],[],[],[],'normal') ;
    if size(mnormalize,2)~=size(xa,2)
        keyboard    
    end;
    [xsup,w,b]=svmclass(xa,ya,C,lambda_2,kernel,kerneloption,verbose,span);

    classifier(itercrossval).xsup=xsup;
    classifier(itercrossval).w=w;
    classifier(itercrossval).b=b;
    classifier(itercrossval).C=C;
    classifier(itercrossval).mnormalize=mnormalize;
    classifier(itercrossval).stdnormalize=stdnormalize;
%     classifier(j).typedata=data.typedata;
    classifier(itercrossval).filename=char(file.app{itercrossval});
%    classifier(itercrossval).channel=channel;
%    classifier(itercrossval).lengthperchannel=lengthperchannel;
    classifier(itercrossval).kernel=kernel;
    classifier(itercrossval).kerneloption=kerneloption;
end;

    save(ClassifierName , 'classifier')





