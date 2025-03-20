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
  % Count occurrences of positive & negative words
  posCount = sum(ismember(words, positiveWords));
  negCount = sum(ismember(words, negativeWords));
 
  % Classify tone
  if posCount > negCount
      articleTones(i) = 1;  % Positive
  elseif negCount > posCount
      articleTones(i) = -1; % Negative
  else
      articleTones(i) = 0;  % Neutral
  end
 
  % Display result
  categories = {"Negative", "Neutral", "Positive"};
  fprintf('Article %d classified as: %s\n', i, categories{articleTones(i) + 2});
end
% Step 3: Check if any articles were processed
if all(isnan(articleTones))
   warning('No articles were successfully processed.');
else
   fprintf('Successfully processed %d articles.\n', sum(~isnan(articleTones)));
end
% Step 4: Visualize Tone Distribution
validTones = articleTones(~isnan(articleTones));
if isempty(validTones)
   error('No valid tones to process. Ensure articles are being processed correctly.');
end
figure;
x = ["Negative", "Neutral", "Positive"];
y = [sum(validTones == -1), sum(validTones == 0), sum(validTones == 1)];
bar(x,y)
title('Tone Distribution of Social Media & Mental Health Articles');
xlabel('Tone Category');
ylabel('Number of Articles');
grid on;


