function channel_coordinates = parse_fnirs_channels_coordinates_nirstar(inlet)

% get the full stream info (including custom meta-data) and dissect it
inf = inlet.info();
tags = inf.desc();

%Get information about the stream
stream_info = inlet.info();

% Get individual stream attributes
stream_name= stream_info.name();
stream_mac= stream_info.type();
stream_n_channels = stream_info.channel_count();

%Point to channel tag
chn = stream_info.desc().child('channels').child('channel');

%% Get Channel Coordinates
nirs_channel = 1;
cor_list = [];
for k = 1:(stream_n_channels)
    if strcmp(chn.child_value('type'),'nirs_raw')    %If the channel is NIRS, let's parse the metadata
        x_cor = chn.child('location').child_value('x');  %Access x coordinate of channel
        y_cor = chn.child('location').child_value('y');  %Access y coordinate of channel
        z_cor = chn.child('location').child_value('z');  %Access z coordinate of channel
        cor_list(nirs_channel,1) = str2double(x_cor);  %String to number
        cor_list(nirs_channel,2) = str2double(y_cor);  %String to number
        cor_list(nirs_channel,3) = str2double(z_cor);  %String to number
        nirs_channel = nirs_channel +1;   % Increase nirs channel counter       
    end
    chn = chn.next_sibling(); % Move to next LSL channel
end
