%% This code is so that RKELM, the best model for sediment transport, can be easily used by planners.
% Sediment data should be distributed in columns. 
% The data should be such that the first column is Cv, the second  is Dgr,
% the third  is d / R,  the fourth  is lambda and the fifth is P/B.

%Enes Gul and Mir Jafar Sadegh Safari

%2020

load rkelm.mat % for model informations.

load data.mat % Sediment data.  Variable name should be input.

input1=input(:,1)';
[xf] = mapminmax('apply',input1,PS1);
I2(:,1)=xf;

input2=input(:,2)';
[xf] = mapminmax('apply',input2,PS2);
I2(:,2)=xf;

input3=input(:,3)';
[xf] = mapminmax('apply',input3,PS3);
I2(:,3)=xf;

input4=input(:,4)';
[xf] = mapminmax('apply',input4,PS4);
I2(:,4)=xf;

input5=input(:,5)';
[xf] = mapminmax('apply',input5,PS5);
I2(:,5)=xf;

input=I2;

Predicteddata=rkelm.predict(input);

Predicteddata=mapminmax('reverse',Predicteddata',PS6);



