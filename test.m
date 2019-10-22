%% this is main part of entire codes
clear all;
addpath(genpath(pwd))
file = 'usps1'
load(file);

T = max(test_y); % the number of classes
d = size(test_x,2); % the number of features

% when use validation set
if(0)
test_x = val_x;o
test_y = val_y;
end
% add bias term;
train_x = [ train_x ones(size(train_x,1),1) ];
test_x = [ test_x ones(size(test_x,1),1) ];


%% learn single task model.
disp('learn old model');
lambda = 0.1; %Hyper parameter for sing le task learning (p)
W_old = learn_old(train_x,train_y,lambda);
[maximum_old pred_old ac_old] = predict(W_old,test_x,test_y);

disp('training without beta and result about that');
disp(ac_old);



%% learn amtl model

delta=zeros(T,1);

lambda_ridge =0.05; %Hyper parameter for amtl (p)
sigma = 0;
[max_stl pred_stl ac_stl perclass_stl] = predict(W_old,test_x,test_y);
ac_stl
W_lasso = W_old; %initialize the W;

W_opt = W_lasso;

param.lambda = lambda_ridge;
param.lambda2 = T;
param.sigma = sigma; % Used in case of imbalanced dataset if not, then 0 (p)
param.sf = 1; % Used in case of imbalanced dataset if not, then 1 (p)
param.c_t = zeros(T,1);

B_lasso = zeros(T-1,T); % B without t-th task
B_lasso_full = zeros(T,T); %B
EPS = 0.00001;
diff1 = 1; diff2=1;

MaxIter = 3; %Maximum alteration (p)
iter = 1;
param.stl = 0;
if (param.stl)
	MaxIter = 2;
end
J_arr = [];
n_t = zeros(T,1);
for t = 1:T;
    n_t(t) = length(find(train_y == t));
    param.c_t(t) = param.sf/n_t(t)^param.sigma;
end
ac_cell = zeros(MaxIter,1); B_cell = cell(MaxIter,1); W_cell = cell(MaxIter,1); pred_cell = cell(MaxIter,1);
J_opt = Inf;

    J_lasso = cal_loss(W_lasso,W_lasso,B_lasso_full,train_x,train_y,lambda_ridge,0,'lasso',param);
    J_arr = [J_arr J_lasso];
    subplot(1,3,2);
    hold on
    plot(J_arr,'rx');
   for t = 1:T
       delta(t) = general_loss(W_lasso,train_x,train_y,0,lambda_ridge,t,'amtl_general') ;
   end
       	B_lasso_full = learnB(W_lasso,delta,param);
		param.B = B_lasso_full;    
        
