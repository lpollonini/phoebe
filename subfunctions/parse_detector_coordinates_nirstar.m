function dtc_cor = parse_detector_coordinates_nirstar(inlet)

% get the full stream info (including custom meta-data) and dissect it
inf = inlet.info();
tags = inf.desc();

%Get information about the stream
stream_info = inlet.info();

% Get individual stream attributes
stream_name= stream_info.name();
stream_mac= stream_info.type();
stream_n_channels = stream_info.channel_count();


%% STORE DETECTOR COORDINATES (X Y Z) %%

ndetectors = str2double(tags.child('montage').child_value('ndetectors')); %number of detector

dtc_loc_pnt = stream_info.desc().child('montage').child('optodes').child('detectors').child('detector'); %point to DETECTOR tag

detector_count = 1;
for k = 1:(ndetectors)
        dtc_x= dtc_loc_pnt.child('location').child_value('x'); %Get detector X coordinate
        dtc_y= dtc_loc_pnt.child('location').child_value('y'); %Get detector Y coordinate
        dtc_z= dtc_loc_pnt.child('location').child_value('z'); %Get detector Z coordinate
        dtc_cor(detector_count,1) = str2double(dtc_x); %String to number
        dtc_cor(detector_count,2) = str2double(dtc_y); %String to number
        dtc_cor(detector_count,3) = str2double(dtc_z); %String to number  
        detector_count = detector_count +1;   % Increase detector counter 
        dtc_loc_pnt = dtc_loc_pnt.next_sibling(); % Move to next detector    
end
