{ stdenvNoCC, fetchFromGitHub, cmake, clang, llvm, python, python3, doxygen, openssl, glibc, bash
    ,  BUILD_TYPE ? "RelWithDebInfo"
    }:   

    stdenvNoCC.mkDerivation {  
        name = "openenclave-sdk";  
        version = "0.12.0";

        nativeBuildInputs =  [ cmake llvm clang bash python python3 doxygen ];  
        # Only one actual import to the package. Everything else is a build tool 
        buildInputs = [ openssl ];  
        src = fetchFromGitHub { 
                      owner = "openenclave";
                      repo = "openenclave";
                      rev  = "v0.12.0";
                      sha256 = "13c8dlmv1vgfx53fr7m7y8d4rcw4alb9xjznns7z6jv9l8s0ak3z";
                      fetchSubmodules = true; 
                }; 

        CC = "clang";
        CXX = "clang++";
        LD = "ld.lld";
        CFLAGS="-Wno-unused-command-line-argument";
        CXXFLAGS="-Wno-unused-command-line-argument";

        NIX_ENFORCE_PURITY=0;
        doCheck = false;
        dontFixup    = true;
        dontStrip    = true;
        dontPatchELF = true;

        builder = ./build.sh;

        configureFlags = "-DCMAKE_BUILD_TYPE="+BUILD_TYPE;
        enableParallelBuild = false;

        patchPhase = ''
                  chmod -R a+rw $src
                  patchShebangs $src
             '';

        configurePhase = ''
                        chmod -R a+rw $src
                        echo "PATCHSHEBANGS $src"
                        patchShebangs $src
                        mkdir -p $out
                        cd $out
                        cmake -G "Unix Makefiles" $src $configureFlags
                        patchShebangs $src
                    '';

        meta = with stdenvNoCC.lib; {
             description = "OpenEnclave SDK.";
             license = licenses.mit;
             maintainers = with maintainers; [ yakman2020  ];
             platforms = [ "x86_64-linux" ];
        };
}  

