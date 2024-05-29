#!/bin/bash
shopt -s expand_aliases

FAKE_ROOT_TEST_DIR=$(mktemp -d -t common_shell_root.XXXXXXXXXXX)
    
apt-get(){
    if [ "$TEST_FAKE_APT_LOCK" != "" ]; then 
        unset TEST_FAKE_APT_LOCK
        return $BASH_FALSE
    fi
    return $BASH_TRUE
}

source ./get-shunit2

testCheckPackageDebIsInstalled(){
    assertTrue "[ $(CheckPackageDebIsInstalled coreutils) "$BASH_TRUE" ]"
}


testGetDebPackVersion(){
    assertEquals "$(
        dpkg -s "coreutils" | grep '^Version' | sed 's/Version:\s*//g'
        )" "$(getDebPackVersion "coreutils")"
}


testGetCurrentDebianFrontend(){
    CheckPackageDebIsInstalled $GTK_DEBIAN_FRONTEND_DEP
    local expected_gtk_debian_frontend=$?

    CheckPackageDebIsInstalled $KDE_DEBIAN_FRONTEND_DEP
    local expected_kde_debian_frontend=$?

    if ! tty | grep -q 'pts/[0-9]'; then 
        getCurrentDebianFrontend
        assertFalse '[Try getCurrent from  non pseudoterminal]' "[ "$DEBIAN_FRONTEND" "" ]"
    fi

    if tty | grep -q 'pts/[0-9]'; then 
        if [ $expected_gtk_debian_frontend = 0 ]; then
            getCurrentDebianFrontend
            assertEquals "[Try getCurrentDebianFrontend from pseudoterminal with $GTK_DEBIAN_FRONTEND_DEP installed]"\
            "$DEBIAN_FRONTEND" "gnome"
        elif [ $expected_kde_debian_frontend = 0 ]; then 
            getCurrentDebianFrontend
            assertEquals "[Try getCurrentDebianFrontend from pseudoterminal with $KDE_DEBIAN_FRONTEND_DEP installed]"\
            "$DEBIAN_FRONTEND" "kde"

        fi
    fi

}

testAptInstall(){
    local apt_out=''
    assertEquals "[Running Apt install without args]" "AptInstall requires arguments" "$(AptInstall)"
    AptInstall gcc
    assertTrue "[Running apt with success]" "$?"
    TEST_FAKE_APT_LOCK=0
    AptInstall gcc
    assertTrue "[Running apt with fails and retry with success]" "$?"
   
    apt-get(){ return $BASH_FALSE ;}

    w=$(AptInstall gcc 2>/dev/null)
    assertFalse "[Running with errors and exit]" "$?"

}


testGetAptKeys(){
    local apt_key_url_repository=(
        "https://dl-ssl.google.com/linux/linux_signing_key.pub"
        "https://static.geogebra.org/linux/office@geogebra.org.gpg.key"
        "https://www.virtualbox.org/download/oracle_vbox_2016.asc"
        "https://www.virtualbox.org/download/oracle_vbox.asc"
        "https://packages.microsoft.com/keys/microsoft.asc")
        
        local expected_message='Getting apt Keys ...\nOK\nOK\nOK\nOK\nOK\n'
        
        Wget(){
            local message="-----BEGIN PGP PUBLIC KEY BLOCK-----\nVGVzdCBDb25maWd1cmVTb3VyY2VzTGlzdCBmdW5jdGlvbgo="
            message+="\n-----END PGP PUBLIC KEY BLOCK-----"

            printf "%b" "$message"
        }

    gpg(){ :; }
    tee(){ :; }
    local fake_array='a=()'
    getAptKeys apt_key_url_repository
    assertTrue "[Installing apt keys on system with success]" $?

    getAptKeys
    assertFalse "[Try install apt keys without reference to array of keys ]" $?
    
    getAptKeys fake_array
    assertFalse "[Try installing apt keys with reference to a string type variable instead of an array]" $?
    unset gpg tee
}


testWriteAptMirrors(){
    mkdir -p "$FAKE_ROOT_TEST_DIR/apt/sources.list.d"

    local repositorys=(
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/google-chrome.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/sublime-text.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/geogebra.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/virtualbox.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/teams.list" )

    local mirrors=(
        'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' 
        'deb https://download.sublimetext.com/ apt/stable/' 
        'deb http://www.geogebra.net/linux/ stable main'
        "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian ${dist_version} contrib"    
        "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main")

    writeAptMirrors
    assertFalse "[Try writeAptMirrors without args]" $?
    
    writeAptMirrors mirrors
    assertFalse "[Try writeAptMirrors with few args]" $?
    
    writeAptMirrors mirrors repositorys
    assertTrue '[Try writeAptMirrors with success' $?
}

testConfigureSourcesList(){
    mkdir -p "$FAKE_ROOT_TEST_DIR/apt/sources.list.d"
    
    install(){ :; }
    gpg(){ :; }
    tee(){ :; }
    Wget(){ :; }
    wget(){ :; }


    local repositorys=(
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/google-chrome.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/sublime-text.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/geogebra.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/virtualbox.list"
        "$FAKE_ROOT_TEST_DIR/apt/sources.list.d/teams.list'")

    local mirrors=(
        'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' 
        'deb https://download.sublimetext.com/ apt/stable/' 
        'deb http://www.geogebra.net/linux/ stable main'
        "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian ${dist_version} contrib"    
        "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main")

    local apt_key_url_repository=(
        "https://dl-ssl.google.com/linux/linux_signing_key.pub"
        "https://static.geogebra.org/linux/office@geogebra.org.gpg.key"
        "https://www.virtualbox.org/download/oracle_vbox_2016.asc"
        "https://www.virtualbox.org/download/oracle_vbox.asc"
        "https://packages.microsoft.com/keys/microsoft.asc")

    ConfigureSourcesList apt_key_url_repository mirrors repositorys
    assertTrue "[Configuring Apt legacy mirror with success]" $?

    ConfigureSourcesList
    assertFalse "[Configuring Apt legacy mirror, but missing args]" $?



    mirrors+=(
        "deb [arch=amd64 signed-by=$FAKE_ROOT_TEST_DIR/etc/apt/keyrings/packages.microsoft.gpg]  https://packages.microsoft.com/repos/code stable main"
        "deb [signed-by=$FAKE_ROOT_TEST_DIR/usr/share/keyrings/meganz-archive-keyring.gpg] https://mega.nz/linux/repo/xUbuntu_22.04/ ./"
    )
    
    repositorys+=(
        $FAKE_ROOT_TEST_DIR/apt/sources.list.d/vscode.list
        $FAKE_ROOT_TEST_DIR/apt/sources.list.d/megasync.list
    )

    apt_key_url_repository+=(
        'https://packages.microsoft.com/keys/microsoft.asc'
        'https://mega.nz/linux/repo/xUbuntu_22.04/Release.key'
    )

    ConfigureSourcesList apt_key_url_repository mirrors repositorys
    assertTrue "[Configuring New Apt mirror with success]" $?

    ConfigureSourcesList
    assertFalse "[Configuring New APTmirror, but missing args]" $?

    local mirrors=(   
        "deb [arch=amd64 signed-by=$FAKE_ROOT_TEST_DIR/etc/apt/keyrings/packages.microsoft.gpg]  https://packages.microsoft.com/repos/code stable main"
        "deb [signed-by=$FAKE_ROOT_TEST_DIR/usr/share/keyrings/meganz-archive-keyring.gpg] https://mega.nz/linux/repo/xUbuntu_22.04/ ./"
    )

    local keys=(
        'https://packages.microsoft.com/keys/microsoft.asc'
        'https://mega.nz/linux/repo/xUbuntu_22.04/Release.key'
    )

    local repo_path=(
        $FAKE_ROOT_TEST_DIR/apt/sources.list.d/vscode.list
        $FAKE_ROOT_TEST_DIR/apt/sources.list.d/megasync.list
    )

    ConfigureSourcesList apt_key_url_repository mirrors repositorys
    assertTrue "[Configuring  only New Apt mirror with success]" $?

    ConfigureSourcesList
    assertFalse "[Configuring only New APTmirror, but missing args]" $?
}

testConfigureSourcesListByScript(){
    local scripts_url=(
        https://deb.nodesource.com/setup_lts.x 
        https://deb.nodesource.com/setup_lts.x 
        https://deb.nodesource.com/setup_lts.x 
        https://deb.nodesource.com/setup_lts.x 
    )
    local expected_message="OK\nOK\nOK\nOK\n"
    local fake_array_url=''
    Wget(){
        echo 'echo OK'
    }

    assertEquals "[Configuring repositories using a script obtained from urls specified in an array]"\
        "$(printf "%b" "$expected_message")" "$(ConfigureSourcesListByScript scripts_url)"
    
    assertEquals "[Configuring repositories using a script obtained from a url passing a string instead of an array]"\
        "" "$(ConfigureSourcesListByScript fake_array_url)"

    assertEquals "[Configuring repositories using a script obtained from a url, but missing args]"\
        "" "$(ConfigureSourcesListByScript)"
}   


testWaitAptDpkg(){
    if [ "$(which fuser)" = "" ]; then
        assertFalse '[psmisc is not installed, exiting test]' 1
        return 
    fi

    lockApt(){
        >${APT_LOCKS[0]}
        exec 3>${APT_LOCKS[0]}
        sleep 0.1
    }

    unlockApt(){
        exec 3>&-
    }

    lockApt &
    waitAptDpkg
    assertTrue '[Wait to apt process busy (apt/dpkg lock)]' $?

    unlockApt
    waitAptDpkg
    assertTrue '[Running waitAptDpkg without apt/dpkg lock' $?

    rm -rf "${FAKE_ROOT_TEST_DIR}"
}


testCheckMinDeps(){

    CheckPackageDebIsInstalled(){ return $BASH_TRUE; }
    apt-get(){ return $BASH_TRUE ;}

    CheckMinDeps
    assertTrue '[Return true if minimal deps is installed]' $?
    
    apt-get(){ return $BASH_FALSE; }

    CheckMinDeps
    assertTrue '[Installing minimal common deps if not installed wget]' $?
}

forEach APT_LOCKS lock 'lock="${FAKE_ROOT_TEST_DIR}${lock}"
    mkdir -p "$(dirname $lock)"'
. $(which shunit2)
