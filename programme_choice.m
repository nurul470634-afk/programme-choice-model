clc;
clear;

% -------------------------------
% DATA
% -------------------------------
programmes = {
    "Pure Sciences";
    "Applied Sciences";
    "Engineering";
    "Accounting";
    "Management";
    "Arts"
};

n = length(programmes);

% -------------------------------
% CREATE FIGURE
% -------------------------------
f = figure('Position',[200 100 900 600], ...
           'Name','Programme Choice System','NumberTitle','off');

% Title
uicontrol(f,'Style','text','Position',[250 550 400 30],...
    'String','Programme Choice System (MNL)','FontSize',14,'FontWeight','bold');

% Factors
factors = {"Interest","Exam","Career","Location","Fees","Explore"};

for j = 1:6
    uicontrol(f,'Style','text',...
        'Position',[150+100*j 500 80 20],...
        'String',factors{j});
end

% -------------------------------
% INPUT BOXES
% -------------------------------
ratingBox = zeros(n,6);

for i = 1:n
    uicontrol(f,'Style','text',...
        'Position',[20 500-50*i 120 20],...
        'String',programmes{i});

    for j = 1:6
        ratingBox(i,j) = uicontrol(f,'Style','edit',...
            'Position',[150+100*j 500-50*i 80 25],...
            'String','0');
    end
end

% -------------------------------
% WEIGHTS
% -------------------------------
uicontrol(f,'Style','text','Position',[20 150 200 20],...
    'String','Enter Weights (0.0-1.0) :');

weightBox = zeros(1,6);

for j = 1:6
    weightBox(j) = uicontrol(f,'Style','edit',...
        'Position',[150+100*j 150 80 25],...
        'String','0');
end

% -------------------------------
% RESULT TEXT
% -------------------------------
resultText = uicontrol(f,'Style','text',...
    'Position',[250 50 400 40],...
    'String','Result will appear here','FontSize',12);

% -------------------------------
% SAVE DATA USING guidata
% -------------------------------
data.ratingBox = ratingBox;
data.weightBox = weightBox;
data.resultText = resultText;
data.programmes = programmes;

guidata(f, data);

% -------------------------------
% BUTTON
% -------------------------------
uicontrol(f,'Style','pushbutton',...
    'Position',[350 100 200 40],...
    'String','Calculate',...
    'Callback', @calculate);

% -------------------------------
% FUNCTION (FIXED)
% -------------------------------
function calculate(src, event)
    % Get GUI data
    f = gcbf;
    data = guidata(f);

    ratingBox = data.ratingBox;
    weightBox = data.weightBox;
    resultText = data.resultText;
    programmes = data.programmes;

    % Read inputs
    ratings = zeros(6,6);
    weights = zeros(1,6);

    for i = 1:6
        for j = 1:6
            ratings(i,j) = str2double(get(ratingBox(i,j),'String'));
        end
    end

    for j = 1:6
        weights(j) = str2double(get(weightBox(j),'String'));
    end

    % Compute Utility
    U = zeros(6,1);
    for i = 1:6
        U(i) = ...
            weights(1)*ratings(i,1) + ...
            weights(2)*ratings(i,2) + ...
            weights(3)*ratings(i,3) + ...
            weights(4)*ratings(i,4) - ...
            weights(5)*ratings(i,5) + ...
            weights(6)*ratings(i,6);
    end

    % MNL
    P = exp(U) ./ sum(exp(U));

    % Best choice
    [maxP, idx] = max(P);

    % Display result
    % Build result string with ALL probabilities
    resultStr = sprintf("Best: %s (%.4f)\n\nAll Probabilities:\n", programmes{idx}, maxP);
    for i = 1:6
        resultStr = sprintf("%s%s: %.4f\n", resultStr, programmes{i}, P(i));
    end

    set(resultText,'String', resultStr);

    % Bar chart
    figure;
    bar(P);
    set(gca,'XTickLabel',programmes);
    xtickangle(45);
    title('Programme Probabilities');
end
