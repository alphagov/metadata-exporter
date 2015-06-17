#!/usr/bin/env sh
function exit_unless {
    exit_code=$1
    if [ ${exit_code} -ne 0 ]
    then
        exit ${exit_code}
    fi
}

bundle
exit_unless $?
echo ""
echo "%% Running tests %%"
echo ""
bundle exec rake pre_commit
exit_unless $?

echo "All good."
