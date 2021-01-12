clc
clear all
close all

dataTest = load("FeatureMatrix2.mat");
dataTrain = load("FeatureMatrix.mat");
testMatrix = dataTest.FeatureMatrix;

%% Naive Bayes Model

naive = load("NaiveData.mat");
[naivePred, NaivePercentErr] = classify(naive.Model, testMatrix);
clear naive;

%% SVM

svm = load("SVMData.mat");
[svmPred, svmPercentErr] = classify(svm.Model, testMatrix);
clear svm;

%% Logistic Regression

logistic = load("logistic.mat");
[logisticPred, logisticPercentErr] = classify(logistic.Model, testMatrix);
clear logistic;

%% 
function [predictions, percentErr]  = classify(model, testMatrix)
    loops = 1:1:6;
    predictions = zeros(5513, 2);

    for i = loops
        
        start = (loops(i)-1)*1000+1;
        endLoop = start+999;
        if endLoop > 5513
            endLoop = 5513;
        end

        [~,score] = predict(model, testMatrix(start:endLoop, :));
        predictions(start:endLoop, :) = score;
    end
    
    labels = ones(5514,1);
    labels(5514, 1) = 0;
    predictions(5514,1) = 1;
    predictions(5514,2) = 0;
    predLabel = predictions(:, 1) < 0.5;
    diff = sum(predLabel ~= labels);
    percentErr = diff/5513;
    
    [X,Y] = perfcurve(labels, predictions(:,2), 1);
    figure
    plot(X,Y);

end


