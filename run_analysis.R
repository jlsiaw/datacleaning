# run_analysis.R does the following: 
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for 
#    each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.


# import dplyr to use functions select(), group_by(), chaining, etc
library(dplyr)

# read test data sets
x.test <- read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
y.test <- read.csv("UCI HAR Dataset/test/y_test.txt", sep="", header=FALSE)
sub.test <- read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", 
                     header=FALSE)

# merge test data with subjects, labels id and features measurement
test <- data.frame(sub.test, y.test, x.test)

# read train data sets
x.train <- read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
y.train <- read.csv("UCI HAR Dataset/train/y_train.txt", sep="", header=FALSE)
sub.train <- read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", 
                      header=FALSE)

# merge train data with subjects, labels id and features measurement
train <- data.frame(sub.train, y.train, x.train)

# merge train and test data by row
data <- rbind(train, test)

# remove unused objects
remove(x.test, y.test, sub.test, x.train, y.train, sub.train, test, train)

# read the features data: V1-id V2-features header
features <- read.csv("UCI HAR Dataset/features.txt", sep="", 
                     colClasses="character", header=FALSE)

# retrieve the second column from features
features.header <- features[,2]

# set column names
names(data) <- c("subject", "activity_label", features.header)

# drop the duplicated column name to prepare it for "select" function execution
data <- data[ , !duplicated(colnames(data))]

# select variable with column name mean and std but without angle and Freq
data <- select(data, contains("subject"), contains("label"), contains("mean"),
               contains("std"), -contains("angle"), -contains("Freq"))

# read the activity labels: V1-id V2-label
act.label <- read.csv("UCI HAR Dataset/activity_labels.txt", 
                            sep="", colClasses="character", header=FALSE)

# replace activity id in col activity_label with the matching act.label
data$activity_label <- act.label[match(data$activity_label, act.label$V1,), "V2"]

# Rename column names to be more descriptive
colnames(data) <- gsub("\\(\\)", "", colnames(data))
colnames(data) <- gsub("-", "_", colnames(data))
colnames(data) <- gsub("BodyBody", "Body", colnames(data))

# tidy set with the average of each feature for each activity and each subject
res <- data %>%
  group_by(subject, activity_label) %>%
  summarise_each(funs(mean))

# export data to a text file
write.table(res, file="UCI HAR Dataset/tidy.txt", row.names = FALSE)
