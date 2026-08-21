clear
close all
clc
warning('off', 'all')
%% directories and fixed variables
pathData = 'C:\Users\katja\OneDrive\POSTDOC\PROJECTS\Pero_Lightlevels\Peromyscus_LightLevels1\manuscript_lightlevel_behavior\VERSION2025\FrontiersZoology\Rebuttal01\to upload';
pathCode = 'C:\Users\katja\OneDrive\POSTDOC\PROJECTS\Pero_Lightlevels\Peromyscus_LightLevels1\manuscript_lightlevel_behavior\VERSION2025\FrontiersZoology\Rebuttal01\to upload\code';

addpath(genpath(pathCode))

load(fullfile(pathData,'main_data_plots'))
load(fullfile(pathData,'main_data_autobehv_newThr'))
load(fullfile(pathData,'main_data'))

load(fullfile(pathData,'main_data_hunting'))
load(fullfile(pathData,'main_data_foraging_new'))

sl = {'Mm','Pm','Pp'};


BCOL = [0 0 0;0.8510    0.3725    0.0078; ...,
    0.1059    0.6196    0.4667;0.1059    0.6196    0.4667;...,
    0.4588    0.4392    0.7020;0.4588    0.4392    0.7020];


%% Plot all traces (Fig. 1B)
figure
imagesc(data_all(sorted_by_max,:),[0 150])
cmap = cmocean('balance',150);
colormap(cmap([round(1:4:75), 75, 76:end],:))

% GLM stimulus-evoked
Xmodel = [];
binned_speed = [];
for s = 1:size(data_all,1)
    curr = data_all(s,28:62);
    bnd = resample(curr,size(curr,2)/5,size(curr,2));
    Xmodel = [Xmodel;repmat([light_all(s)./2 species_all(s)./3 stimuli(s)./3],size(bnd,2),1)];
    binned_speed = [binned_speed bnd];
end
binned_speed = binned_speed./60;
aov = anova(Xmodel,binned_speed',FactorNames=["ND" "Species" "Stimulus"],ModelSpecification = "interactions")


%% Max. speed (Fig. 1D)
figure
maxspeed = max(data_all(:,155:300),[],2);
scol = [0.5 0.5 0.5;0 0 0;0 0.5 0.5];
loomc = cell(3,1);
for m = 1:3
    tmp = find(species_all==m);
    curr = cell(3,1);
    subplot(1,3,m)
    for s = 1:3%dimm, black, white
        tmp2 = find(stimuli(tmp)==s);
        data = maxspeed(tmp(tmp2));
        [h,edg] = histcounts(data,0:30:180);
        curr{s} = data;
        c = cdfplot(data);
        set(c,'color',scol(s,:))
        hold on
        if s == 2
            loomc{m} = data;
        end
    end
    xlabel('max. speed')
    ylabel('probability')
    legend('dimming','black looming','white looming')
    title(sl{m})
end

figure
maxspeed = max(data_all(:,155:300),[],2); %evoked
spcol = [0 0 1;0 1 0;1 0 0];
loomc = cell(3,1);
for m = 1:3
    tmp = find(species_all==m);
    curr = cell(3,1);
    for s = 2%dimm, black, white
        tmp2 = find(stimuli(tmp)==s);
        data = maxspeed(tmp(tmp2));
        [h,edg] = histcounts(data,0:30:180);
        curr{s} = data;
        c = cdfplot(data);
        set(c,'color',spcol(m,:))
        hold on
        if s == 2
            loomc{m} = data;
        end
    end

end
xlabel('max. speed')
ylabel('probability')
legend('Mm','Pm','Pp')
title('species comparison')



%% Bar plots behaviours (Fig. 1G)
cols = BCOL;
cols(4,:) = cols(4,:)*1.4;
cols(5,:) = cols(5,:)*1.4;

data2take = behv_auto_curr;

figure
disp('species plots')
coll = [];
SPEC = []; BEHV = []; AID = [];
for m = 1:3 %go through species
    idsf = find(species_all==m);
    autob = data2take(idsf);
    autob_perc = [];
    absnum = [];
    for b = 0:5
        tmp = find(autob==b);
        absnum = [absnum length(tmp)];
        per = 100/length(autob)*length(tmp);
        autob_perc = [autob_perc per];
        SPEC = [SPEC;species_all(idsf(tmp))];
        BEHV = [BEHV;data2take(idsf(tmp))];
        AID = [AID;animalid_all(idsf(tmp))];
    end
    coll = [coll;autob_perc];
    disp([sl{m},' ',num2str(absnum)])
end
b = bar(coll,'stacked' ,'edgecolor','none');
realids = sum(coll,1);
realids = find(realids>0);
for bb = 1:length(b)
    b(bb).FaceColor = cols(bb,:);
end
axis([0.5 3.5 0 100])
set(gca,'xtick',1:3,'xticklabel',{'Mm','Pm','Pp'})
xlabel('species')

BEHV = categorical(BEHV);
SPEC = categorical(SPEC);
AID  = categorical(AID);
behaviorList = categories(BEHV);
speciesList  = categories(SPEC);
animalList   = categories(AID);
nBehaviors = numel(behaviorList);
nSpecies   = numel(speciesList);
nAnimals   = numel(animalList);
animalCounts = zeros(nAnimals, nBehaviors);
animalSpecies = categorical(strings(nAnimals,1));
for a = 1:nAnimals
    thisAnimalRows = (AID == animalList{a});
    animalSpecies(a) = SPEC(find(thisAnimalRows, 1)); % species doesn't change within an animal
    for b = 1:nBehaviors
        animalCounts(a,b) = sum(thisAnimalRows & BEHV == behaviorList{b});
    end
end
pairs = nchoosek(1:nSpecies, 2);
nPairs = size(pairs, 1);
pairPvals = zeros(nPairs, 1);
pairLabels = strings(nPairs, 1);
nPerm = 10000;
for pr = 1:nPairs
    sp1 = speciesList{pairs(pr,1)};
    sp2 = speciesList{pairs(pr,2)};
    pairLabels(pr) = sp1 + " vs " + sp2;
    keepRows = animalSpecies == sp1 | animalSpecies == sp2;
    subCounts = animalCounts(keepRows, :);
    subSpecies = animalSpecies(keepRows);
    subSpecies = removecats(subSpecies); % drop unused species levels
    nSubAnimals = sum(keepRows);
    subObsTable = zeros(2, nBehaviors);
    subObsTable(1,:) = sum(subCounts(subSpecies == sp1, :), 1);
    subObsTable(2,:) = sum(subCounts(subSpecies == sp2, :), 1);
    rowSums = sum(subObsTable, 2);
    colSums = sum(subObsTable, 1);
    total = sum(subObsTable(:));
    expected = (rowSums * colSums) / total;
    chi2_obs_pair = sum(((subObsTable - expected).^2) ./ expected, 'all');
    chi2_perm_pair = zeros(nPerm, 1);
    for p = 1:nPerm
        permSpecies = subSpecies(randperm(nSubAnimals));
        permTable = zeros(2, nBehaviors);
        permTable(1,:) = sum(subCounts(permSpecies == sp1, :), 1);
        permTable(2,:) = sum(subCounts(permSpecies == sp2, :), 1);

        rowSums_p = sum(permTable, 2);
        colSums_p = sum(permTable, 1);
        total_p = sum(permTable(:));
        expected_p = (rowSums_p * colSums_p) / total_p;
        chi2_perm_pair(p) = sum(((permTable - expected_p).^2) ./ expected_p, 'all');
    end
    pairPvals(pr) = mean(chi2_perm_pair >= chi2_obs_pair);
end
pairPvals_bonf = min(pairPvals * nPairs, 1);
resultsTbl_species = table(pairLabels, pairPvals, pairPvals_bonf, ...
    'VariableNames', {'Comparison','RawP','BonferroniP'});


disp(' ')
disp('light level plots')
figure
coll = [];
LIG = []; BEHV = []; AID = [];
for l = 0:1 %go through light levels
    idsf = find(light_all==l);
    autob = data2take(idsf);
    autob_perc = [];
    absnum = [];
    for b = 0:5
        tmp = find(autob==b);
        absnum = [absnum length(tmp)];
        per = 100/length(autob)*length(tmp);
        autob_perc = [autob_perc per];
        LIG = [LIG;light_all(idsf(tmp))];
        BEHV = [BEHV;data2take(idsf(tmp))];
        AID = [AID;animalid_all(idsf(tmp))];
    end
    coll = [coll;autob_perc];
    disp([sl{m},' ',num2str(absnum)])
end
b = bar(coll,'stacked' ,'edgecolor','none');
realids = sum(coll,1);
realids = find(realids>0);
for bb = 1:length(b)
    b(bb).FaceColor = cols(bb,:);
end
axis([0.5 2.5 0 100])
set(gca,'xtick',1:2,'xticklabel',{'dim','bright'})
BEHV = categorical(BEHV);
SPEC = categorical(LIG);
AID  = categorical(AID);
behaviorList = categories(BEHV);
speciesList  = categories(SPEC);
animalList   = categories(AID);
nBehaviors = numel(behaviorList);
nSpecies   = numel(speciesList);
nAnimals   = numel(animalList);
animalCounts = zeros(nAnimals, nBehaviors);
animalSpecies = categorical(strings(nAnimals,1));
for a = 1:nAnimals
    thisAnimalRows = (AID == animalList{a});
    animalSpecies(a) = SPEC(find(thisAnimalRows, 1)); % species doesn't change within an animal
    for b = 1:nBehaviors
        animalCounts(a,b) = sum(thisAnimalRows & BEHV == behaviorList{b});
    end
end
pairs = nchoosek(1:nSpecies, 2);
nPairs = size(pairs, 1);
pairPvals = zeros(nPairs, 1);
pairLabels = strings(nPairs, 1);
nPerm = 10000;
for pr = 1:nPairs
    sp1 = speciesList{pairs(pr,1)};
    sp2 = speciesList{pairs(pr,2)};
    pairLabels(pr) = sp1 + " vs " + sp2;
    keepRows = animalSpecies == sp1 | animalSpecies == sp2;
    subCounts = animalCounts(keepRows, :);
    subSpecies = animalSpecies(keepRows);
    subSpecies = removecats(subSpecies); % drop unused species levels
    nSubAnimals = sum(keepRows);
    subObsTable = zeros(2, nBehaviors);
    subObsTable(1,:) = sum(subCounts(subSpecies == sp1, :), 1);
    subObsTable(2,:) = sum(subCounts(subSpecies == sp2, :), 1);
    rowSums = sum(subObsTable, 2);
    colSums = sum(subObsTable, 1);
    total = sum(subObsTable(:));
    expected = (rowSums * colSums) / total;
    chi2_obs_pair = sum(((subObsTable - expected).^2) ./ expected, 'all');
    chi2_perm_pair = zeros(nPerm, 1);
    for p = 1:nPerm
        permSpecies = subSpecies(randperm(nSubAnimals));
        permTable = zeros(2, nBehaviors);
        permTable(1,:) = sum(subCounts(permSpecies == sp1, :), 1);
        permTable(2,:) = sum(subCounts(permSpecies == sp2, :), 1);

        rowSums_p = sum(permTable, 2);
        colSums_p = sum(permTable, 1);
        total_p = sum(permTable(:));
        expected_p = (rowSums_p * colSums_p) / total_p;
        chi2_perm_pair(p) = sum(((permTable - expected_p).^2) ./ expected_p, 'all');
    end
    pairPvals(pr) = mean(chi2_perm_pair >= chi2_obs_pair);
end
pairPvals_bonf = min(pairPvals * nPairs, 1);
resultsTbl_light = table(pairLabels, pairPvals, pairPvals_bonf, ...
    'VariableNames', {'Comparison','RawP','BonferroniP'});


disp(' ')
disp('stimuli plots')
figure
coll = [];
STI = []; BEHV = []; AID =[];
for s = 1:3 %go through stimuli
    idsf = find(stimuli==s);
    autob = data2take(idsf);
    autob_perc = [];
    absnum = [];
    for b = 0:5
        tmp = find(autob==b);
        absnum = [absnum length(tmp)];
        per = 100/length(autob)*length(tmp);
        autob_perc = [autob_perc per];
        STI = [STI;stimuli(idsf(tmp))];
        BEHV = [BEHV;data2take(idsf(tmp))];
        AID = [AID;animalid_all(idsf(tmp))];
    end
    coll = [coll;autob_perc];
    disp([sl{m},' ',num2str(absnum)])
end
b = bar(coll,'stacked' ,'edgecolor','none');
realids = sum(coll,1);
realids = find(realids>0);
for bb = 1:length(b)
    b(bb).FaceColor = cols(bb,:);
end
axis([0.5 3.5 0 100])
set(gca,'xtick',1:3,'xticklabel',{'dim','loom','white'})
BEHV = categorical(BEHV);
SPEC = categorical(STI);
AID  = categorical(AID);
behaviorList = categories(BEHV);
speciesList  = categories(SPEC);
animalList   = categories(AID);
nBehaviors = numel(behaviorList);
nSpecies   = numel(speciesList);
nAnimals   = numel(animalList);
animalCounts = zeros(nAnimals, nBehaviors);
animalSpecies = categorical(strings(nAnimals,1));
for a = 1:nAnimals
    thisAnimalRows = (AID == animalList{a});
    animalSpecies(a) = SPEC(find(thisAnimalRows, 1)); % species doesn't change within an animal
    for b = 1:nBehaviors
        animalCounts(a,b) = sum(thisAnimalRows & BEHV == behaviorList{b});
    end
end
pairs = nchoosek(1:nSpecies, 2);
nPairs = size(pairs, 1);
pairPvals = zeros(nPairs, 1);
pairLabels = strings(nPairs, 1);
nPerm = 10000;
for pr = 1:nPairs
    sp1 = speciesList{pairs(pr,1)};
    sp2 = speciesList{pairs(pr,2)};
    pairLabels(pr) = sp1 + " vs " + sp2;
    keepRows = animalSpecies == sp1 | animalSpecies == sp2;
    subCounts = animalCounts(keepRows, :);
    subSpecies = animalSpecies(keepRows);
    subSpecies = removecats(subSpecies); % drop unused species levels
    nSubAnimals = sum(keepRows);
    subObsTable = zeros(2, nBehaviors);
    subObsTable(1,:) = sum(subCounts(subSpecies == sp1, :), 1);
    subObsTable(2,:) = sum(subCounts(subSpecies == sp2, :), 1);
    rowSums = sum(subObsTable, 2);
    colSums = sum(subObsTable, 1);
    total = sum(subObsTable(:));
    expected = (rowSums * colSums) / total;
    chi2_obs_pair = sum(((subObsTable - expected).^2) ./ expected, 'all');
    chi2_perm_pair = zeros(nPerm, 1);
    for p = 1:nPerm
        permSpecies = subSpecies(randperm(nSubAnimals));
        permTable = zeros(2, nBehaviors);
        permTable(1,:) = sum(subCounts(permSpecies == sp1, :), 1);
        permTable(2,:) = sum(subCounts(permSpecies == sp2, :), 1);

        rowSums_p = sum(permTable, 2);
        colSums_p = sum(permTable, 1);
        total_p = sum(permTable(:));
        expected_p = (rowSums_p * colSums_p) / total_p;
        chi2_perm_pair(p) = sum(((permTable - expected_p).^2) ./ expected_p, 'all');
    end
    pairPvals(pr) = mean(chi2_perm_pair >= chi2_obs_pair);
end
pairPvals_bonf = min(pairPvals * nPairs, 1);
resultsTbl_stimuli = table(pairLabels, pairPvals, pairPvals_bonf, ...
    'VariableNames', {'Comparison','RawP','BonferroniP'});
%% Escape latency and speed for black looming (Fig. 2B)
specCol = 'kgr';
figure

for c = [2 6 10 14 18 22]

    dur = 300;
    if  ~isempty(regexp(conds{c},'_bw_'))
        sbp = 4;
        sbp2 = 2;
    elseif  ~isempty(regexp(conds{c},'_po_'))
        sbp = 7;
        sbp2 = 3;
    else
        sbp = 1;
        sbp2 = 1;
    end
    col = 'k';
    if ~isempty(regexp(conds{c},'bright'))
        sbp = sbp+1;
        col = 'b';
        br = 1;
    else
        br = 2;
    end

    behv = ALL_BEH(c,:);
    speed = squeeze(ALL_SPEED(c,:,:));
    bck = speed(:,1:149);
    med = median(bck');
    st = std(bck');
    speed = speed(:,152:end);
    [th1,th2] = max(speed');
    m1 = []; m2 = [];
    mx = [];
    for a = 1:size(speed,1)
        [t1,t2] = find(speed(a,4:end)>30);
        if isempty(t1)
            m1 = [m1;0]; m2 = [m2;0];
            mx = [mx;0];
        else
            m1 = [m1;t1(1)]; m2 = [m2;t2(1)+5];
            mx = [mx;max(speed(a,4+t2(1):min(4+t2(1)+10,size(speed,2))))];
        end

    end

    tmp = find(m1>0);
    latencyescape = m2(tmp);
    behv = behv(tmp);
    maxspeed = mx(tmp);

    subplot(1,2,1)
    cd = cdfplot(latencyescape./30);
    set(cd,'color',specCol(sbp2))
    if br == 1
        set(cd,'LineStyle','--')
    end
    hold on


    subplot(1,2,2)
    cd = cdfplot(maxspeed);
    set(cd,'color',specCol(sbp2))
    if br == 1
        set(cd,'LineStyle','--')
    end
    hold on
end
subplot(1,2,1)
legend({'Mm-bright','Pm-bright','Pp-bright','Mm-dim','Pm-dim','Pp-dim'})
title('latency to running for black loom')
xlabel('latency (sec)')
ylabel('fraction of animals')
subplot(1,2,2)
legend({'Mm-bright','Pm-bright','Pp-bright','Mm-dim','Pm-dim','Pp-dim'})
title('max. speed for black loom')
xlabel('max. speed first bout (cm/s)')
ylabel('fraction of animals')

%% Heading angles after black loom (Fig. 1F-H)
window =  30;%frames at 30Hz
THR = 150;%150 is 10cm/s

llight = {'bright','dim'};
lstim = {'dim','loom','white'};

Aall = [];supercnt = 0; cntr = 0;
AperCond = cell(5,1);
for c = [2 6 10 14 18 22 ]
    take = TAKEN(c,:); take = find(take>0);
    coordx = COORDX(c,take);
    coordy = COORDY(c,take);
    fps = FPS(c,take);
    ids = IDS(c,take);
    px2cm = PIX2CM(c,take);
    cntr = cntr+1;

    disp('=====================================')
    disp(conds{c})

    A = []; ST = []; Mfirst = [];  Mrest = [];
    for a = 1:length(coordx)
        supercnt = supercnt +1;
        autobehv = behv_auto_curr(supercnt);
        x = coordx{a};
        y = coordy{a};
        if ids(a)~=2
            start = fps(a)*5;
            x = x(start:end);
            y = y(start:end);
        end

        startnow = fps(a)*5;
        xx = x(startnow:startnow+fps(a)*10);
        yy = y(startnow:startnow+fps(a)*10);

        dx = diff(xx);
        dy = diff(yy);
        vel = sqrt(dx.^2 + dy.^2);
        vel = vel*px2cm(a)*fps(a);



        prex = x(startnow-fps(a):startnow-1);
        prey = y(startnow-fps(a):startnow-1);

        coeffs = polyfit(xx, yy, 1);  % 1st order polynomial fit
        slope = coeffs(1);

        % Calculate angle from slope (-90 to 90 degrees)
        angle_deg = atand(slope);

        x_diff = xx(end) - xx(1);
        y_diff = yy(end) - yy(1);

        if x_diff > 0  % Moving rightward
            if y_diff < 0  % Moving downward (top-left to bottom-right)
                angle = 270 - angle_deg;
            else  % Moving upward (bottom-left to top-right)
                angle = angle_deg;  % Equivalent to just angle_deg
            end
        else  % Moving leftward
            angle = 180 + angle_deg;

        end

        % Ensure angle is in [0,360)
        angle = mod(angle, 360);
        Aall = [Aall;angle];


        AA = [];
        for s = 1:fps(a)/30*window:length(xx)-fps(a)/30*window



            currx = xx(s:s+fps(a)/30*window);
            curry = yy(s:s+fps(a)/30*window);
            dx = diff(currx);
            dy = diff(curry);
            L = sum(sqrt(dx.^2 + dy.^2));
            if L>THR
                coeffs = polyfit(currx, curry, 1);  % 1st order polynomial fit
                slope = coeffs(1);

                % Calculate angle from slope (-90 to 90 degrees)
                angle_deg = atand(slope);

                x_diff = currx(end) - currx(1);
                y_diff = curry(end) - curry(1);

                if x_diff > 0  % Moving rightward
                    if y_diff < 0  % Moving downward (top-left to bottom-right)
                        angle = 270 - angle_deg;
                    else  % Moving upward (bottom-left to top-right)
                        angle = angle_deg;  % Equivalent to just angle_deg
                    end
                else  % Moving leftward

                    angle = 180 + angle_deg;

                end

                % Ensure angle is in [0,360)
                angle = mod(angle, 360);
                AA = [AA angle];
            else
                AA = [AA NaN];
            end

        end
        stnow = nanstd(AA);
        A = [A;AA];
        ST = [ST;stnow];
        tmp = find(~isnan(AA));
        AAt = AA(tmp);
        Mfirst = [Mfirst AAt(1:min(3,length(AAt)))];%Mfirst = [Mfirst;nanmedian(AA(1:min(3,length(AA))))];
        if length(AAt)>3
            Mrest = [Mrest AAt(4:end)];
        end
    end

    if c<13
        subplot(2,3,1)
    else
        subplot(2,3,4)
    end


    tmp = find(~isnan(A));
    h = polarhistogram(deg2rad(A(tmp)), deg2rad(0:30:360), 'linewidth',3,'normalization','probability');
    h.DisplayStyle = 'stairs';
    hold on
    if c<13
        title('all bright')
    else
        title('all dim')
    end

    % do circular statistics
    AperCond{cntr} = A(tmp);
    A_rad = circ_ang2rad(A(tmp));
    A_mean = circ_rad2ang(circ_mean(A_rad));
    A_median =  circ_rad2ang(circ_median(A_rad));

    R_A = circ_r(A_rad); %length
    S_A = circ_var(A_rad);%variance
    [s_A s0_A] = circ_std(A_rad);%std
    disp(['mean deg: ',num2str(A_mean),', median deg: ',num2str(A_median),', length: ',num2str(R_A)])
    b_A = circ_skewness(A_rad);%swesness
    k_A = circ_kurtosis(A_rad);%kurtosis
    %'Inferential Statistics\n\nTests for Uniformity\
    pr_alpha = circ_rtest(A_rad);%Rayleigh test, unimodla deviation from uniformity
    po_alpha = circ_otest(A_rad);%Omnibus Test, general deviation (also multimodal)
    pra_alpha = circ_raotest(A_rad);%Rao Spacing Test, less assumptions than rayleigh
    pv_alpha = circ_vtest(A_rad,circ_ang2rad(180));%V test, quite useless
    disp(['tests of uniformity: ',num2str(pr_alpha),', ',num2str(po_alpha),', ',...,
        num2str(pra_alpha),', ',num2str(pv_alpha),', '])
    %Tests concerning Mean and Median angle
    t_alpha = circ_confmean(A_rad,0.05);
    disp(['Mean, up 95 perc. CI:', num2str(circ_rad2ang(circ_mean(A_rad)+t_alpha ))])
    h1 = circ_mtest(A_rad,0);
    fprintf('Mean Test, mean = 0 deg:\t\t%d\n',h1)
    h1 = circ_medtest(A_rad,circ_ang2rad(25));
    fprintf('Median Test, median = 25 deg:\t%.2f\n',h1)
    h1 = circ_symtest(A_rad);
    disp(['Symmetry around median: ',num2str(h1)])


    if c<13
        subplot(2,3,2)
    else
        subplot(2,3,5)
    end
    tmp = find(~isnan(Mfirst));
    h = polarhistogram(deg2rad(Mfirst(tmp)), deg2rad(0:30:360), 'linewidth',3,'normalization','probability');
    h.DisplayStyle = 'stairs';
    hold on
    if c<13
        title('first bright')
    else
        title('first dim')
    end

    if c<13
        subplot(2,3,3)
    else
        subplot(2,3,6)
    end
    tmp = find(~isnan(Mrest));
    h = polarhistogram(deg2rad(Mrest(tmp)), deg2rad(0:30:360), 'linewidth',3,'normalization','probability');
    h.DisplayStyle = 'stairs';
    hold on
    if c<13
        title('rest bright')
    else
        title('rest dim')
    end


end

%circular ANOVA
%black looming bright
theta1 =AperCond{1};
theta2 =AperCond{2};
theta3=AperCond{3};
idx1 = repmat(1,length(AperCond{1}),1);
idx2 = repmat(2,length(AperCond{2}),1);
idx3 = repmat(3,length(AperCond{3}),1);
theta = [theta1;theta2;theta3];
idx = [idx1;idx2;idx3];
p = circ_wwtest(theta,idx);%ONE FACTOR ANOVA, theta1 vs theta2 vs theta3
p = circ_wwtest(theta1,theta2)
p = circ_wwtest(theta1,theta3)
p = circ_wwtest(theta2,theta3)
idp = [idx1;idx2];
idq = idp(randperm(length(idp))); % factor 2: random assignment to groups

p = circ_hktest([theta1; theta2], idp,idq,true);

%black looming dim
theta1 =AperCond{4};
theta2 =AperCond{5};
theta3=AperCond{6};
idx1 = repmat(1,length(AperCond{4}),1);
idx2 = repmat(2,length(AperCond{5}),1);
idx3 = repmat(3,length(AperCond{6}),1);
theta = [theta1;theta2;theta3];
idx = [idx1;idx2;idx3];
p = circ_wwtest(theta,idx);%ONE FACTOR ANOVA, theta1 vs theta2 vs theta3

p = circ_wwtest(theta1,theta2)
p = circ_wwtest(theta1,theta3)
p = circ_wwtest(theta2,theta3)

idp = [idx1;idx2];
idq = idp(randperm(length(idp))); % factor 2: random assignment to groups

p = circ_hktest([theta1; theta2], idp,idq,true);

%% Behaviour transitions black loom (Fig. 2I)
bname = {'none','stop','escape','run','dart to safety','dart'};
BCOL3 = [0 0 0;0.8510    0.3725    0.0078; ...,
    0.1059    0.6196    0;0.1059    0.6196    0.8;...,
    0.8    0.4392    0.7020;0.4588    0    0.7020];

tk = find(stimuli == 2);%black loom only
aids = animalid_all(tk);
spcs = species_all(tk);
lght = light_all(tk);%1-bright
bhv = behv_auto_curr(tk);

au = unique(aids);

trans = [];
specs = [];
lightn = [];
for a = 1:length(au)
    tmp = find(aids==au(a));

    if length(tmp)>1
        trans = [trans;bhv(tmp)'];
        specs = [specs;spcs(tmp(1))];
        lightn = [lightn;lght(tmp)'];
    end
end
trans = fliplr(trans);
uT = unique(trans,'rows');

figure
X = [0 0.5 0.5 0 -0.5 -0.5];
Y = [1 0.5 -0.5 -1 -0.5 0.5];
for u = 1:length(uT)
    curr = uT(u,:);
    now = ismember(trans,curr,'rows');
    now = find(now==1);
    p = plot([X(curr(1)+1) X(curr(2)+1)],[Y(curr(1)+1) Y(curr(2)+1)],'-','color',BCOL3(curr(1)+1,:),'linewidth',length(now)*2)
    p.Color(4) = 0.5;
    hold on
end
for x = 1:length(X)
    text(X(x),Y(x),bname{x},'color','r')
end
%% Bar plots per stimulus (Fig. 2C, Fig. 3B)
auto_totake = behv_auto_curr;
% auto:
% 0 = none, k
% 0 = none, k
% 1 = stop, r
% 2 = escape to shelter, green
% 4 = dart to shelter, bright g
% 3 = run no shelter, bright purple
% 5 = dart, purple
specs = {'Mm','Pm','Pp'};
stims = {'dimm','black loom','white loom'};

figure
cols = BCOL;
cols(4,:) = cols(4,:)*1.4;
cols(5,:) = cols(5,:)*1.4;
for l = 0:1 % go through light levels
    idsl = find(light_all==l);
    for s = 1:3%go through stimuli
        ids2 = find(stimuli(idsl)==s);
        ids = idsl(ids2);
        subplot(2,3,s+(3*l))
        coll = [];
        for m = 1:3 % go through species
            ids2 = find(species_all(ids)==m);
            idsf = ids(ids2);
            autob = auto_totake(idsf);
            autob_perc = [];
            for b = 0:5
                tmp = find(autob==b);
                per = 100/length(autob)*length(tmp);
                autob_perc = [autob_perc per];
            end
            coll = [coll;autob_perc];
        end
        b = bar(coll,'stacked' ,'edgecolor','none');
        realids = sum(coll,1);
        realids = find(realids>0);
        for bb = 1:length(b)
            b(bb).FaceColor = cols(bb,:);
        end
        set(gca,'xtick',1:3,'xticklabel',specs)
        if l==0
            title(['dim - ',stims{s}])
        else
            title(['bright - ',stims{s}])
        end
    end
end

%% Hunting (Fig. 3E)
values = logspace(log10(1), log10(255), 10);
cmaph = cmocean('haline');
cmaph = cmaph(round(values),:);
cmaph = flipud(cmaph);
speclist ={'P. pol.','P. man.','Mus'};

figure('position',[490 130 490 530])
for c = 1:6
    if c <4
        subplot(3,2,c*2)
        first = HUNTING_LAT{c,1};
        ALL = HUNTING{c,1};
    else
        subplot(3,2,(c-3)*2-1)
        first = HUNTING_LAT{c-3,2};
        ALL = HUNTING{c-3,2};
    end



    [s1,s2 ]= sort(first);
    imagesc(ALL(s2,:),[0 100])
    colormap(cmaph)

    if c == 1 || c == 4
        si = 3;
    elseif c == 2 || c == 5
        si = 2;
    else
        si = 1;
    end
    if c<4
        light = 'bright';
    else
        light = 'dim';
    end

    title([speclist{si},' ',light])

    if c == 6
        set(gca,'xtick',[200:200:800],'xticklabel',[20:20:80])
        xlabel('cm')
        set(gca,'ytick',[])
    else
        axis off

    end
end

%% Pre-stimulus behaviour (Fig. 4C)
figure
for s = 2:4%Mm, Pm, Po
    for nd = 1:2

        data = medianSpeed{s}(:,nd);%for each behaviour (none, other, stop, escape, skittish)

        data2 = [];
        for ii = 1:length(data)
            if size(data{ii},1)>size(data{ii},2)
                data2 = [data2 data{ii}'];
            else
                data2 = [data2 data{ii}];
            end
        end

        subplot(1,3,s-1)
        sc=swarmchart(repmat(nd,length(data2),1),data2,10, 'k','filled');
        hold on
        plot([nd-0.4 nd+0.4],[nanmedian(data2) nanmedian(data2)],'-r','linewidth',2)

    end
    set(gca,'xtick',1:2,'xticklabel',{'dim','bright'})
    title(sl{s-1})
    ylabel('medina pre-stim speed (cm/s)')
end


