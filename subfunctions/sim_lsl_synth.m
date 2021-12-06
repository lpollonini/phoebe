function sim_lsl_synth(lib,streaming_type)
%SIM_LSL_SYNTH Simulates metadata and data lsl streams using nirstoolbox.
% 
% Arguments
% Input 
% 
% lib               : lsl library, e.g., lib = lsl_loadlib();
% streaming_type    : 'nirs_raw'  will stream raw values
%                   'nirs_hb' will stream Hb values with a DPF value (see
%                   below)
% Notes: The chosen DPF value MUST match the value used in Phoebe.


DPF = 5.9;
if strcmp(streaming_type,'nirs_raw')==1
    unit_type = 'V';
else
    unit_type = 'Hb';
end
probe = nirs.testing.simProbe;
raw = nirs.testing.simARNoise(probe,[],[],0.2);
raw = raw.sorted({'source','detector'});

raw_cardiac = nirs.testing.simPhysioNoise(raw,1.0);
raw_cardiac = raw_cardiac.sorted({'source','detector'});

raw.data(:,1:end/2) = raw_cardiac.data(:,1:end/2);
nsrc = size(raw.probe.srcPos,1);
ndet = size(raw.probe.detPos,1);
links = raw.probe.link;
src3d = raw.probe.srcPos3D;
det3d = raw.probe.detPos3D;
lambda = raw.probe.types;
Fs = raw.Fs;
nchannels = height(links)/2;
nsamples = size(raw.data,1);
% obtaining Hb
j = nirs.modules.OpticalDensity();
j = nirs.modules.BeerLambertLaw(j);
j.PPF = DPF;
hb = j.run(raw);

info = lsl_streaminfo(lib,'NIRStar','NIRS',nchannels*2+1,Fs,'cf_float32','NIRStar');

% Creating fake hardware under info
hwd = info.desc().append_child('hardware');
hwd.append_child_value('device','NIRScout 16x24');
hwd.append_child_value('source_type','LED');
hwd.append_child_value('detector_type','SiPD');
hwd.append_child_value('serial_number','1599990');
hwd.append_child_value('nirstar_version','15.3');
hwd.append_child_value('ntrigger_inputs','0');
hwd.append_child_value('ntrigger_outputs','0');
hwd.append_child_value('nanalog_inputs','0');

%Creating montage under info
mntg = info.desc().append_child('montage');
mntg.append_child_value('nsources',num2str(nsrc));
mntg.append_child_value('ndetectors',num2str(ndet));
mntg.append_child_value('nshortdetectors','0');
mntg.append_child_value('steps_per_frame','8');
mntg.append_child_value('sampling_rate',num2str(Fs));
mntg.append_child_value('coordinate_units','mm');
mntg.append_child_value('headmodel',' ');
mntg.append_child_value('hyperscan','False');

%Creating optodes under montage
opt = mntg.append_child('optodes');

% Creating source under optodes
srcs = opt.append_child('sources');
for i=1:nsrc
    src = srcs.append_child('source');
    src.append_child_value('label',num2str(i));
    srcloc = src.append_child('location');
    srcloc.append_child_value('x',num2str(src3d(i,1)));
    srcloc.append_child_value('y',num2str(src3d(i,2)));
    srcloc.append_child_value('z',num2str(src3d(i,3)));
    srcloc.append_child_value('u','0.000000');
    srcloc.append_child_value('v','0.000000');
    src.append_child_value('subject','1');
end

% Creating detector under optodes
dtcs = opt.append_child('detectors');
for i=1:ndet
    dtc = dtcs.append_child('detector');
    dtc.append_child_value('label',num2str(i));
    dtcloc = dtc.append_child('location');
    dtcloc.append_child_value('x',num2str(det3d(i,1)));
    dtcloc.append_child_value('y',num2str(det3d(i,2)));
    dtcloc.append_child_value('z',num2str(det3d(i,3)));
    dtcloc.append_child_value('u','0.00000');
    dtcloc.append_child_value('v','0.00000');
    dtc.append_child_value('subject','1');
end

%Creating wavelengths under info
wls = info.desc().append_child('wavelengths');
for i = 1:length(lambda)
    wl= wls.append_child('wavelength');
    wl.append_child_value('wavelength',num2str(lambda(i)));
end

%Creating channels under info [two wavelengths(760, 850)]
chns = info.desc().append_child('channels');
% timeframe
ch = chns.append_child('channel');
ch.append_child_value('label','frame');
ch.append_child_value('type','nirs_frame');
ch.append_child_value('unit',' ');

iCh =1;
for i = 1:height(links)
    ch = chns.append_child('channel');
    ch.append_child_value('label',sprintf('%i-%i:%i',...
        links.source(i),links.detector(i),iCh));
    ch.append_child_value('type',streaming_type);
    ch.append_child_value('unit',unit_type);
    ch.append_child_value('subject','1');
    ch.append_child_value('distance','30.000');
    chloc = ch.append_child('location');
    chloc.append_child_value('x','0.00000');
    chloc.append_child_value('y','0.00000');
    chloc.append_child_value('z','0.00000');
    chloc.append_child_value('u','0.00000');
    chloc.append_child_value('v','0.00000');
    ch.append_child_value('wavelength',num2str(links.type(i)));
    ch.append_child_value('source_amplitude','0.00000');

    if iCh==(height(links)/2)
        iCh=1; 
    else
        iCh = iCh+1;
    end
end


% streaming data

disp('Opening an outlet...');
outlet = lsl_outlet(info);

% send data into the outlet, sample by sample
fprintf('Now transmitting data...\nSample#:');

for i=1:nsamples
    if strcmp(streaming_type,'nirs_raw')==1
        outlet.push_sample([i,raw.data(i,:)]);
    else
        outlet.push_sample([i,hb.data(i,:)]);
    end
    
    isamp = num2str(i);
    fprintf('%s',isamp);
    pause(1/Fs);
    fprintf(repmat('\b',1,length(isamp)));
end

outlet.delete();
disp('End of streaming.');

end

