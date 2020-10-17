% RKELM - Reduced Kernel Extreme Learning Machine Class
%   Train and Predict a SLFN based on Reduced Kernel Extreme Learning Machine
%
%   This code was implemented based on the following paper:
%
%   [1] Deng W., Zheng Q., Zhang K, Reduced Kernel Extreme Learning Machine, 
%       In: Burduk R., Jackowski K., Kurzynski M., Wozniak M., 
%       Zolnierek A. (eds) Proceedings of the 8th International Conference 
%       on Computer Recognition Systems CORES 2013, 2013. Advances in Intelligent 
%       Systems and Computing, vol 226. Springer, Heidelberg
%       https://doi.org/10.1007/978-3-319-00969-8_6
%       (https://link.springer.com/chapter/10.1007%2F978-3-319-00969-8_6)
%
%   Attributes: 
%       Attributes between *.* must be informed.
%       RKELM objects must be created using name-value pair arguments (see the Usage Example).
%
%                    kernelType:   Function that defines kernel  
%                Accepted Values:   one of these strings (function handles will be supported in the future):
%                                       'RBF_kernel':     Radial Basis Function (default)
%                                       'lin_kernel':     Linear
%                                       'poly_kernel':    Polynomial
%                                       'wav_kernel':     Wavelet
%
%                   kernelParam:   Kernel Parameter 
%                Accepted Values:   Any positive real number (defaut = 0.1).
%
%       regularizationParameter:   Regularization Parameter 
%                Accepted Values:   Any positive real number (defaut = 1000).
%
%          numberOfHiddenNeurons:   Number of neurons in the hidden layer
%                Accepted Values:   Any positive integer (defaut = 1000).
%
%                         seed:     Seed to generate the pseudo-random values.
%                                   This attribute is for reproducible research.
%              Accepted Values:     RandStream object or a integer seed for RandStream.
%
%       Attributes generated by the code:
%
%                            xTr:   Training data (defined when the model is trained).
%
%                   outputWeight:   Weight matrix that connects the hidden
%                                   layer to the output layer
%
%                        support:   Index of (original) X samples used as support
%
%   Methods:
%
%          obj = RKELM(varargin):   Creates RKELM objects. varargin should be in
%                                   pairs. Look attributes
%
%           obj = obj.train(X,Y):   Method for training. X is the input of size N x n,
%                                   where N is (# of samples) and n is the (# of features).
%                                   Y is the output of size N x m, where m is (# of multiple outputs)
%                            
%          Yhat = obj.predict(X):   Predicts the output for X.
%
%   Usage Example:
%
%       load iris_dataset.mat
%       X    = irisInputs';
%       Y    = irisTargets';
%       rkelm  = RKELM();
%       rkelm  = rkelm.train(X, Y);
%       Yhat = rkelm.predict(X)

%   License:
%
%   Permission to use, copy, or modify this software and its documentation
%   for educational and research purposes only and without fee is here
%   granted, provided that this copyright notice and the original authors'
%   names appear on all copies and supporting documentation. This program
%   shall not be used, rewritten, or adapted as the basis of a commercial
%   software or hardware product without first obtaining permission of the
%   authors. The authors make no representations about the suitability of
%   this software for any purpose. It is provided "as is" without express
%   or implied warranty.
%
%       Federal University of Espirito Santo (UFES), Brazil
%       Computers and Neural Systems Lab. (LabCISNE)
%       Authors:    F. Kentaro, B. Legora Silva, D. Cosmo 
%       email:      labcisne@gmail.com
%       website:    github.com/labcisne/ELMToolbox
%       date:       Jan/2018

classdef RKELM < Util
    properties
        kernelType = 'RBF_kernel'
        kernelParam = 0.1
        regularizationParameter = 1000
        numberOfHiddenNeurons = 1000
        outputWeight = []
        xTr = []
        support = []
    end
    methods
        function self = RKELM(varargin)
%             self = self@ELM(varargin{:});
            for i = 1:2:nargin
                self.(varargin{i}) = varargin{i+1};
            end
            self.seed = self.parseSeed();
        end
        
        function omega = kernel_matrix(self,Xte)
            nb_data = size(self.xTr,1);
            if strcmp(self.kernelType,'RBF_kernel')
                if nargin<2
                    XXh = sum(self.xTr.^2,2)*ones(1,nb_data);
                    omega = XXh + XXh' - 2*(self.xTr*self.xTr');
                    omega = exp(-omega./self.kernelParam(1));
                else
                    XXh1 = sum(self.xTr.^2,2)*ones(1,size(Xte,1));
                    XXh2 = sum(Xte.^2,2)*ones(1,nb_data);
                    omega = XXh1 + XXh2' - 2*self.xTr*Xte';
                    omega = exp(-omega./self.kernelParam(1));
                end
                
            elseif strcmp(self.kernelType,'lin_kernel')
                if nargin<2
                    omega = self.xTr*self.xTr';
                else
                    omega = self.xTr*Xte';
                end
                
            elseif strcmp(self.kernelType,'poly_kernel')
                if nargin<4
                    omega = (self.xTr*self.xTr' + self.kernelParam(1)).^self.kernelParam(2);
                else
                    omega = (self.xTr*Xte' + self.kernelParam(1)).^self.kernelParam(2);
                end
                
            elseif strcmp(self.kernelType,'wav_kernel')
                if nargin<2
                    XXh = sum(self.xTr.^2,2)*ones(1,nb_data);
                    omega = XXh+XXh' - 2*(self.xTr*self.xTr');
                    
                    XXh1 = sum(self.xTr,2)*ones(1,nb_data);
                    omega1 = XXh1 - XXh1';
                    omega = cos(self.kernelParam(3)*omega1./self.kernelParam(2)).*exp(-omega./self.kernelParam(1));
                    
                else
                    XXh1 = sum(self.xTr.^2,2)*ones(1,size(Xte,1));
                    XXh2 = sum(Xte.^2,2)*ones(1,nb_data);
                    omega = XXh1+XXh2' - 2*(self.xTr*Xte');
                    
                    XXh11 = sum(self.xTr,2)*ones(1,size(Xte,1));
                    XXh22 = sum(Xte,2)*ones(1,nb_data);
                    omega1 = XXh11 - XXh22';
                    
                    omega = cos(self.kernelParam(3)*omega1./self.kernelParam(2)).*exp(-omega./self.kernelParam(1));
                end
            end
        end
        
        function self = train(self, X, Y)  
            auxTime = toc;
            self.support = randi(self.seed, size(X,1), [self.numberOfHiddenNeurons,1]);
            self.xTr = X(self.support,:);
            Omega_train = self.kernel_matrix(X)';
            if size(Omega_train,1)>=size(Omega_train,2)
                self.outputWeight = (eye(size(Omega_train,2))/self.regularizationParameter + Omega_train' * Omega_train) \ Omega_train' * Y;
            else
                self.outputWeight = Omega_train' * ((eye(size(Omega_train,1))/self.regularizationParameter + Omega_train * Omega_train') \ Y);
            end
            self.trainTime = toc - auxTime;
        end
        function Yhat = predict(self, Xte)
            auxTime = toc;
            Omega_test = self.kernel_matrix(Xte);
            Yhat = Omega_test' * self.outputWeight;
            self.lastTestTime = toc - auxTime;
        end
    end
end