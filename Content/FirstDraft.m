% Step 1: Setup - List of PDFs
pdfFiles = {'article 1.pdf', 'article 2.pdf', 'article 3.pdf', ...
         'article 4.pdf', 'article 5.pdf', 'article 6.pdf', ...
         'article 7.pdf', 'article 8.pdf', 'article 9.pdf', ...
         'article 10.pdf'};
% Initialize results storage with NaN to track unprocessed articles
articleTones = NaN(1, length(pdfFiles));
% Define Positive & Negative Word Lists
positiveWords = ["multitasking", "healthy", "support", "connection", "community", ...
              "happiness", "belonging", "relationships", "rewarding", "satisfaction"];
negativeWords = ["stigma", "addiction", "risk", "isolation", "disorders", "cyberbullying", ...
              "loneliness", "worry", "worries", "aggression", "concerns", "suicide", ...
              "depression", "stress", "anxiety"];
% Set the correct path to your MATLAB Drive
currentFilePath = mfilename('fullpath');
currentDirPath = string(fileparts(currentFilePath));
pdfFolder = fullfile(currentDirPath, "Articles");
% Step 2: Extract Text & Analyze Tone
for i = 1:length(pdfFiles)
 % Construct the full file path
 filePath = fullfile(pdfFolder, pdfFiles{i});
 %disp(filePath);
 %disp(pdfinfo(filePath));
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
  text = regexprep(text, '[^\w\s]', '');
  % Tokenize words
  words = split(text);
  % Initialize word count storage
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
% Step 3: Check if any articles were processed
if all(isnan(articleTones))
  warning('No articles were successfully processed.');
else
  fprintf('Successfully processed %d articles.\n', sum(~isnan(articleTones)));
end
%% Step 4: Display Detailed Word Count Results
disp('Word Counts Per Article:');
for i = 1:length(pdfFiles)
  fprintf('\nArticle: %s\n', wordCounts(i).article);
  disp('Positive Words:');
  disp(wordCounts(i).positive);
  disp('Negative Words:');
  disp(wordCounts(i).negative);
end
% Step 5: Visualize Tone Distribution
figure;
x = ["Negative", "Neutral", "Positive"];
y = [sum(articleTones == -1), sum(articleTones == 0), sum(articleTones == 1)];
bar(x,y)
title('Tone Distribution of Social Media & Mental Health Articles');
xlabel('Tone Category');
ylabel('Number of Articles');
grid on;
