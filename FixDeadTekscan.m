%% Written by James Caldwell, University of Virginia

% Created: 10/27/2022
% Last Updated: 12/15/2022

% Nanochon Project: 2022-Weightbearing

% Purpose: Fix Tekscan rows/columns that have died with an average of the
% rows/columns on either side of them

%Designed to be run after tekscanFramesToStruct in something such as
%tekscanConditionsSideBySide.
%Function would be called like FixDeadTekscan(frames_15_defect,0)

function [frames] = FixDeadTekscan(frames) %,side) removed this so that always updating medial and lateral sides

%Side:
%Side = -1 fix lateral
%Side = 0  fix both
%Side = 1  fix medial

% don't need this and always fix both sides
% if side == -1
%     lateralmedial = {'Lat'};
%     m = 1;
% elseif side == 1
%     lateralmedial = {'Med'};
%     m = 1;
% elseif side == 0 
%     lateralmedial = {'Lat','Med'};
%     m = 2;
% end
% 
% for n = 1:m 

for n=1:2
    lateralmedial = {'Lat','Med'};

    %% Fix Dead Rows

    %List rows that are zero
    zerorows = zeros(26,(length(fieldnames(frames))/2)); % matrix with rows=Tekscan rows and columns=# of frames per test
    for j=1:(length(fieldnames(frames))/2)
         for i=2:25 %Skipping first and last row for now
             if sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(i,:)) == 0 
                if sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(i-1,:)) == 0 || sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(i+1,:)) == 0 
                    continue %Don't fix rows that also have zero in the rows above or below
                else
                    zerorows(i,j) = i; % final matrix will indicate the rows that are dead in each frame
                end
             end
         end
    end

    %Determine if a row is dead the whole time
    deadrows = zeros(26,1);
    for k=1:26
        if sum(zerorows(k,:)) == 0 %If there are no dead values, ignore this row
            continue
        elseif all(zerorows(k,:))
            deadrows(k) = 1; %Determines a row is dead if the entire run there are zeros in the row
        else 
            [instances,values]=groupcounts(zerorows(k,:)');  %find how many times the row is dead if not dead the whole time
            if instances(2) > 500 %If more than 500 of 2500 frames are 0, we will call the row dead. 
                % Also don't trust the data that the row did provide, just
                % average the above and below row, see next section
                deadrows(k) = 1; 
            end
        end
    end

    %If you want to not fix a certain row, stop here and change the 1 to a 0
    %in deadrows for the row you don't want to fix

    %If a row is dead, average with the above and below row
    for r=1:26
        if all(deadrows(r))
            for j=1:(length(fieldnames(frames))/2)
                frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(r,:)= (frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(r-1,:) + frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(r+1,:))/2; 
            end
        end
    end



    %% Fix Dead Columns

    %List columns that are zero
    zerocolumns = zeros((length(fieldnames(frames))/2),22);
    for j=1:(length(fieldnames(frames))/2)
         for i=2:21 %Skipping first and last column for now
             if sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,i)) == 0 
                if sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,i+1)) == 0 || sum(frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,i-1)) == 0 
                    continue %Don't fix columns that also have zero in the columns left or right
                else
                    zerocolumns(j,i) = i;
                end
             end
         end
    end

    %Determine if a column is dead the whole time
    deadcolumns = zeros(1,22); 
    for k=1:22
        if sum(zerocolumns(:,k)) == 0 %If there are no dead values, ignore this row
            continue
        elseif all(zerocolumns(:,k))
            deadcolumns(k) = 1; %Determines a column is dead if the entire run there are zeros in the column
        else
            [instances,values]=groupcounts(zerocolumns(:,k));  %find how many times the column is dead if not always dead
            if instances(2) > 500 %If more than 500 of 2500 frames are out, we will call the row dead. 
                % Also don't trust the data that the column did provide, just
                % average the left and right column, see next section
                deadcolumns(k) = 1; 
            end
        end
    end

    %If you want to not fix a certain column, stop here and change the 1 to a 0
    %in deadcolumns for the column you don't want to fix

    %If a column is dead, average with the right and left
    for r=1:22
        if all(deadcolumns(r))
            for j=1:(length(fieldnames(frames))/2)
                frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,r)= (frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,r-1) + frames.(strcat('Frame',num2str(j),char(lateralmedial(n))))(:,r+1))/2; 
            end
        end
    end

    %% Display fixed column/row numbers

    %message = strcat('Fixed Columns',{' '},num2str(find(deadcolumns)),{' '},'and Rows',{' '},num2str(find(deadrows')))

end

end