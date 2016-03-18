#!/bin/bash

# start debugging/tracing commands, -e - exit if command returns error (non-zero status)
set -e

echo "Install prerequisites gulp/bower/packages"

npm install -g gulp bower

npm install
bower install

echo "Deploying branch: ${CI_BRANCH}"

branch=${CI_BRANCH}
src=$(git rev-parse --show-toplevel)
base=$(basename ${src})
dest="${base/uqlibrary-/}"

pwd
cd ../${base}
pwd

#echo "Check file syntax"
##gulp syntax

echo "Build distribution"
gulp

# If these files are the same, it means an error in vulcanizing
echo "Checking vulcanization was performed correctly"
set +e
result=`diff dist/elements/elements.html app/elements/elements.html`
set -e

if [ -z "${result}" ]; then
    echo "Improperly vulcanized file"
    echo "This happens sporadically, rebuilding should fix"
    exit 1;
fi

if ! [ -f dist/elements/elements.js ]; then
    echo "Improperly vulcanized file - missing vulcanized.js"
    exit 1;
fi

# use codeship branch environment variable to push to branch name dir unless it's 'production' branch (or master for now)
if [ ${CI_BRANCH} != "production" ]; then
  export S3BucketSubDir=/mylibrary/${CI_BRANCH}/${dest}
  export InvalidationPath=/mylibrary/${CI_BRANCH}/${dest}
else
  export S3BucketSubDir=/mylibrary/${dest}
  export InvalidationPath=mylibrary/${dest}
fi

echo "Deploying to S3 bucket sub-dir: ${S3BucketSubDir}"
echo "Prepare AWS configuration..."

# Use env vars to set AWS config
awsconfigtemp="template.aws.json"
awsconfig="aws.json"

cp $awsconfigtemp $awsconfig

sed -i -e "s#<AWSAccessKeyId>#${AWSAccessKeyId}#g" ${awsconfig}
sed -i -e "s#<AWSSecretKey>#${AWSSecretKey}#g" ${awsconfig}
sed -i -e "s#<S3Bucket>#${S3Bucket}#g" ${awsconfig}
sed -i -e "s#<S3BucketSubDir>#${S3BucketSubDir}#g" ${awsconfig}
sed -i -e "s#<CFDistribution>#${CFDistribution}#g" ${awsconfig}
sed -i -e "s#<AWSRegion>#${AWSRegion}#g" ${awsconfig}

echo "Run gulp task to upload to AWS..."
gulp publish

echo "Run Cloudfront Invalidation: " gulp invalidate --path ${InvalidationPath}
gulp invalidate --path ${InvalidationPath}

echo "Clean up AWS configuration..."
rm -f ${awsconfig}
