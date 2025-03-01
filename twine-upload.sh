#! /usr/bin/env bash
set -Eeuo pipefail


echo \
    '# UNSUPPORTED GITHUB ACTION VERSION' \
    '\n\n' \
    You are using `pypa/gh-action-pypi-publish@master`. \
    The `master` branch of this project has been sunset and will not \
    receive any updates, not even security bug fixes. Please, make \
    sure to use a supported version. If you want to pin to v1 major \
    version, use `pypa/gh-action-pypi-publish@release/v1`. If you \
    feel adventurous, you may opt to use use \
    `pypa/gh-action-pypi-publish@unstable/v1` instead. A more \
    general recommendation is to pin to exact tags or commit shas. \
    '\n\n' \
    '\n\n' \
    '### Oh, and while you are here — #StandWithUkraine' \
    '\n\n' \
    '[![SWUbanner]][SWUdocs]' \
    '\n\n' \
    '[SWUbanner]:' \
    'https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg' \
    '\n\n' \
    '[SWUdocs]:' \
    'https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md' \
    >> "${GITHUB_STEP_SUMMARY}"
echo \
    ::warning file='# >>' PyPA publish to PyPI GHA'%3A' \
    UNSUPPORTED GITHUB ACTION VERSION \
    '<< ':: \
    You are using '"pypa/gh-action-pypi-publish@master"'. \
    The '"master"' branch of this project has been sunset and will not \
    receive any updates, not even security bug fixes. Please, make \
    sure to use a supported version. If you want to pin to v1 major \
    version, use '"pypa/gh-action-pypi-publish@release/v1"'. If you \
    feel adventurous, you may opt to use use \
    '"pypa/gh-action-pypi-publish@unstable/v1"' instead. A more \
    general recommendation is to pin to exact tags or commit shas.


if [[
    "$INPUT_USER" == "__token__" &&
    ! "$INPUT_PASSWORD" =~ ^pypi-
  ]]
then
    echo \
        ::warning file='# >>' PyPA publish to PyPI GHA'%3A' \
        POTENTIALLY INVALID TOKEN \
        '<< ':: \
        It looks like you are trying to use an API token to \
        authenticate in the package index and your token value does \
        not start with '"pypi-"' as it typically should. This may \
        cause an authentication error. Please verify that you have \
        copied your token properly if such an error occurs.
fi

if ( ! ls -A ${INPUT_PACKAGES_DIR%%/}/*.tar.gz &> /dev/null && \
     ! ls -A ${INPUT_PACKAGES_DIR%%/}/*.whl &> /dev/null )
then
    echo \
        ::warning file='# >>' PyPA publish to PyPI GHA'%3A' \
        MISSING DISTS \
        '<< ':: \
        It looks like there are no Python distribution packages to \
        publish in the directory "'${INPUT_PACKAGES_DIR%%/}/'". \
        Please verify that they are in place should you face this \
        problem.
fi

if [[ ${INPUT_VERIFY_METADATA,,} != "false" ]] ; then
    twine check ${INPUT_PACKAGES_DIR%%/}/*
fi

TWINE_EXTRA_ARGS=
if [[ ${INPUT_SKIP_EXISTING,,} != "false" ]] ; then
    TWINE_EXTRA_ARGS=--skip-existing
fi

if [[ ${INPUT_VERBOSE,,} != "false" ]] ; then
    TWINE_EXTRA_ARGS="--verbose $TWINE_EXTRA_ARGS"
fi

if [[ ${INPUT_PRINT_HASH,,} != "false" || ${INPUT_VERBOSE,,} != "false" ]] ; then
    python /app/print-hash.py ${INPUT_PACKAGES_DIR%%/}
fi

TWINE_USERNAME="$INPUT_USER" \
TWINE_PASSWORD="$INPUT_PASSWORD" \
TWINE_REPOSITORY_URL="$INPUT_REPOSITORY_URL" \
  exec twine upload ${TWINE_EXTRA_ARGS} ${INPUT_PACKAGES_DIR%%/}/*
