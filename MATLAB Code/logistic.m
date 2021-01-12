clc; clear all; close all;
%%
load('FeatureMatrix.mat');
fullRange = randperm(size(FeatureMatrix, 1));
trainData = fullRange(1:(length(fullRange)*0.8));
verifyData = fullRange((length(fullRange)*0.8):end);

trainingData = FeatureMatrix(trainData, :);
trainingLabels = labels(trainData, 1:end);

Model = fitclinear(trainingData, trainingLabels, ...
    'OptimizeHyperparameters',  {'Lambda','Regularization'}, ...
    'Learner', 'logistic', 'HyperparameterOptimizationOptions', ...
        struct('Optimizer', 'gridsearch')...
    );
%%
endRange = size(labels(verifyData), 1);
loops = 1:1:(endRange/1000 + 1);
predictions = zeros(endRange, 2);
%%
for i = loops
    i
    start = (loops(i)-1)*1000+1;
    endLoop = start+999;
    if endLoop > endRange
        endLoop = endRange;
    end
    
    [~,score] = predict(Model, FeatureMatrix(verifyData(start:endLoop), :));
    predictions(verifyData(start:endLoop), :) = score;
end

%%
predLabel = predictions(verifyData, 1) < 0.5;
diff = sum(predLabel ~= labels(verifyData, :));
percentErr = diff/endRange*100
%%
[X,Y] = perfcurve(labels(verifyData, :), predictions(verifyData,2), 1);
figure
plot(X,Y);