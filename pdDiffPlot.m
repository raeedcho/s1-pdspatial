%% plotting variables
    datadir = '/home/raeed/data/limblab/data-td/FullWS/Results/PDs';
    filename = {'Chips_20151211_RW_pdTables_run20181113.mat','Han_20160325_RWhold_pdTables_run20181113.mat'};

%% Loop over monkeys
    for monkeynum = 1:length(filename)
        %% load data
            load(fullfile(datadir,filename{monkeynum}))
        
        %% find combinations
            % clean up pdTable and get rid of non-tuned
            pds = pdTable;
            pds(~pds.velTuned,:) = [];
        
            unit_guide = pds.signalID;
            chanlist = unique(unit_guide(:,1));
        
            samechan_combos = [];
            for idx = 1:length(chanlist)
                chan = chanlist(idx);
        
                samechan_idx = find(unit_guide(:,1)==chan);
        
                if length(samechan_idx)>1
                    samechan_combos = [samechan_combos;nchoosek(samechan_idx,2)];
                end
            end
        
            all_combos = nchoosek(1:size(unit_guide,1),2);
        
            diffchan_combos = setdiff(all_combos,samechan_combos,'rows');
        
        %% Calculate PD diffs
            samechan_dPD = zeros(size(samechan_combos,1),1);
            for i = 1:size(samechan_combos,1)
                samechan_dPD(i) = abs(minusPi2Pi(pds.velPD(samechan_combos(i,1))-pds.velPD(samechan_combos(i,2))));
            end
        
            diffchan_dPD = zeros(size(diffchan_combos,1),1);
            for i = 1:size(diffchan_combos,1)
                diffchan_dPD(i) = abs(minusPi2Pi(pds.velPD(diffchan_combos(i,1))-pds.velPD(diffchan_combos(i,2))));
            end
        
            samechan_hist = histcounts(180/pi*samechan_dPD,20);
            samechan_hist = samechan_hist/size(samechan_combos,1)*100;
            [diffchan_hist,edges] = histcounts(180/pi*diffchan_dPD,20);
            diffchan_hist = diffchan_hist/size(diffchan_combos,1)*100;
        
            bin_centers = edges(1:end-1)+1/2*mode(diff(edges));
        
        %% plot
            figure('defaultaxesfontsize',18)
            b = bar(bin_centers,[samechan_hist' diffchan_hist'],1,'edgecolor','none','facecolor','flat');
            b(1).FaceColor = [55 126 184]/255;
            b(2).FaceColor = [228 26 28]/255;
            set(gca,'box','off','tickdir','out','xtick',0:20:180,'ytick',0:5:20)
            xlabel 'Difference in preferred direction (degrees)'
            ylabel 'Percentage'
            title(filename{monkeynum},'interpreter','none')
    end
