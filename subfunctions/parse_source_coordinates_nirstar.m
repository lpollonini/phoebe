function src_cor = parse_source_coordinates_nirstar(inlet)

% get the full stream info (including custom meta-data) and dissect it
inf = inlet.info();
tags = inf.desc();

%Get information about the stream
stream_info = inlet.info();

% Get individual stream attributes
stream_name= stream_info.name();
stream_mac= stream_info.type();
stream_n_channels = stream_info.channel_count();

%% STORE SOURCE COORDINATES (X Y Z) %%
nsources = str2double(tags.child('montage').child_value('nsources')); %number of sources

src_loc_pnt = stream_info.desc().child('montage').child('optodes').child('sources').child('source'); %point to source tag

source_count = 1;
for k = 1:(nsources)
        src_label = src_loc_pnt.child_value('label');
        src_x= src_loc_pnt.child('location').child_value('x');  %Get source X coordinate
        src_y= src_loc_pnt.child('location').child_value('y');  %Get source Y coordinate 
        dtc_z= src_loc_pnt.child('location').child_value('z');  %Get source Z coordinate
        src_cor(source_count,1) = str2double(src_x);   %String to number 
        src_cor(source_count,2) = str2double(src_y);   %String to number
        src_cor(source_count,3) = str2double(dtc_z);   %String to number
        source_count = source_count +1;   % Increase source counter 
        src_loc_pnt = src_loc_pnt.next_sibling(); % Move to next source     
end