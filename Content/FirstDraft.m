% Check for difference
%% Step 1: Setup - List of PDFs
pdfFiles = {'article 1.pdf', 'article 2.pdf', 'article 3.pdf', ...
         'article 4.pdf', 'article 5.pdf', 'article 6.pdf', ...
         'article 7.pdf', 'article 8.pdf', 'article 9.pdf', ...
         'article 10.pdf'};

% Initialize results storage with NaN to track unprocessed articles (used 0
% to describe neutrality so decided to use Not a Number instead) 
articleTones = NaN(1, length(pdfFiles)); 

% Define positive & negative word lists
positiveWords = ["multitasking", "healthy", "support", "connection", "community", ...
              "happiness", "belonging", "relationships", "rewarding", "satisfaction"];
negativeWords = ["stigma", "addiction", "risk", "isolation", "disorders", "cyberbullying", ...
              "loneliness", "worry", "worries", "aggression", "concerns", "suicide", ...
              "depression", "stress", "anxiety"];

% Define classification categories
categories = {'Negative', 'Neutral', 'Positive'};  

% Set the correct path to your MATLAB Drive
currentFilePath = mfilename('fullpath');
currentDirPath = string(fileparts(currentFilePath));
pdfFolder = fullfile(currentDirPath, "Articles");

%% Step 2: Extract Text & Analyze Tone
for i = 1:length(pdfFiles)
    % Construct the full file path
    filePath = fullfile(pdfFolder, pdfFiles{i});

    try
        % Attempt to extract text
        text = extractFileText(filePath);
        if isempty(text)  % Check if no text is extracted
            warning('No text extracted from %s. Skipping.', pdfFiles{i});
            continue; % Skip this file if no text is extracted
        end
    catch
        warning('Could not extract text from %s. Skipping.', pdfFiles{i});
        continue; % Skip this file if unreadable
    end

    % Convert to lowercase
    text = lower(text);
    % Remove punctuation
    text = regexprep(text, '[^\w\s]', ''); % Looked up how to remove punctation correctly! 
    % Tokenize words
    words = split(text); % Split huge text into individual words 

    % Initialize word count storage (creating list with 0s of length of
    % number of words there are - both positive and negative)
    posWordCount = zeros(1, length(positiveWords));
    negWordCount = zeros(1, length(negativeWords));

    % Count occurrences of each positive & negative word
    for p = 1:length(positiveWords)
        posWordCount(p) = sum(ismember(words, positiveWords(p)));
    end
    for n = 1:length(negativeWords)
        negWordCount(n) = sum(ismember(words, negativeWords(n)));
    end

    % Store results for word frequency analysis
    wordCounts(i).article = pdfFiles{i};
    wordCounts(i).positive = array2table(posWordCount, 'VariableNames', cellstr(positiveWords));
    wordCounts(i).negative = array2table(negWordCount, 'VariableNames', cellstr(negativeWords));

    % Determine overall classification
    posTotal = sum(posWordCount);
    negTotal = sum(negWordCount);

    if posTotal > negTotal
        articleTones(i) = 1;  % Positive
    elseif negTotal > posTotal
        articleTones(i) = -1; % Negative
    else
        articleTones(i) = 0;  % Neutral
    end

    % Display classification and word counts
    fprintf('Article %d classified as: %s | Pos: %d, Neg: %d\n', ...
        i, categories{articleTones(i) + 2}, posTotal, negTotal);
end

%% Step 3: Check if any articles were processed
if all(isnan(articleTones))
    warning('No articles were successfully processed.');
else
    fprintf('Successfully processed %d articles.\n', sum(~isnan(articleTones)));
end

%% Step 4: Load Manual Word Count Data 
manualData = readtable('ITP Project 1 word table.xlsx', 'VariableNamingRule', 'preserve');

% Extract manual word counts
manualPosCounts = table2array(manualData(:, 2:11));  % Adjust if necessary
manualNegCounts = table2array(manualData(:, 12:end));

% Compute manual tone classification (based on highest word count category)
manualPosTotals = sum(manualPosCounts, 2);
manualNegTotals = sum(manualNegCounts, 2);

manualTones = zeros(size(manualPosTotals));

for i = 1:length(manualPosTotals)
    if manualPosTotals(i) > manualNegTotals(i)
        manualTones(i) = 1;  % Positive
    elseif manualNegTotals(i) > manualPosTotals(i)
        manualTones(i) = -1; % Negative
    else
        manualTones(i) = 0;  % Neutral
    end
end

%% Step 5: Compare Manual vs. Coded Word Counts 
figure; % Ensure a new figure window opens

% Extract total word counts for manual annotations
manualPosTotal = sum(manualPosCounts, 1); % Sum across articles
manualNegTotal = sum(manualNegCounts, 1);

% Extract total word counts from automated classification (looked up how to
% do this application) 
codedPosTotal = sum(cell2mat(arrayfun(@(x) table2array(x.positive), wordCounts, 'UniformOutput', false)), 1);
codedNegTotal = sum(cell2mat(arrayfun(@(x) table2array(x.negative), wordCounts, 'UniformOutput', false)), 1);

% Ensure consistency in dimensions
minLength = min([length(manualPosTotal), length(codedPosTotal), length(positiveWords)]);
manualPosTotal = manualPosTotal(1:minLength);
codedPosTotal = codedPosTotal(1:minLength);
manualNegTotal = manualNegTotal(1:minLength);
codedNegTotal = codedNegTotal(1:minLength);

% Manual Word Count Comparison
subplot(2,1,1);
bar([manualPosTotal; manualNegTotal]', 'grouped');
set(gca, 'xticklabel', positiveWords(1:minLength));
title('Manual Word Counts per Category');
xlabel('Words');
ylabel('Frequency');
legend({'Positive', 'Negative'}, 'Location', 'best');

% Automated Word Count Comparison
subplot(2,1,2);
bar([codedPosTotal; codedNegTotal]', 'grouped');
set(gca, 'xticklabel', positiveWords(1:minLength));
title('Coded Word Counts per Category');
xlabel('Words');
ylabel('Frequency');
legend({'Positive', 'Negative'}, 'Location', 'best');

%% Step 6: Compare Manual vs. Coded Tone Classification
figure;
manualPercentages = [sum(manualTones == -1), sum(manualTones == 0), sum(manualTones == 1)] / length(manualTones) * 100;
codedPercentages = [sum(articleTones == -1), sum(articleTones == 0), sum(articleTones == 1)] / length(articleTones) * 100;

bar([manualPercentages; codedPercentages]', 'grouped');
set(gca, 'xticklabel', categories);
title('Manual vs. Coded Tone Classification');
xlabel('Tone Category');
ylabel('Percentage of Articles');
legend({'Manual', 'Coded'}, 'Location', 'best');

%% Step 7: Compute Agreement (Cohen’s Kappa & Correlation)
minLength = min(length(manualTones), length(articleTones));
manualTones = manualTones(1:minLength);
articleTones = articleTones(1:minLength);

% Compute confusion matrix
confusionMatrix = confusionmat(manualTones, articleTones);

% Compute Cohen’s Kappa
totalSamples = sum(confusionMatrix(:));
expectedAgreement = sum(sum(confusionMatrix, 1) .* sum(confusionMatrix, 2)) / (totalSamples^2);
observedAgreement = sum(diag(confusionMatrix)) / totalSamples;
cohensKappa = (observedAgreement - expectedAgreement) / (1 - expectedAgreement);

% Had to transpose the matrix for them to be formatted the same (formatted manual data incorrectly)
correlationCoefficient = corr(manualTones, articleTones.');

% Display results
fprintf('\nCohen’s Kappa: %.2f\n', cohensKappa);
fprintf('Correlation Coefficient: %.2f\n', correlationCoefficient);
