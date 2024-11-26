function [] = PreprocessingDataCompileLEARN_JAT(procCaseLoc)


%%%%%%% This codes loads in each subject's MWB and then compiles and saves
%%%%%%% each structure for each variant
% 
% In the learning task, we are asked to identify animals so we only
%%%%%%% need the true category ad subjects' response

% For the learning session here is the following key:
% 55 = start of the experiment
% 1 = stimulus ON
% 2 = stimulus OFF
% 3 = Question Screen Onset
% 20 = Yes (Image was an animal)
% 21 = No (Image was not an animal)
% 6 = End of Delay after Response
% 66 = End of Experiment.

cd(procCaseLoc)
% cd 'E:\Dropbox\LearningRecognitionECoG\Data\ProcessedCases';

%% variant 1 subjects learning
% clear

load VariantInfoTables
%%% image categories
var1learnGroundTruth.category = learn.v1.CatID;
var1learnGroundTruth.Ntrials = length(var1learnGroundTruth.category);
Animals = strfind(var1learnGroundTruth.category, 'smallAnimal');
%%% trial indices
var1learnGroundTruth.AnimalsInd = find(~cellfun(@isempty,Animals));
var1learnGroundTruth.NotAnimalsInd = find(cellfun(@isempty,Animals));
var1learnGroundTruth.aTrials = 20; 
var1learnGroundTruth.naTrials = 80; 
var1learnGroundTruth.fs = 4000;
var1learnGroundTruth.fsDS = 500;
var1learnGroundTruth.subOutliers = cell(1,1);

%%% image categories
var2learnGroundTruth.category = learn.v2.CatID;
var2learnGroundTruth.Ntrials = length(var2learnGroundTruth.category);
Animals = strfind(var2learnGroundTruth.category, 'zzanimal');
%%% trial indices
var2learnGroundTruth.AnimalsInd = find(~cellfun(@isempty,Animals));
var2learnGroundTruth.NotAnimalsInd = find(cellfun(@isempty,Animals));
var2learnGroundTruth.aTrials = 20; 
var2learnGroundTruth.naTrials = 80; 
var2learnGroundTruth.fs = 4000;
var2learnGroundTruth.fsDS = 500;
var2learnGroundTruth.subOutliers = cell(1,1);

%%% image categories
var3learnGroundTruth.category = learn.v3.CatID;
var3learnGroundTruth.Ntrials = length(var3learnGroundTruth.category);
Animals = strfind(var3learnGroundTruth.category, '5animals');
%%% trial indices
var3learnGroundTruth.AnimalsInd = find(~cellfun(@isempty,Animals));
var3learnGroundTruth.NotAnimalsInd = find(cellfun(@isempty,Animals));
var3learnGroundTruth.aTrials = 20; 
var3learnGroundTruth.naTrials = 80; 
var3learnGroundTruth.fs = 4000;
var3learnGroundTruth.fsDS = 500;
var3learnGroundTruth.subOutliers = cell(1,1);

var1NWBlist = {'MW1_NO1_Session_1_filter.nwb','MW2_NO2_Session_3_filter.nwb',...
    'MW3_NO3_Session_1_filter.nwb','MW5_NO4_Session_2_filter.nwb',...
    'MW8_NO5_Session_1_filter.nwb','MW9_NO6_Session_4_filter.nwb',...
    'MW13_NO8_Session_2_filter.nwb','MW16_NO9_Session_1_filter.nwb',...
    'MW2_NO2_Session_1_filter.nwb','MW3_NO3_Session_3_filter.nwb',...
    'MW5_NO4_Session_5_filter.nwb','MW9_NO6_Session_8_filter.nwb',...
    'MW16_NO9_Session_3_filter.nwb','MW1_NO1_Session_3_filter.nwb',...
    'MW2_NO2_Session_5_filter.nwb','MW3_NO3_Session_14_filter.nwb',...
    'MW9_NO6_Session_2_filter.nwb','MW12_NO7_Session_1_filter.nwb',...
    'MW23_NO10_Session_2_filter.nwb'};

mwSubjects = {'MW1','MW2','MW3','MW5','MW8','MW9','MW13','MW16','MW2','MW3',...
              'MW5','MW9','MW16','MW1','MW2','MW3','MW9','MW12','MW23'};

mwKeep = zeros(1,19);

subNUMS = [1:8 , 1:5 , 1:6];
subIDlist = cellfun(@(x) ['Sub',num2str(x)] , num2cell(subNUMS) ,...
    'UniformOutput',false);
varAllID = [ones(8,1);...
            ones(5,1)*2;...
            ones(6,1)*3];

for vbi = 1:length(var1NWBlist)

    nwb = var1NWBlist{vbi};

    switch varAllID(vbi)
        case 1
            [varIN, corAnFrac, corNotAnFrac] = strucBuilder(nwb,var1learnGroundTruth,1);
            if corNotAnFrac > 0.8 && corAnFrac > 0.8
                var1learnSub.(subIDlist{vbi}) = varIN;
                mwKeep(vbi) = 1;
            else
                var1learnGroundTruth.subOutliers = [var1learnGroundTruth.subOutliers, nwb];
            end
        case 2
            [varIN, corAnFrac, corNotAnFrac] = strucBuilder(nwb,var2learnGroundTruth,1);
            if corNotAnFrac > 0.8 && corAnFrac > 0.8
                var2learnSub.(subIDlist{vbi}) = varIN;
                mwKeep(vbi) = 1;
            else
                var2learnGroundTruth.subOutliers = [var2learnGroundTruth.subOutliers, nwb];
            end
        case 3
            [varIN, corAnFrac, corNotAnFrac] = strucBuilder(nwb,var3learnGroundTruth,1);
            if corNotAnFrac > 0.8 && corAnFrac > 0.8
                var3learnSub.(subIDlist{vbi}) = varIN;
                mwKeep(vbi) = 1;
            else
                var3learnGroundTruth.subOutliers = [var3learnGroundTruth.subOutliers, nwb];
            end
    end
end

save('var1learn','var1*','-v7.3')
save('var2learn','var2*','-v7.3')
save('var3learn','var3*','-v7.3')


end

