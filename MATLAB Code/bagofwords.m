clc; clear all; close all;
%%
data = readtable("Combined Dataset.csv");

range1 = uint32(1:1e5);
range2 = uint32(1e5+1:2e5);
range3 = uint32(4e5:450176);
labels = table2array((data([range1 range2 range3], 5)));
%% bag of words on various features

% bag of words on TLDs

TLDs1 = table2array((data(range1, 9)));
TLDs2 = table2array((data(range2, 9)));
TLDs3 = table2array((data(range3, 9)));

TLDs = string([TLDs1; TLDs2; TLDs3]);

clear TLDs1 TLDs2 TLDs3;

splitTLDs = tokenizedDocument(TLDs');

clear TLDs;

bagTLDs = bagOfWords(splitTLDs);
tldFeatures = encode(bagTLDs, splitTLDs);

clear splitTLDs;
%% bag of words on short hostname (Hostname without TLD)

names1 = table2array((data(range1, 8)));
names2 = table2array((data(range2, 8)));
names3 = table2array((data(range3, 8)));

names = string([names1; names2; names3]);

clear names1 names2 names3;

dotCount = zeros(size(names, 1), 1);
names2 = cell(size(names, 1), 1);
for i = 1:size(names, 1)
    names2{i} = strsplit(names(i), '.');
    dotCount(i) = length(names2{i});
end

splitNames = tokenizedDocument(names2, 'TokenizeMethod', 'none');

clear names names2 i;

bagHosts = bagOfWords(splitNames);
hostFeatures = encode(bagHosts, splitNames);

clear splitNames;

%% bag of words on path

urls1 = table2array((data(range1, 3)));
urls2 = table2array((data(range2, 3)));
urls3 = table2array((data(range3, 3)));

hosts1 = table2array((data(range1, 7)));
hosts2 = table2array((data(range2, 7)));
hosts3 = table2array((data(range3, 7)));

urls = string([urls1; urls2; urls3]);
hosts = string([hosts1; hosts2; hosts3]);
clear urls1 urls2 urls3;
clear hosts1 hosts2 hosts3;

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

splitPaths = tokenizedDocument(paths, 'TokenizeMethod', 'none');

clear paths;

bagPaths = bagOfWords(splitPaths);
pathFeatures = encode(bagPaths, splitPaths);

clear splitPaths i;

%% DNS Features
%Binary features: HasA, HasMx, HasNS
dnsBin = uint8(table2array((data([range1 range2 range3], [10,16,22]))));

%% ASN on A,Mx,Ns Records
[AAsnFeatures, bagAAsn] = simpleBag(string(table2array((data([range1 range2 range3], 13)))));
[MxAsnFeatures, bagMxAsn] = simpleBag(string(table2array((data([range1 range2 range3], 19)))));
[NSAsnFeatures, basNsAsn] = simpleBag(string(table2array((data([range1 range2 range3], 25)))));

%% TTL on A,Mx,Ns Records
[ATTLFeatures, bagATTL] = simpleBag(string(table2array((data([range1 range2 range3], 12)))));
[MxTTLFeatures, bagMxTTL] = simpleBag(string(table2array((data([range1 range2 range3], 18)))));
[NsTTLFeatures, bagNsTTL] = simpleBag(string(table2array((data([range1 range2 range3], 24)))));

%% Country on A,Mx,Ns Records
[ACountFeatures, bagACount] = simpleBag(string(table2array((data([range1 range2 range3], 15)))));
[MxCountFeatures, bagMxCount] = simpleBag(string(table2array((data([range1 range2 range3], 21)))));
[NsCountFeatures, bagNsCount] = simpleBag(string(table2array((data([range1 range2 range3], 27)))));

%% Combine Features Into Feature Matrix
FeatureMatrix = [tldFeatures pathFeatures hostFeatures dotCount double(dnsBin) ...
    AAsnFeatures ACountFeatures ATTLFeatures ...
    MxAsnFeatures MxCountFeatures MxTTLFeatures ...
    NSAsnFeatures NsCountFeatures NsTTLFeatures];
%% Functions
function [features, bag] = simpleBag(rows)
    splitRows = tokenizedDocument(rows);
    bag = bagOfWords(splitRows);
    features = encode(bag, splitRows);
end