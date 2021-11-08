function measurement_matrix = parse_fnirs_channels_nirstar(inlet)

% get the full stream info (including custom meta-data) and dissect it
inf = inlet.info();
tags = inf.desc();
tags.first_child().name();
tags.first_child().next_sibling().name();
tags.first_child().next_sibling().next_sibling().name();

%Get information about the stream
stream_info = inlet.info();

% Get individual stream attributes
stream_name= stream_info.name();
stream_mac= stream_info.type();
stream_n_channels = stream_info.channel_count();

% %% Store Source location in a containers map
% 
% % Get number of sources
% nsources = tags.child('montage').child_value('nsources');
% ns= str2num(nsources);
% 
% % Create 3 container.maps for x,y and z coordinates
% xs_cor = containers.Map('KeyType','double','ValueType','any');
% ys_cor = containers.Map('KeyType','double','ValueType','any');
% zs_cor = containers.Map('KeyType','double','ValueType','any');
% 
% % Define source pointer
% source_pnt = stream_info.desc().child('montage').child('optodes').child('sources').child('source');
% 
% 
% sc=0;
% 
% % Run for loop to gather all the sources x,y,z coordinates
% for i=1:ns
%     sc= i+1;
%     src_x= source_pnt.child('location').child_value('x');
%     dtc_y= source_pnt.child('location').child_value('y');
%     dtc_z= source_pnt.child('location').child_value('z');
% 
%     xs_cor(sc) = [src_x];
%     ys_cor(sc) = [dtc_y];
%     zs_cor(sc) = [dtc_z];
% 
%     source_pnt = source_pnt.next_sibling();
%     source_location = source_pnt.child('location').next_sibling();
% end
% 
% 
% 
% %% Store Detector location in a containers map
% 
% % Get number of sources
% ndetectors = tags.child('montage').child_value('ndetectors');
% nd= str2num(ndetectors);
% 
% % Create 3 container.maps for x,y and z coordinates
% xd_cor = containers.Map('KeyType','double','ValueType','any');
% yd_cor = containers.Map('KeyType','double','ValueType','any');
% zd_cor = containers.Map('KeyType','double','ValueType','any');
% 
% % Define source pointer
% detector_pnt = stream_info.desc().child('montage').child('optodes').child('detectors').child('detector');
% 
% dt=0;
% 
% % Run for loop to gather all the detectord x,y,z coordinates
% for m=1:nd
%     dt= m+1;
%     dtc_x= detector_pnt.child('location').child_value('x');
%     dtc_y= detector_pnt.child('location').child_value('y');
%     dtc_z= detector_pnt.child('location').child_value('z');
% 
%     xd_cor(dt) = [dtc_x];
%     yd_cor(dt) = [dtc_y];
%     zd_cor(dt) = [dtc_z];
% 
%     detector_pnt = detector_pnt.next_sibling();
%     detector_location = detector_pnt.child('location').next_sibling();
% end

%% Scan LSL metadata to parse information about fNIRS channels only 

ch = stream_info.desc().child('channels').child('channel');

% Fill measurement list channel-by-channel
% Columns: [s d wl lsl_vector_index) 
nirs_channel = 1;
for k = 1:(stream_n_channels)
    if strcmp(ch.child_value('type'),'nirs_raw')    %If the channel is NIRS, let's parse the metadata
        label = ch.child_value('label');
        wl = ch.child_value('wavelength');
        rg = regexp(label,'(?<s>\d+)-(?<d>\d+)','names'); %extract the source number s and detector number d
        meas_list(nirs_channel,1) = str2double(rg.s);
        meas_list(nirs_channel,2) = str2double(rg.d);
        meas_list(nirs_channel,3) = str2double(wl);
        meas_list(nirs_channel,4) = k;   % This is the index(position) of channel in the LSL vector being streamed
        nirs_channel = nirs_channel +1;   % Increase nirs channel counter 
    end
    ch = ch.next_sibling(); % Move to next LSL channel
end

%% Convert to measurement_matrix: [s d wl1_lsl_index wl2_lsl_index]

% Extract list of all wavelengths streamed by this device
wl_list = unique(meas_list(:,3));
%If wl_list is only two wavelengths, we are good. If more than two, we must select the two preferred wavelengths

measurement_matrix = zeros(size(meas_list,1)/length(wl_list),4); %Prepare for efficiency
channel_list = unique(meas_list(:,1:2),'rows');   % Pull unique list of s-d pairings

% For all occurrences of each s-d pairings, copy LSL index into column 3 and 4 of new matrix 
for i = 1: size(channel_list,1)
   [r1,~] = find(ismember(meas_list(:,1:3),[channel_list(i,:) wl_list(1)],'rows'));   % Find row where s-d pairing at wl1 is
   [r2,~] = find(ismember(meas_list(:,1:3),[channel_list(i,:) wl_list(2)],'rows'));   % Find row where s-d pairing at wl2 is
   measurement_matrix(i,1:2) = channel_list(i,:);   % Place unique s-d pairings
   measurement_matrix(i,3) = meas_list(r1,4);       % Place lsl_index of wl1
   measurement_matrix(i,4) = meas_list(r2,4);       % Place lsl_index of wl2
end

