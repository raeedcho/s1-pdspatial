%% Run data
datadir = '/home/raeed/data/limblab/data-td/FullWS';
% fileprefix = {'Han_20160325_RWhold','Chips_20151211_RW'};
fileprefix = {'Han_20160325_RWhold'};
% fileprefix = {'Han_20171116_COactpas'};
savesuffix = '_pdTables_run20181113.mat';

for filenum = 1:length(fileprefix)
    clear pdTable

    %% Load data
    load(fullfile(datadir,[fileprefix{filenum} '_TD.mat']))

    % prep trial data by getting only rewards and trimming to only movements
    td = trial_data;
    % split into trials
    % td = splitTD(...
    %     trial_data,...
    %     struct(...
    %         'split_idx_name','idx_startTime',...
    %         'linked_fields',{{...
    %             'target_direction',...
    %             'trial_id',...
    %             'result',...
    %             'bumpDir',...
    %             'ctrHold',...
    %             'ctrHoldBump'}},...
    %         'start_name','idx_startTime',...
    %         'end_name','idx_endTime'));
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
    % if any(isnan([td.target_direction]))
    %     warning('Some trials have no target direction, deleting trials...')
    %     td(isnan([td.target_direction])) = [];
    % end

    % Trim td
    td = trimTD(td,{'idx_targetStartTime',0},{'idx_endTime',0});
    % td = trimTD(td,{'idx_goCueTime',0},{'idx_endTime',0});

    % bin data at 50ms
    td = binTD(td,5);

    % add firing rates
    td = addFiringRates(td,struct('array','S1'));

    % caclulate PDs
    pd_params = struct('out_signals','S1_FR','out_signal_names',td(1).S1_unit_guide);
    pdTable = getTDClassicalPDs(td,pd_params);

    %% save
    save(fullfile(datadir,'Results','PDs',[fileprefix{filenum} savesuffix]),'pdTable')
end

