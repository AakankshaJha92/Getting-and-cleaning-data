## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity labels
activitylabels <- read.table("./UCI HAR Dataset/activitylabels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extractfeatures <- grepl("mean|std", features)

# Load and process X_test & y_test data.
Xtest <- read.table("./UCI HAR Dataset/test/Xtest.txt")
ytest <- read.table("./UCI HAR Dataset/test/ytest.txt")
subjecttest <- read.table("./UCI HAR Dataset/test/subjecttest.txt")

names(Xtest) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
Xtest = Xtest[,extractfeatures]

# Load activity labels
ytest[,2] = activitylabels[ytest[,1]]
names(y_test) = c("ActivityID", "ActivityLabel")
names(subjecttest) = "subject"

# Bind data
test_data <- cbind(as.data.table(subjecttest), ytest, Xtest)

# Load and process X_train & y_train data.
Xtrain <- read.table("./UCI HAR Dataset/train/Xtrain.txt")
ytrain <- read.table("./UCI HAR Dataset/train/ytrain.txt")

subjecttrain <- read.table("./UCI HAR Dataset/train/subjecttrain.txt")

names(Xtrain) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
Xtrain = Xtrain[,extractfeatures]

# Load activity data
ytrain[,2] = activitylabels[ytrain[,1]]
names(ytrain) = c("ActivityID", "ActivityLabel")
names(subjecttrain) = "subject"

# Bind data
traindata <- cbind(as.data.table(subjecttrain), ytrain, Xtrain)

# Merge test and train data
data = rbind(testdata, traindata)

idlabels   = c("subject", "ActivityID", "ActivityLabel")
datalabels = setdiff(colnames(data), id_labels)
meltdata      = melt(data, id = idlabels, measure.vars = datalabels)

# Apply mean function to dataset using dcast function
tidydata   = dcast(meltdata, subject + ActivityLabel ~ variable, mean)

write.table(tidydata, file = "./tidy_data.txt")