function  connected = w3conn()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~,b]=dos('ping -n 1 www.google.com');
n=strfind(b,'Lost');
n1=b(n+7);
if(n1=='0')
    connected = 1;
else
    connected = 0;
end
end

