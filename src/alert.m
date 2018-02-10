%% Configuration %%
alertIntervals = [hours(0.25) hours(1) hours(3) hours(6) hours(12) hours(24)];
%% Channel Info %%
% Channel to read humidity difference
channelID = [];
channelReadKey = '';
% Event name and key for the IFTTT WebHooks service
makerEvent = 'humidity_alert';
makerKey = '';


%% Read Data %%
comfortData = thingSpeakRead(channelID, 'ReadKey', channelReadKey, ...
                                'NumMinutes', minutes(alertIntervals(end)), ...
                                'Fields', 3, ...
                                'OutputFormat', 'table');

currState = comfortData.ComfortTier(end);
lastStateChange = [];


%% Use Data %%
% Determine when the last change in state occurred
for i = height(comfortData):-1:1
   comfortTier = comfortData.ComfortTier(i);
   lastStateChange = i;

    if (sign(comfortTier) ~= sign(currState) || comfortTier == 0)
       break
   end
end
lastChangeTime = comfortData.Timestamps(lastStateChange);
timeSinceChange = datetime('now') - lastChangeTime;

% Create a message for the state report
stateMsg = '';
if sign(currState) > 0
    stateMsg = 'humid';
elseif sign(currState) < 0
    stateMsg = 'dry';
end


%% Send Alert %%
% Determine if we are close enough to any of the alert intervals to receive an update
alertCountdowns = alertIntervals - timeSinceChange;
% Send notification if we are within 5 minutes following an alert interval
if sum(alertCountdowns <= 0 & alertCountdowns > -1 * minutes(5)) > 0
    webwrite(strcat('https://maker.ifttt.com/trigger/', makerEvent, ...
                '/with/key/', makerKey), ...
                'value1', stateMsg, ...
                'value2', char(timeSinceChange, 'hh:mm'));
end