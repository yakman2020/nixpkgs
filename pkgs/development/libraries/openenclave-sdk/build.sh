#!/bin/bash

source $stdenv/setup

buildPhase() {
    runHook preBuild

   patchShebangs $src
   patchShebangs $out
echo MY DIRECTORY IS `pwd`

    # set to empty if unset
    : ${makeFlags=}

    if [[ -z "$makeFlags" && -z "${makefile:-}" && ! ( -e Makefile || -e makefile || -e GNUmakefile ) ]]; then
        echo "no Makefile, doing nothing"
    else
        foundMakefile=1

        # Old bash empty array hack
        # shellcheck disable=SC2086
        local flagsArray=(
            ${enableParallelBuilding:+-j${NIX_BUILD_CORES} -l${NIX_BUILD_CORES}}
            SHELL=$SHELL
            $makeFlags ${makeFlagsArray+"${makeFlagsArray[@]}"} 
            $buildFlags ${buildFlagsArray+"${buildFlagsArray[@]}"}
        )

        echoCmd 'build flags' "${flagsArray[@]}"
        make ${makefile:+-f $makefile} "${flagsArray[@]}" "VERBOSE=1"
        unset flagsArray
    fi

    runHook postBuild
}


set -x
genericBuild
set +x
