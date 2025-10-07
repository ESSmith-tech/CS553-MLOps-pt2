#! /bin/bash

PORT=22005
MACHINE=paffenroth-23.dyn.wpi.edu
STUDENT_ADMIN_KEY_PATH=$HOME/CS553
COMMAND="ssh -i ${STUDENT_ADMIN_KEY_PATH}/student-admin_key -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"
REPO_URL="https://github.com/ESSmith-tech/CS553-MLOps-pt2.git"
REPO_DIR="CS553-MLOps-pt2"

${COMMAND} "echo 'testing for student-admin_key'"

if [ $? -ne 0 ]; then
	echo "student admin key not on virtual machine, cancelling deployment"
	exit 1
fi


# Clean up from previous runs
ssh-keygen -f ~/.ssh/known_hosts -R "[paffenroth-23.dyn.wpi.edu]:22005"

# Clean up from previous runs
ssh-keygen -f ~/.ssh/known_hosts -R "[paffenroth-23.dyn.wpi.edu]:21005"
rm -rf tmp

# Create a temporary directory
mkdir tmp

# copy the key to the temporary directory
cp ${STUDENT_ADMIN_KEY_PATH}/student-admin_key* tmp

# Change the premissions of the directory
chmod 700 tmp

# Change to the temporary directory
cd tmp

# Set the permissions of the key
chmod 600 student-admin_key*

# Create a unique key
rm -f mykey
read -sp "answer my riddles three: " PASSAGE
echo
ssh-keygen -f mykey -t ed25519 -N "${PASSAGE}"

# Insert the key into the authorized_keys file on the server
# One > creates
cat mykey.pub >authorized_keys
# two >> appends
# Remove to lock down machine
#cat student-admin_key.pub >> authorized_keys

chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

# Copy the authorized_keys file to the server
# FIX NEEDED FIX NEEDED FIX NEEDED
# if line fails then it removes access to the machine, find way to fix
#scp -i student-admin_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

OLD_KEY=$(cat student-admin_key.pub)
NEW_KEY=$(cat mykey.pub)

${COMMAND} "sed -i 's|${OLD_KEY}|${NEW_KEY}|g' .ssh/authorized_keys"

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add mykey

# Check the key file on the server
echo "checking that the authorized_keys file is correct"
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

# clone the repo
echo "Cloning repository from main branch..."
git clone --branch main --single-branch "$REPO_URL" "$REPO_DIR"
