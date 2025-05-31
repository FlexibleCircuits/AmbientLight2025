clear
close all
clc

%% directories and fixed variables
pathData = 'C:\Users\you\data';
pathCode = 'C:\Users\you\code';
addpath(genpath(pathCode))

load(fullfile(pathData,'main_data'))
load(fullfile(pathData,'main_data_hunting'))
load(fullfile(pathData,'main_data_foraging'))

stopping = [2,3];%1
escaping = [1,5,7,11];%2
dart = [4,8];%3
other = [6,9,10];%4

specs = [1 1 1 1 2 2 2 2 3 3 3 3 1 1 1 1 2 2 2 2 3 3 3 3];
behaviourgroup = {'stopping','escape','darts to safety','darts'};
stimlist = {'sweeping','black looming','white looming','dimming'};
speclist ={'P. pol.','P. man.','Mus'};
params = {'medianSpeed','%TimeCenter','%TimeShelter','%TimeDangerZone','distTravelled'};
cmp = [0.5 0.5 0.5;  0.5 0.5 0.5;0.851 0.3725 0.0078; 0.6980    0.8745    0.5412;0.1059    0.6196    0.4667;0.2 0.4 0.2];

expa10Duration = 300;%expa10Duration = 291; in frames given 30fps
expa06Duration = 150;%expa06Duration = 145;
dimmDuration = 150; %dimmDuration = 145;
sweepingDuration = 300;%sweepingDuration = 183;
huntingDuration = 300;
%% Behaviour classes (Figure 1)
figure('position',[360 360 880 190])
for b = 1:3 % go through behaviour types (stop, escape, dart)

    row = []; col = [];
    for r = 1:size(ALL_BEH,1) % go through conditions

        for c = 1:size(ALL_BEH,2)
            if b == 1
                if ~isempty(find(stopping == ALL_BEH(r,c)))
                    row = [row r];
                    col = [col c];

                end
            elseif b == 2
                if ~isempty(find(escaping == ALL_BEH(r,c)))
                    row = [row r];
                    col = [col c];

                end
            elseif b ==3
                if ~isempty(find(dart == ALL_BEH(r,c)))
                    row = [row r];
                    col = [col c];

                end
            end
        end

    end



    DATA = [];
    for a = 1:length(row)
        curr = squeeze(ALL_SPEED(row(a), col(a),:));
        DATA = [DATA;curr'];
    end
    bck = mean(DATA(:,1:150)');
    st = std(DATA(:,1:150)');
    DATA2 = [];
    for d = 1:size(DATA,1)
        now = DATA(d,:);
        tmp = find(now<0);%smoothing can introduce some small neg. values
        now(tmp)=0;
        now2 = (now-bck(d))./st(d); %z-score
        DATA2 = [DATA2;now2]; %normalized running speed
    end

    DATA2 = DATA2(:,1:450);


    if b == 3
        incorner = [];
        for r = 1:length(row)
            incorner = [incorner ALL_CORN(row(r),col(r))];
        end
        tmp = find(incorner==0);%dart, no hiding
        data_dartNoH = DATA2(tmp,:);
        tmp = find(incorner==1);%dart, hiding
        data_dart = DATA2(tmp,:);
    end


    if b==1
        m1 = min(DATA2(:,151:400)');
        t1 = [];
        for d = 1:size(DATA2,1)
            tmp = find(DATA2(d,151:400)==m1(d));
            t1 = [t1;tmp(1)+150];
        end
        [s1,s2] = sort(t1,'ascend');
    elseif b == 2
        [m1,m2] = max(DATA2(:,151:400)');
        [s1,s2] = sort(m2,'ascend');

    end

    if b<3
        bb = b;
        axes('position',[0.09+(b-1)*0.2 0.1 0.15 0.6])
        imagesc(DATA2(s2,1:450),[-2 5])
        cmap = cmocean('balance',23);
        colormap(gca,[cmap(7,:); cmap(9,:); 0.8 0.8 0.8;cmap([14 16 18 20 22],:)])
        hold on
        plot([150 150],[0.5 size(DATA2,1)+0.5],'-k')
        axis off
        axes('position',[0.09+(b-1)*0.2 0.73 0.15 0.2])
        plot(nanmean(DATA2(:,1:450)),'-k')
        hold on
        box off
        axis([0 450 -1 4])
        set(gca,'xtick',[])
        title(behaviourgroup{bb})

        axes('position',[0.09+(b-1)*0.2-0.01 0.1 0.008 0.6])
        imagesc(specs(row(s2))',[1 3])
        colormap(gca,[0 0 0; 0.5 0.5 0.5;0.9 0.9 0.9])
        axis off


    else
        for bb = 3:4
            if bb == 3
                DATA2 = data_dart;
            else
                DATA2 = data_dartNoH;
            end
            [m1,m2] = max(DATA2(:,151:400)');
            [s1,s2] = sort(m2,'ascend');

            axes('position',[0.09+(bb-1)*0.2 0.1 0.15 0.6])
            imagesc(DATA2(s2,1:450),[-2 5])
            cmap = cmocean('balance',23);
            colormap(gca,[cmap(7,:); cmap(9,:); 0.8 0.8 0.8;cmap([14 16 18 20 22],:)])
            hold on
            plot([150 150],[0.5 size(DATA2,1)+0.5],'-k')
            axis off

            axes('position',[0.09+(bb-1)*0.2 0.73 0.15 0.2])
            plot(nanmean(DATA2(:,1:450)),'-k')
            hold on
            box off
            axis([0 450 -1 4])
            set(gca,'xtick',[])
            title(behaviourgroup{bb})

            axes('position',[0.09+(bb-1)*0.2-0.01 0.1 0.008 0.6])
            imagesc(specs(row(s2))',[1 3])
            colormap(gca,[0 0 0; 0.5 0.5 0.5;0.9 0.9 0.9])
            axis off



        end
    end

end

%% Heatmaps and behaviour classes per stimulus and species (Figure 2, 3)

zmax = 3; %max. z-score for plotting
short = 1; % ideal for white loom and dimming where fewer repetitions were shown

f1 = figure('position',[200 200 900 340]);
f2 = figure('position',[200 200 900 340]);

allBehvType = cell(12,1);

for c = 1:length(conds)

    idsorder = [];

    if ~isempty(regexp(conds{c},'dimm'))
        dur = dimmDuration;
        co = 4;
    elseif ~isempty(regexp(conds{c},'ex10'))
        dur = expa10Duration;
        co = 2;
    elseif ~isempty(regexp(conds{c},'ex06'))
        dur = expa06Duration;
        co = 3;
    elseif ~isempty(regexp(conds{c},'swep'))
        dur = sweepingDuration;
        co = 1;
    end
    if  ~isempty(regexp(conds{c},'_bw_'))
        r = 2;
    elseif  ~isempty(regexp(conds{c},'_po_'))
        r = 1;
    else
        r = 3;
    end
    if ~isempty(regexp(conds{c}(1:3),'dim'))
        fct = 0;
    else
        fct = 1;
    end

    ids = IDS(c,:);% which experimenter(different pre-stim times, need to be cropped differently)
    good = find(ids>0);% trials that were included in analysis
    beh = ALL_BEH(c,good); %manual behavior
    incorner =ALL_CORN(c,good);

    beh_type = [];% 0 = none, 1 = other, 2 = stop, 3 = escape, 4 = erratic

    for b = 1:length(beh)
        if beh(b) == 0
            beh_type = [beh_type;0];
        elseif ~isempty(find(beh(b)==stopping))
            beh_type = [beh_type;2];
        elseif ~isempty(find(beh(b)==escaping))
            beh_type = [beh_type;3];
        elseif ~isempty(find(beh(b)==dart))
            beh_type = [beh_type;4];
        elseif ~isempty(find(beh(b)==other))
            beh_type = [beh_type;1];
        else
            beh_type = [beh_type;-1];
        end
    end



    tmp  = find(beh_type>-1);%only trials that could be assigned a behavior
    DATA = squeeze(ALL_SPEED(c,good(tmp),:)); %condition (species,stimulus,lightlevel) x animals x time

    bck = mean(DATA(:,1:150)');
    st = std(DATA(:,1:150)');
    DATA2 = [];
    for d = 1:size(DATA,1)
        now = DATA(d,:);
        tmp = find(now<0);%smoothing can introduce some small neg. values
        now(tmp)=0;
        now2 = (now-bck(d))./st(d); %
        DATA2 = [DATA2;now2]; %normalized running speed
    end

    DATA2 = DATA2(:,1:150+dur);


    tmp = find(beh_type>-1);
    beh_type2 = beh_type(tmp);


    tmp = find(beh_type2==2);%stop
    [M1,M2] = min(DATA2(tmp,151:end)');
    [S1,S2] = sort(M2);
    DATA3 = DATA2(tmp(S2),:);
    bords = size(DATA3,1);

    if size(tmp,1)>size(tmp,2)
        tmp = tmp';
    end

    idsorder = tmp(S2);

    tmp = find(beh_type2==3);%escape
    DATAtemp = DATA2(tmp,:);
    [M1,M2] = max(DATAtemp(:,151:end)');
    [S1,S2] = sort(M2);
    DATAtemp = DATAtemp(S2,:);
    DATA3 = [DATA3;DATAtemp];
    bords = [bords;size(DATA3,1)];

    idstmp = tmp;
    idstmp = idstmp(S2);
    if size(idstmp,1)>size(idstmp,2)
        idstmp = idstmp';
    end
    idsorder = [idsorder idstmp];

    tmp = find(beh_type2==4);%darts
    DATAtemp = DATA2(tmp,:);
    [M1,M2] = max(DATAtemp(:,151:end)');
    [S1,S2] = sort(M2);
    DATAtemp = DATAtemp(S2,:);
    DATA3 = [DATA3;DATAtemp];
    bords = [bords;size(DATA3,1)];

    idstmp = tmp;
    idstmp = idstmp(S2);
    if size(idstmp,1)>size(idstmp,2)
        idstmp = idstmp';
    end
    idsorder = [idsorder idstmp];



    tmp = find(beh_type2==1);%other
    DATA3 = [DATA3;DATA2(tmp,:)];
    if size(tmp,1)>size(tmp,2)
        tmp = tmp';
    end
    idsorder = [idsorder tmp];

    if co ~= 2
        tmp = find(beh_type2==0);
        DATA3 = [DATA3;DATA2(tmp,:)];

        if size(tmp,1)>size(tmp,2)
            tmp = tmp';
        end
        idsorder = [idsorder tmp];
    end


    figure(f1)
    axes('position',[0.1+(co-1)*0.22+(fct*0.101) 0.1+0.28*(r-1) 0.098 0.22])
    if short == 1
        DATA3 = DATA3(:,120:300);
    end
    imagesc(DATA3,[-2 zmax])
    hold on
    if short == 1
        axis([0 180 -inf inf])
    else
        axis([0 150+dur -inf inf])
    end
    cmap = cmocean('balance',23);
    if zmax == 5
        colormap(gca,[cmap(7,:); cmap(9,:); 0.8 0.8 0.8;cmap([14 16 18 20 22],:)])
    else
        colormap(gca,[cmap(7,:); cmap(9,:); 0.8 0.8 0.8;cmap([14  18  22],:)])
    end
    if short == 1
        plot([31 31],[0.5 size(DATA3,1)+0.5],'--k')
    else
        plot([151 151],[0.5 size(DATA3,1)+0.5],'--k')
    end


    if r == 1 && co == 1
        if fct == 0
            if short == 0
                set(gca,'xtick',[0 150 300 450],'xticklabel',[-5 0 5 10])
            else
                set(gca,'xtick',[0 30 180],'xticklabel',[-1 0 5])
            end
            set(gca,'ytick','')
            xlabel('time (sec)')
            ylabel('# animals')
        else
            set(gca,'xtick',[],'ytick',[])
        end
    else
        set(gca,'xtick',[],'ytick',[])
    end

    if co == 1 && fct == 0
        text(-70,size(DATA,1)/2,speclist{r},'HorizontalAlignment','center','rotation',90)
    end

    if fct == 0 && r == 3
        if short == 0
            text(dur +150, 0-size(DATA,1)*0.1,stimlist{co},'HorizontalAlignment','center')
        else
            text(180, 0-size(DATA,1)*0.1,stimlist{co},'HorizontalAlignment','center')
        end
    end

    figure(f2)
    axes('position',[0.1+(co-1)*0.22+(fct*0.101) 0.1+0.28*(r-1) 0.098 0.22])
    tmp = find(beh_type2==4);
    inc = incorner(tmp);
    tmp2 = find(inc==0);
    beh_type3 = beh_type2;
    beh_type3(tmp(tmp2)) = 5;%the ones that don't go into shelter
    [s1,s2] = sort(beh_type3);
    imagesc(flipud(s1),[0 5])
    colormap(gca,cmp)
    if r == 1 && co == 1
        if fct == 0
            set(gca,'xtick',[1 ],'xticklabel',{'dim'})
            set(gca,'ytick',[])
        else
            set(gca,'xtick',[1 ],'xticklabel',{'bright'})
            set(gca,'ytick',[])

        end
    else
        set(gca,'xtick',[],'ytick',[])
    end
    if fct == 0 && r == 3
        text(1.5, 0-size(DATA,1)*0.1,stimlist{co},'HorizontalAlignment','center')
    end

    if co == 1 && fct == 0
        text(0.2,size(DATA,1)/2,speclist{r},'HorizontalAlignment','center','rotation',90)
    end

end

%% Hunting (Figure 3)
values = logspace(log10(1), log10(255), 10);
cmaph = cmocean('haline');
cmaph = cmaph(round(values),:);
cmaph = flipud(cmaph);

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

%% pre-stimulus behaviour
figure('position',  [488 120 770 570])
ndcolor = 'bk';
for s = 1:3%species
    for d = 1:5%variable
        for nd = 1:2%NDs
            subplot(5,1,d)
            if d == 1
                data = medianSpeed{s}(:,nd);%for each behaviour (none, other, stop, escape, skittish)
            elseif d == 2
                data = percentTimeCenter{s}(:,nd);
            elseif d == 3
                data = percentTimeShelter{s}(:,nd);
            elseif d == 4
                data = percentTimeDanger{s}(:,nd);
            elseif d == 5
                data = totDist{s}(:,nd);
            end

            escp = data{4};%escaping
            errat = data{5};%darting
            rest = [];%all other
            for x = 1:3
                if size(data{x},1)<size(data{x},2)
                    rest = [rest data{x}];
                else
                    rest = [rest data{x}'];
                end
            end
            hold on
            sc=swarmchart(repmat((s-1)*7+nd*3-3,length(escp),1),escp,5, ndcolor(nd),'filled');
            sc=swarmchart(repmat((s-1)*7+nd*3-2,length(errat),1),errat,5, ndcolor(nd),'filled');
            sc=swarmchart(repmat((s-1)*7+nd*3-1,length(rest),1),rest,5, ndcolor(nd),'filled');
            plot([(s-1)*7+nd*3-3-0.4 (s-1)*7+nd*3-3+0.4],[nanmedian(escp) nanmedian(escp)],'-','color',ndcolor(nd),'linewidth',2)
            plot([(s-1)*7+nd*3-2-0.4 (s-1)*7+nd*3-2+0.4],[nanmedian(errat) nanmedian(errat)],'-','color',ndcolor(nd),'linewidth',2)
            plot([(s-1)*7+nd*3-1-0.4 (s-1)*7+nd*3-1+0.4],[nanmedian(rest) nanmedian(rest)],'-','color',ndcolor(nd),'linewidth',2)

            ylabel(params{d})
            yl = get(gca,'ylim');
            axis([-1 20 -inf inf])

            if d == 1
                text(2,yl(2)*1.1,speclist{1})
                text(9,yl(2)*1.1,speclist{2})
                text(16,yl(2)*1.1,speclist{3})
            end
            if d == 5
                set(gca,'xtick',[0:5 7:12 14 16 17 19],'xticklabel',{'escape','darts','stop&none',...,
                    'escape','darts','stop&none','escape','darts','stop&none',...,
                    'escape','darts','stop&none','escape','stop&none','escape','stop&none'},'XTickLabelRotation',90)

            else
                set(gca,'xtick',[])
            end

        end

    end
end



