% Author: Kha Vo.
% Date: March 2017.
% USAGE: 

function [iter, classified_letter, row, col] = Dynamic_Classify_Letter(x, ...
    stimuli_code, classifiers, typedataset)

theta_1_tilde = 1;
theta_2_tilde = 3;

iter = 0;
s_row = zeros(6,1); s_col = zeros(6,1);
s_row_indi= zeros(6, length(classifiers)); s_col_indi = s_row_indi;
stopflag = 0;

while stopflag==0
   M = zeros(6,6);
   iter = iter+1;
   xt = x((iter-1)*12+1:iter*12,:);
   code_t = stimuli_code((iter-1)*12+1 : iter*12);
   
      [yt, yt_individual]=Ensemble_Score_Vector(classifiers,xt);
   
    for index = 1:6
        s_row(index) = s_row(index) + yt(code_t==index);
        s_col(index) = s_col(index) + yt(code_t==index+6);
        s_row_indi(index,:) = s_row_indi(index,:) +  yt_individual(code_t==index,:);
        s_col_indi(index,:) = s_col_indi(index,:) +  yt_individual(code_t==index+6,:);
    end
    
    for p = 1:length(classifiers)
        [~,r] = max(s_row_indi(:,p));
        [~,c] = max(s_col_indi(:,p));
        M(r,c) = M(r,c) + 1;
    end
    
    denomi_theta_1 = (1/6)*(sum(s_row-min(s_row)) + sum(s_col-min(s_col))); %denominator of theta_1
    nomi_theta_1 = max(s_row) - max(s_row(s_row<max(s_row)))...
            + max(s_col) - max(s_col(s_col<max(s_col))); %nominator of theta_1
    theta_1 = nomi_theta_1 / denomi_theta_1;
    [theta_2, maxindex] = max(M(:));
          
    [~, r1] = max(s_row); 
    [~, c1] = max(s_col);
    [r2, c2] = ind2sub(size(M),maxindex);
    
    if iter == 15
        stopflag = 1;
    end
    if (theta_1 >= theta_1_tilde && theta_2 >= theta_2_tilde && r1==r2 && c1==c2)
            stopflag = 1;
    end
   
end

switch typedataset
    case 'BCI2'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_']';
    case 'BCI3'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_']';
    case 'Akimpech'
        matrix=['ABCDEF';'GHIJKL';'MNOPQR';'STUVWX';'YZ1234';'56789_'];
end

classified_letter = matrix(r1, c1);
row = r1; col = c1;

end