filename <- "getdata_projectfiles_UCI HAR Dataset.zip"

## check if file exists
if (!file.exists(filename)){
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, filename, method="curl")
}  

## unzip dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)
}

# get activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# extract only the mean and standard deviation
meanAndSd <- grep(".*mean.*|.*std.*", features[,2])
meanAndSd.names <- features[meanAndSd,2]
meanAndSd.names = gsub('-mean', 'Mean', meanAndSd.names)
meanAndSd.names = gsub('-std', 'Std', meanAndSd.names)
meanAndSd.names <- gsub('[-()]', '', meanAndSd.names)


# load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[meanAndSd]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[meanAndSd]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", meanAndSd.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

# get average of each measurement for each subject and activity
tidyData <- aggregate(allData[meanAndSd.names], list(subject=allData$subject,activity=allData$activity), mean)
tidyData <- tidyData[order(tidyData$subject),]

#output to tidy.txt
write.table(tidyData, "tidy.txt", row.names = FALSE, quote = FALSE)