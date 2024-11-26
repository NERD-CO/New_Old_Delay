function [varOUT, corPRIM, corSEC] = strucBuilder(nwb,varGroundTruth,learnORrecog)
%builds the subject structure for saving
tmp_LA = nwbRead(nwb);

% Loads in Macrowire timestamps
LFP_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').timestamps.load;
% Voltage data for all macrowires and their channels
LFP_data = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').data.load;
% To get sampling frequency info you get it from the description
% LFP_sessionInfo = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
%     ('LFP').electricalseries.get('MacroWireSeries');
varOUT.LFP_data = double(LFP_data);
varOUT.LFP_time = downsample(LFP_timestamps,8);

if matches('MW1_NO1_Session_1_filter.nwb',nwb)
    % fix weird time thing
    varOUT.LFP_data = varOUT.LFP_data(:,45000:end);
    varOUT.LFP_time = varOUT.LFP_time(45000:end);
end

% channel ID
chanLabels = cellstr(tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('label').data.load()); %use MA only!
MAchan = find(contains(chanLabels,'MA_'));
chanID = cellstr(tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('location').data.load());
hemisphere = cellstr(tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('hemisph').data.load());
shortBnames = cellstr(tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('shortBAn').data.load());
%%% INDEX and add to VAR
varOUT.chanID = chanID(MAchan);
varOUT.chanHemi = hemisphere(MAchan);
varOUT.chanSname = shortBnames(MAchan);

%%% CONSIDER LEFT AND RIGHT

%%% find unique brain regions - TURN in to TABLE
tmpBRegUni = unique(varOUT.chanSname);
hemiTemp = cell(length(tmpBRegUni),1);
longName = cell(length(tmpBRegUni),1);
for ui = 1:length(tmpBRegUni)
    tmpIND = find(matches(varOUT.chanSname,tmpBRegUni{ui}),1,'first');
    hemiTemp{ui} = varOUT.chanHemi{tmpIND};
    longName{ui} = varOUT.chanID{tmpIND};
end

brTABLE = table(tmpBRegUni,hemiTemp,longName,'VariableNames',{'SEEGele',...
    'Hemisphere','LongBRname'});

varOUT.BrainRegions = brTABLE;

%%% assign the LFP to each brain region
varOUT.RegionLFP = cell(length(varOUT.BrainRegions.SEEGele),1);
for k = 1:height(varOUT.BrainRegions)
    reg = strcmp(varOUT.BrainRegions.SEEGele{k},varOUT.chanSname);
    varOUT.RegionLFP{k} = varOUT.LFP_data(reg,:);
end

%extract event key
varOUT.eventTimes = tmp_LA.acquisition.get('NLXEvents').timestamps.load();
varOUT.eventIDs = cellstr(tmp_LA.acquisition.get('MatIntEvents').data.load());

if learnORrecog % 1 == Learn

    %%%% responses
    responseInd = find(contains(varOUT.eventIDs,'20')|contains(varOUT.eventIDs,'21'));
    response = cellfun(@(x) str2double(x), (varOUT.eventIDs(responseInd)), 'UniformOutput', true);
    varOUT.responseTimes = varOUT.eventTimes(responseInd);
    response(response==20) = 1;
    response(response==21) = 0; %yes (1) and no (0)
    varOUT.responses = response;
    %%% correct and incorrect trials
    varOUT.correctAnimalTrials = varGroundTruth.AnimalsInd(response(varGroundTruth.AnimalsInd)==1);
    varOUT.correctNotAnimalTrials = varGroundTruth.NotAnimalsInd(response(varGroundTruth.NotAnimalsInd)==0);
    varOUT.incorrectAnimalTrials = varGroundTruth.AnimalsInd(response(varGroundTruth.AnimalsInd)==0);
    varOUT.incorrectNotAnimalTrials = varGroundTruth.NotAnimalsInd(response(varGroundTruth.NotAnimalsInd)==1);
    %%% trial stimuli
    stimOnInd = strcmp(varOUT.eventIDs,'1'); varOUT.stimOn=varOUT.eventTimes(stimOnInd);
    stimOffInd = strcmp(varOUT.eventIDs,'2'); varOUT.stimOff=varOUT.eventTimes(stimOffInd);
    PromptInd = strcmp(varOUT.eventIDs,'3'); varOUT.Prompt=varOUT.eventTimes(PromptInd);
    varOUT.RT = varOUT.responseTimes-varOUT.Prompt;

    corAnFrac = length(varOUT.correctAnimalTrials)/varGroundTruth.aTrials;
    corNotAnFrac = length(varOUT.correctNotAnimalTrials)/varGroundTruth.naTrials;

    corPRIM = corAnFrac;
    corSEC = corNotAnFrac;

else

    %%%% responses
    responseInd = find(matches(varOUT.eventIDs,{'31','32','33','34','35','36'}));
    response = cellfun(@(x) str2double(x), (varOUT.eventIDs(responseInd)), 'UniformOutput', true);
    response2 = response;
    varOUT.responseTimes = varOUT.eventTimes(responseInd);
    response2(response==31) = 1; %yes (1) 31 = High YES OLD
    response2(response==32) = 1; %yes (1) 32 = Mid YES OLD
    response2(response==33) = 1; %yes (1) 33 = Low YES OLD
    response2(response==34) = 0; %no  (0) 34 = Low NO NEW
    response2(response==35) = 0; %no  (0) 35 = Mid NO NEW
    response2(response==36) = 0; %no  (0) 36 = High NO NEW
    % 6 = End of Delay
    varOUT.responses = response2; % Change in future
    varOUT.responsesG = response; % Change in future
    %%% correct and incorrect trials
    varOUT.correctNewTrials = find(varGroundTruth.OLDNewT == 1 & response2 == 1);
    varOUT.correctOldTrials = find(varGroundTruth.OLDNewT == 0 & response2 == 0);
    varOUT.incorrectNewTrials = find(varGroundTruth.OLDNewT == 1 & response2 == 0);
    varOUT.incorrectOldTrials = find(varGroundTruth.OLDNewT == 0 & response2 == 1);
    %%% trial stimuli
    stimOnInd = strcmp(varOUT.eventIDs,'1'); 
    varOUT.stimOn = varOUT.eventTimes(stimOnInd);
    stimOffInd = strcmp(varOUT.eventIDs,'2'); 
    varOUT.stimOff =varOUT.eventTimes(stimOffInd);
    PromptInd = strcmp(varOUT.eventIDs,'3'); 
    varOUT.Prompt =varOUT.eventTimes(PromptInd);
    varOUT.RT = varOUT.responseTimes-varOUT.Prompt;

    corNewFrac = length(varOUT.correctNewTrials)/varGroundTruth.newTrials;
    corOldFrac = length(varOUT.correctOldTrials)/varGroundTruth.oldTrials;

    corPRIM = corNewFrac;
    corSEC = corOldFrac;



end





end