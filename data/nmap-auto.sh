#!/bin/bash
# nmap_auto.sh

original_nmap() {
    local args=("$@")
    local has_script=false
    local has_sv=false
    local has_xml=false
    
    for arg in "${args[@]}"; do
        case "$arg" in
            --script=*|--script) has_script=true ;;
            -sV) has_sv=true ;;
            -oX*) has_xml=true ;;
        esac
    done
    
    if [ "$has_script" = false ]; then
        args+=(--script=vulners,http-title,ssl-cert)
        echo "Auto-added: --script=vulners,http-title,ssl-cert"
    fi
    
    if [ "$has_sv" = false ]; then
        args+=(-sV)
        echo "Auto-added: -sV"
    fi
    
    if [ "$has_xml" = false ]; then
        args+=(-oX output.xml)
        echo "Auto-added: -oX output.xml"
    fi
    
    echo "Running: nmap ${args[*]}"
    command nmap "${args[@]}"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "Scan was completed"
        
        if [ -f "nmap-to-sqlite.py" ]; then
            if ls *.xml 1> /dev/null 2>&1; then
                echo "Python script is running..."
                xml_file=$(ls *.xml | head -n 1)
                python3 nmap-to-sqlite.py "$xml_file"
                echo 'Run successful!'
                
                rm *.xml
                echo "XML files deleted"
            else
                echo "No XML output found"
            fi
        else
            echo "nmap-to-sqlite.py can't find"
        fi
    else
        echo "Nmap failed"
    fi
    
    return $exit_code
}

alias nmap='original_nmap'
