%% Run data
datadir = '/home/raeed/data/limblab/data-td/FullWS';
fileprefix = {'Han_20160325_RWhold','Chips_20151211_RW'};
savesuffix = '_pdTables_run20181113.mat';

for filenum = 1:length(fileprefix)
    clear pdTable

    %% Load data
    load(fullfile(datadir,[fileprefix{filenum} '_TD.mat']))

    % prep trial data by getting only rewards and trimming to only movements
    % first process marker data
    td = trial_data;
    [~,td] = getTDidx(td,'result','R');

    % Remove unsorted channels
    keepers = (td(1).S1_unit_guide(:,2)~=0);
    for trial = 1:length(td)
        td(trial).S1_unit_guide = td(trial).S1_unit_guide(keepers,:);
        td(trial).S1_spikes = td(trial).S1_spikes(:,keepers);
    end

    % remove low firing neurons
    td = removeBadNeurons(td,struct('min_fr',0.1));
    
    % remove trials with no go cue
    if any(isnan([td.idx_targetStartTime]))
        warning('Some trials have no go cue time, deleting trials...')
        td(isnan([td.idx_targetStartTime])) = [];
    end

    % bin data at 50ms
    td = binTD(td,5);

    % add firing rates
    td = addFiringRates(td,struct('array','S1'));

    % Trim td
    td = trimTD(td,{'idx_targetStartTime',0},{'idx_endTime',0});

    % caclulate PDs
    pd_params = struct('out_signals','S1_FR','out_signal_names',td(1).S1_unit_guide);
    pdTable = getTDClassicalPDs(td,pd_params);

    %% save
    save(fullfile(datadir,'Results','PDs',[fileprefix{filenum} savesuffix]),'pdTable')
end

