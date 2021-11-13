function [lsl_buffer] = fill_lsl_buffer(inlet,lsl_buffer)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Read a chunk of data and fill the buffer (all devices)
while nnz(lsl_buffer(:,1)) < size(lsl_buffer,1) % if the FIFO buffer is not totally full (first few secs), wait until it fills
    while 1
        [chunk,~] = inlet.pull_chunk(); % Pull a chunk of fresh samples
        if ~isempty(chunk)
            break
        end
    end
    chunk = chunk';
    if size(chunk,1) < size(lsl_buffer,1)    % If the data chunk is smaller than the buffer
        lsl_buffer(1:size(lsl_buffer,1)-size(chunk,1),:) = lsl_buffer(size(chunk,1)+1:end,:); % Shift up the buffer to make room 
        lsl_buffer(size(lsl_buffer,1)-size(chunk,1)+1:end,:) = chunk; % Put chunk in buffer
    else
        lsl_buffer(:,:) = chunk(size(chunk,1)-size(lsl_buffer,1)+1:end,:); % Put chunk in buffer
    end% Put chunk in buffer
end
% We are repeating the same code above to make room for new samples when the buffer is already filled from previous pulls 
while 1
    [chunk,~] = inlet.pull_chunk(); % Pull a chunk of fresh samples
    if ~isempty(chunk)
        break
    end
end
chunk = chunk';
if size(chunk,1) < size(lsl_buffer,1)    % If the data chunk is smaller than the buffer
    lsl_buffer(1:size(lsl_buffer,1)-size(chunk,1),:) = lsl_buffer(size(chunk,1)+1:end,:); % Shift up the buffer to make room 
    lsl_buffer(size(lsl_buffer,1)-size(chunk,1)+1:end,:) = chunk; % Put chunk in buffer
else
    lsl_buffer(:,:) = chunk(size(chunk,1)-size(lsl_buffer,1)+1:end,:); % Put chunk in buffer
end

end

