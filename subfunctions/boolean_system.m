
function [N]=boolean_system(n_opt,A,W)

% Generic solution of a boolean system with N optodes, with constant probe
% A (adjacency matrix) and weight W (related to SCI)

N = -1*ones(n_opt,1); % Initially, all optodes are undetermined

E = triu(A); % Active edges E: discards the lower symmetry of the adjacency matrix to have a unique pairing of Si and Dj
W = triu(W); % Discard the lower symmetry of W for same reason	

% If W(i,j)==1, then both Ni=1 and Nj=1
[opt1,opt2] = find(W==1); 

N(opt1) = 1;
N(opt2) = 1;

% If W(i,j)==0 with Ni=1 or Nj=1, then Nj=0 or Ni=0 (respectively)
[opt1,opt2]=find(W-E==-1); % We get -1 only where W(i,j)=0 but a connection exists in E(i,j)=1. Since both W and E are triu, then W-E is also triu
for i=1:length(opt1)
   if N(opt1(i))==1
      N(opt2(i))=0; 
   end
   if N(opt2(i))==1
      N(opt1(i))=0; 
   end
end

%At this point we could verify that the direct problem is still consistent
%with W   W=(N'*N).*A
% Then, for all undetermined optodes, we start cutting equations from the boolean system to see if we can converge 
%[opt1,opt2]=find(W==1)

green_optodes=find(N==1);
red_optodes=find(N==0);
undetermined_optodes=find(N==-1);

% opt_combs=dec2bin(0:2^n_opt-1,n_opt)-'0';  % All possible combinations of node status (0=disconnected, 1=connected)
% E=triu(A);  % Matrix of edges E: discards the lower simmetry of the adjacency matrix
% [eq_row,eq_col] = find(E==1);   % Identify the connections of the specific probe (constant)
% eq_combs=dec2bin(0:2^length(eq_row)-1,length(eq_row))-'0';  % All possible combinations of boolean equations
% eq_combs(1,:)=[];                                  % Delete the row with zero good SCIs (all undetermined) 
% green_array=zeros(size(eq_combs,1),n_opt);         % Array of optodes in contact with the scalp
% red_array=zeros(size(eq_combs,1),n_opt);           % Array of optodes uncoupled to the scalp
% undetermined_array=ones(size(eq_combs,1),n_opt);  % Array of undetermined optodes
% 
% for j=1:size(eq_combs,1)                % For all possible equations...
%     which_eq=find(eq_combs(j,:)==1);    % ...select the equations to form the boolean system
%     n_eq=length(which_eq);
%     eq_system=zeros(2^n_opt,n_eq);             % System of equations to solve [n_opt x n_eq]
%     for i=1:n_eq
%        eq_system(:,i) = ( opt_combs(:,eq_row(which_eq(i))) & opt_combs(:,eq_col(which_eq(i))) ) == W(eq_row(which_eq(i)),eq_col(which_eq(i))); 
%     end
%     
%     result = opt_combs(all(eq_system'),:);  % Array of solutions of the boolean system
%     
%     if isempty(result)
%         continue;
%     end
%     
%     if size(result,1)>1 % If the boolean system has one or more solutions (i.e. the status of at least one optode can be determined)  
%         green_array(j,:)=all(result);   % ...determine which optodes are commonly coupled to the scalp in all solutions
%         red_array(j,:)=all(~result);    % ...determine which optodes are commonly uncoupled to the scalp in all solutions
%         undetermined_array(j,:) = ones(1,n_opt)-green_array(j,:)-red_array(j,:);    %..and the remaining optodes are undetermined
%     else
%         green_array(j,:)=result;   % ...determine which optodes are commonly coupled to the scalp in all solutions
%         red_array(j,:)=~result;    % ...determine which optodes are commonly uncoupled to the scalp in all solutions
%         undetermined_array(j,:) = ones(1,n_opt)-green_array(j,:)-red_array(j,:);    %..and the remaining optodes are undetermined
%     end
% end
% 
% num_undetermined=sum(undetermined_array,2);     % For all combinations of equations, calculate how many undetermined optodes...
% green_map=green_array(find(num_undetermined==min(num_undetermined)),:)    % ...and select only the optode combination that minimize the uncertain optodes 
% red_map=red_array(find(num_undetermined==min(num_undetermined)),:)      % ...and select only the optode combination that minimize the uncertain optodes
% undetermined_map=undetermined_array(find(num_undetermined==min(num_undetermined)),:)
% 
% green_optodes=green_map(1,:)
% red_optodes=red_map(1,:)
% undetermined_optodes=undetermined_map(1,:)



