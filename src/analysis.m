%% Channel Info %%
% Channel to read indoor humidity
indoorChannelID = [];
indoorChannelReadKey = '';

% MathWorks weather station to read outdoor temperature
outdoorChannelID = 12397;
outdoorChannelReadKey = ''; % Not needed for public channel

% Channel to read & post humidity difference
diffChannelID = [];
diffChannelReadKey = '';
diffChannelWriteKey = '';


%% Fetch Data %%
indoorData = thingSpeakRead(indoorChannelID, ...
                            'ReadKey', indoorChannelReadKey, ...
                            'NumMinutes', 5);
outdoorData = thingSpeakRead(outdoorChannelID, ...
                            'ReadKey', outdoorChannelReadKey, ...
                            'NumMinutes', 5, ...
                            'Fields', 4); % Only fetch temperature
diffData = thingSpeakRead(diffChannelID, ...
                            'ReadKey', diffChannelReadKey, ...
                            'NumMinutes', 20, ...
                            'Fields', 1); % Only fetch RH difference

% using webread because thingSpeakRead does not give access to the channel metadata
indoorChannelData = webread(strcat('https://api.thingspeak.com/channels/', ...
                                    num2str(indoorChannelID), ...
                                    '/feeds.json?metadata=true&api_key=', ...
                                    indoorChannelReadKey));
diffChannelData = webread(strcat('https://api.thingspeak.com/channels/', ...
                                    num2str(diffChannelID), ...
                                    '/feeds.json?metadata=true&api_key=', ...
                                    diffChannelReadKey));


%% Prepare Data %%
humidityLookup = cell2mat(textscan(indoorChannelData.channel.metadata, '%f, %f'));
stateLookup = textscan(diffChannelData.channel.metadata, '%f %q');


%% Use Data %%
curHumidity = mean(indoorData(:,1));
curTempIn = mean(indoorData(:,2));
curTempOut = mean(outdoorData(:,1));

% Determine the target humidity using a polynomial fit over the lookup data
lookupFit = polyfit(humidityLookup(:, 1), humidityLookup(:, 2), length(humidityLookup) - 1);
optimalHumidity = polyval(lookupFit, curTempOut);

humidityDiff = curHumidity - optimalHumidity;

% Add the most recent diff in the data
diffData = [diffData ; humidityDiff];
avgDiff = mean(diffData);


%% Determine Comfort Level %%
comfortTier = 0;

% loop through the lookup table and find which threshold the humidity falls under
for i = 1:length(stateLookup{1})
    comfortTier = i;
    if abs(avgDiff) < stateLookup{1}(i)
        break
    end
end

% Create a message describing the current comfort level
comfortMsg = stateLookup{2}(comfortTier);

% Append a further description if not within the lowest threshold
if comfortTier > 1
    if avgDiff > 0
        comfortMsg = strcat(comfortMsg, ' -- too humid');
    else
        comfortMsg = strcat(comfortMsg, ' -- too dry');
    end
end

% Give the comfortTier a sign to denote if it is too dry/humid
% sign of avgDiff is subtracted to make 0 the base (okay/comfortable) value
comfortTier = comfortTier * sign(avgDiff) - sign(avgDiff);

%% Publish Data %%
% Using webread because thingSpeakWrite does not allow the status field
webread(cell2mat(strcat('https://api.thingspeak.com/update?', ...
            'api_key=', diffChannelWriteKey, ...
            '&status=', comfortMsg, ...
            '&field1=', num2str(humidityDiff), ...
            '&field2=', num2str(optimalHumidity), ...
            '&field3=', num2str(comfortTier))));