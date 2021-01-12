clc
clear all
close all

%% load data

dataTest = readtable("Combined-Dataset-2.csv");
dataTrain = load("FullFeaturesBags.mat");
%% using original bags to create new feature matrix

% creating TLD features

TLDsTest = string(table2array(dataTest(:, 9)));
splitTLDsTest = tokenizedDocument(TLDsTest');

clear TLDsTest;

tldFeatures = encode(dataTrain.bagTLDs, splitTLDsTest);

clear splitTLDsTest;
%% creating short hostname features (Hostname without TLD)

namesTest = string(table2array(dataTest(:, 8)));

dotCount = zeros(size(namesTest, 1), 1);
names = cell(size(namesTest, 1), 1);
for i = 1:size(namesTest, 1)
    names{i} = strsplit(namesTest(i), '.');
    dotCount(i) = length(names{i});
end

splitNamesTest = tokenizedDocument(names, 'TokenizeMethod', 'none');

clear namesTest names i;

hostFeatures = encode(dataTrain.bagHosts, splitNamesTest);

clear splitNamesTest;
%% bag of words on path

urls = string(table2array(dataTest(:, 3)));
hosts = string(table2array(dataTest(:, 7)));

paths = cell(size(hosts, 1), 1);
for i = 1:size(hosts, 1)
    url = urls(i);
    startIndC = strfind(url, hosts(i));
    if(~isempty(startIndC))
        startInd = startIndC(1) + strlength(hosts(i))+1;
        if(startInd <= strlength(url))
            endInd = strlength(url);
            path = extractBetween(url, startInd, endInd);
            paths{i} = strsplit(path, {'.', '/', '?', '=', '-', '_'});
        else
            paths{i} = "";
        end
    else
        paths{i} = "";
    end
end
clear url startIndC startInd endInd path;

splitPathsTest = tokenizedDocument(paths, 'TokenizeMethod', 'none');

clear paths;

pathFeatures = encode(dataTrain.bagPaths, splitPathsTest);

clear splitPathsTest i;

%% DNS Features
% Binary features: HasA, HasMx, HasNS
dnsBin = uint8(table2array(dataTest(:, [10, 16, 22])));

%% ASN on A,Mx,Ns Records
AAsnFeatures = simpleBag(string(table2array((dataTest(:, 13)))), dataTrain.bagAAsn);
MxAsnFeatures = simpleBag(string(table2array((dataTest(:, 19)))), dataTrain.bagMxAsn);
NSAsnFeatures = simpleBag(string(table2array((dataTest(:, 25)))), dataTrain.basNsAsn);

%% TTL on A,Mx,Ns Records
ATTLFeatures = simpleBag(string(table2array((dataTest(:, 12)))), dataTrain.bagATTL);
MxTTLFeatures = simpleBag(string(table2array((dataTest(:, 18)))), dataTrain.bagMxTTL);
NsTTLFeatures = simpleBag(string(table2array((dataTest(:, 24)))), dataTrain.bagNsTTL);

%% Country on A,Mx,Ns Records
ACountFeatures = simpleBag(string(table2array((dataTest(:, 15)))), dataTrain.bagACount);
MxCountFeatures = simpleBag(string(table2array((dataTest(:, 21)))), dataTrain.bagMxCount);
NsCountFeatures = simpleBag(string(table2array((dataTest(:, 27)))), dataTrain.bagNsCount);

%% Combine Features Into Feature Matrix
FeatureMatrix = [tldFeatures pathFeatures hostFeatures dotCount double(dnsBin) ...
    AAsnFeatures ACountFeatures ATTLFeatures ...
    MxAsnFeatures MxCountFeatures MxTTLFeatures ...
    NSAsnFeatures NsCountFeatures NsTTLFeatures];
%% Functions
function features = simpleBag(rows, bag)
    splitRows = tokenizedDocument(rows);
    features = encode(bag, splitRows);
end